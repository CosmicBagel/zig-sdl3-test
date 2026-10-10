// # CategoryTime
//
// SDL realtime clock and date/time routines.
//
// There are two data types that are used in this category: SDL_Time, which
// represents the nanoseconds since a specific moment (an "epoch"), and
// SDL_DateTime, which breaks time down into human-understandable components:
// years, months, days, hours, etc.
//
// Much of the functionality is involved in converting those two types to
// other useful forms.

const stdinc = @import("stdinc.zig");

/// A structure holding a calendar date and time broken down into its
/// components.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_DateTime = extern struct {
    /// Year
    year: c_int = 0,
    /// Month [01-12]
    month: c_int = 0,
    /// Day of the month [01-31]
    day: c_int = 0,
    /// Hour [0-23]
    hour: c_int = 0,
    /// Minute [0-59]
    minute: c_int = 0,
    /// Seconds [0-60]
    second: c_int = 0,
    /// Nanoseconds [0-999999999]
    nanosecond: c_int = 0,
    /// Day of the week [0-6] (0 being Sunday)
    day_of_week: c_int = 0,
    /// Seconds east of UTC
    utc_offset: c_int = 0,
};

/// The preferred date format of the current system locale.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_GetDateTimeLocalePreferences
pub const SDL_DateFormat = enum(c_uint) {
    /// Year/Month/Day
    yyyymmdd = 0,
    /// Day/Month/Year
    ddmmyyyy = 1,
    /// Month/Day/Year
    mmddyyyy = 2,
};

/// The preferred time format of the current system locale.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_GetDateTimeLocalePreferences
pub const SDL_TimeFormat = enum(c_uint) {
    /// 24 hour time
    hr24 = 0,
    /// 12 hour time
    hr12 = 1,
};

/// Gets the current preferred date and time format for the system locale.
///
/// This might be a "slow" call that has to query the operating system. It's
/// best to ask for this once and save the results. However, the preferred
/// formats can change, usually because the user has changed a system
/// preference outside of your program.
///
/// \param dateFormat a pointer to the SDL_DateFormat to hold the returned date
///                   format, may be NULL.
/// \param timeFormat a pointer to the SDL_TimeFormat to hold the returned time
///                   format, may be NULL.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function is not thread safe.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetDateTimeLocalePreferences(
    dateFormat: [*c]SDL_DateFormat,
    timeFormat: [*c]SDL_TimeFormat,
) bool;
// extern SDL_DECLSPEC bool SDLCALL SDL_GetDateTimeLocalePreferences(SDL_DateFormat *dateFormat, SDL_TimeFormat *timeFormat);

/// Gets the current value of the system realtime clock in nanoseconds since
/// Jan 1, 1970 in Universal Coordinated Time (UTC).
///
/// \param ticks the SDL_Time to hold the returned tick count.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetCurrentTime(ticks: [*c]stdinc.SDL_Time) bool;
// extern SDL_DECLSPEC bool SDLCALL SDL_GetCurrentTime(stdinc.SDL_Time *ticks);

/// Converts an SDL_Time in nanoseconds since the epoch to a calendar time in
/// the SDL_DateTime format.
///
/// \param ticks the SDL_Time to be converted.
/// \param dt the resulting SDL_DateTime.
/// \param localTime the resulting SDL_DateTime will be expressed in local time
///                  if true, otherwise it will be in Universal Coordinated
///                  Time (UTC).
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_TimeToDateTime(
    ticks: stdinc.SDL_Time,
    dt: *SDL_DateTime,
    localTime: bool,
) bool;

/// Converts a calendar time to an SDL_Time in nanoseconds since the epoch.
///
/// This function ignores the day_of_week member of the SDL_DateTime struct, so
/// it may remain unset.
///
/// \param dt the source SDL_DateTime.
/// \param ticks the resulting SDL_Time.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DateTimeToTime(dt: *const SDL_DateTime, ticks: *stdinc.SDL_Time) bool;

/// Converts an SDL time into a Windows FILETIME (100-nanosecond intervals
/// since January 1, 1601).
///
/// This function fills in the two 32-bit values of the FILETIME structure.
///
/// \param ticks the time to convert.
/// \param dwLowDateTime a pointer filled in with the low portion of the
///                      Windows FILETIME value.
/// \param dwHighDateTime a pointer filled in with the high portion of the
///                       Windows FILETIME value.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_TimeToWindows(
    ticks: stdinc.SDL_Time,
    dwLowDateTime: *u32,
    dwHighDateTime: *u32,
) void;

/// Converts a Windows FILETIME (100-nanosecond intervals since January 1,
/// 1601) to an SDL time.
///
/// This function takes the two 32-bit values of the FILETIME structure as
/// parameters.
///
/// \param dwLowDateTime the low portion of the Windows FILETIME value.
/// \param dwHighDateTime the high portion of the Windows FILETIME value.
/// \returns the converted SDL time.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_TimeFromWindows(dwLowDateTime: u32, dwHighDateTime: u32) stdinc.SDL_Time;

/// Get the number of days in a month for a given year.
///
/// \param year the year.
/// \param month the month [1-12].
/// \returns the number of days in the requested month or -1 on failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetDaysInMonth(year: c_int, month: c_int) c_int;

/// Get the day of year for a calendar date.
///
/// \param year the year component of the date.
/// \param month the month component of the date.
/// \param day the day component of the date.
/// \returns the day of year [0-365] if the date is valid or -1 on failure;
///          call SDL_GetError() for more information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetDayOfYear(year: c_int, month: c_int, day: c_int) c_int;

/// Get the day of week for a calendar date.
///
/// \param year the year component of the date.
/// \param month the month component of the date.
/// \param day the day component of the date.
/// \returns a value between 0 and 6 (0 being Sunday) if the date is valid or
///          -1 on failure; call SDL_GetError() for more information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetDayOfWeek(year: c_int, month: c_int, day: c_int) c_int;
