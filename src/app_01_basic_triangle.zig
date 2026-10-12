const std = @import("std");

const sdl = @import("sdl/sdl.zig");
const sdl_helpers = @import("sdl_helpers.zig");
const errorWrap = sdl_helpers.errorWrap;

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
pub fn AppInit(appstate: ?*?*anyopaque, args: std.process.Args.Vector) !sdl.init.SDL_AppResult {
    _ = appstate;
    _ = args;

    const source_location = @src();
    const app_name = source_location.file;

    sdl.log.SDL_SetLogPriorities(.verbose);
    sdl.log.SDL_Log(app_name);

    try errorWrap(sdl.init.SDL_SetAppMetadata(
        app_name,
        "0.0.1",
        "com.cosmicbagel." ++ app_name,
    ));

    if (!sdl.init.SDL_Init(.{ .video = true })) {
        sdl.log.SDL_Log("Failed to initialize SDL: %s", sdl.sdl_error.SDL_GetError());
        return .app_failure;
    }

    return .app_continue;
}

var last_time: u64 = 0;
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
pub fn AppIterate(appstate: ?*anyopaque) !sdl.init.SDL_AppResult {
    _ = appstate;

    const new_time: u64 = sdl.timer.SDL_GetTicks() / 1000;
    const delta_time = new_time - last_time;
    last_time = new_time;

    _ = delta_time;

    // immediately quit
    return .app_success;
}

/// This will be called whenever an SDL event arrives. Your app should not call
/// SDL_PollEvent, SDL_PumpEvent, etc, as SDL will manage all this for you.
/// Return values are the same as from SDL_AppIterate(), so you can terminate
/// in response to SDL_EVENT_QUIT, etc.
pub fn AppEvent(appstate: ?*anyopaque, event: ?*sdl.events.SDL_Event) !sdl.init.SDL_AppResult {
    _ = appstate;
    _ = event;

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
pub fn AppQuit(appstate: ?*anyopaque, app_result: sdl.init.SDL_AppResult) !void {
    _ = appstate;
    _ = app_result;
}
