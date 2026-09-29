const init = @import("init.zig");

/// The prototype for the application's main() function
///
/// \param argc an ANSI-C style main function's argc.
/// \param argv an ANSI-C style main function's argv.
/// \returns an ANSI-C main return code; generally 0 is considered successful
///          program completion, and small non-zero values are considered
///          errors.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_main_func = *const fn (argc: c_int, argv: [*c][*c]u8) callconv(.c) c_int;

/// Initializes and launches an SDL application, by doing platform-specific
/// initialization before calling your mainFunction and cleanups after it
/// returns, if that is needed for a specific platform, otherwise it just calls
/// mainFunction.
///
/// You can use this if you want to use your own main() implementation without
/// using SDL_main (like when using SDL_MAIN_HANDLED). When using this, you do
/// *not* need SDL_SetMainReady().
///
/// If `argv` is NULL, SDL will provide command line arguments, either by
/// querying the OS for them if possible, or supplying a filler array if not.
///
/// \param argc the argc parameter from the application's main() function, or 0
///             if the platform's main-equivalent has no argc.
/// \param argv the argv parameter from the application's main() function, or
///             NULL if the platform's main-equivalent has no argv.
/// \param mainFunction your SDL app's C-style main(). NOT the function you're
///                     calling this from! Its name doesn't matter; it doesn't
///                     literally have to be `main`.
/// \param reserved should be NULL (reserved for future use, will probably be
///                 platform-specific then).
/// \returns the return value from mainFunction: 0 on success, otherwise
///          failure; SDL_GetError() might have more information on the
///          failure.
///
/// \threadsafety Generally this is called once, near startup, from the
///               process's initial thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_RunApp(argc: c_int, argv: ?[*:null]?[*:0]u8, mainFunction: SDL_main_func, reserved: ?*anyopaque) callconv(.c) c_int;

/// An entry point for SDL's use in SDL_MAIN_USE_CALLBACKS.
///
/// Generally, you should not call this function directly. This only exists to
/// hand off work into SDL as soon as possible, where it has a lot more control
/// and functionality available, and make the inline code in SDL_main.h as
/// small as possible.
///
/// Not all platforms use this, it's actual use is hidden in a magic
/// header-only library, and you should not call this directly unless you
/// _really_ know what you're doing.
///
/// \param argc standard Unix main argc.
/// \param argv standard Unix main argv.
/// \param appinit the application's SDL_AppInit function.
/// \param appiter the application's SDL_AppIterate function.
/// \param appevent the application's SDL_AppEvent function.
/// \param appquit the application's SDL_AppQuit function.
/// \returns standard Unix main return value.
///
/// \threadsafety It is not safe to call this anywhere except as the only
///               function call in SDL_main.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_EnterAppMainCallbacks(
    argc: c_int,
    argv: [*c][*c]u8,
    appinit: init.AppInit_func,
    appiter: init.AppIterate_func,
    appevent: init.AppEvent_func,
    appquit: init.AppQuit_func,
) callconv(.c) c_int;
