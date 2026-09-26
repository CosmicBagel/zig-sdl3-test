// # CategoryLog
//
// Simple log messages with priorities and categories. A message's
// SDL_LogPriority signifies how important the message is. A message's
// SDL_LogCategory signifies from what domain it belongs to. Every category
// has a minimum priority specified: when a message belongs to that category,
// it will only be sent out if it has that minimum priority or higher.
//
// SDL's own logs are sent below the default priority threshold, so they are
// quiet by default.
//
// You can change the log verbosity programmatically using
// SDL_SetLogPriority() or with SDL_SetHint(SDL_HINT_LOGGING, ...), or with
// the "SDL_LOGGING" environment variable. This variable is a comma separated
// set of category=level tokens that define the default logging levels for SDL
// applications.
//
// The category can be a numeric category, one of "app", "error", "assert",
// "system", "audio", "video", "render", "input", "test", or `*` for any
// unspecified category.
//
// The level can be a numeric level, one of "trace", "verbose", "debug",
// "info", "warn", "error", "critical", or "quiet" to disable that category.
//
// You can omit the category if you want to set the logging level for all
// categories.
//
// If this hint isn't set, the default log levels are equivalent to:
//
// `app=info,assert=warn,test=verbose,*=error`
//
// Here's where the messages go on different platforms:
//
// - Windows: debug output stream
// - Android: log output
// - Others: standard error output (stderr)
//
// You don't need to have a newline (`\n`) on the end of messages, the
// functions will do that for you. For consistent behavior cross-platform, you
// shouldn't have any newlines in messages, such as to log multiple lines in
// one call; unusual platform-specific behavior can be observed in such usage.
// Do one log call per line instead, with no newlines in messages.
//
// Each log call is atomic, so you won't see log messages cut off one another
// when logging from multiple threads.

/// The predefined log categories
///
/// By default the application and gpu categories are enabled at the INFO
/// level, the assert category is enabled at the WARN level, test is enabled at
/// the VERBOSE level and all other categories are enabled at the ERROR level.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_LogCategory = enum(c_uint) {
    application = 0,
    error_category = 1,
    assert = 2,
    system = 3,
    audio = 4,
    video = 5,
    render = 6,
    input = 7,
    test_category = 8,
    gpu = 9,

    /// Reserved for future SDL library use
    reserved2 = 10,
    reserved3 = 11,
    reserved4 = 12,
    reserved5 = 13,
    reserved6 = 14,
    reserved7 = 15,
    reserved8 = 16,
    reserved9 = 17,
    reserved10 = 18,

    /// Beyond this point is reserved for application use, e.g.
    /// enum {
    ///     MYAPP_CATEGORY_AWESOME1 = SDL_LOG_CATEGORY_CUSTOM,
    ///     MYAPP_CATEGORY_AWESOME2,
    ///     MYAPP_CATEGORY_AWESOME3,
    ///     ...
    /// };
    custom = 19,
};

/// The predefined log priorities
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_LogPriority = enum(c_uint) {
    invalid = 0,
    trace = 1,
    verbose = 2,
    debug = 3,
    info = 4,
    warn = 5,
    error_priority = 6,
    critical = 7,
    count = 8,
};

/// Set the priority of all log categories.
///
/// \param priority the SDL_LogPriority to assign.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_ResetLogPriorities
/// \sa SDL_SetLogPriority
pub extern fn SDL_SetLogPriorities(priority: SDL_LogPriority) void;

/// Set the priority of a particular log category.
///
/// \param category the category to assign a priority to.
/// \param priority the SDL_LogPriority to assign.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GetLogPriority
/// \sa SDL_ResetLogPriorities
/// \sa SDL_SetLogPriorities
pub extern fn SDL_SetLogPriority(category: SDL_LogCategory, priority: SDL_LogPriority) void;

/// Get the priority of a particular log category.
///
/// \param category the category to query.
/// \returns the SDL_LogPriority for the requested category.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SetLogPriority
pub extern fn SDL_GetLogPriority(category: SDL_LogCategory) SDL_LogPriority;

/// Reset all priorities to default.
///
/// This is called by SDL_Quit().
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SetLogPriorities
/// \sa SDL_SetLogPriority
pub extern fn SDL_ResetLogPriorities() void;

/// Set the text prepended to log messages of a given priority.
///
/// By default SDL_LOG_PRIORITY_INFO and below have no prefix, and
/// SDL_LOG_PRIORITY_WARN and higher have a prefix showing their priority, e.g.
/// "WARNING: ".
///
/// This function makes a copy of its string argument, **prefix**, so it is not
/// necessary to keep the value of **prefix** alive after the call returns.
///
/// \param priority the SDL_LogPriority to modify.
/// \param prefix the prefix to use for that log priority, or NULL to use no
///               prefix.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SetLogPriorities
/// \sa SDL_SetLogPriority
pub extern fn SDL_SetLogPriorityPrefix(priority: SDL_LogPriority, prefix: [*c]const u8) bool;

/// Log a message with SDL_LOG_CATEGORY_APPLICATION and SDL_LOG_PRIORITY_INFO.
///
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the `fmt` string, if
///            any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
extern fn SDL_Log(fmt: [*c]const u8, ...) void;

/// Log a message with SDL_LOG_PRIORITY_TRACE.
///
/// \param category the category of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
pub extern fn SDL_LogTrace(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;

/// Log a message with SDL_LOG_PRIORITY_VERBOSE.
///
/// \param category the category of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogWarn
pub extern fn SDL_LogVerbose(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;

/// Log a message with SDL_LOG_PRIORITY_DEBUG.
///
/// \param category the category of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
pub extern fn SDL_LogDebug(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;

/// Log a message with SDL_LOG_PRIORITY_INFO.
///
/// \param category the category of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
pub extern fn SDL_LogInfo(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;

/// Log a message with SDL_LOG_PRIORITY_WARN.
///
/// \param category the category of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
pub extern fn SDL_LogWarn(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;

/// Log a message with SDL_LOG_PRIORITY_ERROR.
///
/// \param category the category of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
pub extern fn SDL_LogError(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;

/// Log a message with SDL_LOG_PRIORITY_CRITICAL.
///
/// \param category the category of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogMessageV
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
pub extern fn SDL_LogCritical(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;

/// Log a message with the specified category and priority.
///
/// \param category the category of the message.
/// \param priority the priority of the message.
/// \param fmt a printf() style message format string.
/// \param ... additional parameters matching % tokens in the **fmt** string,
///            if any.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessageV
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
pub extern fn SDL_LogMessage(
    category: SDL_LogCategory,
    priority: SDL_LogPriority,
    fmt: [*c]const u8,
    ...,
) void;

/// Log a message with the specified category and priority.
///
/// \param category the category of the message.
/// \param priority the priority of the message.
/// \param fmt a printf() style message format string.
/// \param ap a variable argument list.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Log
/// \sa SDL_LogCritical
/// \sa SDL_LogDebug
/// \sa SDL_LogError
/// \sa SDL_LogInfo
/// \sa SDL_LogMessage
/// \sa SDL_LogTrace
/// \sa SDL_LogVerbose
/// \sa SDL_LogWarn
////
///tern SDL_DECLSPEC void SDLCALL SDL_LogMessageV(int category,
pub extern fn SDL_LogMessageV(
    category: SDL_LogCategory,
    priority: SDL_LogPriority,
    fmt: [*c]const u8,
    ap: [*c]u8,
) void;

/// The prototype for the log output callback function.
///
/// This function is called by SDL when there is new text to be logged. A mutex
/// is held so that this function is never called by more than one thread at
/// once.
///
/// \param userdata what was passed as `userdata` to
///                 SDL_SetLogOutputFunction().
/// \param category the category of the message.
/// \param priority the priority of the message.
/// \param message the message being output.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_LogOutputFunction = ?*const fn (
    userdata: ?*anyopaque,
    category: SDL_LogCategory,
    priority: SDL_LogPriority,
    message: [*c]const u8,
) callconv(.c) void;

/// Get the default log output function.
///
/// \returns the default log output callback. It should be called with NULL for
///          the userdata argument.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SetLogOutputFunction
/// \sa SDL_GetLogOutputFunction
pub extern fn SDL_GetDefaultLogOutputFunction() SDL_LogOutputFunction;

/// Get the current log output function.
///
/// \param callback an SDL_LogOutputFunction filled in with the current log
///                 callback.
/// \param userdata a pointer filled in with the pointer that is passed to
///                 `callback`.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GetDefaultLogOutputFunction
/// \sa SDL_SetLogOutputFunction
pub extern fn SDL_GetLogOutputFunction(
    callback: [*c]SDL_LogOutputFunction,
    userdata: [*c]?*anyopaque,
) void;

/// Replace the default log output function with one of your own.
///
/// \param callback an SDL_LogOutputFunction to call instead of the default.
/// \param userdata a pointer that is passed to `callback`.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GetDefaultLogOutputFunction
/// \sa SDL_GetLogOutputFunction
pub extern fn SDL_SetLogOutputFunction(callback: SDL_LogOutputFunction, userdata: ?*anyopaque) void;

