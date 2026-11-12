/// main.zig just handles sdl entrypoint and callbacks
/// Game/app code starts in app.zig
/// This allows providing some nice zig quality of life features like error
/// trace and tidy args
const std = @import("std");
const sdl = @import("sdl/sdl.zig");

// const app = @import("app_01_basic_triangle.zig");
const app = @import("app_01_basic_triangle.zig");

var io: std.Io = undefined;

const debug_memory_limit = 1024 * 1024 * 500; //about 500MiB
var gpa: std.mem.Allocator = undefined;

pub fn main(init: std.process.Init.Minimal) u8 {
    var debug_allocator = std.heap.DebugAllocator(.{ .enable_memory_limit = true }).init;
    debug_allocator.requested_memory_limit = debug_memory_limit;
    defer {
        const check = debug_allocator.deinit();
        if (check == .leak) {
            std.debug.print("ERROR: one or more memory leaks detected!", .{});
        }
    }
    gpa = debug_allocator.allocator();

    var threaded_io: std.Io.Threaded = .init(gpa, .{
        .argv0 = .init(.{ .vector = init.args.vector }),
        .environ = .{ .block = init.environ.block },
    });
    defer threaded_io.deinit();
    io = threaded_io.io();

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

    return unwrapWithTrace(app.appInit(io, gpa, appstate, c_argv.?[0..argc]));
}

// see sdl.init.AppIterate_func
pub export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) sdl.init.SDL_AppResult {
    return unwrapWithTrace(app.appIterate(io, gpa, appstate));
}

// see sdl.init.AppEvent_func
pub export fn SDL_AppEvent(
    appstate: ?*anyopaque,
    event: ?*sdl.events.SDL_Event,
) callconv(.c) sdl.init.SDL_AppResult {
    return unwrapWithTrace(app.appEvent(io, gpa, appstate, event));
}

// see sdl.init.AppQuit_func
pub export fn SDL_AppQuit(
    appstate: ?*anyopaque,
    app_result: sdl.init.SDL_AppResult,
) callconv(.c) void {
    app.appQuit(io, gpa, appstate, app_result) catch |err| {
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
