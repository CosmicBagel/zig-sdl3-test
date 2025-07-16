const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_revision.h");
    @cDefine("SDL_MAIN_USE_CALLBACKS", {}); // We are providing our own entry point
    @cInclude("SDL3/SDL_main.h");
});

const std = @import("std");

const SDLHelpers = @import("SDLHelpers.zig");
const errorWrap = SDLHelpers.errorWrap;

// SDL3 is handling the main func
pub const main = c.main;

// 0 = uncapped, we'll use SDL_Delay to control the framerate
const foreground_rate = "0";
// prefer "waitevent" unless you need it running for debug purposes
const background_rate = "waitevent";

// ns because that's what SDL_Delay uses (SDL_Delay just converts MS to NS then
// calls SDL_DelayNS)
const target_frame_time_ns = 16 * 1_000_000;

var window: ?*c.SDL_Window = null;
var gpu_device: ?*c.SDL_GPUDevice = null;

pub export fn SDL_AppInit(appstate: ?*?*anyopaque, argc: c_int, argv: ?[*:null]?[*:0]u8) callconv(.c) c.SDL_AppResult {
    _ = appstate;
    _ = argc;
    _ = argv;

    c.SDL_Log("zig-sdl3-test");

    errorWrap(c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate)) catch {
        c.SDL_Log("SDL_SetHint failed: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    errorWrap(c.SDL_SetAppMetadata(
        "zig-sdl3-test",
        "0.0.1",
        "com.cosmicbagel.zig-sdl3-test",
    )) catch {
        c.SDL_Log("SDL_SetAppMetadata failed: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    errorWrap(c.SDL_Init(c.SDL_INIT_VIDEO)) catch {
        c.SDL_Log("Couldn't initialize SDL: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    window = errorWrap(c.SDL_CreateWindow(
        "zig-sdl3-test",
        640,
        480,
        c.SDL_WINDOW_RESIZABLE,
    )) catch {
        c.SDL_Log("Couldn't create window: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    gpu_device = errorWrap(c.SDL_CreateGPUDevice(
        c.SDL_GPU_SHADERFORMAT_MSL,
        false,
        null,
    )) catch {
        c.SDL_Log("SDL_CreateGPUDevice failed: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    errorWrap(c.SDL_SetGPUAllowedFramesInFlight(gpu_device, 1)) catch {
        c.SDL_Log("SDL_SetGPUAllowedFramesInFlight failed: %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    };

    errorWrap(c.SDL_ClaimWindowForGPUDevice(gpu_device, window)) catch {
        c.SDL_Log("SDL_ClaimWindowForGPUDevice failed: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    const vertex_shader_msl_code = @embedFile("vert.msl");

    const vertex_shader = c.SDL_CreateGPUShader(gpu_device, &c.SDL_GPUShaderCreateInfo{
        .code = vertex_shader_msl_code,
        .code_size = vertex_shader_msl_code.len,
        .entrypoint = "vert_shader",
        .format = c.SDL_GPU_SHADERFORMAT_MSL,
        .stage = c.SDL_GPU_SHADERSTAGE_VERTEX,
        .num_samplers = 0,
        .num_storage_buffers = 0,
        .num_storage_textures = 0,
        .num_uniform_buffers = 0,
    });

    const frag_shader_msl_code = @embedFile("frag.msl");

    const fragment_shader = c.SDL_CreateGPUShader(gpu_device, &c.SDL_GPUShaderCreateInfo{
        .code = frag_shader_msl_code,
        .code_size = frag_shader_msl_code.len,
        .entrypoint = "frag_shader",
        .format = c.SDL_GPU_SHADERFORMAT_MSL,
        .stage = c.SDL_GPU_SHADERSTAGE_FRAGMENT,
        .num_samplers = 0,
        .num_storage_buffers = 0,
        .num_storage_textures = 0,
        .num_uniform_buffers = 0,
    });

    _ = c.SDL_CreateGPUGraphicsPipeline(
        gpu_device,
        &c.SDL_GPUGraphicsPipelineCreateInfo{
            .vertex_shader = vertex_shader,
            .fragment_shader = fragment_shader,
            .target_info = c.SDL_GPUGraphicsPipelineTargetInfo{
                .num_color_targets = 1,
                .color_target_descriptions = &c.SDL_GPUColorTargetDescription{
                    .format = c.SDL_GetGPUSwapchainTextureFormat(gpu_device, window),
                    // .blend_state = .{ .enable_blend =  }
                },
            },
            .primitive_type = c.SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP,
            .vertex_input_state = .{
                .num_vertex_buffers = 1,
                .vertex_buffer_descriptions = &c.SDL_GPUVertexBufferDescription{
                    .slot = 0,
                    .input_rate = c.SDL_GPU_VERTEXINPUTRATE_VERTEX,
                    .instance_step_rate = 0,
                    .pitch = 36,
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
    );

    // we don't need to store the shaders after creating the pipeline
    c.SDL_ReleaseGPUShader(gpu_device, vertex_shader);
    c.SDL_ReleaseGPUShader(gpu_device, fragment_shader);

    // create verticies, create vertex buffer, create transfer buffer, memcpy, unmap

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc SDL_AppInit error: %s", error_check);
        _ = c.SDL_ClearError();
    }

    return c.SDL_APP_CONTINUE;
}

// draw triangle?
// - build graphics pipeline
//   - shaders (vert and frag)
// - upload colored verts to a buffer
//   - vert buffer, transfer buffer, cpu side copy
//   - copy pass to upload
// - render pass
//   - bind vert buf and pipeline
//   - draw

pub export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) c.SDL_AppResult {
    _ = appstate;

    const app_iterate_start = c.SDL_GetTicksNS();

    const now: f64 = @as(f64, @floatFromInt(c.SDL_GetTicks())) / 1000.0; // convert from milliseconds to seconds.
    // choose the color for the frame we will draw. The sine wave trick makes it fade between colors smoothly.
    const red: f32 = @floatCast(0.5 + 0.5 * c.SDL_sin(now));
    const green: f32 = @floatCast(0.5 + 0.5 * c.SDL_sin(now + c.SDL_PI_D * 2 / 3));
    const blue: f32 = @floatCast(0.5 + 0.5 * c.SDL_sin(now + c.SDL_PI_D * 4 / 3));

    // get command buffer (crash on null)
    const command_buffer: ?*c.SDL_GPUCommandBuffer = errorWrap(c.SDL_AcquireGPUCommandBuffer(gpu_device)) catch {
        c.SDL_Log("SDL_AcquireGPUCommandBuffer error: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    // wait for swapchain texture (crash on fail, okay if null)
    var swapchain_texture: ?*c.SDL_GPUTexture = null;
    var swapchain_texture_width: u32 = undefined;
    var swapchain_texture_height: u32 = undefined;
    errorWrap(c.SDL_WaitAndAcquireGPUSwapchainTexture(
        command_buffer,
        window,
        &swapchain_texture,
        &swapchain_texture_width,
        &swapchain_texture_height,
    )) catch {
        c.SDL_Log("SDL_AcquireGPUCommandBuffer error: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    if (swapchain_texture != null) {
        // render pass with colortarget info configured for clear color
        const render_pass: ?*c.SDL_GPURenderPass = errorWrap(c.SDL_BeginGPURenderPass(
            command_buffer,
            &[1]c.SDL_GPUColorTargetInfo{
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
                },
            },
            1,
            null,
        )) catch {
            c.SDL_Log("SDL_BeginGPURenderPass error: %s", c.SDL_GetError());
            return c.SDL_APP_FAILURE;
        };

        // empty render pass
        c.SDL_EndGPURenderPass(render_pass);
    }

    // submit command buffer (always submit, even if swapchain texture null)
    errorWrap(c.SDL_SubmitGPUCommandBuffer(command_buffer)) catch {
        c.SDL_Log("SDL_SubmitGPUCommandBuffer error: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

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

pub export fn SDL_AppEvent(appstate: ?*anyopaque, event: ?*c.SDL_Event) callconv(.c) c.SDL_AppResult {
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
        errorWrap(c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate)) catch {
            c.SDL_Log("SetHint %s", c.SDL_GetError());
            _ = c.SDL_ClearError();
        };
    }

    if (event.?.type == c.SDL_EVENT_WINDOW_FOCUS_LOST) {
        errorWrap(c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", background_rate)) catch {
            c.SDL_Log("SetHint %s", c.SDL_GetError());
            _ = c.SDL_ClearError();
        };
    }

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc SDL_AppEvent error: %s", error_check);
        _ = c.SDL_ClearError();
    }

    return c.SDL_APP_CONTINUE;
}

pub export fn SDL_AppQuit(appstate: ?*anyopaque, result: c.SDL_AppResult) callconv(.c) void {
    _ = appstate;
    _ = result;

    // is best to destroy things in reverse order of creation
    c.SDL_DestroyGPUDevice(gpu_device);
    c.SDL_DestroyWindow(window);
}
