// # CategoryMetal
//
// Functions to creating Metal layers and views on SDL windows.
//
// This provides some platform-specific glue for Apple platforms. Most macOS
// and iOS apps can use SDL without these functions, but this API they can be
// useful for specific OS-level integration tasks.

const video = @import("video.zig");

/// A handle to a CAMetalLayer-backed NSView (macOS) or UIView (iOS/tvOS).
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_MetalView = ?*anyopaque;

/////////////////////////////
// Metal support functions
/////////////////////////////

/// Create a CAMetalLayer-backed NSView/UIView and attach it to the specified
/// window.
///
/// On macOS, this does *not* associate a MTLDevice with the CAMetalLayer on
/// its own. It is up to user code to do that.
///
/// The returned handle can be casted directly to a NSView or UIView. To access
/// the backing CAMetalLayer, call SDL_Metal_GetLayer().
///
/// \param window the window.
/// \returns handle NSView or UIView.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Metal_DestroyView
/// \sa SDL_Metal_GetLayer
pub extern fn SDL_Metal_CreateView(window: ?*video.SDL_Window) SDL_MetalView;

/// Destroy an existing SDL_MetalView object.
///
/// This should be called before SDL_DestroyWindow, if SDL_Metal_CreateView was
/// called after SDL_CreateWindow.
///
/// \param view the SDL_MetalView object.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_Metal_CreateView
pub extern fn SDL_Metal_DestroyView(view: SDL_MetalView) void;

/// Get a pointer to the backing CAMetalLayer for the given view.
///
/// \param view the SDL_MetalView object.
/// \returns a pointer.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_Metal_GetLayer(view: SDL_MetalView) ?*anyopaque;
