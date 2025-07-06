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

const foreground_rate = "60";
// prefer "waitevent" unless you need it running for debug purposes
const background_rate = "waitevent";

var window: ?*c.SDL_Window = null;
var renderer: ?*c.SDL_Renderer = null;
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

    errorWrap(c.SDL_SetHint("SDL_RENDER_GPU_LOW_POWER", "1")) catch {
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

    errorWrap(c.SDL_CreateWindowAndRenderer(
        "zig-sdl3-test",
        640,
        480,
        c.SDL_WINDOW_RESIZABLE,
        &window,
        &renderer,
    )) catch {
        c.SDL_Log("Couldn't create window/renderer: %s", c.SDL_GetError());
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

    errorWrap(c.SDL_ClaimWindowForGPUDevice(gpu_device, window)) catch {
        c.SDL_Log("SDL_ClaimWindowForGPUDevice failed: %s", c.SDL_GetError());
        return c.SDL_APP_FAILURE;
    };

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc SDL_AppInit error: %s", error_check);
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

    // new color, full alpha.
    errorWrap(c.SDL_SetRenderDrawColorFloat(
        renderer,
        red,
        green,
        blue,
        c.SDL_ALPHA_OPAQUE_FLOAT,
    )) catch {
        c.SDL_Log("SetRenderDrawColorFloat %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    };

    // clear the window to the draw color.
    errorWrap(c.SDL_RenderClear(renderer)) catch {
        c.SDL_Log("RenderClear %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    };

    // put the newly-cleared rendering on the screen.
    errorWrap(c.SDL_RenderPresent(renderer)) catch {
        c.SDL_Log("RenderPresent %s", c.SDL_GetError());
        _ = c.SDL_ClearError();
    };

    const error_check = c.SDL_GetError();
    if (c.strlen(error_check) > 0) {
        c.SDL_Log("Misc SDL_AppIterate error: %s", error_check);
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
    c.SDL_DestroyRenderer(renderer);
    c.SDL_DestroyWindow(window);
}
