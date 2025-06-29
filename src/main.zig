//#region notes

// note: @cimport and @cinclude will be deprecated in favour of c-translate
// library that extends the build system, this way the c-translate can be
// developed and released independently of the compiler
// https://github.com/ziglang/zig/issues/20630
// https://github.com/ziglang/translate-c
// at some point I'll have to change this over, I suspect @cimport and @cinclude

// note: currently using https://github.com/castholm/SDL/
// a port of SDL to the zig build system, should be a reasonably stable
// approach.
// alternative library:
// https://github.com/ikskuh/SDL.zig to work
// SDL is looking at generating API bindings which would allow ikskuh's library
// to progress in development for sdl3.
// see: https://github.com/libsdl-org/SDL/issues/6337
// Once this library was working, it may be preferable to the build system
// port, or used in conjunction with build system port

// todo: reads
// - https://moonside.games/posts/sdl-gpu-sprite-batcher/
// - https://moonside.games/posts/sdl-gpu-concepts-cycling/
// - https://moonside.games/posts/introducing-sdl-shadercross/
// - https://examples.libsdl.org/SDL3/
// - https://hamdy-elzanqali.medium.com/let-there-be-triangles-sdl-gpu-edition-bd82cf2ef615

//#endregion notes

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_revision.h");
    @cDefine("SDL_MAIN_USE_CALLBACKS", {}); // We are providing our own entry point
    @cInclude("SDL3/SDL_main.h");
});

const std = @import("std");

// SDL3 is handling the main func
pub const main = c.main;

const foreground_rate = "60";
// prefer "waitevent" unless you need it running for debug purposes
const background_rate = "waitevent";

var window: ?*c.SDL_Window = null;
var renderer: ?*c.SDL_Renderer = null;

pub export fn SDL_AppInit(appstate: ?*?*anyopaque, argc: c_int, argv: ?[*:null]?[*:0]u8) callconv(.c) c.SDL_AppResult {
    _ = appstate;
    _ = argc;
    _ = argv;

    c.SDL_Log("zig sdl3 test");

    _ = c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate);
    _ = c.SDL_SetHint("SDL_RENDER_GPU_LOW_POWER", "1");

    _ = c.SDL_SetAppMetadata("Example Renderer Clear", "1.0", "com.example.renderer-clear");

    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        c.SDL_Log("Couldn't initialize SDL: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    }

    if (!c.SDL_CreateWindowAndRenderer(
        "examples/renderer/clear",
        640,
        480,
        c.SDL_WINDOW_RESIZABLE,
        &window,
        &renderer,
    )) {
        c.SDL_Log("Couldn't create window/renderer: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    }

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc init error %s", error_check);
        _ = c.SDL_ClearError();
    }

    return c.SDL_APP_CONTINUE;
}

pub export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) c.SDL_AppResult {
    _ = appstate;

    const now: f64 = @as(f64, @floatFromInt(c.SDL_GetTicks())) / 1000.0; // convert from milliseconds to seconds.
    // choose the color for the frame we will draw. The sine wave trick makes it fade between colors smoothly.
    const red: f32 = @floatCast(0.5 + 0.5 * c.SDL_sin(now));
    const green: f32 = @floatCast(0.5 + 0.5 * c.SDL_sin(now + c.SDL_PI_D * 2 / 3));
    const blue: f32 = @floatCast(0.5 + 0.5 * c.SDL_sin(now + c.SDL_PI_D * 4 / 3));
    var did_error = c.SDL_SetRenderDrawColorFloat(renderer, red, green, blue, c.SDL_ALPHA_OPAQUE_FLOAT); // new color, full alpha.
    if (!did_error) {
        c.SDL_Log("SetRenderDrawColorFloat %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    }

    // clear the window to the draw color.
    did_error = c.SDL_RenderClear(renderer);
    if (!did_error) {
        c.SDL_Log("RenderClear %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    }

    // put the newly-cleared rendering on the screen.
    did_error = c.SDL_RenderPresent(renderer);
    if (!did_error) {
        c.SDL_Log("RenderPresent %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    }

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc iterate error %s", error_check);
        _ = c.SDL_ClearError();
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
        if (scancode == c.SDL_SCANCODE_ESCAPE or scancode == c.SDL_SCANCODE_Q) {
            return c.SDL_APP_SUCCESS;
        }
    }

    if (event.?.type == c.SDL_EVENT_WINDOW_FOCUS_GAINED) {
        const did_error = c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", foreground_rate);
        if (!did_error) {
            c.SDL_Log("SetHint %s", c.SDL_GetError());
            _ = c.SDL_ClearError();
        }
    }

    if (event.?.type == c.SDL_EVENT_WINDOW_FOCUS_LOST) {
        const did_error = c.SDL_SetHint("SDL_MAIN_CALLBACK_RATE", background_rate);
        if (!did_error) {
            c.SDL_Log("SetHint %s", c.SDL_GetError());
            _ = c.SDL_ClearError();
        }
    }

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc event error %s", error_check);
        _ = c.SDL_ClearError();
    }

    return c.SDL_APP_CONTINUE;
}

pub export fn SDL_AppQuit(appstate: ?*anyopaque, result: c.SDL_AppResult) callconv(.c) void {
    _ = appstate;
    _ = result;
}
