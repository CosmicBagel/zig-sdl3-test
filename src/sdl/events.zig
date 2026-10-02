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

    low_memory = 258,
    will_enter_background = 259,
    did_enter_background = 260,
    will_enter_foreground = 261,
    did_enter_foreground = 262,
    locale_changed = 263,
    system_theme_changed = 264,

    // Display events

    display_orientation_or_display_first = 337,
    display_added = 338,
    display_removed = 339,
    display_moved = 340,
    display_desktop_mode_changed = 341,
    display_current_mode_changed = 342,
    display_content_scale_changed = 343,
    display_usable_bounds_changed_or_display_last = 344,

    // Window events

    window_shown_or_window_first = 514,
    window_hidden = 515,
    window_exposed = 516,
    window_moved = 517,
    window_resized = 518,
    window_pixel_size_changed = 519,
    window_metal_view_resized = 520,
    window_minimized = 521,
    window_maximized = 522,
    window_restored = 523,
    window_mouse_enter = 524,
    window_mouse_leave = 525,
    window_focus_gained = 526,
    window_focus_lost = 527,
    window_close_requested = 528,
    window_hit_test = 529,
    window_iccprof_changed = 530,
    window_display_changed = 531,
    window_display_scale_changed = 532,
    window_safe_area_changed = 533,
    window_occluded = 534,
    window_enter_fullscreen = 535,
    window_leave_fullscreen = 536,
    window_destroyed = 537,
    window_hdr_state_changed_or_window_last = 538,

    // Keyboard events

    key_down = 768,
    key_up = 769,
    text_editing = 770,
    text_input = 771,
    keymap_changed = 772,

    keyboard_added = 773,
    keyboard_removed = 774,
    text_editing_candidates = 775,
    screen_keyboard_shown = 776,
    screen_keyboard_hidden = 777,

    // Mouse events

    mouse_motion = 1024,
    mouse_button_down = 1025,
    mouse_button_up = 1026,
    mouse_wheel = 1027,
    mouse_added = 1028,
    mouse_removed = 1029,

    // Joystick events

    joystick_axis_motion = 1536,
    joystick_ball_motion = 1537,
    joystick_hat_motion = 1538,
    joystick_button_down = 1539,
    joystick_button_up = 1540,
    joystick_added = 1541,
    joystick_removed = 1542,
    joystick_battery_updated = 1543,
    joystick_update_complete = 1544,

    // Gamepad events

    gamepad_axis_motion = 1616,
    gamepad_button_down = 1617,
    gamepad_button_up = 1618,
    gamepad_added = 1619,
    gamepad_removed = 1620,
    gamepad_remapped = 1621,
    gamepad_touchpad_down = 1622,
    gamepad_touchpad_motion = 1623,
    gamepad_touchpad_up = 1624,
    gamepad_sensor_update = 1625,
    gamepad_update_complete = 1626,
    gamepad_steam_handle_updated = 1627,

    // Touch events

    finger_down = 1792,
    finger_up = 1793,
    finger_motion = 1794,
    finger_canceled = 1795,

    // Pinch events
    
    pinch_begin = 1808,
    pinch_update = 1809,
    pinch_end = 1810,

    // Cliboard events

    clipboard_update = 2304,

    // Drag and drop events

    drop_file = 4096,
    drop_text = 4097,
    drop_begin = 4098,
    drop_complete = 4099,
    drop_position = 4100,

    // Audio hotplug events

    audio_device_added = 4352,
    audio_device_removed = 4353,
    audio_device_format_changed = 4354,

    // Sensor events

    sensor_update = 4608,

    // Pressure-sensitive pen events

    pen_proximity_in = 4864,
    pen_proximity_out = 4865,
    pen_down = 4866,
    pen_up = 4867,
    pen_button_down = 4868,
    pen_button_up = 4869,
    pen_motion = 4870,
    pen_axis = 4871,

    // Camera hotplug events

    camera_device_added = 5120,
    camera_device_removed = 5121,
    camera_device_approved = 5122,
    camera_device_denied = 5123,

    // Render events

    render_targets_reset = 8192,
    render_device_reset = 8193,
    render_device_lost = 8194,

    // Reserved events for private platforms

    private0 = 16384,
    private1 = 16385,
    private2 = 16386,
    private3 = 16387,

    // Internal events
    poll_sentinel = 32512,

    /// Events SDL_EVENT_USER through SDL_EVENT_LAST are for your use,
    /// and should be allocated with SDL_RegisterEvents()
    user = 0x8000,

    /// This last event is only for bounding internal arrays
    ///
    last = 0xFFFF,

    /// This just makes sure the enum is the size of Uint32 
    enum_padding = 0x7FFFFFFF,
};


pub const SDL_CommonEvent = extern struct {
    type: u32 = 0,
    reserved: u32 = 0,
    timestamp: u64 = 0,
};

pub const SDL_DisplayEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    displayID: video.SDL_DisplayID = 0,
    data1: i32 = 0,
    data2: i32 = 0,
};

pub const SDL_WindowEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    data1: i32 = 0,
    data2: i32 = 0,
};

pub const SDL_KeyboardDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: video.SDL_KeyboardID = 0,
};

pub const SDL_KeyboardEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: keyboard.SDL_KeyboardID = 0,
    scancode: scancode.SDL_Scancode = @import("std").mem.zeroes(scancode.SDL_Scancode),
    key: keycode.SDL_Keycode = 0,
    mod: keycode.SDL_Keymod = 0,
    raw: u16 = 0,
    down: bool = false,
    repeat: bool = false,
};

pub const SDL_TextEditingEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    text: [*c]const u8 = null,
    start: i32 = 0,
    length: i32 = 0,
};

pub const SDL_TextEditingCandidatesEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    candidates: [*c]const [*c]const u8 = null,
    num_candidates: i32 = 0,
    selected_candidate: i32 = 0,
    horizontal: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_TextInputEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    text: [*c]const u8 = null,
};

pub const SDL_MouseDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: mouse.SDL_MouseID = 0,
};

pub const SDL_MouseMotionEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: mouse.SDL_MouseID = 0,
    state: mouse.SDL_MouseButtonFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    xrel: f32 = 0,
    yrel: f32 = 0,
};

pub const SDL_MouseButtonEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: mouse.SDL_MouseID = 0,
    button: u8 = 0,
    down: bool = false,
    clicks: u8 = 0,
    padding: u8 = 0,
    x: f32 = 0,
    y: f32 = 0,
};

pub const SDL_MouseWheelEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: mouse.SDL_MouseID = 0,
    x: f32 = 0,
    y: f32 = 0,
    direction: mouse.SDL_MouseWheelDirection = @import("std").mem.zeroes(mouse.SDL_MouseWheelDirection),
    mouse_x: f32 = 0,
    mouse_y: f32 = 0,
    integer_x: i32 = 0,
    integer_y: i32 = 0,
};

pub const SDL_JoyAxisEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    axis: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
    value: i16 = 0,
    padding4: u16 = 0,
};

pub const SDL_JoyBallEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    ball: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
    xrel: i16 = 0,
    yrel: i16 = 0,
};

pub const SDL_JoyHatEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    hat: u8 = 0,
    value: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

pub const SDL_JoyButtonEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    button: u8 = 0,
    down: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

pub const SDL_JoyDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
};

pub const SDL_JoyBatteryEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    state: power.SDL_PowerState = @import("std").mem.zeroes(power.SDL_PowerState),
    percent: c_int = 0,
};

pub const SDL_GamepadAxisEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    axis: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
    value: i16 = 0,
    padding4: u16 = 0,
};

pub const SDL_GamepadButtonEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    button: u8 = 0,
    down: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

pub const SDL_GamepadDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
};

pub const SDL_GamepadTouchpadEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    touchpad: i32 = 0,
    finger: i32 = 0,
    x: f32 = 0,
    y: f32 = 0,
    pressure: f32 = 0,
};

pub const SDL_GamepadSensorEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: joystick.SDL_JoystickID = 0,
    sensor: i32 = 0,
    data: [3]f32 = @import("std").mem.zeroes([3]f32),
    sensor_timestamp: u64 = 0,
};

pub const SDL_AudioDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: audio.SDL_AudioDeviceID = 0,
    recording: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_CameraDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: camera.SDL_CameraID = 0,
};

pub const SDL_RenderEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
};

pub const SDL_TouchFingerEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    touchID: touch.SDL_TouchID = 0,
    fingerID: touch.SDL_FingerID = 0,
    x: f32 = 0,
    y: f32 = 0,
    dx: f32 = 0,
    dy: f32 = 0,
    pressure: f32 = 0,
    windowID: video.SDL_WindowID = 0,
};

pub const SDL_PinchFingerEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    scale: f32 = 0,
    windowID: video.SDL_WindowID = 0,
};

pub const SDL_PenProximityEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: pen.SDL_PenID = 0,
};

pub const SDL_PenMotionEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: pen.SDL_PenID = 0,
    pen_state: pen.SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
};

pub const SDL_PenTouchEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: pen.SDL_PenID = 0,
    pen_state: pen.SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    eraser: bool = false,
    down: bool = false,
};

pub const SDL_PenButtonEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: pen.SDL_PenID = 0,
    pen_state: pen.SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    button: u8 = 0,
    down: bool = false,
};

pub const SDL_PenAxisEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    which: pen.SDL_PenID = 0,
    pen_state: pen.SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    axis: pen.SDL_PenAxis = @import("std").mem.zeroes(pen.SDL_PenAxis),
    value: f32 = 0,
};

pub const SDL_DropEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    x: f32 = 0,
    y: f32 = 0,
    source: [*c]const u8 = null,
    data: [*c]const u8 = null,
};

pub const SDL_ClipboardEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    owner: bool = false,
    num_mime_types: i32 = 0,
    mime_types: [*c][*c]const u8 = null,
};

pub const SDL_SensorEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: sensor.SDL_SensorID = 0,
    data: [6]f32 = @import("std").mem.zeroes([6]f32),
    sensor_timestamp: u64 = 0,
};

pub const SDL_QuitEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
};

pub const SDL_UserEvent = extern struct {
    type: u32 = 0,
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.SDL_WindowID = 0,
    code: i32 = 0,
    data1: ?*anyopaque = null,
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

// Function prototypes

/// The type of action to request from SDL_PeepEvents().
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_EventAction = enum(c_uint) {
    /// Add events to the back of the queue.
    addevent = 0,
    /// Check but don't remove events from the queue front.
    peekevent = 1,
    /// Retrieve/remove events from the front of the queue.
    getevent = 2,
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
pub extern fn SDL_PeepEvents(events: [*c]SDL_Event, numevents: c_int, action: SDL_EventAction, minType: u32, maxType: u32) c_int;

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
pub extern fn SDL_PollEvent(event: [*c]SDL_Event) bool;

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
pub extern fn SDL_WaitEvent(event: [*c]SDL_Event) bool;

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
pub extern fn SDL_WaitEventTimeout(event: [*c]SDL_Event, timeoutMS: i32) bool;

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
pub extern fn SDL_PushEvent(event: [*c]SDL_Event) bool;

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
pub extern fn SDL_GetWindowFromEvent(event: [*c]const SDL_Event) ?*video.SDL_Window;

/// Generate an English description of an event.
///
/// This will fill `buf` with a null-terminated string that might look
/// something like this:
///
/// ```
/// SDL_EVENT_MOUSE_MOTION (timestamp=1140256324 windowid=2 which=0 state=0 x=492.99 y=139.09 xrel=52 yrel=6)
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
pub extern fn SDL_GetEventDescription(event: [*c]const SDL_Event, buf: [*c]u8, buflen: c_int) c_int;

