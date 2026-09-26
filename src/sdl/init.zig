const events = @import("events.zig");

/// Initialization flags for SDL_Init and/or SDL_InitSubSystem
///
/// These are the flags which may be passed to SDL_Init(). You should specify
/// the subsystems which you will be using in your application.
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_Init
/// \sa SDL_Quit
/// \sa SDL_InitSubSystem
/// \sa SDL_QuitSubSystem
/// \sa SDL_WasInit
pub const SDL_InitFlags = packed struct(u32) {
    // audio    0b0000_0000_0000_0000_0000_0000_0001_0000 bit 4
    // video    0b0000_0000_0000_0000_0000_0000_0010_0000 bit 5
    // joystick 0b0000_0000_0000_0000_0000_0010_0000_0000 bit 9
    // haptic   0b0000_0000_0000_0000_0001_0000_0000_0000 bit 12
    // gamepad  0b0000_0000_0000_0000_0010_0000_0000_0000 bit 13
    // events   0b0000_0000_0000_0000_0100_0000_0000_0000 bit 14
    // sensor   0b0000_0000_0000_0000_1000_0000_0000_0000 bit 15
    // camera   0b0000_0000_0000_0001_0000_0000_0000_0000 bit 16

    // BitField 0000_0000_0000_000C_SEGH_00J0_00VA_0000

    _reserved0: u4, // bits 0-5
    /// `SDL_INIT_AUDIO` implies `SDL_INIT_EVENTS`
    audio: bool, // bit 4
    /// `SDL_INIT_VIDEO` implies `SDL_INIT_EVENTS`, should be initialized on the main thread
    video: bool, // bit 5
    _reserved1: u3, // bits 6-10
    /// `SDL_INIT_JOYSTICK` implies `SDL_INIT_EVENTS`
    joystick: bool, // bit 9
    _reserved2: u2, // bits 10-13
    haptic: bool, // bit 12
    /// `SDL_INIT_GAMEPAD` implies `SDL_INIT_JOYSTICK`
    gamepad: bool, // bit 13
    events: bool, // bit 14
    /// `SDL_INIT_SENSOR` implies `SDL_INIT_EVENTS`
    sensor: bool, // bit 15
    /// `SDL_INIT_CAMERA` implies `SDL_INIT_EVENTS`
    camera: bool, // bit 16
};

/// Return values for optional main callbacks.
///
/// Returning SDL_APP_SUCCESS or SDL_APP_FAILURE from SDL_AppInit,
/// SDL_AppEvent, or SDL_AppIterate will terminate the program and report
/// success/failure to the operating system. What that means is
/// platform-dependent. On Unix, for example, on success, the process error
/// code will be zero, and on failure it will be 1. This interface doesn't
/// allow you to return specific exit codes, just whether there was an error
/// generally or not.
///
/// Returning SDL_APP_CONTINUE from these functions will let the app continue
/// to run.
///
/// See
/// [Main callbacks in SDL3](https://wiki.libsdl.org/SDL3/README-main-functions#main-callbacks-in-sdl3)
/// for complete details.
///
/// \since This enum is available since SDL 3.2.0.
///
pub const SDL_AppResult = enum(c_uint) {
    /// Value that requests that the app continue from the main callbacks.
    app_continue = 0,
    /// Value that requests termination with success from the main callbacks.
    app_success = 1,
    /// Value that requests termination with error from the main callbacks.
    app_failure = 2,
};

/// Function pointer typedef for SDL_AppInit.
///
/// These are used by SDL_EnterAppMainCallbacks. This mechanism operates behind
/// the scenes for apps using the optional main callbacks. Apps that want to
/// use this should just implement SDL_AppInit directly.
///
/// \param appstate a place where the app can optionally store a pointer for
///                 future use.
/// \param argc the standard ANSI C main's argc; number of elements in `argv`.
/// \param argv the standard ANSI C main's argv; array of command line
///             arguments.
/// \returns SDL_APP_FAILURE to terminate with an error, SDL_APP_SUCCESS to
///          terminate with success, SDL_APP_CONTINUE to continue.
///
/// \since This datatype is available since SDL 3.2.0.
pub const AppInit_func = ?*const fn (appstate: ?*?*anyopaque, argc: c_int, argv: ?[*:null]?[*:0]u8) callconv(.c) SDL_AppResult;

/// Function pointer typedef for SDL_AppIterate.
///
/// These are used by SDL_EnterAppMainCallbacks. This mechanism operates behind
/// the scenes for apps using the optional main callbacks. Apps that want to
/// use this should just implement SDL_AppIterate directly.
///
/// \param appstate an optional pointer, provided by the app in SDL_AppInit.
/// \returns SDL_APP_FAILURE to terminate with an error, SDL_APP_SUCCESS to
///          terminate with success, SDL_APP_CONTINUE to continue.
///
/// \since This datatype is available since SDL 3.2.0.
pub const AppIterate_func = ?*const fn (appstate: ?*anyopaque) callconv(.c) SDL_AppResult;

/// Function pointer typedef for SDL_AppEvent.
///
/// These are used by SDL_EnterAppMainCallbacks. This mechanism operates behind
/// the scenes for apps using the optional main callbacks. Apps that want to
/// use this should just implement SDL_AppEvent directly.
///
/// \param appstate an optional pointer, provided by the app in SDL_AppInit.
/// \param event the new event for the app to examine.
/// \returns SDL_APP_FAILURE to terminate with an error, SDL_APP_SUCCESS to
///          terminate with success, SDL_APP_CONTINUE to continue.
///
/// \since This datatype is available since SDL 3.2.0.
pub const AppEvent_func = ?*const fn (appstate: ?*anyopaque, event: [*c]events.SDL_Event) callconv(.c) SDL_AppResult;

/// Function pointer typedef for SDL_AppQuit.
///
/// These are used by SDL_EnterAppMainCallbacks. This mechanism operates behind
/// the scenes for apps using the optional main callbacks. Apps that want to
/// use this should just implement SDL_AppEvent directly.
///
/// \param appstate an optional pointer, provided by the app in SDL_AppInit.
/// \param result the result code that terminated the app (success or failure).
///
/// \since This datatype is available since SDL 3.2.0.
pub const AppQuit_func = ?*const fn (appstate: ?*anyopaque, result: SDL_AppResult) callconv(.c) void;


/// Initialize the SDL library.
/// 
/// SDL_Init() simply forwards to calling SDL_InitSubSystem(). Therefore, the
/// two may be used interchangeably. Though for readability of your code
/// SDL_InitSubSystem() might be preferred.
/// 
/// The file I/O (for example: SDL_IOFromFile) and threading (SDL_CreateThread)
/// subsystems are initialized by default. Message boxes
/// (SDL_ShowSimpleMessageBox) also attempt to work without initializing the
/// video subsystem, in hopes of being useful in showing an error dialog when
/// SDL_Init fails. You must specifically initialize other subsystems if you
/// use them in your application.
/// 
/// Logging (such as SDL_Log) works without initialization, too.
/// 
/// `flags` may be any of the following OR'd together:
/// 
/// - `SDL_INIT_AUDIO`: audio subsystem; automatically initializes the events
///   subsystem
/// - `SDL_INIT_VIDEO`: video subsystem; automatically initializes the events
///   subsystem, should be initialized on the main thread.
/// - `SDL_INIT_JOYSTICK`: joystick subsystem; automatically initializes the
///   events subsystem
/// - `SDL_INIT_HAPTIC`: haptic (force feedback) subsystem
/// - `SDL_INIT_GAMEPAD`: gamepad subsystem; automatically initializes the
///   joystick subsystem
/// - `SDL_INIT_EVENTS`: events subsystem
/// - `SDL_INIT_SENSOR`: sensor subsystem; automatically initializes the events
///   subsystem
/// - `SDL_INIT_CAMERA`: camera subsystem; automatically initializes the events
///   subsystem
/// 
/// Subsystem initialization is ref-counted, you must call SDL_QuitSubSystem()
/// for each SDL_InitSubSystem() to correctly shutdown a subsystem manually (or
/// call SDL_Quit() to force shutdown). If a subsystem is already loaded then
/// this call will increase the ref-count and return.
/// 
/// Consider reporting some basic metadata about your application before
/// calling SDL_Init, using either SDL_SetAppMetadata() or
/// SDL_SetAppMetadataProperty().
/// 
/// \param flags subsystem initialization flags.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
/// 
/// \threadsafety This function should only be called on the main thread.
/// 
/// \since This function is available since SDL 3.2.0.
/// 
/// \sa SDL_SetAppMetadata
/// \sa SDL_SetAppMetadataProperty
/// \sa SDL_InitSubSystem
/// \sa SDL_Quit
/// \sa SDL_SetMainReady
/// \sa SDL_WasInit
pub extern fn SDL_Init(flags: SDL_InitFlags) bool;

/// Compatibility function to initialize the SDL library.
///
/// This function and SDL_Init() are interchangeable.
///
/// \param flags any of the flags used by SDL_Init(); see SDL_Init for details.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Init
/// \sa SDL_Quit
/// \sa SDL_QuitSubSystem
pub extern fn SDL_InitSubSystem(flags: SDL_InitFlags) bool;

/// Shut down specific SDL subsystems.
///
/// You still need to call SDL_Quit() even if you close all open subsystems
/// with SDL_QuitSubSystem().
///
/// \param flags any of the flags used by SDL_Init(); see SDL_Init for details.
///
/// \threadsafety This function is not thread safe.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_InitSubSystem
/// \sa SDL_Quit
pub extern fn SDL_QuitSubSystem(flags: SDL_InitFlags) void;

/// Get a mask of the specified subsystems which are currently initialized.
///
/// \param flags any of the flags used by SDL_Init(); see SDL_Init for details.
/// \returns a mask of all initialized subsystems if `flags` is 0, otherwise it
///          returns the initialization status of the specified subsystems.
///
/// \threadsafety This function is not thread safe.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Init
/// \sa SDL_InitSubSystem
pub extern fn SDL_WasInit(flags: SDL_InitFlags) SDL_InitFlags;

/// Clean up all initialized subsystems.
///
/// You should call this function even if you have already shutdown each
/// initialized subsystem with SDL_QuitSubSystem(). It is safe to call this
/// function even in the case of errors in initialization.
///
/// You can use this function with atexit() to ensure that it is run when your
/// application is shutdown, but it is not wise to do this from a library or
/// other dynamically loaded code.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Init
/// \sa SDL_QuitSubSystem
pub extern fn SDL_Quit() void;

/// Return whether this is the main thread.
///
/// On Apple platforms, the main thread is the thread that runs your program's
/// main() entry point. On other platforms, the main thread is the one that
/// calls SDL_Init(SDL_INIT_VIDEO), which should usually be the one that runs
/// your program's main() entry point. If you are using the main callbacks,
/// SDL_AppInit(), SDL_AppIterate(), and SDL_AppQuit() are all called on the
/// main thread.
///
/// \returns true if this thread is the main thread, or false otherwise.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_RunOnMainThread
pub extern fn SDL_IsMainThread() bool;

