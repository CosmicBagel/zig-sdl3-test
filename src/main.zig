/// main.zig just handles sdl entrypoint and callbacks
/// Game/app code starts in app.zig
/// This allows providing some nice zig quality of life features like error
/// trace and tidy args
const std = @import("std");
const app = @import("app.zig");
const sdl = @import("sdl/sdl.zig");

pub export fn main(argc: c_int, argv: [*c][*c]u8) c_int {
    return sdl.SDL_RunApp(argc, argv, RunAppCallback, null);
}

pub export fn RunAppCallback(argc: c_int, argv: [*c][*c]u8) c_int {
    return sdl.SDL_EnterAppMainCallbacks(
        argc,
        argv,
        SDL_AppInit,
        SDL_AppIterate,
        SDL_AppEvent,
        SDL_AppQuit,
    );
}

pub export fn SDL_AppInit(appstate: ?*?*anyopaque, c_argc: c_int, c_argv: ?[*:null]?[*:0]u8) callconv(.c) sdl.AppResult {
    const argc = @as(usize, @intCast(c_argc));
    const argv = @as([*][*:0]u8, @ptrCast(c_argv));

    return unwrapWithTrace(app.AppInit(appstate, argv[0..argc]));
}

pub export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) sdl.AppResult {
    return unwrapWithTrace(app.AppIterate(appstate));
}

pub export fn SDL_AppEvent(appstate: ?*anyopaque, event: ?*sdl.SDL_Event) callconv(.c) sdl.AppResult {
    return unwrapWithTrace(app.AppEvent(appstate, event));
}

pub export fn SDL_AppQuit(appstate: ?*anyopaque, app_result: sdl.AppResult) callconv(.c) void {
    app.AppQuit(appstate, app_result) catch |err| {
        if (@errorReturnTrace()) |trace| std.debug.dumpErrorReturnTrace(trace);
        std.log.err("{t}", .{err});
        sdl.SDL_LogError(.error_category, "%s", sdl.SDL_GetError());
    };
}

/// unwraps error union, dumps error trace if error
/// result needs to be !c.SDL_AppResult error union type
fn unwrapWithTrace(result: anytype) sdl.AppResult {
    if (@typeInfo(@TypeOf(result)).error_union.payload != sdl.AppResult) {
        @compileError("expecting !sdl.AppResult error union type");
    }
    const unwrapped_result = result catch |err| {
        if (@errorReturnTrace()) |trace| std.debug.dumpErrorReturnTrace(trace);
        std.log.err("{t}", .{err});
        sdl.SDL_LogError( .error_category, "%s", sdl.SDL_GetError());
        return sdl.AppResult.app_failure;
    };

    return unwrapped_result;
}
