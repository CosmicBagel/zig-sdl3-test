const std = @import("std");
const sdl = @import("sdl/sdl.zig");
const app_common = @import("app_common.zig");

var app_context = app_common.AppContext{
    .name = "BasicTriangle",
};

pub fn appInit(appstate: ?*?*anyopaque, args: std.process.Args.Vector) !sdl.init.SDL_AppResult {
    _ = appstate;
    _ = args;

    try app_common.appInitMinimal(&app_context);

    return .app_continue;
}

pub fn appIterate(appstate: ?*anyopaque) !sdl.init.SDL_AppResult {
    _ = appstate;

    const new_time: u64 = sdl.timer.SDL_GetTicks() / 1000;
    const delta_time = new_time - app_context.last_time;
    app_context.last_time = new_time;

    _ = delta_time;

    // immediately quit
    return .app_success;
}

pub fn appEvent(appstate: ?*anyopaque, event: ?*sdl.events.SDL_Event) !sdl.init.SDL_AppResult {
    _ = appstate;
    _ = event;

    return .app_continue;
}

pub fn appQuit(appstate: ?*anyopaque, app_result: sdl.init.SDL_AppResult) !void {
    _ = appstate;
    _ = app_result;
    app_common.appDeinitMinimal(&app_context);
}
