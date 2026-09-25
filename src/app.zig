const std = @import("std");

const sdl = @import("sdl/sdl.zig");
const sdl_helpers = @import("sdl_helpers.zig");
const errorWrap = sdl_helpers.errorWrap;

const build_options = @import("build_options");

const ShaderConfig = struct {
    const shader_format = switch (build_options.graphics_api) {
        .Metal => sdl.SDL_GPUShaderFormat.msl,
        .DirectX, .Vulkan =>  sdl.SDL_GPUShaderFormat.spirv,
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

var frag_uniform = FragUniform{
    .time = 0,
};

// uniforms must follow std140, which means vec3 and vec4 fields must be 16byte aligned
const VertUniform = extern struct {
    world_position: [2]f32,
    scale: [2]f32,
    rotation: f32,
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
    window: ?*sdl.SDL_Window = null,
    gpu_device: ?*sdl.SDL_GPUDevice = null,
    graphics_pipeline_sprites: ?*sdl.SDL_GPUGraphicsPipeline = null,
    vertex_buffer: ?*sdl.SDL_GPUBuffer = null,
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
pub fn AppInit(appstate: ?*?*anyopaque, args: std.process.Args.Vector) !sdl.SDL_AppResult {
    _ = appstate;
    _ = args;

    sdl.SDL_SetLogPriorities(.verbose);
    sdl.SDL_Log("zig-sdl3-test");

    try errorWrap(sdl.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate));

    try errorWrap(sdl.SDL_SetAppMetadata(
        "zig-sdl3-test",
        "0.0.1",
        "com.cosmicbagel.zig-sdl3-test",
    ));

    try errorWrap(sdl.SDL_Init(sdl.SDL_INIT_VIDEO));

    sdl_handles.window = try errorWrap(sdl.SDL_CreateWindow(
        "zig-sdl3-test",
        480,
        480,
        sdl.SDL_WINDOW_RESIZABLE,
    ));

    sdl_handles.gpu_device = try errorWrap(sdl.SDL_CreateGPUDevice(
        ShaderConfig.shader_format,
        true,
        ShaderConfig.gpu_driver,
    ));

    if (!sdl.SDL_SetGPUAllowedFramesInFlight(sdl_handles.gpu_device, 1)) {
        sdl.SDL_Log("SDL_SetGPUAllowedFramesInFlight failed: %s", sdl.SDL_GetError());
        _ = sdl.SDL_ClearError();
    }

    try errorWrap(sdl.SDL_ClaimWindowForGPUDevice(
        sdl_handles.gpu_device,
        sdl_handles.window,
    ));

    const vertex_shader = try errorWrap(sdl.SDL_CreateGPUShader(
        sdl_handles.gpu_device,
        &sdl.SDL_GPUShaderCreateInfo{
            .code = ShaderConfig.vertex_shader_code,
            .code_size = ShaderConfig.vertex_shader_code.len,
            .entrypoint = ShaderConfig.vertex_entrypoint,
            .format = ShaderConfig.shader_format,
            .stage = sdl.SDL_GPUShaderStage.vertex,
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = 1,
        },
    ));

    const fragment_shader = try errorWrap(sdl.SDL_CreateGPUShader(
        sdl_handles.gpu_device,
        &sdl.SDL_GPUShaderCreateInfo{
            .code = ShaderConfig.frag_shader_code,
            .code_size = ShaderConfig.frag_shader_code.len,
            .entrypoint = ShaderConfig.frag_entrypoint,
            .format = ShaderConfig.shader_format,
            .stage = sdl.SDL_GPUShaderStage.fragment,
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = 1,
        },
    ));

    sdl_handles.graphics_pipeline_sprites = try errorWrap(sdl.SDL_CreateGPUGraphicsPipeline(
        sdl_handles.gpu_device,
        &sdl.SDL_GPUGraphicsPipelineCreateInfo{
            .vertex_shader = vertex_shader,
            .fragment_shader = fragment_shader,
            .target_info = sdl.SDL_GPUGraphicsPipelineTargetInfo{
                .num_color_targets = 1,
                .color_target_descriptions = &sdl.SDL_GPUColorTargetDescription{
                    .format = sdl.SDL_GetGPUSwapchainTextureFormat(sdl_handles.gpu_device, sdl_handles.window),
                    .blend_state = sdl.SDL_GPUColorTargetBlendState{
                        .enable_blend = true,
                        .color_blend_op = sdl.SDL_GPUBlendOp.add,
                        .alpha_blend_op = sdl.SDL_GPUBlendOp.add,
                        .src_color_blendfactor = sdl.SDL_GPUBlendFactor.src_alpha,
                        .dst_color_blendfactor = sdl.SDL_GPUBlendFactor.one_minus_src_alpha,
                        .src_alpha_blendfactor = sdl.SDL_GPUBlendFactor.src_alpha,
                        .dst_alpha_blendfactor = sdl.SDL_GPUBlendFactor.one_minus_src_alpha,
                    },
                },
            },
            .primitive_type = sdl.SDL_GPUPrimitiveType.trianglestrip,
            .vertex_input_state = .{
                .num_vertex_buffers = 1,
                .vertex_buffer_descriptions = &sdl.SDL_GPUVertexBufferDescription{
                    .slot = 0,
                    .input_rate = sdl.SDL_GPUVertexInputRate.vertex,
                    .instance_step_rate = 0,
                    .pitch = @sizeOf(VertexColored),
                },
                .num_vertex_attributes = 2,
                .vertex_attributes = &[_]sdl.SDL_GPUVertexAttribute{
                    sdl.SDL_GPUVertexAttribute{
                        // position
                        .buffer_slot = 0,
                        .location = 0,
                        .format = sdl.SDL_GPUVertexElementFormat.float3,
                        .offset = 0,
                    },
                    sdl.SDL_GPUVertexAttribute{
                        // color
                        .buffer_slot = 0,
                        .location = 1,
                        .format = sdl.SDL_GPUVertexElementFormat.float4,
                        .offset = @sizeOf(f32) * 3,
                    },
                },
            },
        },
    ));

    // we don't need to store the shaders after creating the pipeline
    sdl.SDL_ReleaseGPUShader(sdl_handles.gpu_device, vertex_shader);
    sdl.SDL_ReleaseGPUShader(sdl_handles.gpu_device, fragment_shader);

    // create verticies, create vertex buffer, create transfer buffer, memcpy, unmap

    // create gpu buffer (this buffer exists gpu side I think)
    // we will use a transfer buffer and a copy pass to upload veticies to it
    sdl_handles.vertex_buffer = try errorWrap(sdl.SDL_CreateGPUBuffer(
        sdl_handles.gpu_device,
        &sdl.SDL_GPUBufferCreateInfo{
            .usage = sdl.SDL_GPU_BUFFERUSAGE_VERTEX,
            .size = triangle_verticies.len * @sizeOf(VertexColored),
            .props = 0,
        },
    ));

    const transfer_buffer = try errorWrap(sdl.SDL_CreateGPUTransferBuffer(
        sdl_handles.gpu_device,
        &sdl.SDL_GPUTransferBufferCreateInfo{
            .size = triangle_verticies.len * @sizeOf(VertexColored),
            .usage = .upload,
            .props = 0,
        },
    ));

    const outbound_data = sdl.SDL_MapGPUTransferBuffer(
        sdl_handles.gpu_device,
        transfer_buffer,
        false,
    );
    // copy in data to be uploaded in copy pass
    _ = sdl.SDL_memcpy(
        outbound_data,
        &triangle_verticies,
        triangle_verticies.len * @sizeOf(VertexColored),
    );
    sdl.SDL_UnmapGPUTransferBuffer(sdl_handles.gpu_device, transfer_buffer);

    // copy pass

    // get command buffer (crash on null)
    const command_buffer: ?*sdl.SDL_GPUCommandBuffer = try errorWrap(
        sdl.SDL_AcquireGPUCommandBuffer(sdl_handles.gpu_device),
    );

    const copy_pass: ?*sdl.SDL_GPUCopyPass = try errorWrap(sdl.SDL_BeginGPUCopyPass(command_buffer));

    // upload verticies
    sdl.SDL_UploadToGPUBuffer(
        copy_pass,
        &sdl.SDL_GPUTransferBufferLocation{
            .offset = 0,
            .transfer_buffer = transfer_buffer,
        },
        &sdl.SDL_GPUBufferRegion{
            .buffer = sdl_handles.vertex_buffer,
            .offset = 0,
            .size = triangle_verticies.len * @sizeOf(VertexColored),
        },
        false,
    );
    sdl.SDL_EndGPUCopyPass(copy_pass);

    // submit command buffer (always submit)
    try errorWrap(sdl.SDL_SubmitGPUCommandBuffer(command_buffer));

    const error_check = sdl.SDL_GetError();
    if (std.mem.len(error_check) > 0) {
        sdl.SDL_Log("Misc SDL_AppInit error: %s", error_check);
        _ = sdl.SDL_ClearError();
    }

    return .app_continue;
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
pub fn AppIterate(appstate: ?*anyopaque) !sdl.SDL_AppResult {
    _ = appstate;

    const app_iterate_start = sdl.SDL_GetTicksNS();

    var now: f32 = @floatFromInt(sdl.SDL_GetTicks());
    now /= 1000;

    // choose the color for the frame we will draw. The sine wave trick makes it fade between colors smoothly.
    const red: f32 = 0.5 + 0.5 * @sin(now);
    const green: f32 = 0.5 + 0.5 * @sin(now + sdl.SDL_PI_F * 2 / 3);
    const blue: f32 = 0.5 + 0.5 * @sin(now + sdl.SDL_PI_F * 4 / 3);

    // get command buffer (crash on null)
    const command_buffer: ?*sdl.SDL_GPUCommandBuffer = try errorWrap(
        sdl.SDL_AcquireGPUCommandBuffer(sdl_handles.gpu_device),
    );

    // wait for swapchain texture (crash on fail, okay if null)
    var swapchain_texture: ?*sdl.SDL_GPUTexture = null;
    var swapchain_texture_width: u32 = undefined;
    var swapchain_texture_height: u32 = undefined;
    try errorWrap(sdl.SDL_WaitAndAcquireGPUSwapchainTexture(
        command_buffer,
        sdl_handles.window,
        &swapchain_texture,
        &swapchain_texture_width,
        &swapchain_texture_height,
    ));

    if (swapchain_texture != null) {
        // render pass with colortarget info configured for clear color
        const color_target =
            sdl.SDL_GPUColorTargetInfo{
                // new color, full alpha.
                .clear_color = .{
                    .r = red,
                    .g = green,
                    .b = blue,
                    .a = 1.0,
                },
                .texture = swapchain_texture,
                .load_op = .clear,
                .store_op = .store,
                .cycle = false,
            };
        const render_pass: ?*sdl.SDL_GPURenderPass = try errorWrap(sdl.SDL_BeginGPURenderPass(
            command_buffer,
            &color_target,
            1,
            null,
        ));

        sdl.SDL_BindGPUGraphicsPipeline(
            render_pass,
            sdl_handles.graphics_pipeline_sprites,
        );
        sdl.SDL_BindGPUVertexBuffers(
            render_pass,
            0,
            &sdl.SDL_GPUBufferBinding{
                .buffer = sdl_handles.vertex_buffer,
                .offset = 0,
            },
            1,
        );

        // the time since the app started in seconds
        frag_uniform.time = @as(f32, @floatFromInt(sdl.SDL_GetTicksNS())) / @as(f32, 1e9);
        sdl.SDL_PushGPUFragmentUniformData(
            command_buffer,
            0,
            &frag_uniform,
            @sizeOf(FragUniform),
        );

        sdl.SDL_PushGPUVertexUniformData(
            command_buffer,
            0,
            &vert_uniform_a,
            @sizeOf(VertUniform),
        );

        // draw 4 realz (well put the draw call in the command buffer)
        sdl.SDL_DrawGPUPrimitives(
            render_pass,
            3,
            1,
            0,
            0,
        );

        sdl.SDL_PushGPUVertexUniformData(
            command_buffer,
            0,
            &vert_uniform_b,
            @sizeOf(VertUniform),
        );

        // draw 4 realz (well put the draw call in the command buffer)
        sdl.SDL_DrawGPUPrimitives(
            render_pass,
            3,
            1,
            0,
            0,
        );

        vert_uniform_c.rotation += 0.01;
        sdl.SDL_PushGPUVertexUniformData(
            command_buffer,
            0,
            &vert_uniform_c,
            @sizeOf(VertUniform),
        );

        // draw 4 realz (well put the draw call in the command buffer)
        sdl.SDL_DrawGPUPrimitives(
            render_pass,
            3,
            1,
            0,
            0,
        );

        sdl.SDL_EndGPURenderPass(render_pass);
    }

    // submit command buffer (always submit, even if swapchain texture null)
    try errorWrap(sdl.SDL_SubmitGPUCommandBuffer(command_buffer));

    const error_check = sdl.SDL_GetError();
    if (std.mem.len(error_check) > 0) {
        sdl.SDL_Log("Misc SDL_AppIterate error: %s", error_check);
        _ = sdl.SDL_ClearError();
    }

    // wait a sensible amount of time for next frame (assuming foreground rate
    // is unlmited)
    const time_spent = sdl.SDL_GetTicksNS() - app_iterate_start;
    if (time_spent < target_frame_time_ns) {
        sdl.SDL_DelayNS(target_frame_time_ns - time_spent);
    }

    return .app_continue;
}

/// This will be called whenever an SDL event arrives. Your app should not call
/// SDL_PollEvent, SDL_PumpEvent, etc, as SDL will manage all this for you.
/// Return values are the same as from SDL_AppIterate(), so you can terminate
/// in response to SDL_EVENT_QUIT, etc.
pub fn AppEvent(appstate: ?*anyopaque, event: ?*sdl.SDL_Event) !sdl.SDL_AppResult {
    _ = appstate;

    if (event.?.type == .quit) {
        return .app_success; // end the program, reporting success to the OS.
    }

    if (event.?.type == .key_down) {
        const scancode = event.?.key.scancode;
        if (scancode == .escape) {
            return .app_success;
        }
    }

    if (event.?.type == .window_focus_gained) {
        try errorWrap(sdl.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate));
    }

    if (event.?.type == .window_focus_lost) {
        try errorWrap(sdl.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", background_rate));
    }

    const error_check = sdl.SDL_GetError();
    if (std.mem.len(error_check) > 0) {
        sdl.SDL_Log("Misc SDL_AppEvent error: %s", error_check);
        _ = sdl.SDL_ClearError();
    }

    return .app_continue;
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
pub fn AppQuit(appstate: ?*anyopaque, app_result: sdl.SDL_AppResult) !void {
    _ = appstate;
    _ = app_result;

    // is best to destroy things in reverse order of creation
    sdl.SDL_ReleaseGPUGraphicsPipeline(
        sdl_handles.gpu_device,
        sdl_handles.graphics_pipeline_sprites,
    );
    sdl.SDL_ReleaseGPUBuffer(sdl_handles.gpu_device, sdl_handles.vertex_buffer);
    sdl.SDL_DestroyGPUDevice(sdl_handles.gpu_device);
    sdl.SDL_DestroyWindow(sdl_handles.window);
}
