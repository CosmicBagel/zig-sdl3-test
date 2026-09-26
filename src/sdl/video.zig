/// This is a unique ID for a display for the time it is connected to the
/// system, and is never reused for the lifetime of the application.
/// 
/// If the display is disconnected and reconnected, it will get a new ID.
/// 
/// The value 0 is an invalid ID.
/// 
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_WindowID = u32;

/// This is a unique ID for a window.
///
/// The value 0 is an invalid ID.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_DisplayID = u32;

/// The struct used as an opaque handle to a window.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateWindow
pub const SDL_Window = opaque {};
