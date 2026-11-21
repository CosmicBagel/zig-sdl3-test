const std = @import("std");
const sdl = @import("sdl/sdl.zig");
const app_common = @import("app_common.zig");

var app_context = app_common.AppContext{
    .name = "BasicTriangle",
};

var fill_pipeline: ?*sdl.gpu.SDL_GPUGraphicsPipeline = null;
var line_pipeline: ?*sdl.gpu.SDL_GPUGraphicsPipeline = null;
var small_viewport: sdl.gpu.SDL_GPUViewport = .{
    .x = 160,
    .y = 120,
    .w = 320,
    .h = 240,
    .min_depth = 0.1,
    .max_depth = 1.0,
};
var scissor_rect: sdl.rect.SDL_Rect = .{ .x = 320, .y = 240, .w = 320, .h = 240 };

var use_wireframe_mode = false;
var use_small_viewport = false;
var use_scissor_rect = false;

pub fn appInit(io: std.Io, gpa: std.mem.Allocator, appstate: ?*?*anyopaque, args: std.process.Args.Vector) !sdl.init.SDL_AppResult {
    _ = appstate;
    _ = args;

    try app_common.appInitMinimal(io, &app_context);
    const vertex_shader = try app_common.loadShader(
        io,
        gpa,
        app_context.device.?,
        "RawTriangle.vert",
        0,
        0,
        0,
        0,
    );

    const fragment_shader = try app_common.loadShader(
        io,
        gpa,
        app_context.device.?,
        "SolidColor.frag",
        0,
        0,
        0,
        0,
    );

    // Create the pipelines
    var pipeline_create_info: sdl.gpu.SDL_GPUGraphicsPipelineCreateInfo = .{
        .target_info = .{
            .num_color_targets = 1,
            .color_target_descriptions = &.{sdl.gpu.SDL_GPUColorTargetDescription{
                .format = sdl.gpu.SDL_GetGPUSwapchainTextureFormat(
                    app_context.device.?,
                    app_context.window.?,
                ),
            }},
        },
        .primitive_type = .trianglelist,
        .vertex_shader = vertex_shader,
        .fragment_shader = fragment_shader,
    };

    pipeline_create_info.rasterizer_state.fill_mode = .fill;

    fill_pipeline = sdl.gpu.SDL_CreateGPUGraphicsPipeline(
        app_context.device.?,
        &pipeline_create_info,
    ) orelse {
        std.debug.print("failed to create fill pipeline: {s}\n", .{sdl.sdl_error.SDL_GetError()});
        return .app_failure;
    };

    pipeline_create_info.rasterizer_state.fill_mode = .line;
    line_pipeline = sdl.gpu.SDL_CreateGPUGraphicsPipeline(
        app_context.device.?,
        &pipeline_create_info,
    ) orelse {
        std.debug.print("failed to create line pipeline: {s}\n", .{sdl.sdl_error.SDL_GetError()});
        return .app_failure;
    };

    // Clean up shader resources
    sdl.gpu.SDL_ReleaseGPUShader(app_context.device.?, vertex_shader);
    sdl.gpu.SDL_ReleaseGPUShader(app_context.device.?, fragment_shader);

    // Print instructions
    std.debug.print("Press Left to toggle wireframe mode\n", .{});
    std.debug.print("Press Down to toggle small viewport\n", .{});
    std.debug.print("Press Right to toggle scissor rect\n", .{});

    return .app_continue;
}

pub fn appIterate(io: std.Io, gpa: std.mem.Allocator, appstate: ?*anyopaque) !sdl.init.SDL_AppResult {
    _ = io;
    _ = gpa;
    _ = appstate;

    const new_time: u64 = sdl.timer.SDL_GetTicks() / 1000;
    const delta_time = new_time - app_context.last_time;
    app_context.last_time = new_time;

    _ = delta_time;

    const cmd_buf: *sdl.gpu.SDL_GPUCommandBuffer = sdl.gpu.SDL_AcquireGPUCommandBuffer(app_context.device.?) orelse {
        std.debug.print("AcquireGPUCommandBuffer failed: {s}\n", .{sdl.sdl_error.SDL_GetError()});
        return .app_failure;
    };

    var swapchain_texture: ?*sdl.gpu.SDL_GPUTexture = null;
    if (!sdl.gpu.SDL_WaitAndAcquireGPUSwapchainTexture(cmd_buf, app_context.window.?, &swapchain_texture, null, null)) {
        std.debug.print("WaitAndAcquireGPUSwapchainTexture failed: {s}\n", .{sdl.sdl_error.SDL_GetError()});
        return .app_failure;
    }

    if (swapchain_texture) |texture| {
        const color_target_info: sdl.gpu.SDL_GPUColorTargetInfo = .{
            .texture = texture,
            .clear_color = .{},
            .load_op = .clear,
            .store_op = .store,
        };

        const render_pass: *sdl.gpu.SDL_GPURenderPass = sdl.gpu.SDL_BeginGPURenderPass(
            cmd_buf,
            &.{color_target_info},
            1,
            null,
        ).?;
        sdl.gpu.SDL_BindGPUGraphicsPipeline(
            render_pass,
            if (use_wireframe_mode) line_pipeline.? else fill_pipeline.?,
        );
        if (use_small_viewport) {
            sdl.gpu.SDL_SetGPUViewport(render_pass, &small_viewport);
        }
        if (use_scissor_rect) {
            sdl.gpu.SDL_SetGPUScissor(render_pass, &scissor_rect);
        }
        sdl.gpu.SDL_DrawGPUPrimitives(render_pass, 3, 1, 0, 0);
        sdl.gpu.SDL_EndGPURenderPass(render_pass);
    }

    _ = sdl.gpu.SDL_SubmitGPUCommandBuffer(cmd_buf);

    return .app_continue;
}

pub fn appEvent(io: std.Io, gpa: std.mem.Allocator, appstate: ?*anyopaque, event: ?*sdl.events.SDL_Event) !sdl.init.SDL_AppResult {
    _ = io;
    _ = gpa;
    _ = appstate;

    if (!app_common.commonHandleEvent(event.?, &app_context)) {
        // on false, quit app
        return .app_success;
    }

    if (app_context.left_pressed) {
        use_wireframe_mode = !use_wireframe_mode;
    }

    if (app_context.down_pressed) {
        use_small_viewport = !use_small_viewport;
    }

    if (app_context.right_pressed) {
        use_scissor_rect = !use_scissor_rect;
    }

    return .app_continue;
}

pub fn appQuit(io: std.Io, gpa: std.mem.Allocator, appstate: ?*anyopaque, app_result: sdl.init.SDL_AppResult) !void {
    _ = gpa;
    _ = appstate;
    _ = app_result;

    sdl.gpu.SDL_ReleaseGPUGraphicsPipeline(app_context.device.?, fill_pipeline.?);
    sdl.gpu.SDL_ReleaseGPUGraphicsPipeline(app_context.device.?, line_pipeline.?);

    app_context.left_pressed = false;
    app_context.right_pressed = false;
    app_context.up_pressed = false;
    app_context.down_pressed = false;

    app_common.appDeinitMinimal(io, &app_context);
}
