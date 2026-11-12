const std = @import("std");
const sdl = @import("sdl/sdl.zig");
const app_common = @import("app_common.zig");

var app_context = app_common.AppContext{
    .name = "BasicTriangle",
};

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

    _ = vertex_shader;
    _ = fragment_shader;

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

    // immediately quit
    return .app_success;
}

pub fn appEvent(io: std.Io, gpa: std.mem.Allocator, appstate: ?*anyopaque, event: ?*sdl.events.SDL_Event) !sdl.init.SDL_AppResult {
    _ = io;
    _ = gpa;
    _ = appstate;
    _ = event;

    return .app_continue;
}

pub fn appQuit(io: std.Io, gpa: std.mem.Allocator, appstate: ?*anyopaque, app_result: sdl.init.SDL_AppResult) !void {
    _ = gpa;
    _ = appstate;
    _ = app_result;
    app_common.appDeinitMinimal(io, &app_context);
}
