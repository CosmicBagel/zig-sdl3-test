/// The basic state for the system's power supply.
///
/// These are results returned by SDL_GetPowerInfo().
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_PowerState = enum(c_int) {
    /// error determining power status
    error_state = -1,
    /// cannot determine power status 
    unknown = 0,
    /// Not plugged in, running on the battery 
    on_battery = 1,
    /// Plugged in, no battery available 
    no_battery = 2,
    /// Plugged in, charging battery 
    charging = 3,
    /// Plugged in, battery charged 
    charged = 4,
};
