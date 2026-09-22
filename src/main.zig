/// main.zig just handles sdl entrypoint and callbacks
/// Game/app code starts in app.zig
/// This allows providing some nice zig quality of life features like error
/// trace and tidy args

const c = @import("c");
const std = @import("std");
const app = @import("app.zig");

// SDL3 is handling the main func
pub const main = c.main;

pub export fn SDL_AppInit(appstate: ?*?*anyopaque, c_argc: c_int, c_argv: ?[*:null]?[*:0]u8) callconv(.c) c.SDL_AppResult {
    const argc = @as(usize, @intCast(c_argc));
    const argv = @as([*][*:0]u8, @ptrCast(c_argv));

    return unwrapWithTrace(app.AppInit(appstate, argv[0..argc]));
}

pub export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) c.SDL_AppResult {
    return unwrapWithTrace(app.AppIterate(appstate));
}

pub export fn SDL_AppEvent(appstate: ?*anyopaque, event: ?*c.SDL_Event) callconv(.c) c.SDL_AppResult {
    return unwrapWithTrace(app.AppEvent(appstate, event));
}

pub export fn SDL_AppQuit(appstate: ?*anyopaque, app_result: c.SDL_AppResult) callconv(.c) void {
    app.AppQuit(appstate, app_result) catch |err| {
        if (@errorReturnTrace()) |trace| std.debug.dumpErrorReturnTrace(trace);
        std.log.err("{t}", .{err});
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
    };
}

/// unwraps error union, dumps error trace if error
/// result needs to be !c.SDL_AppResult error union type
fn unwrapWithTrace(result: anytype) c.SDL_AppResult {
    if (@typeInfo(@TypeOf(result)).error_union.payload != c.SDL_AppResult) {
        @compileError("expecting !c.SDL_AppResult error union type");
    }
    const unwrapped_result = result catch |err| {
        if (@errorReturnTrace()) |trace| std.debug.dumpErrorReturnTrace(trace);
        std.log.err("{t}", .{err});
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    return unwrapped_result;
}
