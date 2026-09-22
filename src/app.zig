const c = @import("c");
const std = @import("std");

const build_options = @import("build_options");

const ShaderConfig = struct {
    const shader_format = switch (build_options.graphics_api) {
        .Metal => c.SDL_GPU_SHADERFORMAT_MSL,
        .DirectX, .Vulkan => c.SDL_GPU_SHADERFORMAT_SPIRV,
    };
    const vertex_shader_code = switch (build_options.graphics_api) {
        .Metal => @embedFile("vert.msl"),
        .DirectX, .Vulkan => @embedFile("vert.spirv"),
    };
    const vertex_entrypoint = switch (build_options.graphics_api) {
        .Metal => "vert_shader",
        .DirectX, .Vulkan => "main",
    };
    const frag_shader_code = switch (build_options.graphics_api) {
        .Metal => @embedFile("frag.msl"),
        .DirectX, .Vulkan => @embedFile("frag.spirv"),
    };
    const frag_entrypoint = switch (build_options.graphics_api) {
        .Metal => "frag_shader",
        .DirectX, .Vulkan => "main",
    };
    const gpu_driver = switch (build_options.graphics_api) {
        .Metal => "metal",
        .Vulkan => "vulkan",
        .DirectX => "direct3d12",
    };
};

const sdl_helpers = @import("sdl_helpers.zig");
const errorWrap = sdl_helpers.errorWrap;

// 0 = uncapped, we'll use SDL_Delay to control the framerate
const foreground_rate = "0";
// prefer "waitevent" unless you need it running for debug purposes
const background_rate = "waitevent";

// ns because that's what SDL_Delay uses (SDL_Delay just converts MS to NS then
// calls SDL_DelayNS)
const target_frame_time_ns = 16 * 1_000_000;

// extern might not be necessary here, but wanted to be sure zig doesn't
// reorder any members
const VertexColored = extern struct { x: f32, y: f32, z: f32, r: f32, g: f32, b: f32, a: f32 };

const triangle_verticies = [_]VertexColored{
    VertexColored{ .x = 0, .y = 1, .z = 0, .r = 1, .g = 0, .b = 0, .a = 1 }, // lefttop-red
    VertexColored{ .x = -1, .y = -1, .z = 0, .r = 0, .g = 1, .b = 0, .a = 1 }, //leftbottom-yellow
    VertexColored{ .x = 1, .y = -1, .z = 0, .r = 0, .g = 0, .b = 1, .a = 1 }, // rightbottom-purple
};

const quad_verticies = [_]VertexColored{
    VertexColored{ .x = 1, .y = 1, .z = 0, .r = 0, .g = 0, .b = 1, .a = 1 }, // righttop-blue
    VertexColored{ .x = -1, .y = 1, .z = 0, .r = 1, .g = 0, .b = 0, .a = 1 }, // lefttop-red
    VertexColored{ .x = -1, .y = -1, .z = 0, .r = 0, .g = 1, .b = 0, .a = 1 }, //leftbottom-yellow
    VertexColored{ .x = 1, .y = -1, .z = 0, .r = 0, .g = 0, .b = 1, .a = 1 }, // rightbottom-purple
};

// uniforms must follow std140, which means vec3 and vec4 fields must be 16byte aligned
const FragUniform = extern struct {
    time: f32,
};

// uniforms must follow std140, which means vec3 and vec4 fields must be 16byte aligned
const VertUniform = extern struct {
    world_position: [2]f32,
    scale: [2]f32,
    rotation: f32,
};

var frag_uniform = FragUniform{
    .time = 0,
};

var vert_uniform_a = VertUniform{
    .world_position = .{ 0.5, -0.5 },
    .scale = .{ 0.5, 0.5 },
    .rotation = 0,
};

var vert_uniform_b = VertUniform{
    .world_position = .{ -0.5, -0.5 },
    .scale = .{ 0.5, 0.5 },
    .rotation = 0.5,
};

var vert_uniform_c = VertUniform{
    .world_position = .{ 0, 0.5 },
    // .world_position = .{ 0, 0 },
    .scale = .{ 0.5, 0.5 },
    // .scale = .{ 1, 1},
    .rotation = -0.05,
};

const SDLHandles = struct {
    window: ?*c.SDL_Window = null,
    gpu_device: ?*c.SDL_GPUDevice = null,
    graphics_pipeline_sprites: ?*c.SDL_GPUGraphicsPipeline = null,
    vertex_buffer: ?*c.SDL_GPUBuffer = null,
};
var sdl_handles = SDLHandles{};

/// This will be called once before anything else. argc/argv work like they
/// always do. If this returns SDL_APP_CONTINUE, the app runs. If it returns
/// SDL_APP_FAILURE, the app calls SDL_AppQuit and terminates with an exit code
/// that reports an error to the platform. If it returns SDL_APP_SUCCESS, the
/// app calls SDL_AppQuit and terminates with an exit code that reports success
/// to the platform. This function should not go into an infinite mainloop; it
/// should do any one-time startup it requires and then return.
///
/// If you want to, you can assign a pointer to *appstate, and this pointer will
/// be made available to you in later functions calls in their appstate
/// parameter. This allows you to avoid global variables, but is totally
/// optional. If you don't set this, the pointer will be NULL in later function
/// calls.
pub fn AppInit(appstate: ?*?*anyopaque, args: std.process.Args.Vector) !c.SDL_AppResult {
    _ = appstate;
    _ = args;

    c.SDL_SetLogPriorities(c.SDL_LOG_PRIORITY_VERBOSE);
    c.SDL_Log("zig-sdl3-test");

    try errorWrap(c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate));

    try errorWrap(c.SDL_SetAppMetadata(
        "zig-sdl3-test",
        "0.0.1",
        "com.cosmicbagel.zig-sdl3-test",
    ));

    try errorWrap(c.SDL_Init(c.SDL_INIT_VIDEO));

    sdl_handles.window = try errorWrap(c.SDL_CreateWindow(
        "zig-sdl3-test",
        480,
        480,
        c.SDL_WINDOW_RESIZABLE,
    ));

    sdl_handles.gpu_device = try errorWrap(c.SDL_CreateGPUDevice(
        ShaderConfig.shader_format,
        true,
        ShaderConfig.gpu_driver,
    ));

    if (!c.SDL_SetGPUAllowedFramesInFlight(sdl_handles.gpu_device, 1)) {
        c.SDL_Log("SDL_SetGPUAllowedFramesInFlight failed: %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    }

    try errorWrap(c.SDL_ClaimWindowForGPUDevice(
        sdl_handles.gpu_device,
        sdl_handles.window,
    ));

    const vertex_shader = try errorWrap(c.SDL_CreateGPUShader(
        sdl_handles.gpu_device,
        &c.SDL_GPUShaderCreateInfo{
            .code = ShaderConfig.vertex_shader_code,
            .code_size = ShaderConfig.vertex_shader_code.len,
            .entrypoint = ShaderConfig.vertex_entrypoint,
            .format = ShaderConfig.shader_format,
            .stage = c.SDL_GPU_SHADERSTAGE_VERTEX,
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = 1,
        },
    ));

    const fragment_shader = try errorWrap(c.SDL_CreateGPUShader(
        sdl_handles.gpu_device,
        &c.SDL_GPUShaderCreateInfo{
            .code = ShaderConfig.frag_shader_code,
            .code_size = ShaderConfig.frag_shader_code.len,
            .entrypoint = ShaderConfig.frag_entrypoint,
            .format = ShaderConfig.shader_format,
            .stage = c.SDL_GPU_SHADERSTAGE_FRAGMENT,
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = 1,
        },
    ));

    sdl_handles.graphics_pipeline_sprites = try errorWrap(c.SDL_CreateGPUGraphicsPipeline(
        sdl_handles.gpu_device,
        &c.SDL_GPUGraphicsPipelineCreateInfo{
            .vertex_shader = vertex_shader,
            .fragment_shader = fragment_shader,
            .target_info = c.SDL_GPUGraphicsPipelineTargetInfo{
                .num_color_targets = 1,
                .color_target_descriptions = &c.SDL_GPUColorTargetDescription{
                    .format = c.SDL_GetGPUSwapchainTextureFormat(sdl_handles.gpu_device, sdl_handles.window),
                    .blend_state = c.SDL_GPUColorTargetBlendState{
                        .enable_blend = true,
                        .color_blend_op = c.SDL_GPU_BLENDOP_ADD,
                        .alpha_blend_op = c.SDL_GPU_BLENDOP_ADD,
                        .src_color_blendfactor = c.SDL_GPU_BLENDFACTOR_SRC_ALPHA,
                        .dst_color_blendfactor = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                        .src_alpha_blendfactor = c.SDL_GPU_BLENDFACTOR_SRC_ALPHA,
                        .dst_alpha_blendfactor = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
                    },
                },
            },
            .primitive_type = c.SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP,
            .vertex_input_state = .{
                .num_vertex_buffers = 1,
                .vertex_buffer_descriptions = &c.SDL_GPUVertexBufferDescription{
                    .slot = 0,
                    .input_rate = c.SDL_GPU_VERTEXINPUTRATE_VERTEX,
                    .instance_step_rate = 0,
                    .pitch = @sizeOf(VertexColored),
                },
                .num_vertex_attributes = 2,
                .vertex_attributes = &[_]c.SDL_GPUVertexAttribute{
                    c.SDL_GPUVertexAttribute{
                        // position
                        .buffer_slot = 0,
                        .location = 0,
                        .format = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3,
                        .offset = 0,
                    },
                    c.SDL_GPUVertexAttribute{
                        // color
                        .buffer_slot = 0,
                        .location = 1,
                        .format = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4,
                        .offset = @sizeOf(f32) * 3,
                    },
                },
            },
        },
    ));

    // we don't need to store the shaders after creating the pipeline
    c.SDL_ReleaseGPUShader(sdl_handles.gpu_device, vertex_shader);
    c.SDL_ReleaseGPUShader(sdl_handles.gpu_device, fragment_shader);

    // create verticies, create vertex buffer, create transfer buffer, memcpy, unmap

    // create gpu buffer (this buffer exists gpu side I think)
    // we will use a transfer buffer and a copy pass to upload veticies to it
    sdl_handles.vertex_buffer = try errorWrap(c.SDL_CreateGPUBuffer(
        sdl_handles.gpu_device,
        &c.SDL_GPUBufferCreateInfo{
            .usage = c.SDL_GPU_BUFFERUSAGE_VERTEX,
            .size = triangle_verticies.len * @sizeOf(VertexColored),
            .props = 0,
        },
    ));

    const transfer_buffer = try errorWrap(c.SDL_CreateGPUTransferBuffer(
        sdl_handles.gpu_device,
        &c.SDL_GPUTransferBufferCreateInfo{
            .size = triangle_verticies.len * @sizeOf(VertexColored),
            .usage = c.SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
            .props = 0,
        },
    ));

    const outbound_data = c.SDL_MapGPUTransferBuffer(
        sdl_handles.gpu_device,
        transfer_buffer,
        false,
    );
    // copy in data to be uploaded in copy pass
    _ = c.SDL_memcpy(
        outbound_data,
        &triangle_verticies,
        triangle_verticies.len * @sizeOf(VertexColored),
    );
    c.SDL_UnmapGPUTransferBuffer(sdl_handles.gpu_device, transfer_buffer);

    // copy pass

    // get command buffer (crash on null)
    const command_buffer: ?*c.SDL_GPUCommandBuffer = try errorWrap(
        c.SDL_AcquireGPUCommandBuffer(sdl_handles.gpu_device),
    );

    const copy_pass: ?*c.SDL_GPUCopyPass = try errorWrap(c.SDL_BeginGPUCopyPass(command_buffer));

    // upload verticies
    c.SDL_UploadToGPUBuffer(
        copy_pass,
        &c.SDL_GPUTransferBufferLocation{
            .offset = 0,
            .transfer_buffer = transfer_buffer,
        },
        &c.SDL_GPUBufferRegion{
            .buffer = sdl_handles.vertex_buffer,
            .offset = 0,
            .size = triangle_verticies.len * @sizeOf(VertexColored),
        },
        false,
    );
    c.SDL_EndGPUCopyPass(copy_pass);

    // submit command buffer (always submit)
    try errorWrap(c.SDL_SubmitGPUCommandBuffer(command_buffer));

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc SDL_AppInit error: %s", error_check);
        _ = c.SDL_ClearError();
    }

    return c.SDL_APP_CONTINUE;
}

/// This is called over and over, possibly at the refresh rate of the display or
/// some other metric that the platform dictates. This is where the heart of
/// your app runs. It should return as quickly as reasonably possible, but it's
/// not a "run one memcpy and that's all the time you have" sort of thing. The
/// app should do any game updates, and render a frame of video. If it returns
/// SDL_APP_FAILURE, SDL will call SDL_AppQuit and terminate the process with an
/// exit code that reports an error to the platform. If it returns
/// SDL_APP_SUCCESS, the app calls SDL_AppQuit and terminates with an exit code
/// that reports success to the platform. If it returns SDL_APP_CONTINUE, then
/// SDL_AppIterate will be called again at some regular frequency. The platform
/// may choose to run this more or less (perhaps less in the background, etc),
/// or it might just call this function in a loop as fast as possible. You do
/// not check the event queue in this function (SDL_AppEvent exists for that).
pub fn AppIterate(appstate: ?*anyopaque) !c.SDL_AppResult {
    _ = appstate;

    const app_iterate_start = c.SDL_GetTicksNS();

    var now: f32 = @floatFromInt(c.SDL_GetTicks());
    now /= 1000;

    // choose the color for the frame we will draw. The sine wave trick makes it fade between colors smoothly.
    const red: f32 = 0.5 + 0.5 * @sin(now);
    const green: f32 = 0.5 + 0.5 * @sin(now + c.SDL_PI_F * 2 / 3);
    const blue: f32 = 0.5 + 0.5 * @sin(now + c.SDL_PI_F * 4 / 3);

    // get command buffer (crash on null)
    const command_buffer: ?*c.SDL_GPUCommandBuffer = try errorWrap(
        c.SDL_AcquireGPUCommandBuffer(sdl_handles.gpu_device),
    );

    // wait for swapchain texture (crash on fail, okay if null)
    var swapchain_texture: ?*c.SDL_GPUTexture = null;
    var swapchain_texture_width: u32 = undefined;
    var swapchain_texture_height: u32 = undefined;
    try errorWrap(c.SDL_WaitAndAcquireGPUSwapchainTexture(
        command_buffer,
        sdl_handles.window,
        &swapchain_texture,
        &swapchain_texture_width,
        &swapchain_texture_height,
    ));

    if (swapchain_texture != null) {
        // render pass with colortarget info configured for clear color
        const color_target =
            c.SDL_GPUColorTargetInfo{
                // new color, full alpha.
                .clear_color = .{
                    .r = red,
                    .g = green,
                    .b = blue,
                    .a = 1.0,
                },
                .texture = swapchain_texture,
                .load_op = c.SDL_GPU_LOADOP_CLEAR,
                .store_op = c.SDL_GPU_STOREOP_STORE,
                .cycle = false,
            };
        const render_pass: ?*c.SDL_GPURenderPass = try errorWrap(c.SDL_BeginGPURenderPass(
            command_buffer,
            &color_target,
            1,
            null,
        ));

        c.SDL_BindGPUGraphicsPipeline(
            render_pass,
            sdl_handles.graphics_pipeline_sprites,
        );
        c.SDL_BindGPUVertexBuffers(
            render_pass,
            0,
            &c.SDL_GPUBufferBinding{
                .buffer = sdl_handles.vertex_buffer,
                .offset = 0,
            },
            1,
        );

        // the time since the app started in seconds
        frag_uniform.time = @as(f32, @floatFromInt(c.SDL_GetTicksNS())) / @as(f32, 1e9);
        c.SDL_PushGPUFragmentUniformData(
            command_buffer,
            0,
            &frag_uniform,
            @sizeOf(FragUniform),
        );

        c.SDL_PushGPUVertexUniformData(
            command_buffer,
            0,
            &vert_uniform_a,
            @sizeOf(VertUniform),
        );

        // draw 4 realz (well put the draw call in the command buffer)
        c.SDL_DrawGPUPrimitives(
            render_pass,
            3,
            1,
            0,
            0,
        );

        c.SDL_PushGPUVertexUniformData(
            command_buffer,
            0,
            &vert_uniform_b,
            @sizeOf(VertUniform),
        );

        // draw 4 realz (well put the draw call in the command buffer)
        c.SDL_DrawGPUPrimitives(
            render_pass,
            3,
            1,
            0,
            0,
        );

        vert_uniform_c.rotation += 0.01;
        c.SDL_PushGPUVertexUniformData(
            command_buffer,
            0,
            &vert_uniform_c,
            @sizeOf(VertUniform),
        );

        // draw 4 realz (well put the draw call in the command buffer)
        c.SDL_DrawGPUPrimitives(
            render_pass,
            3,
            1,
            0,
            0,
        );

        c.SDL_EndGPURenderPass(render_pass);
    }

    // submit command buffer (always submit, even if swapchain texture null)
    try errorWrap(c.SDL_SubmitGPUCommandBuffer(command_buffer));

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc SDL_AppIterate error: %s", error_check);
        _ = c.SDL_ClearError();
    }

    // wait a sensible amount of time for next frame (assuming foreground rate
    // is unlmited)
    const time_spent = c.SDL_GetTicksNS() - app_iterate_start;
    if (time_spent < target_frame_time_ns) {
        c.SDL_DelayNS(target_frame_time_ns - time_spent);
    }

    return c.SDL_APP_CONTINUE;
}

/// This will be called whenever an SDL event arrives. Your app should not call
/// SDL_PollEvent, SDL_PumpEvent, etc, as SDL will manage all this for you.
/// Return values are the same as from SDL_AppIterate(), so you can terminate
/// in response to SDL_EVENT_QUIT, etc.
pub fn AppEvent(appstate: ?*anyopaque, event: ?*c.SDL_Event) !c.SDL_AppResult {
    _ = appstate;

    if (event.?.type == c.SDL_EVENT_QUIT) {
        return c.SDL_APP_SUCCESS; // end the program, reporting success to the OS.
    }

    if (event.?.type == c.SDL_EVENT_KEY_DOWN) {
        const scancode = event.?.key.scancode;
        if (scancode == c.SDL_SCANCODE_ESCAPE) {
            return c.SDL_APP_SUCCESS;
        }
    }

    if (event.?.type == c.SDL_EVENT_WINDOW_FOCUS_GAINED) {
        try errorWrap(c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate));
    }

    if (event.?.type == c.SDL_EVENT_WINDOW_FOCUS_LOST) {
        try errorWrap(c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", background_rate));
    }

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc SDL_AppEvent error: %s", error_check);
        _ = c.SDL_ClearError();
    }

    return c.SDL_APP_CONTINUE;
}

/// This is called once before terminating the app--assuming the app isn't
/// being forcibly killed or crashed--as a last chance to clean up. After this
/// returns, SDL will call SDL_Quit so the app doesn't have to (but it's safe
/// for the app to call it, too). Process termination proceeds as if the app
/// returned normally from main(), so atexit handles will run, if your platform
/// supports that.
///
/// If you set *appstate during SDL_AppInit, this is where you should free that
/// data, as this pointer will not be provided to your app again.
///
/// The SDL_AppResult value that terminated the app is provided here, in case
/// it's useful to know if this was a successful or failing run of the app.
pub fn AppQuit(appstate: ?*anyopaque, app_result: c.SDL_AppResult) !void {
    _ = appstate;
    _ = app_result;

    // is best to destroy things in reverse order of creation
    c.SDL_ReleaseGPUGraphicsPipeline(
        sdl_handles.gpu_device,
        sdl_handles.graphics_pipeline_sprites,
    );
    c.SDL_ReleaseGPUBuffer(sdl_handles.gpu_device, sdl_handles.vertex_buffer);
    c.SDL_DestroyGPUDevice(sdl_handles.gpu_device);
    c.SDL_DestroyWindow(sdl_handles.window);
}
