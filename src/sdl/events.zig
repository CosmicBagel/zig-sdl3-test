// # CategoryEvents
//
// Event queue management.
//
// It's extremely common--often required--that an app deal with SDL's event
// queue. Almost all useful information about interactions with the real world
// flow through here: the user interacting with the computer and app, hardware
// coming and going, the system changing in some way, etc.
//
// An app generally takes a moment, perhaps at the start of a new frame, to
// examine any events that have occurred since the last time and process or
// ignore them. This is generally done by calling SDL_PollEvent() in a loop
// until it returns false (or, if using the main callbacks, events are
// provided one at a time in calls to SDL_AppEvent() before the next call to
// SDL_AppIterate(); in this scenario, the app does not call SDL_PollEvent()
// at all).
//
// There is other forms of control, too: SDL_PeepEvents() has more
// functionality at the cost of more complexity, and SDL_WaitEvent() can block
// the process until something interesting happens, which might be beneficial
// for certain types of programs on low-power hardware. One may also call
// SDL_AddEventWatch() to set a callback when new events arrive.
//
// The app is free to generate their own events, too: SDL_PushEvent allows the
// app to put events onto the queue for later retrieval; SDL_RegisterEvents
// can guarantee that these events have a type that isn't in use by other
// parts of the system.

const audio = @import("audio.zig");
const camera = @import("camera.zig");
const gamepad = @import("gamepad.zig");
const joystick = @import("joystick.zig");
const keyboard = @import("keyboard.zig");
const keycode = @import("keycode.zig");
const mouse = @import("mouse.zig");
const pen = @import("pen.zig");
const power = @import("power.zig");
const sensor = @import("sensor.zig");
const scancode = @import("scancode.zig");
const touch = @import("touch.zig");
const video = @import("video.zig");

// General keyboard/mouse/pen state definitions

/// The types of events that can be delivered.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_EventType = enum(c_uint) {
    /// Unused (do not remove)
    first = 0,

    // Application events

    /// User-requested quit
    quit = 0x100,

    /// These application events have special meaning on iOS and Android, see
    /// README-ios.md and README-android.md for details
    ///
    /// The application is being terminated by the OS. This event must be
    /// handled in a callback set with SDL_AddEventWatch().
    /// Called on iOS in applicationWillTerminate()
    /// Called on Android in onDestroy()
    terminating = 257,
    /// The application is low on memory, free memory if possible. This event
    /// must be handled in a callback set with SDL_AddEventWatch().
    ///
    /// Called on iOS in applicationDidReceiveMemoryWarning()
    /// Called on Android in onTrimMemory()
    low_memory = 258,
    /// The application is about to enter the background. This event must be
    /// handled in a callback set with SDL_AddEventWatch().
    ///
    /// Called on iOS in applicationWillResignActive()
    /// Called on Android in onPause()
    will_enter_background = 259,
    /// The application did enter the background and may not get CPU for some
    /// time. This event must be handled in a callback set with
    /// SDL_AddEventWatch().
    ///
    /// Called on iOS in applicationDidEnterBackground()
    /// Called on Android in onPause()
    did_enter_background = 260,
    /// The application is about to enter the foreground. This event must be
    /// handled in a callback set with SDL_AddEventWatch().
    ///
    /// Called on iOS in applicationWillEnterForeground()
    /// Called on Android in onResume()
    will_enter_foreground = 261,
    /// The application is now interactive. This event must be handled in a
    /// callback set with SDL_AddEventWatch().
    /// Called on iOS in applicationDidBecomeActive()
    /// Called on Android in onResume()
    did_enter_foreground = 262,
    /// The user's locale preferences have changed.
    locale_changed = 263,
    /// The system theme changed
    system_theme_changed = 264,

    // Display events
    // 0x150 was SDL_DISPLAYEVENT, reserve the number for sdl2-compat

    /// Display orientation has changed to data1 OR display first
    display_orientation_or_display_first = 337,
    /// Display has been added to the system
    display_added = 338,
    /// Display has been removed from the system
    display_removed = 339,
    /// Display has changed position
    display_moved = 340,
    /// Display has changed desktop mode
    display_desktop_mode_changed = 341,
    /// Display has changed current mode
    display_current_mode_changed = 342,
    /// Display has changed content scale
    display_content_scale_changed = 343,
    /// Display has changed usable bounds OR display last
    display_usable_bounds_changed_or_display_last = 344,

    // Window events
    // 0x200 was SDL_WINDOWEVENT, reserve the number for sdl2-compat
    // 0x201 was SDL_SYSWMEVENT, reserve the number for sdl2-compat

    /// Window has been shown OR window first
    window_shown_or_window_first = 514,
    /// Window has been hidden
    window_hidden = 515,
    /// Window has been exposed and should be redrawn, and can be redrawn
    /// directly from event watchers for this event. data1 is 1 for live-resize
    /// expose events, 0 otherwise.
    window_exposed = 516,
    /// Window has been moved to data1, data2
    window_moved = 517,
    /// Window has been resized to data1xdata2
    window_resized = 518,
    /// The pixel size of the window has changed to data1xdata2
    window_pixel_size_changed = 519,
    /// The pixel size of a Metal view associated with the window has changed
    window_metal_view_resized = 520,
    /// Window has been minimized
    window_minimized = 521,
    /// Window has been maximized
    window_maximized = 522,
    /// Window has been restored to normal size and position
    window_restored = 523,
    /// Window has gained mouse focus
    window_mouse_enter = 524,
    /// Window has lost mouse focus
    window_mouse_leave = 525,
    /// Window has gained keyboard focus
    window_focus_gained = 526,
    /// Window has lost keyboard focus
    window_focus_lost = 527,
    /// The window manager requests that the window be closed
    window_close_requested = 528,
    /// Window had a hit test that wasn't SDL_HITTEST_NORMAL
    window_hit_test = 529,
    /// The ICC profile of the window's display has changed
    window_iccprof_changed = 530,
    /// Window has been moved to display data1
    window_display_changed = 531,
    /// Window display scale has been changed
    window_display_scale_changed = 532,
    /// The window safe area has been changed
    window_safe_area_changed = 533,
    /// The window has been occluded
    window_occluded = 534,
    /// The window has entered fullscreen mode
    window_enter_fullscreen = 535,
    /// The window has left fullscreen mode
    window_leave_fullscreen = 536,
    /// The window with the associated ID is being or has been destroyed. If
    /// this message is being handled in an event watcher, the window handle is
    /// still valid and can still be used to retrieve any properties associated
    /// with the window. Otherwise, the handle has already been destroyed and
    /// all resources associated with it are invalid
    window_destroyed = 537,
    /// Window HDR properties have changed OR window last
    window_hdr_state_changed_or_window_last = 538,

    // Keyboard events

    /// Key pressed
    key_down = 768,
    /// Key released
    key_up = 769,
    /// Keyboard text editing (composition)
    text_editing = 770,
    /// Keyboard text input
    text_input = 771,
    /// Keymap changed due to a system event such as an input language or
    /// keyboard layout change.
    keymap_changed = 772,
    /// A new keyboard has been inserted into the system
    keyboard_added = 773,
    /// A keyboard has been removed
    keyboard_removed = 774,
    /// Keyboard text editing candidates
    text_editing_candidates = 775,
    /// The on-screen keyboard has been shown
    screen_keyboard_shown = 776,
    /// The on-screen keyboard has been hidden
    screen_keyboard_hidden = 777,

    // Mouse events

    /// Mouse moved
    mouse_motion = 1024,
    /// Mouse button pressed
    mouse_button_down = 1025,
    /// Mouse button released
    mouse_button_up = 1026,
    /// Mouse wheel motion
    mouse_wheel = 1027,
    /// A new mouse has been inserted into the system
    mouse_added = 1028,
    /// A mouse has been removed
    mouse_removed = 1029,

    // Joystick events

    /// Joystick axis motion
    joystick_axis_motion = 1536,
    /// Joystick trackball motion
    joystick_ball_motion = 1537,
    /// Joystick hat position change
    joystick_hat_motion = 1538,
    /// Joystick button pressed
    joystick_button_down = 1539,
    /// Joystick button released
    joystick_button_up = 1540,
    /// A new joystick has been inserted into the system
    joystick_added = 1541,
    /// An opened joystick has been removed
    joystick_removed = 1542,
    /// Joystick battery level change
    joystick_battery_updated = 1543,
    /// Joystick update is complete
    joystick_update_complete = 1544,

    // Gamepad events

    /// Gamepad axis motion
    gamepad_axis_motion = 1616,
    /// Gamepad button pressed
    gamepad_button_down = 1617,
    /// Gamepad button released
    gamepad_button_up = 1618,
    /// A new gamepad has been inserted into the system
    gamepad_added = 1619,
    /// A gamepad has been removed
    gamepad_removed = 1620,
    /// The gamepad mapping was updated
    gamepad_remapped = 1621,
    /// Gamepad touchpad was touched
    gamepad_touchpad_down = 1622,
    /// Gamepad touchpad finger was moved
    gamepad_touchpad_motion = 1623,
    /// Gamepad touchpad finger was lifted
    gamepad_touchpad_up = 1624,
    /// Gamepad sensor was updated
    gamepad_sensor_update = 1625,
    /// Gamepad update is complete
    gamepad_update_complete = 1626,
    /// Gamepad Steam handle has changed
    gamepad_steam_handle_updated = 1627,

    // Touch events

    finger_down = 1792,
    finger_up = 1793,
    finger_motion = 1794,
    finger_canceled = 1795,

    // Pinch events

    /// Pinch gesture started
    pinch_begin = 1808,
    /// Pinch gesture updated
    pinch_update = 1809,
    /// Pinch gesture ended
    pinch_end = 1810,

    // Cliboard events

    /// The clipboard changed
    clipboard_update = 2304,

    // Drag and drop events

    /// The system requests a file open
    drop_file = 4096,
    /// text/plain drag-and-drop event
    drop_text = 4097,
    /// A new set of drops is beginning (NULL filename)
    drop_begin = 4098,
    /// Current set of drops is now complete (NULL filename)
    drop_complete = 4099,
    /// Position while moving over the window
    drop_position = 4100,

    // Audio hotplug events

    /// A new audio device is available
    audio_device_added = 4352,
    /// An audio device has been removed.
    audio_device_removed = 4353,
    /// An audio device's format has been changed by the system.
    audio_device_format_changed = 4354,

    // Sensor events

    /// A sensor was updated
    sensor_update = 4608,

    // Pressure-sensitive pen events

    /// Pressure-sensitive pen has become available
    pen_proximity_in = 4864,
    /// Pressure-sensitive pen has become unavailable
    pen_proximity_out = 4865,
    /// Pressure-sensitive pen touched drawing surface
    pen_down = 4866,
    /// Pressure-sensitive pen stopped touching drawing surface
    pen_up = 4867,
    /// Pressure-sensitive pen button pressed
    pen_button_down = 4868,
    /// Pressure-sensitive pen button released
    pen_button_up = 4869,
    /// Pressure-sensitive pen is moving on the tablet
    pen_motion = 4870,
    /// Pressure-sensitive pen angle/pressure/etc changed
    pen_axis = 4871,

    // Camera hotplug events

    /// A new camera device is available
    camera_device_added = 5120,
    /// A camera device has been removed.
    camera_device_removed = 5121,
    /// A camera device has been approved for use by the user.
    camera_device_approved = 5122,
    /// A camera device has been denied for use by the user.
    camera_device_denied = 5123,

    // Render events

    /// The render targets have been reset and their contents need to be updated
    render_targets_reset = 8192,
    /// The device has been reset and all textures need to be recreated
    render_device_reset = 8193,
    /// The device has been lost and can't be recovered.
    render_device_lost = 8194,

    // Reserved events for private platforms

    private0 = 16384,
    private1 = 16385,
    private2 = 16386,
    private3 = 16387,

    // Internal events
    /// Signals the end of an event poll cycle
    poll_sentinel = 32512,

    /// Events SDL_EVENT_USER through SDL_EVENT_LAST are for your use,
    /// and should be allocated with SDL_RegisterEvents()
    user = 0x8000,

    /// This last event is only for bounding internal arrays
    last = 0xFFFF,

    /// This just makes sure the enum is the size of Uint32
    enum_padding = 0x7FFFFFFF,
};

/// Fields shared by every event
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_CommonEvent = extern struct {
    /// Event type, shared with all events, Uint32 to cover user events which
    /// are not in the SDL_EventType enumeration
    type: u32 = 0,
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
};

/// Display state change event data (event.display.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_DisplayEvent = extern struct {
    /// SDL_EVENT_DISPLAY_*
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The associated display
    displayID: video.SDL_DisplayID = 0,
    /// event dependent data
    data1: i32 = 0,
    /// event dependent data
    data2: i32 = 0,
};

/// Window state change event data (event.window.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_WindowEvent = extern struct {
    /// SDL_EVENT_WINDOW_*
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The associated window
    windowID: video.SDL_WindowID = 0,
    /// event dependent data
    data1: i32 = 0,
    /// event dependent data
    data2: i32 = 0,
};

/// Keyboard device event structure (event.kdevice.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_KeyboardDeviceEvent = extern struct {
    /// SDL_EVENT_KEYBOARD_ADDED or SDL_EVENT_KEYBOARD_REMOVED
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The keyboard instance id
    which: keyboard.SDL_KeyboardID = 0,
};

/// Keyboard button event structure (event.key.*)
///
/// The `key` is the base SDL_Keycode generated by pressing the `scancode`
/// using the current keyboard layout, applying any options specified in
/// SDL_HINT_KEYCODE_OPTIONS. You can get the SDL_Keycode corresponding to the
/// event scancode and modifiers directly from the keyboard layout, bypassing
/// SDL_HINT_KEYCODE_OPTIONS, by calling SDL_GetKeyFromScancode().
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GetKeyFromScancode
/// \sa SDL_HINT_KEYCODE_OPTIONS
pub const SDL_KeyboardEvent = extern struct {
    /// SDL_EVENT_KEY_DOWN or SDL_EVENT_KEY_UP
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with keyboard focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The keyboard instance id, or 0 if unknown or virtual
    which: keyboard.SDL_KeyboardID = 0,
    /// SDL physical key code
    scancode: scancode.SDL_Scancode = @import("std").mem.zeroes(scancode.SDL_Scancode),
    /// SDL virtual key code
    key: keycode.SDL_Keycode = @enumFromInt(0),
    /// current key modifiers
    mod: keycode.SDL_Keymod = @enumFromInt(0),
    /// The platform dependent scancode for this event
    raw: u16 = 0,
    /// true if the key is pressed
    down: bool = false,
    /// true if this is a key repeat
    repeat: bool = false,
};

/// Keyboard text editing event structure (event.edit.*)
///
/// The start cursor is the position, in UTF-8 characters, where new typing
/// will be inserted into the editing text. The length is the number of UTF-8
/// characters that will be replaced by new typing.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_TextEditingEvent = extern struct {
    /// SDL_EVENT_TEXT_EDITING
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with keyboard focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The editing text
    text: ?[*]const u8 = null,
    /// The start cursor of selected editing text, or -1 if not set
    start: i32 = 0,
    /// The length of selected editing text, or -1 if not set
    length: i32 = 0,
};

/// Keyboard IME candidates event structure (event.edit_candidates.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_TextEditingCandidatesEvent = extern struct {
    /// SDL_EVENT_TEXT_EDITING_CANDIDATES
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with keyboard focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The list of candidates, or NULL if there are no candidates available
    candidates: ?[*]const [*:0]const u8 = null,
    /// The number of strings in `candidates`
    num_candidates: i32 = 0,
    /// The index of the selected candidate, or -1 if no candidate is selected
    selected_candidate: i32 = 0,
    /// true if the list is horizontal, false if it's vertical
    horizontal: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/// Keyboard text input event structure (event.text.*)
///
/// This event will never be delivered unless text input is enabled by calling
/// SDL_StartTextInput(). Text input is disabled by default!
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_StartTextInput
/// \sa SDL_StopTextInput
pub const SDL_TextInputEvent = extern struct {
    /// SDL_EVENT_TEXT_INPUT
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with keyboard focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The input text, UTF-8 encoded
    text: ?[*:0]const u8 = null,
};

/// Mouse device event structure (event.mdevice.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_MouseDeviceEvent = extern struct {
    /// SDL_EVENT_MOUSE_ADDED or SDL_EVENT_MOUSE_REMOVED
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The mouse instance id
    which: mouse.SDL_MouseID = 0,
};

/// Mouse motion event structure (event.motion.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_MouseMotionEvent = extern struct {
    /// SDL_EVENT_MOUSE_MOTION
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with mouse focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The mouse instance id in relative mode, SDL_TOUCH_MOUSEID for touch events, or 0
    which: mouse.SDL_MouseID = 0,
    /// The current button state
    state: mouse.SDL_MouseButtonFlags = .{},
    /// X coordinate, relative to window
    x: f32 = 0,
    /// Y coordinate, relative to window
    y: f32 = 0,
    /// The relative motion in the X direction
    xrel: f32 = 0,
    /// The relative motion in the Y direction
    yrel: f32 = 0,
};

/// Mouse button event structure (event.button.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_MouseButtonEvent = extern struct {
    /// SDL_EVENT_MOUSE_BUTTON_DOWN or SDL_EVENT_MOUSE_BUTTON_UP
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with mouse focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The mouse instance id in relative mode, SDL_TOUCH_MOUSEID for touch events, or 0
    which: mouse.SDL_MouseID = 0,
    /// The mouse button index
    button: u8 = 0,
    /// true if the button is pressed
    down: bool = false,
    /// 1 for single-click, 2 for double-click, etc.
    clicks: u8 = 0,
    padding: u8 = 0,
    /// X coordinate, relative to window
    x: f32 = 0,
    /// Y coordinate, relative to window
    y: f32 = 0,
};

/// Mouse wheel event structure (event.wheel.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_MouseWheelEvent = extern struct {
    /// SDL_EVENT_MOUSE_WHEEL
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with mouse focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The mouse instance id in relative mode or 0
    which: mouse.SDL_MouseID = 0,
    /// The amount scrolled horizontally, positive to the right and negative to the left
    x: f32 = 0,
    /// The amount scrolled vertically, positive away from the user and negative toward the user
    y: f32 = 0,
    /// Set to one of the SDL_MOUSEWHEEL_* defines. When FLIPPED the values in
    /// X and Y will be opposite. Multiply by -1 to change them back
    direction: mouse.SDL_MouseWheelDirection = @import("std").mem.zeroes(mouse.SDL_MouseWheelDirection),
    /// X coordinate, relative to window
    mouse_x: f32 = 0,
    /// Y coordinate, relative to window
    mouse_y: f32 = 0,
    /// The amount scrolled horizontally, accumulated to whole scroll "ticks" (added in 3.2.12)
    integer_x: i32 = 0,
    /// The amount scrolled vertically, accumulated to whole scroll "ticks" (added in 3.2.12)
    integer_y: i32 = 0,
};

/// Joystick axis motion event structure (event.jaxis.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_JoyAxisEvent = extern struct {
    /// SDL_EVENT_JOYSTICK_AXIS_MOTION
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The joystick axis index
    axis: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
    /// The axis value (range: -32768 to 32767)
    value: i16 = 0,
    padding4: u16 = 0,
};

/// Joystick trackball motion event structure (event.jball.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_JoyBallEvent = extern struct {
    /// SDL_EVENT_JOYSTICK_BALL_MOTION
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The joystick trackball index
    ball: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
    /// The relative motion in the X direction
    xrel: i16 = 0,
    /// The relative motion in the Y direction
    yrel: i16 = 0,
};

/// Joystick hat position change event structure (event.jhat.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_JoyHatEvent = extern struct {
    /// SDL_EVENT_JOYSTICK_HAT_MOTION
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The joystick hat index
    hat: u8 = 0,
    /// The hat position value.
    /// \sa SDL_HAT_LEFTUP SDL_HAT_UP SDL_HAT_RIGHTUP
    /// \sa SDL_HAT_LEFT SDL_HAT_CENTERED SDL_HAT_RIGHT
    /// \sa SDL_HAT_LEFTDOWN SDL_HAT_DOWN SDL_HAT_RIGHTDOWN
    ///
    /// Note that zero means the POV is centered.
    value: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

/// Joystick button event structure (event.jbutton.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_JoyButtonEvent = extern struct {
    /// SDL_EVENT_JOYSTICK_BUTTON_DOWN or SDL_EVENT_JOYSTICK_BUTTON_UP
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The joystick button index
    button: u8 = 0,
    /// true if the button is pressed
    down: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

/// Joystick device event structure (event.jdevice.*)
///
/// SDL will send JOYSTICK_ADDED events for devices that are already plugged in
/// during SDL_Init.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GamepadDeviceEvent
pub const SDL_JoyDeviceEvent = extern struct {
    /// SDL_EVENT_JOYSTICK_ADDED or SDL_EVENT_JOYSTICK_REMOVED or
    /// SDL_EVENT_JOYSTICK_UPDATE_COMPLETE
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
};

/// Joystick battery level change event structure (event.jbattery.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_JoyBatteryEvent = extern struct {
    /// SDL_EVENT_JOYSTICK_BATTERY_UPDATED
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The joystick battery state
    state: power.SDL_PowerState = @import("std").mem.zeroes(power.SDL_PowerState),
    /// The joystick battery percent charge remaining
    percent: c_int = 0,
};

/// Gamepad axis motion event structure (event.gaxis.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_GamepadAxisEvent = extern struct {
    /// SDL_EVENT_GAMEPAD_AXIS_MOTION
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The gamepad axis (SDL_GamepadAxis)
    axis: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
    /// The axis value (range: -32768 to 32767)
    value: i16 = 0,
    padding4: u16 = 0,
};

/// Gamepad button event structure (event.gbutton.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_GamepadButtonEvent = extern struct {
    /// SDL_EVENT_GAMEPAD_BUTTON_DOWN or SDL_EVENT_GAMEPAD_BUTTON_UP
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The gamepad button (SDL_GamepadButton)
    button: u8 = 0,
    /// true if the button is pressed
    down: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

/// Gamepad device event structure (event.gdevice.*)
///
/// Joysticks that are supported gamepads receive both an SDL_JoyDeviceEvent
/// and an SDL_GamepadDeviceEvent.
///
/// SDL will send GAMEPAD_ADDED events for joysticks that are already plugged
/// in during SDL_Init() and are recognized as gamepads. It will also send
/// events for joysticks that get gamepad mappings at runtime.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_JoyDeviceEvent
pub const SDL_GamepadDeviceEvent = extern struct {
    /// SDL_EVENT_GAMEPAD_ADDED, SDL_EVENT_GAMEPAD_REMOVED, or
    /// SDL_EVENT_GAMEPAD_REMAPPED, SDL_EVENT_GAMEPAD_UPDATE_COMPLETE or
    /// SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
};

/// Gamepad touchpad event structure (event.gtouchpad.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_GamepadTouchpadEvent = extern struct {
    /// SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN or SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION or
    /// SDL_EVENT_GAMEPAD_TOUCHPAD_UP
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The index of the touchpad
    touchpad: i32 = 0,
    /// The index of the finger on the touchpad
    finger: i32 = 0,
    /// Normalized in the range 0...1 with 0 being on the left
    x: f32 = 0,
    /// Normalized in the range 0...1 with 0 being at the top
    y: f32 = 0,
    /// Normalized in the range 0...1
    pressure: f32 = 0,
};

/// Gamepad sensor event structure (event.gsensor.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_GamepadSensorEvent = extern struct {
    /// SDL_EVENT_GAMEPAD_SENSOR_UPDATE
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The joystick instance id
    which: joystick.SDL_JoystickID = 0,
    /// The type of the sensor, one of the values of SDL_SensorType
    sensor: i32 = 0,
    /// Up to 3 values from the sensor, as defined in SDL_sensor.h
    data: [3]f32 = @import("std").mem.zeroes([3]f32),
    /// The timestamp of the sensor reading in nanoseconds, not necessarily
    /// synchronized with the system clock
    sensor_timestamp: u64 = 0,
};

/// Audio device event structure (event.adevice.*)
///
/// Note that SDL will send a SDL_EVENT_AUDIO_DEVICE_ADDED event for every
/// device it discovers during initialization. After that, this event will only
/// arrive when a device is hotplugged during the program's run.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_AudioDeviceEvent = extern struct {
    /// SDL_EVENT_AUDIO_DEVICE_ADDED, or SDL_EVENT_AUDIO_DEVICE_REMOVED, or
    /// SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// SDL_AudioDeviceID for the device being added or removed or changing
    which: audio.SDL_AudioDeviceID = 0,
    /// false if a playback device, true if a recording device.
    recording: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/// Camera device event structure (event.cdevice.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_CameraDeviceEvent = extern struct {
    /// SDL_EVENT_CAMERA_DEVICE_ADDED, SDL_EVENT_CAMERA_DEVICE_REMOVED,
    /// SDL_EVENT_CAMERA_DEVICE_APPROVED, SDL_EVENT_CAMERA_DEVICE_DENIED
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// SDL_CameraID for the device being added or removed or changing
    which: camera.SDL_CameraID = 0,
};

/// Renderer event structure (event.render.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_RenderEvent = extern struct {
    /// SDL_EVENT_RENDER_TARGETS_RESET, SDL_EVENT_RENDER_DEVICE_RESET,
    /// SDL_EVENT_RENDER_DEVICE_LOST
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window containing the renderer in question.
    windowID: video.SDL_WindowID = 0,
};

/// Touch finger event structure (event.tfinger.*)
///
/// Coordinates in this event are normalized. `x` and `y` are normalized to a
/// range between 0.0f and 1.0f, relative to the window, so (0,0) is the top
/// left and (1,1) is the bottom right. Delta coordinates `dx` and `dy` are
/// normalized in the ranges of -1.0f (traversed all the way from the bottom or
/// right to all the way up or left) to 1.0f (traversed all the way from the
/// top or left to all the way down or right).
///
/// Note that while the coordinates are _normalized_, they are not _clamped_,
/// which means in some circumstances you can get a value outside of this
/// range. For example, a renderer using logical presentation might give a
/// negative value when the touch is in the letterboxing. Some platforms might
/// report a touch outside of the window, which will also be outside of the
/// range.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_TouchFingerEvent = extern struct {
    /// SDL_EVENT_FINGER_DOWN, SDL_EVENT_FINGER_UP, SDL_EVENT_FINGER_MOTION, or
    /// SDL_EVENT_FINGER_CANCELED
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The touch device id
    touchID: touch.SDL_TouchID = 0,
    fingerID: touch.SDL_FingerID = 0,
    /// Normalized in the range 0...1
    x: f32 = 0,
    /// Normalized in the range 0...1
    y: f32 = 0,
    /// Normalized in the range -1...1
    dx: f32 = 0,
    /// Normalized in the range -1...1
    dy: f32 = 0,
    /// Normalized in the range 0...1
    pressure: f32 = 0,
    /// The window underneath the finger, if any
    windowID: video.SDL_WindowID = 0,
};

/// Pinch event structure (event.pinch.*)
pub const SDL_PinchFingerEvent = extern struct {
    /// ::SDL_EVENT_PINCH_BEGIN or ::SDL_EVENT_PINCH_UPDATE or ::SDL_EVENT_PINCH_END
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The scale change since the last SDL_EVENT_PINCH_UPDATE. Scale < 1 is
    /// "zoom out". Scale > 1 is "zoom in".
    scale: f32 = 0,
    /// The window underneath the finger, if any
    windowID: video.SDL_WindowID = 0,
};

/// Pressure-sensitive pen proximity event structure (event.pproximity.*)
///
/// When a pen becomes visible to the system (it is close enough to a tablet,
/// etc), SDL will send an SDL_EVENT_PEN_PROXIMITY_IN event with the new pen's
/// ID. This ID is valid until the pen leaves proximity again (has been removed
/// from the tablet's area, the tablet has been unplugged, etc). If the same
/// pen reenters proximity again, it will be given a new ID.
///
/// Note that "proximity" means "close enough for the tablet to know the tool
/// is there." The pen touching and lifting off from the tablet while not
/// leaving the area are handled by SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP.
///
/// Not all platforms have a window associated with the pen during proximity
/// events. Some wait until motion/button/etc events to offer this info.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_PenProximityEvent = extern struct {
    /// SDL_EVENT_PEN_PROXIMITY_IN or SDL_EVENT_PEN_PROXIMITY_OUT
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with pen focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The pen instance id
    which: pen.SDL_PenID = 0,
};

/// Pressure-sensitive pen motion event structure (event.pmotion.*)
///
/// Depending on the hardware, you may get motion events when the pen is not
/// touching a tablet, for tracking a pen even when it isn't drawing. You
/// should listen for SDL_EVENT_PEN_DOWN and SDL_EVENT_PEN_UP events, or check
/// `pen_state & SDL_PEN_INPUT_DOWN` to decide if a pen is "drawing" when
/// dealing with pen motion.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_PenMotionEvent = extern struct {
    /// SDL_EVENT_PEN_MOTION
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with pen focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The pen instance id
    which: pen.SDL_PenID = 0,
    /// Complete pen input state at time of event
    pen_state: pen.SDL_PenInputFlags = .{},
    /// X coordinate, relative to window
    x: f32 = 0,
    /// Y coordinate, relative to window
    y: f32 = 0,
};

/// Pressure-sensitive pen touched event structure (event.ptouch.*)
///
/// These events come when a pen touches a surface (a tablet, etc), or lifts
/// off from one.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_PenTouchEvent = extern struct {
    /// SDL_EVENT_PEN_DOWN or SDL_EVENT_PEN_UP
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with pen focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The pen instance id
    which: pen.SDL_PenID = 0,
    /// Complete pen input state at time of event
    pen_state: pen.SDL_PenInputFlags = .{},
    /// X coordinate, relative to window
    x: f32 = 0,
    /// Y coordinate, relative to window
    y: f32 = 0,
    /// true if eraser end is used (not all pens support this).
    eraser: bool = false,
    /// true if the pen is touching or false if the pen is lifted off
    down: bool = false,
};

/// Pressure-sensitive pen button event structure (event.pbutton.*)
///
/// This is for buttons on the pen itself that the user might click. The pen
/// itself pressing down to draw triggers a SDL_EVENT_PEN_DOWN event instead.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_PenButtonEvent = extern struct {
    /// SDL_EVENT_PEN_BUTTON_DOWN or SDL_EVENT_PEN_BUTTON_UP
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with mouse focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The pen instance id
    which: pen.SDL_PenID = 0,
    /// Complete pen input state at time of event
    pen_state: pen.SDL_PenInputFlags = .{},
    /// X coordinate, relative to window
    x: f32 = 0,
    /// Y coordinate, relative to window
    y: f32 = 0,
    /// The pen button index (first button is 1).
    button: u8 = 0,
    /// true if the button is pressed
    down: bool = false,
};

/// Pressure-sensitive pen pressure / angle event structure (event.paxis.*)
///
/// You might get some of these events even if the pen isn't touching the
/// tablet.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_PenAxisEvent = extern struct {
    /// SDL_EVENT_PEN_AXIS
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window with pen focus, if any
    windowID: video.SDL_WindowID = 0,
    /// The pen instance id
    which: pen.SDL_PenID = 0,
    /// Complete pen input state at time of event
    pen_state: pen.SDL_PenInputFlags = .{},
    /// X coordinate, relative to window
    x: f32 = 0,
    /// Y coordinate, relative to window
    y: f32 = 0,
    /// Axis that has changed
    axis: pen.SDL_PenAxis = @import("std").mem.zeroes(pen.SDL_PenAxis),
    /// New value of axis
    value: f32 = 0,
};

/// An event used to drop text or request a file open by the system
/// (event.drop.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_DropEvent = extern struct {
    /// SDL_EVENT_DROP_BEGIN or SDL_EVENT_DROP_FILE or SDL_EVENT_DROP_TEXT or
    /// SDL_EVENT_DROP_COMPLETE or SDL_EVENT_DROP_POSITION
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The window that was dropped on, if any
    windowID: video.SDL_WindowID = 0,
    /// X coordinate, relative to window (not on begin)
    x: f32 = 0,
    /// Y coordinate, relative to window (not on begin)
    y: f32 = 0,
    /// The source app that sent this drop event, or NULL if that isn't available
    source: ?[*:0]const u8 = null,
    /// The text for SDL_EVENT_DROP_TEXT and the file name for
    /// SDL_EVENT_DROP_FILE, NULL for other events
    data: ?[*:0]const u8 = null,
};

/// An event triggered when the clipboard contents have changed
/// (event.clipboard.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_ClipboardEvent = extern struct {
    /// SDL_EVENT_CLIPBOARD_UPDATE
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// are we owning the clipboard (internal update)
    owner: bool = false,
    /// number of mime types
    num_mime_types: i32 = 0,
    /// current mime types
    mime_types: ?[*][*:0]const u8 = null,
};

/// Sensor event structure (event.sensor.*)
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_SensorEvent = extern struct {
    /// SDL_EVENT_SENSOR_UPDATE
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The instance ID of the sensor
    which: sensor.SDL_SensorID = 0,
    /// Up to 6 values from the sensor - additional values can be queried using SDL_GetSensorData()
    data: [6]f32 = @import("std").mem.zeroes([6]f32),
    /// The timestamp of the sensor reading in nanoseconds, not necessarily
    /// synchronized with the system clock
    sensor_timestamp: u64 = 0,
};

/// The "quit requested" event
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_QuitEvent = extern struct {
    /// SDL_EVENT_QUIT
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
};

/// A user-defined event type (event.user.*)
///
/// This event is unique; it is never created by SDL, but only by the
/// application. The event can be pushed onto the event queue using
/// SDL_PushEvent(). The contents of the structure members are completely up to
/// the programmer; the only requirement is that '''type''' is a value obtained
/// from SDL_RegisterEvents().
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_UserEvent = extern struct {
    /// SDL_EVENT_USER through SDL_EVENT_LAST, Uint32 because these are not in
    /// the SDL_EventType enumeration
    type: u32 = 0,
    reserved: u32 = 0,
    /// In nanoseconds, populated using SDL_GetTicksNS()
    timestamp: u64 = 0,
    /// The associated window if any
    windowID: video.SDL_WindowID = 0,
    /// User defined event code
    code: i32 = 0,
    /// User defined data pointer
    data1: ?*anyopaque = null,
    /// User defined data pointer
    data2: ?*anyopaque = null,
};

/// The structure for all events in SDL.
///
/// The SDL_Event structure is the core of all event handling in SDL. SDL_Event
/// is a union of all event structures used in SDL.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_Event = extern union {
    /// Event type, shared with all events, Uint32 to cover user events which
    /// are not in the SDL_EventType enumeration
    event_type: SDL_EventType,
    /// Common event data
    common: SDL_CommonEvent,
    /// Display event data
    display: SDL_DisplayEvent,
    /// Window event data
    window: SDL_WindowEvent,
    /// Keyboard device change event data
    kdevice: SDL_KeyboardDeviceEvent,
    /// Keyboard event data
    key: SDL_KeyboardEvent,
    /// Text editing event data
    edit: SDL_TextEditingEvent,
    /// Text editing candidates event data
    edit_candidates: SDL_TextEditingCandidatesEvent,
    /// Text input event data
    text: SDL_TextInputEvent,
    /// Mouse device change event data
    mouse_device: SDL_MouseDeviceEvent,
    /// Mouse motion event data
    mouse_motion: SDL_MouseMotionEvent,
    /// Mouse button event data
    mouse_button: SDL_MouseButtonEvent,
    /// Mouse wheel event data
    mouse_wheel: SDL_MouseWheelEvent,
    /// Joystick device change event data
    joy_device: SDL_JoyDeviceEvent,
    /// Joystick axis event data
    joy_axis: SDL_JoyAxisEvent,
    /// Joystick ball event data
    joy_ball: SDL_JoyBallEvent,
    /// Joystick hat event data
    joy_hat: SDL_JoyHatEvent,
    /// Joystick button event data
    joy_button: SDL_JoyButtonEvent,
    /// Joystick battery event data
    joy_battery: SDL_JoyBatteryEvent,
    /// Gamepad device event data
    gamepad_device: SDL_GamepadDeviceEvent,
    /// Gamepad axis event data
    gamepad_axis: SDL_GamepadAxisEvent,
    /// Gamepad button event data
    gamepad_button: SDL_GamepadButtonEvent,
    /// Gamepad touchpad eventdata
    gamepad_touchpad: SDL_GamepadTouchpadEvent,
    /// Gamepad sensor event data
    gamepad_sensor: SDL_GamepadSensorEvent,
    /// Audio device event data
    audio_device: SDL_AudioDeviceEvent,
    /// Camera device event data
    camera_device: SDL_CameraDeviceEvent,
    /// Sensor event data
    sensor: SDL_SensorEvent,
    /// Quit request event data
    quit: SDL_QuitEvent,
    /// Custom event data
    user: SDL_UserEvent,
    /// Touch finger event data
    touch_finger: SDL_TouchFingerEvent,
    /// Pinch event data
    pinch: SDL_PinchFingerEvent,
    /// Pen proximity event data
    pen_proximity: SDL_PenProximityEvent,
    /// Pen tip touching event data
    pen_touch: SDL_PenTouchEvent,
    /// Pen motion event data
    pen_motion: SDL_PenMotionEvent,
    /// Pen button event data
    pen_button: SDL_PenButtonEvent,
    /// Pen axis event data
    pen_axis: SDL_PenAxisEvent,
    /// Render event data
    render: SDL_RenderEvent,
    /// Drag and drop event data
    drop: SDL_DropEvent,
    /// Clipboard event data
    clipboard: SDL_ClipboardEvent,

    /// This is necessary for ABI compatibility between Visual C++ and GCC.
    /// Visual C++ will respect the push pack pragma and use 52 bytes (size of
    /// SDL_TextEditingEvent, the largest structure for 32-bit and 64-bit
    /// architectures) for this union, and GCC will use the alignment of the
    /// largest datatype within the union, which is 8 bytes on 64-bit
    /// architectures.
    ///
    /// So... we'll add padding to force the size to be the same for both.
    ///
    /// On architectures where pointers are 16 bytes, this needs rounding up to
    /// the next multiple of 16, 64, and on architectures where pointers are
    /// even larger the size of SDL_UserEvent will dominate as being 3 pointers.
    padding: [128]u8,
};

/////////////////////////////
// Function prototypes
/////////////////////////////

/// Pump the event loop, gathering events from the input devices.
///
/// This function updates the event queue and internal input device state.
///
/// SDL_PumpEvents() gathers all the pending input information from devices and
/// places it in the event queue. Without calls to SDL_PumpEvents() no events
/// would ever be placed on the queue. Often the need for calls to
/// SDL_PumpEvents() is hidden from the user since SDL_PollEvent() and
/// SDL_WaitEvent() implicitly call SDL_PumpEvents(). However, if you are not
/// polling or waiting for events (e.g. you are filtering them), then you must
/// call SDL_PumpEvents() to force an event queue update.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PollEvent
/// \sa SDL_WaitEvent
pub extern fn SDL_PumpEvents() void;

/// The type of action to request from SDL_PeepEvents().
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_EventAction = enum(c_uint) {
    /// Add events to the back of the queue.
    addevent,
    /// Check but don't remove events from the queue front.
    peekevent,
    /// Retrieve/remove events from the front of the queue.
    getevent,
};

/// Check the event queue for messages and optionally return them.
///
/// `action` may be any of the following:
///
/// - `SDL_ADDEVENT`: up to `numevents` events will be added to the back of the
///   event queue.
/// - `SDL_PEEKEVENT`: `numevents` events at the front of the event queue,
///   within the specified minimum and maximum type, will be returned to the
///   caller and will _not_ be removed from the queue. If you pass NULL for
///   `events`, then `numevents` is ignored and the total number of matching
///   events will be returned.
/// - `SDL_GETEVENT`: up to `numevents` events at the front of the event queue,
///   within the specified minimum and maximum type, will be returned to the
///   caller and will be removed from the queue.
///
/// You may have to call SDL_PumpEvents() before calling this function.
/// Otherwise, the events may not be ready to be filtered when you call
/// SDL_PeepEvents().
///
/// \param events destination buffer for the retrieved events, may be NULL to
///               leave the events in the queue and return the number of events
///               that would have been stored.
/// \param numevents if action is SDL_ADDEVENT, the number of events to add
///                  back to the event queue; if action is SDL_PEEKEVENT or
///                  SDL_GETEVENT, the maximum number of events to retrieve.
/// \param action action to take; see [Remarks](#remarks) for details.
/// \param minType minimum value of the event type to be considered;
///                SDL_EVENT_FIRST is a safe choice.
/// \param maxType maximum value of the event type to be considered;
///                SDL_EVENT_LAST is a safe choice.
/// \returns the number of events actually stored or -1 on failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PollEvent
/// \sa SDL_PumpEvents
/// \sa SDL_PushEvent
pub extern fn SDL_PeepEvents(
    events: ?*SDL_Event,
    numevents: c_int,
    action: SDL_EventAction,
    minType: u32,
    maxType: u32,
) c_int;

/// Check for the existence of a certain event type in the event queue.
///
/// If you need to check for a range of event types, use SDL_HasEvents()
/// instead.
///
/// \param type the type of event to be queried; see SDL_EventType for details.
/// \returns true if events matching `type` are present, or false if events
///          matching `type` are not present.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_HasEvents
pub extern fn SDL_HasEvent(eventType: u32) bool;

/// Check for the existence of certain event types in the event queue.
///
/// If you need to check for a single event type, use SDL_HasEvent() instead.
///
/// \param minType the low end of event type to be queried, inclusive; see
///                SDL_EventType for details.
/// \param maxType the high end of event type to be queried, inclusive; see
///                SDL_EventType for details.
/// \returns true if events with type >= `minType` and <= `maxType` are
///          present, or false if not.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_HasEvents
pub extern fn SDL_HasEvents(minType: u32, maxType: u32) bool;

/// Clear events of a specific type from the event queue.
///
/// This will unconditionally remove any events from the queue that match
/// `type`. If you need to remove a range of event types, use SDL_FlushEvents()
/// instead.
///
/// It's also normal to just ignore events you don't care about in your event
/// loop without calling this function.
///
/// This function only affects currently queued events. If you want to make
/// sure that all pending OS events are flushed, you can call SDL_PumpEvents()
/// on the main thread immediately before the flush call.
///
/// If you have user events with custom data that needs to be freed, you should
/// use SDL_PeepEvents() to remove and clean up those events before calling
/// this function.
///
/// \param type the type of event to be cleared; see SDL_EventType for details.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_FlushEvents
pub extern fn SDL_FlushEvent(eventType: u32) void;

/// Clear events of a range of types from the event queue.
///
/// This will unconditionally remove any events from the queue that are in the
/// range of `minType` to `maxType`, inclusive. If you need to remove a single
/// event type, use SDL_FlushEvent() instead.
///
/// It's also normal to just ignore events you don't care about in your event
/// loop without calling this function.
///
/// This function only affects currently queued events. If you want to make
/// sure that all pending OS events are flushed, you can call SDL_PumpEvents()
/// on the main thread immediately before the flush call.
///
/// \param minType the low end of event type to be cleared, inclusive; see
///                SDL_EventType for details.
/// \param maxType the high end of event type to be cleared, inclusive; see
///                SDL_EventType for details.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_FlushEvent
pub extern fn SDL_FlushEvents(minType: u32, maxType: u32) void;

/// Poll for currently pending events.
///
/// If `event` is not NULL, the next event is removed from the queue and stored
/// in the SDL_Event structure pointed to by `event`.
///
/// If `event` is NULL, it simply returns true if there is an event in the
/// queue, but will not remove it from the queue.
///
/// As this function may implicitly call SDL_PumpEvents(), you can only call
/// this function in the thread that initialized the video subsystem.
///
/// SDL_PollEvent() is the favored way of receiving system events since it can
/// be done from the main loop and does not suspend the main loop while waiting
/// on an event to be posted.
///
/// The common practice is to fully process the event queue once every frame,
/// usually as a first step before updating the game's state:
///
/// ```c
/// while (game_is_still_running) {
///     SDL_Event event;
///     while (SDL_PollEvent(&event)) {  // poll until all events are handled!
///         // decide what to do with this event.
///     }
///
///     // update game state, draw the current frame
/// }
/// ```
///
/// Note that Windows (and possibly other platforms) has a quirk about how it
/// handles events while dragging/resizing a window, which can cause this
/// function to block for significant amounts of time. Technical explanations
/// and solutions are discussed on the wiki:
///
/// https://wiki.libsdl.org/SDL3/AppFreezeDuringDrag
///
/// \param event the SDL_Event structure to be filled with the next event from
///              the queue, or NULL.
/// \returns true if this got an event or false if there are none available.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PushEvent
/// \sa SDL_WaitEvent
/// \sa SDL_WaitEventTimeout
pub extern fn SDL_PollEvent(event: ?*SDL_Event) bool;

/// Wait indefinitely for the next available event.
///
/// If `event` is not NULL, the next event is removed from the queue and stored
/// in the SDL_Event structure pointed to by `event`.
///
/// As this function may implicitly call SDL_PumpEvents(), you can only call
/// this function in the thread that initialized the video subsystem.
///
/// \param event the SDL_Event structure to be filled in with the next event
///              from the queue, or NULL.
/// \returns true on success or false if there was an error while waiting for
///          events; call SDL_GetError() for more information.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PollEvent
/// \sa SDL_PushEvent
/// \sa SDL_WaitEventTimeout
pub extern fn SDL_WaitEvent(event: ?*SDL_Event) bool;

/// Wait until the specified timeout (in milliseconds) for the next available
/// event.
///
/// If `event` is not NULL, the next event is removed from the queue and stored
/// in the SDL_Event structure pointed to by `event`.
///
/// As this function may implicitly call SDL_PumpEvents(), you can only call
/// this function in the thread that initialized the video subsystem.
///
/// The timeout is not guaranteed, the actual wait time could be longer due to
/// system scheduling.
///
/// \param event the SDL_Event structure to be filled in with the next event
///              from the queue, or NULL.
/// \param timeoutMS the maximum number of milliseconds to wait for the next
///                  available event.
/// \returns true if this got an event or false if the timeout elapsed without
///          any events available.
///
/// \threadsafety This function should only be called on the main thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PollEvent
/// \sa SDL_PushEvent
/// \sa SDL_WaitEvent
pub extern fn SDL_WaitEventTimeout(event: *SDL_Event, timeoutMS: i32) bool;

/// Add an event to the event queue.
///
/// The event queue can actually be used as a two way communication channel.
/// Not only can events be read from the queue, but the user can also push
/// their own events onto it. `event` is a pointer to the event structure you
/// wish to push onto the queue. The event is copied into the queue, and the
/// caller may dispose of the memory pointed to after SDL_PushEvent() returns.
///
/// Note: Pushing device input events onto the queue doesn't modify the state
/// of the device within SDL.
///
/// Note: Events pushed onto the queue with SDL_PushEvent() get passed through
/// the event filter but events added with SDL_PeepEvents() do not.
///
/// For pushing application-specific events, please use SDL_RegisterEvents() to
/// get an event type that does not conflict with other code that also wants
/// its own custom event types.
///
/// \param event the SDL_Event to be added to the queue.
/// \returns true on success, false if the event was filtered or on failure;
///          call SDL_GetError() for more information. A common reason for
///          error is the event queue being full.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PeepEvents
/// \sa SDL_PollEvent
/// \sa SDL_RegisterEvents
pub extern fn SDL_PushEvent(event: *SDL_Event) bool;

/// A function pointer used for callbacks that watch the event queue.
///
/// \param userdata what was passed as `userdata` to SDL_SetEventFilter() or
///                 SDL_AddEventWatch, etc.
/// \param event the event that triggered the callback.
/// \returns true to permit event to be added to the queue, and false to
///          disallow it. When used with SDL_AddEventWatch, the return value is
///          ignored.
///
/// \threadsafety SDL may call this callback at any time from any thread; the
///               application is responsible for locking resources the callback
///               touches that need to be protected.
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_SetEventFilter
/// \sa SDL_AddEventWatch
// typedef bool (SDLCALL *SDL_EventFilter)(void *userdata, SDL_Event *event);
pub const SDL_EventFilter = *const fn (userdata: *anyopaque, event: *SDL_Event) bool;

/// Set up a filter to process all events before they are added to the internal
/// event queue.
///
/// If you just want to see events without modifying them or preventing them
/// from being queued, you should use SDL_AddEventWatch() instead.
///
/// If the filter function returns true when called, then the event will be
/// added to the internal queue. If it returns false, then the event will be
/// dropped from the queue, but the internal state will still be updated. This
/// allows selective filtering of dynamically arriving events.
///
/// **WARNING**: Be very careful of what you do in the event filter function,
/// as it may run in a different thread! The exception is handling of
/// SDL_EVENT_WINDOW_EXPOSED, which is guaranteed to be sent from the OS on the
/// main thread and you are expected to redraw your window in response to this
/// event.
///
/// On platforms that support it, if the quit event is generated by an
/// interrupt signal (e.g. pressing Ctrl-C), it will be delivered to the
/// application at the next event poll.
///
/// Note: Disabled events never make it to the event filter function; see
/// SDL_SetEventEnabled().
///
/// Note: Events pushed onto the queue with SDL_PushEvent() get passed through
/// the event filter, but events pushed onto the queue with SDL_PeepEvents() do
/// not.
///
/// \param filter a function to call when an event happens.
/// \param userdata a pointer that is passed to `filter`.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_AddEventWatch
/// \sa SDL_SetEventEnabled
/// \sa SDL_GetEventFilter
/// \sa SDL_PeepEvents
/// \sa SDL_PushEvent
pub extern fn SDL_SetEventFilter(filter: SDL_EventFilter, userdata: *anyopaque) void;

/// Query the current event filter.
///
/// This function can be used to "chain" filters, by saving the existing filter
/// before replacing it with a function that will call that saved filter.
///
/// \param filter the current callback function will be stored here.
/// \param userdata the pointer that is passed to the current event filter will
///                 be stored here.
/// \returns true on success or false if there is no event filter set.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SetEventFilter
pub extern fn SDL_GetEventFilter(filter: *SDL_EventFilter, userdata: **anyopaque) bool;

/// Add a callback to be triggered when an event is added to the event queue.
///
/// `filter` will be called when an event happens, and its return value is
/// ignored.
///
/// **WARNING**: Be very careful of what you do in the event filter function,
/// as it may run in a different thread!
///
/// If the quit event is generated by a signal (e.g. SIGINT), it will bypass
/// the internal queue and be delivered to the watch callback immediately, and
/// arrive at the next event poll.
///
/// Note: the callback is called for events posted by the user through
/// SDL_PushEvent(), but not for disabled events, nor for events by a filter
/// callback set with SDL_SetEventFilter(), nor for events posted by the user
/// through SDL_PeepEvents().
///
/// \param filter an SDL_EventFilter function to call when an event happens.
/// \param userdata a pointer that is passed to `filter`.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_RemoveEventWatch
/// \sa SDL_SetEventFilter
pub extern fn SDL_AddEventWatch(filter: SDL_EventFilter, userdata: *anyopaque) bool;

/// Remove an event watch callback added with SDL_AddEventWatch().
///
/// This function takes the same input as SDL_AddEventWatch() to identify and
/// delete the corresponding callback.
///
/// \param filter the function originally passed to SDL_AddEventWatch().
/// \param userdata the pointer originally passed to SDL_AddEventWatch().
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_AddEventWatch
pub extern fn SDL_RemoveEventWatch(filter: SDL_EventFilter, userdata: *anyopaque) void;

/// Run a specific filter function on the current event queue, removing any
/// events for which the filter returns false.
///
/// See SDL_SetEventFilter() for more information. Unlike SDL_SetEventFilter(),
/// this function does not change the filter permanently, it only uses the
/// supplied filter until this function returns.
///
/// \param filter the SDL_EventFilter function to call when an event happens.
/// \param userdata a pointer that is passed to `filter`.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GetEventFilter
/// \sa SDL_SetEventFilter
pub extern fn SDL_FilterEvents(filter: SDL_EventFilter, userdata: *anyopaque) void;

/// Set the state of processing events by type.
///
/// \param type the type of event; see SDL_EventType for details.
/// \param enabled whether to process the event or not.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_EventEnabled
pub extern fn SDL_SetEventEnabled(eventType: u32, enabled: bool) void;

/// Query the state of processing events by type.
///
/// \param type the type of event; see SDL_EventType for details.
/// \returns true if the event is being processed, false otherwise.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SetEventEnabled
pub extern fn SDL_EventEnabled(eventType: u32) bool;

/// Allocate a set of user-defined events, and return the beginning event
/// number for that set of events.
///
/// \param numevents the number of events to be allocated.
/// \returns the beginning event number, or 0 if numevents is invalid or if
///          there are not enough user-defined events left.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PushEvent
pub extern fn SDL_RegisterEvents(numevents: c_int) u32;

/// Get window associated with an event.
///
/// \param event an event containing a `windowID`.
/// \returns the associated window on success or NULL if there is none.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PollEvent
/// \sa SDL_WaitEvent
/// \sa SDL_WaitEventTimeout
pub extern fn SDL_GetWindowFromEvent(event: *const SDL_Event) ?*video.SDL_Window;

/// Generate an English description of an event.
///
/// This will fill `buf` with a null-terminated string that might look
/// something like this:
///
/// ```
/// SDL_EVENT_MOUSE_MOTION (
///     timestamp=1140256324 windowid=2 which=0 state=0 x=492.99 y=139.09 xrel=52 yrel=6
/// )
/// ```
///
/// The exact format of the string is not guaranteed; it is intended for
/// logging purposes, to be read by a human, and not parsed by a computer.
///
/// The returned value follows the same rules as SDL_snprintf(): `buf` will
/// always be NULL-terminated (unless `buflen` is zero), and will be truncated
/// if `buflen` is too small. The return code is the number of bytes needed for
/// the complete string, not counting the NULL-terminator, whether the string
/// was truncated or not. Unlike SDL_snprintf(), though, this function never
/// returns -1.
///
/// \param event an event to describe. May be NULL.
/// \param buf the buffer to fill with the description string. May be NULL.
/// \param buflen the maximum bytes that can be written to `buf`.
/// \returns number of bytes needed for the full string, not counting the
///          null-terminator byte.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.4.0.
pub extern fn SDL_GetEventDescription(event: ?*const SDL_Event, buf: ?[*:0]u8, buflen: c_int) c_int;
