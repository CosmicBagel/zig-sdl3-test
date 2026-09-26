/// SDL pen instance IDs.
///
/// Zero is used to signify an invalid/null device.
///
/// These show up in pen events when SDL sees input from them. They remain
/// consistent as long as SDL can recognize a tool to be the same pen; but if a
/// pen's digitizer table is physically detached from the computer, it might
/// get a new ID when reconnected, as SDL won't know it's the same device.
///
/// These IDs are only stable within a single run of a program; the next time a
/// program is run, the pen's ID will likely be different, even if the hardware
/// hasn't been disconnected, etc.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_PenID = u32;

/// Pen input flags, as reported by various pen events' `pen_state` field.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_PenInputFlags = packed struct(u32) {
    // BitField IE00_0000_0000_0000_0000_0000_0054_321D

    /// pen is pressed down
    down: bool, // bit 0
    /// button 1 is pressed
    button_1: bool, // bit 1
    /// button 2 is pressed
    button_2: bool, // bit 2
    /// button 3 is pressed
    button_3: bool, // bit 3
    /// button 4 is pressed
    button_4: bool, // bit 4
    /// button 5 is pressed
    button_5: bool, // bit 5
    _reserved: u24, // bit 6 - 29
    /// eraser tip is used
    eraser_tip: bool, // bit 30
    /// pen is in proximity (since SDL 3.4.0)
    in_proximity: bool, // bit 31
};

/// Pen axis indices.
///
/// These are the valid values for the `axis` field in SDL_PenAxisEvent. All
/// axes are either normalised to 0..1 or report a (positive or negative) angle
/// in degrees, with 0.0 representing the centre. Not all pens/backends support
/// all axes: unsupported axes are always zero.
///
/// To convert angles for tilt and rotation into vector representation, use
/// SDL_sinf on the XTILT, YTILT, or ROTATION component, for example:
///
/// `SDL_sinf(xtilt * SDL_PI_F / 180.0)`.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_PenAxis = enum(c_uint) {
    /// Pen pressure.  Unidirectional: 0 to 1.0
    pressure = 0,
    /// Pen horizontal tilt angle.  Bidirectional: -90.0 to 90.0 (left-to-right).
    xtilt = 1,
    /// Pen vertical tilt angle.  Bidirectional: -90.0 to 90.0 (top-to-down).
    ytilt = 2,
    /// Pen distance to drawing surface.  Unidirectional: 0.0 to 1.0
    distance = 3,
    /// Pen barrel rotation.  Bidirectional: -180 to 179.9 (clockwise, 0 is
    /// facing up, -180.0 is facing down). 
    rotation = 4,
    /// Pen finger wheel or slider (e.g., Airbrush Pen).  Unidirectional: 0 to 1.0 
    slider = 5,
    /// Pressure from squeezing the pen ("barrel pressure").
    tangential_pressure = 6,
    /// Total known pen axis types in this version of SDL. This number may grow in future releases!
    count = 7,
};
