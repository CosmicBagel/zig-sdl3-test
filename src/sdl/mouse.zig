/// This is a unique ID for a mouse for the time it is connected to the system,
/// and is never reused for the lifetime of the application.
///
/// If the mouse is disconnected and reconnected, it will get a new ID.
///
/// The value 0 is an invalid ID.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_MouseID = u32;

/// Scroll direction types for the Scroll event
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_MouseWheelDirection = enum(c_uint) {
    /// The scroll direction is normal
    normal = 0,
    /// The scroll direction is flipped / natural
    flipped = 1,
};

/// A bitmask of pressed mouse buttons, as reported by SDL_GetMouseState, etc.
///
/// - Button 1: Left mouse button
/// - Button 2: Middle mouse button
/// - Button 3: Right mouse button
/// - Button 4: Side mouse button 1
/// - Button 5: Side mouse button 2
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_GetMouseState
/// \sa SDL_GetGlobalMouseState
/// \sa SDL_GetRelativeMouseState
pub const SDL_MouseButtonFlags = packed struct(u32) {
    left: bool, // bit 0
    middle: bool, // bit 1
    right: bool, // bit 2
    side_1: bool, // bit 3
    side_2: bool, // bit 4
};
