/// An ID that represents a properties set.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_PropertiesID = u32;

/// SDL property type
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_PropertyType  = enum(c_uint) {
    invalid = 0,
    pointer = 1,
    string = 2,
    number = 3,
    float = 4,
    boolean = 5,
};

/// A generic property for naming things.
///
/// This property is intended to be added to any SDL_PropertiesID that needs a
/// generic name associated with the property set. It is not guaranteed that
/// any property set will include this key, but it is convenient to have a
/// standard key that any piece of code could reasonably agree to use.
///
/// For example, the properties associated with an SDL_Texture might have a
/// name string of "player sprites", or an SDL_AudioStream might have
/// "background music", etc. This might also be useful for an SDL_IOStream to
/// list the path to its asset.
///
/// There is no format for the value set with this key; it is expected to be
/// human-readable and informational in nature, possibly for logging or
/// debugging purposes.
///
/// SDL does not currently set this property on any objects it creates, but
/// this may change in later versions; it is currently expected that apps and
/// external libraries will take advantage of it, when appropriate.
///
/// \since This macro is available since SDL 3.4.0.
pub const SDL_PROP_NAME_STRING = "SDL.name";

