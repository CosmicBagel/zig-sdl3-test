/// The flip mode.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_FlipMode = enum(c_uint) {
    none = 0,
    horizontal = 1,
    vertical = 2,
    horizontal_and_vertical = 3,
};
