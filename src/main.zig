/// main.zig just handles sdl entrypoint and callbacks
/// Game/app code starts in app.zig
/// This allows providing some nice zig quality of life features like error
/// trace and tidy args
const std = @import("std");
const app = @import("app.zig");
const sdl = @import("sdl/sdl.zig");

pub fn main() u8 {
    return @intCast(sdl.main.SDL_RunApp(0, null, RunAppCallback, null));
}

pub export fn RunAppCallback(argc: c_int, argv: ?[*][*:0]u8) c_int {
    return sdl.main.SDL_EnterAppMainCallbacks(
        argc,
        argv,
        SDL_AppInit,
        SDL_AppIterate,
        SDL_AppEvent,
        SDL_AppQuit,
    );
}

// see sdl.init.AppInit_func
pub export fn SDL_AppInit(
    appstate: ?*?*anyopaque,
    c_argc: c_int,
    c_argv: ?[*][*:0]u8,
) callconv(.c) sdl.init.SDL_AppResult {
    const argc = @as(usize, @intCast(c_argc));

    return unwrapWithTrace(app.AppInit(appstate, c_argv.?[0..argc]));
}

// see sdl.init.AppIterate_func
pub export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) sdl.init.SDL_AppResult {
    return unwrapWithTrace(app.AppIterate(appstate));
}

// see sdl.init.AppEvent_func
pub export fn SDL_AppEvent(
    appstate: ?*anyopaque,
    event: ?*sdl.events.SDL_Event,
) callconv(.c) sdl.init.SDL_AppResult {
    return unwrapWithTrace(app.AppEvent(appstate, event));
}

// see sdl.init.AppQuit_func
pub export fn SDL_AppQuit(
    appstate: ?*anyopaque,
    app_result: sdl.init.SDL_AppResult,
) callconv(.c) void {
    app.AppQuit(appstate, app_result) catch |err| {
        if (@errorReturnTrace()) |trace| std.debug.dumpErrorReturnTrace(trace);
        std.log.err("{t}", .{err});
        sdl.SDL_LogError(.error_category, "%s", sdl.SDL_GetError());
    };
}

/// unwraps error union, dumps error trace if error
/// result needs to be !c.SDL_AppResult error union type
fn unwrapWithTrace(result: anytype) sdl.init.SDL_AppResult {
    if (@typeInfo(@TypeOf(result)).error_union.payload != sdl.init.SDL_AppResult) {
        @compileError("expecting !sdl.AppResult error union type");
    }
    const unwrapped_result = result catch |err| {
        if (@errorReturnTrace()) |trace| std.debug.dumpErrorReturnTrace(trace);
        std.log.err("{t}", .{err});
        sdl.log.SDL_LogError(.error_category, "%s", sdl.sdl_error.SDL_GetError());
        return sdl.init.SDL_AppResult.app_failure;
    };

    return unwrapped_result;
}
