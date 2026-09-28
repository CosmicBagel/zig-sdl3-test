/// A rectangle, with the origin at the upper left (using integers).
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_RectEmpty
/// \sa SDL_RectsEqual
/// \sa SDL_HasRectIntersection
/// \sa SDL_GetRectIntersection
/// \sa SDL_GetRectAndLineIntersection
/// \sa SDL_GetRectUnion
/// \sa SDL_GetRectEnclosingPoints
pub const SDL_Rect = extern struct {
    x: c_int = 0,
    y: c_int = 0,
    w: c_int = 0,
    h: c_int = 0,
};
