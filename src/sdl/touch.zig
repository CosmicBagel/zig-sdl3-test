/// A unique ID for a touch device.
///
/// This ID is valid for the time the device is connected to the system, and is
/// never reused for the lifetime of the application.
///
/// The value 0 is an invalid ID.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_TouchID = u64;

/// A unique ID for a single finger on a touch device.
///
/// This ID is valid for the time the finger (stylus, etc) is touching and will
/// be unique for all fingers currently in contact, so this ID tracks the
/// lifetime of a single continuous touch. This value may represent an index, a
/// pointer, or some other unique ID, depending on the platform.
///
/// The value 0 is an invalid ID.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_FingerID = u64;
