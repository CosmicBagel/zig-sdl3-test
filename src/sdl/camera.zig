/// This is a unique ID for a camera device for the time it is connected to the
/// system, and is never reused for the lifetime of the application.
///
/// If the device is disconnected and reconnected, it will get a new ID.
///
/// The value 0 is an invalid ID.
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_GetCameras
pub const SDL_CameraID = u32;
