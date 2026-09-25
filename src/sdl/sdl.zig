const std = @import("std");
const __helpers = std.zig.c_translation.helpers;

pub const va_list = [*c]u8;
pub const wchar_t = c_int;

const __root = @This();
pub const main_func = ?*const fn (argc: c_int, argv: [*c][*c]u8) callconv(.c) c_int;
pub const AppInit_func = ?*const fn (appstate: ?*?*anyopaque, argc: c_int, argv: ?[*:null]?[*:0]u8) callconv(.c) SDL_AppResult;
pub const AppIterate_func = ?*const fn (appstate: ?*anyopaque) callconv(.c) SDL_AppResult;
pub const AppEvent_func = ?*const fn (appstate: ?*anyopaque, event: [*c]SDL_Event) callconv(.c) SDL_AppResult;
pub const AppQuit_func = ?*const fn (appstate: ?*anyopaque, result: SDL_AppResult) callconv(.c) void;

pub extern fn SDL_RunApp(argc: c_int, argv: [*c][*c]u8, mainFunction: main_func, reserved: ?*anyopaque) c_int;
pub extern fn SDL_EnterAppMainCallbacks(argc: c_int, argv: [*c][*c]u8, appinit: AppInit_func, appiter: AppIterate_func, appevent: AppEvent_func, appquit: AppQuit_func) c_int;

pub const SDL_AppResult = enum(c_uint) {
    app_continue = 0,
    app_success = 1,
    app_failure = 2,
};

pub const SDL_InitFlags = u32;

pub const SDL_INIT_AUDIO = @as(c_uint, 0x00000010);
pub const SDL_INIT_VIDEO = @as(c_uint, 0x00000020);
pub const SDL_INIT_JOYSTICK = @as(c_uint, 0x00000200);
pub const SDL_INIT_HAPTIC = @as(c_uint, 0x00001000);
pub const SDL_INIT_GAMEPAD = @as(c_uint, 0x00002000);
pub const SDL_INIT_EVENTS = @as(c_uint, 0x00004000);
pub const SDL_INIT_SENSOR = @as(c_uint, 0x00008000);
pub const SDL_INIT_CAMERA = __helpers.promoteIntLiteral(c_uint, 0x00010000, .hex);

pub extern fn SDL_Init(flags: SDL_InitFlags) bool;
pub extern fn SDL_InitSubSystem(flags: SDL_InitFlags) bool;
pub extern fn SDL_QuitSubSystem(flags: SDL_InitFlags) void;
pub extern fn SDL_WasInit(flags: SDL_InitFlags) SDL_InitFlags;
pub extern fn SDL_Quit() void;
pub extern fn SDL_IsMainThread() bool;

pub const SDL_PropertiesID = u32;
pub const SDL_WindowID = u32;
pub const SDL_DisplayID = u32;
pub const SDL_JoystickID = u32;
pub const SDL_SensorID = u32;
pub const SDL_KeyboardID = u32;
pub const SDL_MouseID = u32;
pub const SDL_AudioDeviceID = u32;
pub const SDL_CameraID = u32;
pub const SDL_TouchID = u64;
pub const SDL_FingerID = u64;
pub const SDL_PenID = u32;

pub const SDL_PenInputFlags = u32;

pub const SDL_PEN_AXIS_PRESSURE: c_int = 0;
pub const SDL_PEN_AXIS_XTILT: c_int = 1;
pub const SDL_PEN_AXIS_YTILT: c_int = 2;
pub const SDL_PEN_AXIS_DISTANCE: c_int = 3;
pub const SDL_PEN_AXIS_ROTATION: c_int = 4;
pub const SDL_PEN_AXIS_SLIDER: c_int = 5;
pub const SDL_PEN_AXIS_TANGENTIAL_PRESSURE: c_int = 6;
pub const SDL_PEN_AXIS_COUNT: c_int = 7;
pub const enum_SDL_PenAxis = c_uint;
pub const SDL_PenAxis = enum_SDL_PenAxis;

pub const SDL_MouseButtonFlags = u32;

pub const SDL_MouseWheelDirection = enum(c_uint) {
    sdl_mousewheel_normal = 0,
    sdl_mousewheel_flipped = 1,
};

pub const SDL_Event = extern union {
    type: SDL_EventType,
    common: SDL_CommonEvent,
    display: SDL_DisplayEvent,
    window: SDL_WindowEvent,
    kdevice: SDL_KeyboardDeviceEvent,
    key: SDL_KeyboardEvent,
    edit: SDL_TextEditingEvent,
    edit_candidates: SDL_TextEditingCandidatesEvent,
    text: SDL_TextInputEvent,
    mdevice: SDL_MouseDeviceEvent,
    motion: SDL_MouseMotionEvent,
    button: SDL_MouseButtonEvent,
    wheel: SDL_MouseWheelEvent,
    jdevice: SDL_JoyDeviceEvent,
    jaxis: SDL_JoyAxisEvent,
    jball: SDL_JoyBallEvent,
    jhat: SDL_JoyHatEvent,
    jbutton: SDL_JoyButtonEvent,
    jbattery: SDL_JoyBatteryEvent,
    gdevice: SDL_GamepadDeviceEvent,
    gaxis: SDL_GamepadAxisEvent,
    gbutton: SDL_GamepadButtonEvent,
    gtouchpad: SDL_GamepadTouchpadEvent,
    gsensor: SDL_GamepadSensorEvent,
    adevice: SDL_AudioDeviceEvent,
    cdevice: SDL_CameraDeviceEvent,
    sensor: SDL_SensorEvent,
    quit: SDL_QuitEvent,
    user: SDL_UserEvent,
    tfinger: SDL_TouchFingerEvent,
    pinch: SDL_PinchFingerEvent,
    pproximity: SDL_PenProximityEvent,
    ptouch: SDL_PenTouchEvent,
    pmotion: SDL_PenMotionEvent,
    pbutton: SDL_PenButtonEvent,
    paxis: SDL_PenAxisEvent,
    render: SDL_RenderEvent,
    drop: SDL_DropEvent,
    clipboard: SDL_ClipboardEvent,
    padding: [128]u8,
    pub const SDL_PeepEvents = __root.SDL_PeepEvents;
    pub const SDL_PollEvent = __root.SDL_PollEvent;
    pub const SDL_WaitEvent = __root.SDL_WaitEvent;
    pub const SDL_WaitEventTimeout = __root.SDL_WaitEventTimeout;
    pub const SDL_PushEvent = __root.SDL_PushEvent;
    pub const SDL_GetWindowFromEvent = __root.SDL_GetWindowFromEvent;
    pub const SDL_GetEventDescription = __root.SDL_GetEventDescription;
};

pub const SDL_EventAction = enum(c_uint) {
    addevent = 0,
    peekevent = 1,
    getevent = 2,
};

pub extern fn SDL_PeepEvents(events: [*c]SDL_Event, numevents: c_int, action: SDL_EventAction, minType: u32, maxType: u32) c_int;
pub extern fn SDL_WaitEvent(event: [*c]SDL_Event) bool;
pub extern fn SDL_WaitEventTimeout(event: [*c]SDL_Event, timeoutMS: i32) bool;
pub extern fn SDL_PushEvent(event: [*c]SDL_Event) bool;
pub extern fn SDL_GetWindowFromEvent(event: [*c]const SDL_Event) ?*SDL_Window;
pub extern fn SDL_GetEventDescription(event: [*c]const SDL_Event, buf: [*c]u8, buflen: c_int) c_int;
pub extern fn SDL_PollEvent(event: [*c]SDL_Event) bool;

pub const SDL_CommonEvent = extern struct {
    type: u32 = 0,
    reserved: u32 = 0,
    timestamp: u64 = 0,
};
pub const SDL_DisplayEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    displayID: SDL_DisplayID = 0,
    data1: i32 = 0,
    data2: i32 = 0,
};
pub const SDL_WindowEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    data1: i32 = 0,
    data2: i32 = 0,
};
pub const SDL_KeyboardDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_KeyboardID = 0,
};
pub const SDL_KeyboardEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_KeyboardID = 0,
    scancode: SDL_Scancode = @import("std").mem.zeroes(SDL_Scancode),
    key: SDL_Keycode = 0,
    mod: SDL_Keymod = 0,
    raw: u16 = 0,
    down: bool = false,
    repeat: bool = false,
};
pub const SDL_TextEditingEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    text: [*c]const u8 = null,
    start: i32 = 0,
    length: i32 = 0,
};
pub const SDL_TextEditingCandidatesEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
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
    windowID: SDL_WindowID = 0,
    text: [*c]const u8 = null,
};
pub const SDL_MouseDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_MouseID = 0,
};
pub const SDL_MouseMotionEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_MouseID = 0,
    state: SDL_MouseButtonFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    xrel: f32 = 0,
    yrel: f32 = 0,
};
pub const SDL_MouseButtonEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_MouseID = 0,
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
    windowID: SDL_WindowID = 0,
    which: SDL_MouseID = 0,
    x: f32 = 0,
    y: f32 = 0,
    direction: SDL_MouseWheelDirection = @import("std").mem.zeroes(SDL_MouseWheelDirection),
    mouse_x: f32 = 0,
    mouse_y: f32 = 0,
    integer_x: i32 = 0,
    integer_y: i32 = 0,
};
pub const SDL_JoyAxisEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_JoystickID = 0,
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
    which: SDL_JoystickID = 0,
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
    which: SDL_JoystickID = 0,
    hat: u8 = 0,
    value: u8 = 0,
    padding1: u8 = 0,
    padding2: u8 = 0,
};
pub const SDL_JoyButtonEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_JoystickID = 0,
    button: u8 = 0,
    down: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};
pub const SDL_JoyDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_JoystickID = 0,
};
pub const SDL_JoyBatteryEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_JoystickID = 0,
    state: SDL_PowerState = @import("std").mem.zeroes(SDL_PowerState),
    percent: c_int = 0,
};
pub const SDL_GamepadAxisEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_JoystickID = 0,
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
    which: SDL_JoystickID = 0,
    button: u8 = 0,
    down: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};
pub const SDL_GamepadDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_JoystickID = 0,
};
pub const SDL_GamepadTouchpadEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_JoystickID = 0,
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
    which: SDL_JoystickID = 0,
    sensor: i32 = 0,
    data: [3]f32 = @import("std").mem.zeroes([3]f32),
    sensor_timestamp: u64 = 0,
};
pub const SDL_AudioDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_AudioDeviceID = 0,
    recording: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};
pub const SDL_CameraDeviceEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    which: SDL_CameraID = 0,
};
pub const SDL_RenderEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
};
pub const SDL_TouchFingerEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    touchID: SDL_TouchID = 0,
    fingerID: SDL_FingerID = 0,
    x: f32 = 0,
    y: f32 = 0,
    dx: f32 = 0,
    dy: f32 = 0,
    pressure: f32 = 0,
    windowID: SDL_WindowID = 0,
};
pub const SDL_PinchFingerEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    scale: f32 = 0,
    windowID: SDL_WindowID = 0,
};
pub const SDL_PenProximityEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_PenID = 0,
};
pub const SDL_PenMotionEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_PenID = 0,
    pen_state: SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
};
pub const SDL_PenTouchEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_PenID = 0,
    pen_state: SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    eraser: bool = false,
    down: bool = false,
};
pub const SDL_PenButtonEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_PenID = 0,
    pen_state: SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    button: u8 = 0,
    down: bool = false,
};
pub const SDL_PenAxisEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
    which: SDL_PenID = 0,
    pen_state: SDL_PenInputFlags = 0,
    x: f32 = 0,
    y: f32 = 0,
    axis: SDL_PenAxis = @import("std").mem.zeroes(SDL_PenAxis),
    value: f32 = 0,
};
pub const SDL_DropEvent = extern struct {
    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: SDL_WindowID = 0,
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
    which: SDL_SensorID = 0,
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
    windowID: SDL_WindowID = 0,
    code: i32 = 0,
    data1: ?*anyopaque = null,
    data2: ?*anyopaque = null,
};

pub const SDL_EventType = enum(c_uint) {
    first = 0,
    quit = 256,
    terminating = 257,
    low_memory = 258,
    will_enter_background = 259,
    did_enter_background = 260,
    will_enter_foreground = 261,
    did_enter_foreground = 262,
    locale_changed = 263,
    system_theme_changed = 264,
    display_orientation_or_display_first = 337,
    display_added = 338,
    display_removed = 339,
    display_moved = 340,
    display_desktop_mode_changed = 341,
    display_current_mode_changed = 342,
    display_content_scale_changed = 343,
    display_usable_bounds_changed_or_display_last = 344,
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
    mouse_motion = 1024,
    mouse_button_down = 1025,
    mouse_button_up = 1026,
    mouse_wheel = 1027,
    mouse_added = 1028,
    mouse_removed = 1029,
    joystick_axis_motion = 1536,
    joystick_ball_motion = 1537,
    joystick_hat_motion = 1538,
    joystick_button_down = 1539,
    joystick_button_up = 1540,
    joystick_added = 1541,
    joystick_removed = 1542,
    joystick_battery_updated = 1543,
    joystick_update_complete = 1544,
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
    finger_down = 1792,
    finger_up = 1793,
    finger_motion = 1794,
    finger_canceled = 1795,
    pinch_begin = 1808,
    pinch_update = 1809,
    pinch_end = 1810,
    clipboard_update = 2304,
    drop_file = 4096,
    drop_text = 4097,
    drop_begin = 4098,
    drop_complete = 4099,
    drop_position = 4100,
    audio_device_added = 4352,
    audio_device_removed = 4353,
    audio_device_format_changed = 4354,
    sensor_update = 4608,
    pen_proximity_in = 4864,
    pen_proximity_out = 4865,
    pen_down = 4866,
    pen_up = 4867,
    pen_button_down = 4868,
    pen_button_up = 4869,
    pen_motion = 4870,
    pen_axis = 4871,
    camera_device_added = 5120,
    camera_device_removed = 5121,
    camera_device_approved = 5122,
    camera_device_denied = 5123,
    render_targets_reset = 8192,
    render_device_reset = 8193,
    render_device_lost = 8194,
    private0 = 16384,
    private1 = 16385,
    private2 = 16386,
    private3 = 16387,
    poll_sentinel = 32512,
    user = 32768,
    last = 65535,
    enum_padding = 2147483647,
};

pub const SDL_Window = opaque {
    pub const SDL_GetDisplayForWindow = __root.SDL_GetDisplayForWindow;
    pub const SDL_GetWindowPixelDensity = __root.SDL_GetWindowPixelDensity;
    pub const SDL_GetWindowDisplayScale = __root.SDL_GetWindowDisplayScale;
    pub const SDL_SetWindowFullscreenMode = __root.SDL_SetWindowFullscreenMode;
    pub const SDL_GetWindowFullscreenMode = __root.SDL_GetWindowFullscreenMode;
    pub const SDL_GetWindowICCProfile = __root.SDL_GetWindowICCProfile;
    pub const SDL_GetWindowPixelFormat = __root.SDL_GetWindowPixelFormat;
    pub const SDL_CreatePopupWindow = __root.SDL_CreatePopupWindow;
    pub const SDL_GetWindowID = __root.SDL_GetWindowID;
    pub const SDL_GetWindowParent = __root.SDL_GetWindowParent;
    pub const SDL_GetWindowProperties = __root.SDL_GetWindowProperties;
    pub const SDL_GetWindowFlags = __root.SDL_GetWindowFlags;
    pub const SDL_SetWindowTitle = __root.SDL_SetWindowTitle;
    pub const SDL_GetWindowTitle = __root.SDL_GetWindowTitle;
    pub const SDL_SetWindowIcon = __root.SDL_SetWindowIcon;
    pub const SDL_SetWindowPosition = __root.SDL_SetWindowPosition;
    pub const SDL_GetWindowPosition = __root.SDL_GetWindowPosition;
    pub const SDL_SetWindowSize = __root.SDL_SetWindowSize;
    pub const SDL_GetWindowSize = __root.SDL_GetWindowSize;
    pub const SDL_GetWindowSafeArea = __root.SDL_GetWindowSafeArea;
    pub const SDL_SetWindowAspectRatio = __root.SDL_SetWindowAspectRatio;
    pub const SDL_GetWindowAspectRatio = __root.SDL_GetWindowAspectRatio;
    pub const SDL_GetWindowBordersSize = __root.SDL_GetWindowBordersSize;
    pub const SDL_GetWindowSizeInPixels = __root.SDL_GetWindowSizeInPixels;
    pub const SDL_SetWindowMinimumSize = __root.SDL_SetWindowMinimumSize;
    pub const SDL_GetWindowMinimumSize = __root.SDL_GetWindowMinimumSize;
    pub const SDL_SetWindowMaximumSize = __root.SDL_SetWindowMaximumSize;
    pub const SDL_GetWindowMaximumSize = __root.SDL_GetWindowMaximumSize;
    pub const SDL_SetWindowBordered = __root.SDL_SetWindowBordered;
    pub const SDL_SetWindowResizable = __root.SDL_SetWindowResizable;
    pub const SDL_SetWindowAlwaysOnTop = __root.SDL_SetWindowAlwaysOnTop;
    pub const SDL_SetWindowFillDocument = __root.SDL_SetWindowFillDocument;
    pub const SDL_ShowWindow = __root.SDL_ShowWindow;
    pub const SDL_HideWindow = __root.SDL_HideWindow;
    pub const SDL_RaiseWindow = __root.SDL_RaiseWindow;
    pub const SDL_MaximizeWindow = __root.SDL_MaximizeWindow;
    pub const SDL_MinimizeWindow = __root.SDL_MinimizeWindow;
    pub const SDL_RestoreWindow = __root.SDL_RestoreWindow;
    pub const SDL_SetWindowFullscreen = __root.SDL_SetWindowFullscreen;
    pub const SDL_SyncWindow = __root.SDL_SyncWindow;
    pub const SDL_WindowHasSurface = __root.SDL_WindowHasSurface;
    pub const SDL_GetWindowSurface = __root.SDL_GetWindowSurface;
    pub const SDL_SetWindowSurfaceVSync = __root.SDL_SetWindowSurfaceVSync;
    pub const SDL_GetWindowSurfaceVSync = __root.SDL_GetWindowSurfaceVSync;
    pub const SDL_UpdateWindowSurface = __root.SDL_UpdateWindowSurface;
    pub const SDL_UpdateWindowSurfaceRects = __root.SDL_UpdateWindowSurfaceRects;
    pub const SDL_DestroyWindowSurface = __root.SDL_DestroyWindowSurface;
    pub const SDL_SetWindowKeyboardGrab = __root.SDL_SetWindowKeyboardGrab;
    pub const SDL_SetWindowMouseGrab = __root.SDL_SetWindowMouseGrab;
    pub const SDL_GetWindowKeyboardGrab = __root.SDL_GetWindowKeyboardGrab;
    pub const SDL_GetWindowMouseGrab = __root.SDL_GetWindowMouseGrab;
    pub const SDL_SetWindowMouseRect = __root.SDL_SetWindowMouseRect;
    pub const SDL_GetWindowMouseRect = __root.SDL_GetWindowMouseRect;
    pub const SDL_SetWindowOpacity = __root.SDL_SetWindowOpacity;
    pub const SDL_GetWindowOpacity = __root.SDL_GetWindowOpacity;
    pub const SDL_SetWindowParent = __root.SDL_SetWindowParent;
    pub const SDL_SetWindowModal = __root.SDL_SetWindowModal;
    pub const SDL_SetWindowFocusable = __root.SDL_SetWindowFocusable;
    pub const SDL_ShowWindowSystemMenu = __root.SDL_ShowWindowSystemMenu;
    pub const SDL_SetWindowHitTest = __root.SDL_SetWindowHitTest;
    pub const SDL_SetWindowShape = __root.SDL_SetWindowShape;
    pub const SDL_FlashWindow = __root.SDL_FlashWindow;
    pub const SDL_SetWindowProgressState = __root.SDL_SetWindowProgressState;
    pub const SDL_GetWindowProgressState = __root.SDL_GetWindowProgressState;
    pub const SDL_SetWindowProgressValue = __root.SDL_SetWindowProgressValue;
    pub const SDL_GetWindowProgressValue = __root.SDL_GetWindowProgressValue;
    pub const SDL_DestroyWindow = __root.SDL_DestroyWindow;
    pub const SDL_GL_CreateContext = __root.SDL_GL_CreateContext;
    pub const SDL_GL_MakeCurrent = __root.SDL_GL_MakeCurrent;
    pub const SDL_EGL_GetWindowSurface = __root.SDL_EGL_GetWindowSurface;
    pub const SDL_GL_SwapWindow = __root.SDL_GL_SwapWindow;
    pub const SDL_StartTextInput = __root.SDL_StartTextInput;
    pub const SDL_StartTextInputWithProperties = __root.SDL_StartTextInputWithProperties;
    pub const SDL_TextInputActive = __root.SDL_TextInputActive;
    pub const SDL_StopTextInput = __root.SDL_StopTextInput;
    pub const SDL_ClearComposition = __root.SDL_ClearComposition;
    pub const SDL_SetTextInputArea = __root.SDL_SetTextInputArea;
    pub const SDL_GetTextInputArea = __root.SDL_GetTextInputArea;
    pub const SDL_ScreenKeyboardShown = __root.SDL_ScreenKeyboardShown;
    pub const SDL_WarpMouseInWindow = __root.SDL_WarpMouseInWindow;
    pub const SDL_SetWindowRelativeMouseMode = __root.SDL_SetWindowRelativeMouseMode;
    pub const SDL_GetWindowRelativeMouseMode = __root.SDL_GetWindowRelativeMouseMode;
    pub const SDL_Metal_CreateView = __root.SDL_Metal_CreateView;
    pub const SDL_CreateRenderer = __root.SDL_CreateRenderer;
    pub const SDL_GetRenderer = __root.SDL_GetRenderer;
    pub const GetDisplayForWindow = __root.SDL_GetDisplayForWindow;
    pub const GetWindowPixelDensity = __root.SDL_GetWindowPixelDensity;
    pub const GetWindowDisplayScale = __root.SDL_GetWindowDisplayScale;
    pub const SetWindowFullscreenMode = __root.SDL_SetWindowFullscreenMode;
    pub const GetWindowFullscreenMode = __root.SDL_GetWindowFullscreenMode;
    pub const GetWindowICCProfile = __root.SDL_GetWindowICCProfile;
    pub const GetWindowPixelFormat = __root.SDL_GetWindowPixelFormat;
    pub const CreatePopupWindow = __root.SDL_CreatePopupWindow;
    pub const GetWindowID = __root.SDL_GetWindowID;
    pub const GetWindowParent = __root.SDL_GetWindowParent;
    pub const GetWindowProperties = __root.SDL_GetWindowProperties;
    pub const GetWindowFlags = __root.SDL_GetWindowFlags;
    pub const SetWindowTitle = __root.SDL_SetWindowTitle;
    pub const GetWindowTitle = __root.SDL_GetWindowTitle;
    pub const SetWindowIcon = __root.SDL_SetWindowIcon;
    pub const SetWindowPosition = __root.SDL_SetWindowPosition;
    pub const GetWindowPosition = __root.SDL_GetWindowPosition;
    pub const SetWindowSize = __root.SDL_SetWindowSize;
    pub const GetWindowSize = __root.SDL_GetWindowSize;
    pub const GetWindowSafeArea = __root.SDL_GetWindowSafeArea;
    pub const SetWindowAspectRatio = __root.SDL_SetWindowAspectRatio;
    pub const GetWindowAspectRatio = __root.SDL_GetWindowAspectRatio;
    pub const GetWindowBordersSize = __root.SDL_GetWindowBordersSize;
    pub const GetWindowSizeInPixels = __root.SDL_GetWindowSizeInPixels;
    pub const SetWindowMinimumSize = __root.SDL_SetWindowMinimumSize;
    pub const GetWindowMinimumSize = __root.SDL_GetWindowMinimumSize;
    pub const SetWindowMaximumSize = __root.SDL_SetWindowMaximumSize;
    pub const GetWindowMaximumSize = __root.SDL_GetWindowMaximumSize;
    pub const SetWindowBordered = __root.SDL_SetWindowBordered;
    pub const SetWindowResizable = __root.SDL_SetWindowResizable;
    pub const SetWindowAlwaysOnTop = __root.SDL_SetWindowAlwaysOnTop;
    pub const SetWindowFillDocument = __root.SDL_SetWindowFillDocument;
    pub const ShowWindow = __root.SDL_ShowWindow;
    pub const HideWindow = __root.SDL_HideWindow;
    pub const RaiseWindow = __root.SDL_RaiseWindow;
    pub const MaximizeWindow = __root.SDL_MaximizeWindow;
    pub const MinimizeWindow = __root.SDL_MinimizeWindow;
    pub const RestoreWindow = __root.SDL_RestoreWindow;
    pub const SetWindowFullscreen = __root.SDL_SetWindowFullscreen;
    pub const SyncWindow = __root.SDL_SyncWindow;
    pub const WindowHasSurface = __root.SDL_WindowHasSurface;
    pub const GetWindowSurface = __root.SDL_GetWindowSurface;
    pub const SetWindowSurfaceVSync = __root.SDL_SetWindowSurfaceVSync;
    pub const GetWindowSurfaceVSync = __root.SDL_GetWindowSurfaceVSync;
    pub const UpdateWindowSurface = __root.SDL_UpdateWindowSurface;
    pub const UpdateWindowSurfaceRects = __root.SDL_UpdateWindowSurfaceRects;
    pub const DestroyWindowSurface = __root.SDL_DestroyWindowSurface;
    pub const SetWindowKeyboardGrab = __root.SDL_SetWindowKeyboardGrab;
    pub const SetWindowMouseGrab = __root.SDL_SetWindowMouseGrab;
    pub const GetWindowKeyboardGrab = __root.SDL_GetWindowKeyboardGrab;
    pub const GetWindowMouseGrab = __root.SDL_GetWindowMouseGrab;
    pub const SetWindowMouseRect = __root.SDL_SetWindowMouseRect;
    pub const GetWindowMouseRect = __root.SDL_GetWindowMouseRect;
    pub const SetWindowOpacity = __root.SDL_SetWindowOpacity;
    pub const GetWindowOpacity = __root.SDL_GetWindowOpacity;
    pub const SetWindowParent = __root.SDL_SetWindowParent;
    pub const SetWindowModal = __root.SDL_SetWindowModal;
    pub const SetWindowFocusable = __root.SDL_SetWindowFocusable;
    pub const ShowWindowSystemMenu = __root.SDL_ShowWindowSystemMenu;
    pub const SetWindowHitTest = __root.SDL_SetWindowHitTest;
    pub const SetWindowShape = __root.SDL_SetWindowShape;
    pub const FlashWindow = __root.SDL_FlashWindow;
    pub const SetWindowProgressState = __root.SDL_SetWindowProgressState;
    pub const GetWindowProgressState = __root.SDL_GetWindowProgressState;
    pub const SetWindowProgressValue = __root.SDL_SetWindowProgressValue;
    pub const GetWindowProgressValue = __root.SDL_GetWindowProgressValue;
    pub const DestroyWindow = __root.SDL_DestroyWindow;
    pub const CreateContext = __root.SDL_GL_CreateContext;
    pub const MakeCurrent = __root.SDL_GL_MakeCurrent;
    pub const SwapWindow = __root.SDL_GL_SwapWindow;
    pub const StartTextInput = __root.SDL_StartTextInput;
    pub const StartTextInputWithProperties = __root.SDL_StartTextInputWithProperties;
    pub const TextInputActive = __root.SDL_TextInputActive;
    pub const StopTextInput = __root.SDL_StopTextInput;
    pub const ClearComposition = __root.SDL_ClearComposition;
    pub const SetTextInputArea = __root.SDL_SetTextInputArea;
    pub const GetTextInputArea = __root.SDL_GetTextInputArea;
    pub const ScreenKeyboardShown = __root.SDL_ScreenKeyboardShown;
    pub const WarpMouseInWindow = __root.SDL_WarpMouseInWindow;
    pub const SetWindowRelativeMouseMode = __root.SDL_SetWindowRelativeMouseMode;
    pub const GetWindowRelativeMouseMode = __root.SDL_GetWindowRelativeMouseMode;
    pub const CreateView = __root.SDL_Metal_CreateView;
    pub const CreateRenderer = __root.SDL_CreateRenderer;
    pub const GetRenderer = __root.SDL_GetRenderer;
};

pub const SDL_Scancode = enum(c_uint) {
    unknown = 0,
    a = 4,
    b = 5,
    c = 6,
    d = 7,
    e = 8,
    f = 9,
    g = 10,
    h = 11,
    i = 12,
    j = 13,
    k = 14,
    l = 15,
    m = 16,
    n = 17,
    o = 18,
    p = 19,
    q = 20,
    r = 21,
    s = 22,
    t = 23,
    u = 24,
    v = 25,
    w = 26,
    x = 27,
    y = 28,
    z = 29,
    number_row_1 = 30,
    number_row_2 = 31,
    number_row_3 = 32,
    number_row_4 = 33,
    number_row_5 = 34,
    number_row_6 = 35,
    number_row_7 = 36,
    number_row_8 = 37,
    number_row_9 = 38,
    number_row_0 = 39,
    return_key = 40,
    escape = 41,
    backspace = 42,
    tab = 43,
    space = 44,
    minus = 45,
    equals = 46,
    leftbracket = 47,
    rightbracket = 48,
    backslash = 49,
    nonushash = 50,
    semicolon = 51,
    apostrophe = 52,
    grave = 53,
    comma = 54,
    period = 55,
    slash = 56,
    capslock = 57,
    f1 = 58,
    f2 = 59,
    f3 = 60,
    f4 = 61,
    f5 = 62,
    f6 = 63,
    f7 = 64,
    f8 = 65,
    f9 = 66,
    f10 = 67,
    f11 = 68,
    f12 = 69,
    printscreen = 70,
    scrolllock = 71,
    pause = 72,
    insert = 73,
    home = 74,
    pageup = 75,
    delete = 76,
    end = 77,
    pagedown = 78,
    right = 79,
    left = 80,
    down = 81,
    up = 82,
    numlockclear = 83,
    kp_divide = 84,
    kp_multiply = 85,
    kp_minus = 86,
    kp_plus = 87,
    kp_enter = 88,
    kp_1 = 89,
    kp_2 = 90,
    kp_3 = 91,
    kp_4 = 92,
    kp_5 = 93,
    kp_6 = 94,
    kp_7 = 95,
    kp_8 = 96,
    kp_9 = 97,
    kp_0 = 98,
    kp_period = 99,
    nonusbackslash = 100,
    application = 101,
    power = 102,
    kp_equals = 103,
    f13 = 104,
    f14 = 105,
    f15 = 106,
    f16 = 107,
    f17 = 108,
    f18 = 109,
    f19 = 110,
    f20 = 111,
    f21 = 112,
    f22 = 113,
    f23 = 114,
    f24 = 115,
    execute = 116,
    help = 117,
    menu = 118,
    select = 119,
    stop = 120,
    again = 121,
    undo = 122,
    cut = 123,
    copy = 124,
    paste = 125,
    find = 126,
    mute = 127,
    volumeup = 128,
    volumedown = 129,
    kp_comma = 133,
    kp_equalsas400 = 134,
    international1 = 135,
    international2 = 136,
    international3 = 137,
    international4 = 138,
    international5 = 139,
    international6 = 140,
    international7 = 141,
    international8 = 142,
    international9 = 143,
    lang1 = 144,
    lang2 = 145,
    lang3 = 146,
    lang4 = 147,
    lang5 = 148,
    lang6 = 149,
    lang7 = 150,
    lang8 = 151,
    lang9 = 152,
    alterase = 153,
    sysreq = 154,
    cancel = 155,
    clear = 156,
    prior = 157,
    return2 = 158,
    separator = 159,
    out = 160,
    oper = 161,
    clearagain = 162,
    crsel = 163,
    exsel = 164,
    kp_00 = 176,
    kp_000 = 177,
    thousandsseparator = 178,
    decimalseparator = 179,
    currencyunit = 180,
    currencysubunit = 181,
    kp_leftparen = 182,
    kp_rightparen = 183,
    kp_leftbrace = 184,
    kp_rightbrace = 185,
    kp_tab = 186,
    kp_backspace = 187,
    kp_a = 188,
    kp_b = 189,
    kp_c = 190,
    kp_d = 191,
    kp_e = 192,
    kp_f = 193,
    kp_xor = 194,
    kp_power = 195,
    kp_percent = 196,
    kp_less = 197,
    kp_greater = 198,
    kp_ampersand = 199,
    kp_dblampersand = 200,
    kp_verticalbar = 201,
    kp_dblverticalbar = 202,
    kp_colon = 203,
    kp_hash = 204,
    kp_space = 205,
    kp_at = 206,
    kp_exclam = 207,
    kp_memstore = 208,
    kp_memrecall = 209,
    kp_memclear = 210,
    kp_memadd = 211,
    kp_memsubtract = 212,
    kp_memmultiply = 213,
    kp_memdivide = 214,
    kp_plusminus = 215,
    kp_clear = 216,
    kp_clearentry = 217,
    kp_binary = 218,
    kp_octal = 219,
    kp_decimal = 220,
    kp_hexadecimal = 221,
    lctrl = 224,
    lshift = 225,
    lalt = 226,
    lgui = 227,
    rctrl = 228,
    rshift = 229,
    ralt = 230,
    rgui = 231,
    mode = 257,
    sleep = 258,
    wake = 259,
    channel_increment = 260,
    channel_decrement = 261,
    media_play = 262,
    media_pause = 263,
    media_record = 264,
    media_fast_forward = 265,
    media_rewind = 266,
    media_next_track = 267,
    media_previous_track = 268,
    media_stop = 269,
    media_eject = 270,
    media_play_pause = 271,
    media_select = 272,
    ac_new = 273,
    ac_open = 274,
    ac_close = 275,
    ac_exit = 276,
    ac_save = 277,
    ac_print = 278,
    ac_properties = 279,
    ac_search = 280,
    ac_home = 281,
    ac_back = 282,
    ac_forward = 283,
    ac_stop = 284,
    ac_refresh = 285,
    ac_bookmarks = 286,
    softleft = 287,
    softright = 288,
    call = 289,
    endcall = 290,
    reserved = 400,
    count = 512,
};

pub const SDL_Keycode = u32;
pub const SDL_Keymod = u16;

pub const SDL_PowerState = enum(c_int) {
    error_state = -1,
    unknown = 0,
    on_battery = 1,
    no_battery = 2,
    charging = 3,
    charged = 4,
};

pub const SDL_LogCategory = enum(c_int) {
    application = 0,
    error_category = 1,
    assert = 2,
    system = 3,
    audio = 4,
    video = 5,
    render = 6,
    input = 7,
    test_category = 8,
    gpu = 9,
    reserved2 = 10,
    reserved3 = 11,
    reserved4 = 12,
    reserved5 = 13,
    reserved6 = 14,
    reserved7 = 15,
    reserved8 = 16,
    reserved9 = 17,
    reserved10 = 18,
    custom = 19,
};

pub const SDL_LogPriority = enum(c_int) {
    invalid = 0,
    trace = 1,
    verbose = 2,
    debug = 3,
    info = 4,
    warn = 5,
    error_priority = 6,
    critical = 7,
    count = 8,
};

pub extern fn SDL_SetLogPriorities(priority: SDL_LogPriority) void;
pub extern fn SDL_SetLogPriority(category: SDL_LogCategory, priority: SDL_LogPriority) void;
pub extern fn SDL_GetLogPriority(category: SDL_LogCategory) SDL_LogPriority;
pub extern fn SDL_ResetLogPriorities() void;
pub extern fn SDL_SetLogPriorityPrefix(priority: SDL_LogPriority, prefix: [*c]const u8) bool;
pub extern fn SDL_Log(fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogTrace(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogVerbose(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogDebug(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogInfo(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogWarn(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogError(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogCritical(category: SDL_LogCategory, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogMessage(category: SDL_LogCategory, priority: SDL_LogPriority, fmt: [*c]const u8, ...) void;
pub extern fn SDL_LogMessageV(category: SDL_LogCategory, priority: SDL_LogPriority, fmt: [*c]const u8, ap: [*c]u8) void;

pub const SDL_LogOutputFunction = ?*const fn (userdata: ?*anyopaque, category: SDL_LogCategory, priority: SDL_LogPriority, message: [*c]const u8) callconv(.c) void;
pub extern fn SDL_GetDefaultLogOutputFunction() SDL_LogOutputFunction;
pub extern fn SDL_GetLogOutputFunction(callback: [*c]SDL_LogOutputFunction, userdata: [*c]?*anyopaque) void;
pub extern fn SDL_SetLogOutputFunction(callback: SDL_LogOutputFunction, userdata: ?*anyopaque) void;

pub extern fn SDL_SetError(fmt: [*c]const u8, ...) bool;
pub extern fn SDL_SetErrorV(fmt: [*c]const u8, ap: [*c]u8) bool;
pub extern fn SDL_OutOfMemory() bool;
pub extern fn SDL_GetError() [*c]const u8;
pub extern fn SDL_ClearError() bool;

pub const SDL_GPUShaderFormat = enum(u32) {
    invalid = @as(c_int, 0),
    private = @as(c_uint, 1) << @as(c_int, 0),
    spirv = @as(c_uint, 1) << @as(c_int, 1),
    dxbc = @as(c_uint, 1) << @as(c_int, 2),
    dxil = @as(c_uint, 1) << @as(c_int, 3),
    msl = @as(c_uint, 1) << @as(c_int, 4),
};

pub const SDL_GPUComputePipelineCreateInfo = extern struct {
    code_size: usize = 0,
    code: [*c]const u8 = null,
    entrypoint: [*c]const u8 = null,
    format: SDL_GPUShaderFormat = 0,
    num_samplers: u32 = 0,
    num_readonly_storage_textures: u32 = 0,
    num_readonly_storage_buffers: u32 = 0,
    num_readwrite_storage_textures: u32 = 0,
    num_readwrite_storage_buffers: u32 = 0,
    num_uniform_buffers: u32 = 0,
    threadcount_x: u32 = 0,
    threadcount_y: u32 = 0,
    threadcount_z: u32 = 0,
    props: SDL_PropertiesID = 0,
};

pub const SDL_GPUGraphicsPipelineCreateInfo = extern struct {
    vertex_shader: ?*SDL_GPUShader = null,
    fragment_shader: ?*SDL_GPUShader = null,
    vertex_input_state: SDL_GPUVertexInputState = @import("std").mem.zeroes(SDL_GPUVertexInputState),
    primitive_type: SDL_GPUPrimitiveType = @import("std").mem.zeroes(SDL_GPUPrimitiveType),
    rasterizer_state: SDL_GPURasterizerState = @import("std").mem.zeroes(SDL_GPURasterizerState),
    multisample_state: SDL_GPUMultisampleState = @import("std").mem.zeroes(SDL_GPUMultisampleState),
    depth_stencil_state: SDL_GPUDepthStencilState = @import("std").mem.zeroes(SDL_GPUDepthStencilState),
    target_info: SDL_GPUGraphicsPipelineTargetInfo = @import("std").mem.zeroes(SDL_GPUGraphicsPipelineTargetInfo),
    props: SDL_PropertiesID = 0,
};

pub const SDL_GPUGraphicsPipelineTargetInfo = extern struct {
    color_target_descriptions: [*c]const SDL_GPUColorTargetDescription = null,
    num_color_targets: u32 = 0,
    depth_stencil_format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
    has_depth_stencil_target: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_GPUColorTargetDescription = extern struct {
    format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
    blend_state: SDL_GPUColorTargetBlendState = @import("std").mem.zeroes(SDL_GPUColorTargetBlendState),
};

pub const SDL_GPUColorTargetBlendState = extern struct {
    src_color_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    dst_color_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    color_blend_op: SDL_GPUBlendOp = @import("std").mem.zeroes(SDL_GPUBlendOp),
    src_alpha_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    dst_alpha_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    alpha_blend_op: SDL_GPUBlendOp = @import("std").mem.zeroes(SDL_GPUBlendOp),
    color_write_mask: SDL_GPUColorComponentFlags = 0,
    enable_blend: bool = false,
    enable_color_write_mask: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

pub const SDL_GPUColorComponentFlags = u8;

pub const SDL_GPUBlendOp = enum(c_uint) {
    invalid = 0,
    add = 1,
    subtract = 2,
    reverse_subtract = 3,
    min = 4,
    max = 5,
};

pub const SDL_GPUCompareOp = enum(c_uint) {
    invalid = 0,
    never = 1,
    less = 2,
    equal = 3,
    less_or_equal = 4,
    greater = 5,
    not_equal = 6,
    greater_or_equal = 7,
    always = 8,
};

pub const SDL_GPUBlendFactor = enum(c_uint) {
    invalid = 0,
    zero = 1,
    one = 2,
    src_color = 3,
    one_minus_src_color = 4,
    dst_color = 5,
    one_minus_dst_color = 6,
    src_alpha = 7,
    one_minus_src_alpha = 8,
    dst_alpha = 9,
    one_minus_dst_alpha = 10,
    constant_color = 11,
    one_minus_constant_color = 12,
    src_alpha_saturate = 13,
};

pub const SDL_GPUStencilOp = enum(c_uint) {
    invalid = 0,
    keep = 1,
    zero = 2,
    replace = 3,
    increment_and_clamp = 4,
    decrement_and_clamp = 5,
    invert = 6,
    increment_and_wrap = 7,
    decrement_and_wrap = 8,
};

pub const SDL_GPUDepthStencilState = extern struct {
    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
    back_stencil_state: SDL_GPUStencilOpState = @import("std").mem.zeroes(SDL_GPUStencilOpState),
    front_stencil_state: SDL_GPUStencilOpState = @import("std").mem.zeroes(SDL_GPUStencilOpState),
    compare_mask: u8 = 0,
    write_mask: u8 = 0,
    enable_depth_test: bool = false,
    enable_depth_write: bool = false,
    enable_stencil_test: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_GPUStencilOpState = extern struct {
    fail_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
    pass_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
    depth_fail_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
};

pub const SDL_GPUSampleCount = enum(c_uint) {
    samplecount_1 = 0,
    samplecount_2 = 1,
    samplecount_4 = 2,
    samplecount_8 = 3,
};

pub const SDL_GPUMultisampleState = extern struct {
    sample_count: SDL_GPUSampleCount = @import("std").mem.zeroes(SDL_GPUSampleCount),
    sample_mask: u32 = 0,
    enable_mask: bool = false,
    enable_alpha_to_coverage: bool = false,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_GPUFillMode = enum(c_uint) {
    fill = 0,
    line = 1,
};

pub const SDL_GPUCullMode = enum(c_uint) {
    none = 0,
    front = 1,
    back = 2,
};

pub const SDL_GPUFrontFace = enum(c_uint) {
    counter_clockwise = 0,
    clockwise = 1,
};

pub const SDL_GPURasterizerState = extern struct {
    fill_mode: SDL_GPUFillMode = @import("std").mem.zeroes(SDL_GPUFillMode),
    cull_mode: SDL_GPUCullMode = @import("std").mem.zeroes(SDL_GPUCullMode),
    front_face: SDL_GPUFrontFace = @import("std").mem.zeroes(SDL_GPUFrontFace),
    depth_bias_constant_factor: f32 = 0,
    depth_bias_clamp: f32 = 0,
    depth_bias_slope_factor: f32 = 0,
    enable_depth_bias: bool = false,
    enable_depth_clip: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

pub const SDL_GPUVertexInputState = extern struct {
    vertex_buffer_descriptions: [*c]const SDL_GPUVertexBufferDescription = null,
    num_vertex_buffers: u32 = 0,
    vertex_attributes: [*c]const SDL_GPUVertexAttribute = null,
    num_vertex_attributes: u32 = 0,
};

pub const SDL_GPUVertexBufferDescription = extern struct {
    slot: u32 = 0,
    pitch: u32 = 0,
    input_rate: SDL_GPUVertexInputRate = @import("std").mem.zeroes(SDL_GPUVertexInputRate),
    instance_step_rate: u32 = 0,
};

pub const SDL_GPUVertexAttribute = extern struct {
    location: u32 = 0,
    buffer_slot: u32 = 0,
    format: SDL_GPUVertexElementFormat = @import("std").mem.zeroes(SDL_GPUVertexElementFormat),
    offset: u32 = 0,
};

pub const SDL_GPUFilter = enum(c_uint) {
    nearest = 0,
    linear = 1,
};

pub const SDL_GPUSamplerMipmapMode = enum(c_uint) {
    nearest = 0,
    linear = 1,
};

pub const SDL_GPUSamplerCreateInfo = extern struct {
    min_filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
    mag_filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
    mipmap_mode: SDL_GPUSamplerMipmapMode = @import("std").mem.zeroes(SDL_GPUSamplerMipmapMode),
    address_mode_u: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
    address_mode_v: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
    address_mode_w: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
    mip_lod_bias: f32 = 0,
    max_anisotropy: f32 = 0,
    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
    min_lod: f32 = 0,
    max_lod: f32 = 0,
    enable_anisotropy: bool = false,
    enable_compare: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    props: SDL_PropertiesID = 0,
};

pub const SDL_GPUSamplerAddressMode = enum(c_uint) {
    repeat = 0,
    mirrored_repeat = 1,
    clamp_to_edge = 2,
};

pub const SDL_GPUPresentMode = enum(c_uint) {
    vsync = 0,
    immediate = 1,
    mailbox = 2,
};

pub const SDL_GPUSwapchainComposition = enum(c_uint) {
    sdr = 0,
    sdr_linear = 1,
    hdr_extended_linear = 2,
    hdr10_st2084 = 3,
};

pub const SDL_GPUTextureFormat = enum(c_uint) {
    invalid = 0,
    a8_unorm = 1,
    r8_unorm = 2,
    r8g8_unorm = 3,
    r8g8b8a8_unorm = 4,
    r16_unorm = 5,
    r16g16_unorm = 6,
    r16g16b16a16_unorm = 7,
    r10g10b10a2_unorm = 8,
    b5g6r5_unorm = 9,
    b5g5r5a1_unorm = 10,
    b4g4r4a4_unorm = 11,
    b8g8r8a8_unorm = 12,
    bc1_rgba_unorm = 13,
    bc2_rgba_unorm = 14,
    bc3_rgba_unorm = 15,
    bc4_r_unorm = 16,
    bc5_rg_unorm = 17,
    bc7_rgba_unorm = 18,
    bc6h_rgb_float = 19,
    bc6h_rgb_ufloat = 20,
    r8_snorm = 21,
    r8g8_snorm = 22,
    r8g8b8a8_snorm = 23,
    r16_snorm = 24,
    r16g16_snorm = 25,
    r16g16b16a16_snorm = 26,
    r16_float = 27,
    r16g16_float = 28,
    r16g16b16a16_float = 29,
    r32_float = 30,
    r32g32_float = 31,
    r32g32b32a32_float = 32,
    r11g11b10_ufloat = 33,
    r8_uint = 34,
    r8g8_uint = 35,
    r8g8b8a8_uint = 36,
    r16_uint = 37,
    r16g16_uint = 38,
    r16g16b16a16_uint = 39,
    r32_uint = 40,
    r32g32_uint = 41,
    r32g32b32a32_uint = 42,
    r8_int = 43,
    r8g8_int = 44,
    r8g8b8a8_int = 45,
    r16_int = 46,
    r16g16_int = 47,
    r16g16b16a16_int = 48,
    r32_int = 49,
    r32g32_int = 50,
    r32g32b32a32_int = 51,
    r8g8b8a8_unorm_srgb = 52,
    b8g8r8a8_unorm_srgb = 53,
    bc1_rgba_unorm_srgb = 54,
    bc2_rgba_unorm_srgb = 55,
    bc3_rgba_unorm_srgb = 56,
    bc7_rgba_unorm_srgb = 57,
    d16_unorm = 58,
    d24_unorm = 59,
    d32_float = 60,
    d24_unorm_s8_uint = 61,
    d32_float_s8_uint = 62,
    astc_4X4_unorm = 63,
    astc_5X4_unorm = 64,
    astc_5X5_unorm = 65,
    astc_6X5_unorm = 66,
    astc_6X6_unorm = 67,
    astc_8X5_unorm = 68,
    astc_8X6_unorm = 69,
    astc_8X8_unorm = 70,
    astc_10X5_unorm = 71,
    astc_10X6_unorm = 72,
    astc_10X8_unorm = 73,
    astc_10X10_unorm = 74,
    astc_12X10_unorm = 75,
    astc_12X12_unorm = 76,
    astc_4X4_unorm_srgb = 77,
    astc_5X4_unorm_srgb = 78,
    astc_5X5_unorm_srgb = 79,
    astc_6X5_unorm_srgb = 80,
    astc_6X6_unorm_srgb = 81,
    astc_8X5_unorm_srgb = 82,
    astc_8X6_unorm_srgb = 83,
    astc_8X8_unorm_srgb = 84,
    astc_10X5_unorm_srgb = 85,
    astc_10X6_unorm_srgb = 86,
    astc_10X8_unorm_srgb = 87,
    astc_10X10_unorm_srgb = 88,
    astc_12X10_unorm_srgb = 89,
    astc_12X12_unorm_srgb = 90,
    astc_4X4_float = 91,
    astc_5X4_float = 92,
    astc_5X5_float = 93,
    astc_6X5_float = 94,
    astc_6X6_float = 95,
    astc_8X5_float = 96,
    astc_8X6_float = 97,
    astc_8X8_float = 98,
    astc_10X5_float = 99,
    astc_10X6_float = 100,
    astc_10X8_float = 101,
    astc_10X10_float = 102,
    astc_12X10_float = 103,
    astc_12X12_float = 104,
};

pub const SDL_GPUPrimitiveType = enum(c_uint) {
    trianglelist = 0,
    trianglestrip = 1,
    linelist = 2,
    linestrip = 3,
    pointlist = 4,
};

pub const SDL_GPUVertexInputRate = enum(c_uint) {
    vertex = 0,
    instance = 1,
};

pub const SDL_GPUVertexElementFormat = enum(c_uint) {
    invalid = 0,
    int = 1,
    int2 = 2,
    int3 = 3,
    int4 = 4,
    uint = 5,
    uint2 = 6,
    uint3 = 7,
    uint4 = 8,
    float = 9,
    float2 = 10,
    float3 = 11,
    float4 = 12,
    byte2 = 13,
    byte4 = 14,
    ubyte2 = 15,
    ubyte4 = 16,
    byte2_norm = 17,
    byte4_norm = 18,
    ubyte2_norm = 19,
    ubyte4_norm = 20,
    short2 = 21,
    short4 = 22,
    ushort2 = 23,
    ushort4 = 24,
    short2_norm = 25,
    short4_norm = 26,
    ushort2_norm = 27,
    ushort4_norm = 28,
    half2 = 29,
    half4 = 30,
};

pub const SDL_GPUShaderStage = enum(c_uint) {
    vertex = 0,
    fragment = 1,
};

pub const SDL_GPUShaderCreateInfo = extern struct {
    code_size: usize = 0,
    code: [*c]const u8 = null,
    entrypoint: [*c]const u8 = null,
    format: SDL_GPUShaderFormat = .invalid,
    stage: SDL_GPUShaderStage = @import("std").mem.zeroes(SDL_GPUShaderStage),
    num_samplers: u32 = 0,
    num_storage_textures: u32 = 0,
    num_storage_buffers: u32 = 0,
    num_uniform_buffers: u32 = 0,
    props: SDL_PropertiesID = 0,
};

pub const SDL_GPUTextureType = enum(c_uint) {
    texturetype_2d = 0,
    texturetype_2d_array = 1,
    texturetype_3d = 2,
    texturetype_cube = 3,
    texturetype_cube_array = 4,
};

pub const SDL_GPUTextureUsageFlags = u32;
pub const SDL_GPU_TEXTUREUSAGE_SAMPLER = @as(c_uint, 1) << @as(c_int, 0);
pub const SDL_GPU_TEXTUREUSAGE_COLOR_TARGET = @as(c_uint, 1) << @as(c_int, 1);
pub const SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET = @as(c_uint, 1) << @as(c_int, 2);
pub const SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 3);
pub const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 4);
pub const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE = @as(c_uint, 1) << @as(c_int, 5);
pub const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE = @as(c_uint, 1) << @as(c_int, 6);

pub const SDL_GPUTextureCreateInfo = extern struct {
    type: SDL_GPUTextureType = @import("std").mem.zeroes(SDL_GPUTextureType),
    format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
    usage: SDL_GPUTextureUsageFlags = 0,
    width: u32 = 0,
    height: u32 = 0,
    layer_count_or_depth: u32 = 0,
    num_levels: u32 = 0,
    sample_count: SDL_GPUSampleCount = @import("std").mem.zeroes(SDL_GPUSampleCount),
    props: SDL_PropertiesID = 0,
};

pub const SDL_GPUBufferUsageFlags = u32;
pub const SDL_GPU_BUFFERUSAGE_VERTEX = @as(c_uint, 1) << @as(c_int, 0);
pub const SDL_GPU_BUFFERUSAGE_INDEX = @as(c_uint, 1) << @as(c_int, 1);
pub const SDL_GPU_BUFFERUSAGE_INDIRECT = @as(c_uint, 1) << @as(c_int, 2);
pub const SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 3);
pub const SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 4);
pub const SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE = @as(c_uint, 1) << @as(c_int, 5);

pub const SDL_GPUBufferCreateInfo = extern struct {
    usage: SDL_GPUBufferUsageFlags = 0,
    size: u32 = 0,
    props: SDL_PropertiesID = 0,
};

pub const SDL_GPUTransferBufferCreateInfo = extern struct {
    usage: SDL_GPUTransferBufferUsage = @import("std").mem.zeroes(SDL_GPUTransferBufferUsage),
    size: u32 = 0,
    props: SDL_PropertiesID = 0,
};

pub const SDL_GPUTransferBufferUsage = enum(c_uint) {
    upload = 0,
    download = 1,
};

pub const SDL_GPULoadOp = enum(c_uint) {
    load = 0,
    clear = 1,
    dont_care = 2,
};

pub const SDL_GPUStoreOp = enum(c_uint) {
    store = 0,
    dont_care = 1,
    resolve = 2,
    resolve_and_store = 3,
};

pub const SDL_GPUColorTargetInfo = extern struct {
    texture: ?*SDL_GPUTexture = null,
    mip_level: u32 = 0,
    layer_or_depth_plane: u32 = 0,
    clear_color: SDL_FColor = @import("std").mem.zeroes(SDL_FColor),
    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
    resolve_texture: ?*SDL_GPUTexture = null,
    resolve_mip_level: u32 = 0,
    resolve_layer: u32 = 0,
    cycle: bool = false,
    cycle_resolve_texture: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

pub const SDL_FColor = extern struct {
    r: f32 = 0,
    g: f32 = 0,
    b: f32 = 0,
    a: f32 = 0,
};

pub const SDL_GPUDepthStencilTargetInfo = extern struct {
    texture: ?*SDL_GPUTexture = null,
    clear_depth: f32 = 0,
    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
    stencil_load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    stencil_store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
    cycle: bool = false,
    clear_stencil: u8 = 0,
    mip_level: u8 = 0,
    layer: u8 = 0,
};

pub const SDL_GPUViewport = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    w: f32 = 0,
    h: f32 = 0,
    min_depth: f32 = 0,
    max_depth: f32 = 0,
};

pub const SDL_Rect = extern struct {
    x: c_int = 0,
    y: c_int = 0,
    w: c_int = 0,
    h: c_int = 0,
    pub const SDL_RectToFRect = __root.SDL_RectToFRect;
    pub const SDL_RectEmpty = __root.SDL_RectEmpty;
    pub const SDL_RectsEqual = __root.SDL_RectsEqual;
    pub const SDL_HasRectIntersection = __root.SDL_HasRectIntersection;
    pub const SDL_GetRectIntersection = __root.SDL_GetRectIntersection;
    pub const SDL_GetRectUnion = __root.SDL_GetRectUnion;
    pub const SDL_GetRectAndLineIntersection = __root.SDL_GetRectAndLineIntersection;
    pub const SDL_GetDisplayForRect = __root.SDL_GetDisplayForRect;
    pub const RectToFRect = __root.SDL_RectToFRect;
    pub const RectEmpty = __root.SDL_RectEmpty;
    pub const RectsEqual = __root.SDL_RectsEqual;
    pub const HasRectIntersection = __root.SDL_HasRectIntersection;
    pub const GetRectIntersection = __root.SDL_GetRectIntersection;
    pub const GetRectUnion = __root.SDL_GetRectUnion;
    pub const GetRectAndLineIntersection = __root.SDL_GetRectAndLineIntersection;
    pub const GetDisplayForRect = __root.SDL_GetDisplayForRect;
};

pub const SDL_GPUBufferBinding = extern struct {
    buffer: ?*SDL_GPUBuffer = null,
    offset: u32 = 0,
};

pub const SDL_GPUIndexElementSize = enum(c_uint) {
    size_16bit = 0,
    size_32bit = 1,
};

pub const SDL_GPUTextureSamplerBinding = extern struct {
    texture: ?*SDL_GPUTexture = null,
    sampler: ?*SDL_GPUSampler = null,
};

pub const struct_SDL_GPUStorageTextureReadWriteBinding = extern struct {
    texture: ?*SDL_GPUTexture = null,
    mip_level: u32 = 0,
    layer: u32 = 0,
    cycle: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_GPUStorageTextureReadWriteBinding = extern struct {
    texture: ?*SDL_GPUTexture = null,
    mip_level: u32 = 0,
    layer: u32 = 0,
    cycle: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_GPUStorageBufferReadWriteBinding = extern struct {
    buffer: ?*SDL_GPUBuffer = null,
    cycle: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_GPUTextureTransferInfo = extern struct {
    transfer_buffer: ?*SDL_GPUTransferBuffer = null,
    offset: u32 = 0,
    pixels_per_row: u32 = 0,
    rows_per_layer: u32 = 0,
};

pub const SDL_GPUTextureRegion = extern struct {
    texture: ?*SDL_GPUTexture = null,
    mip_level: u32 = 0,
    layer: u32 = 0,
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0,
    w: u32 = 0,
    h: u32 = 0,
    d: u32 = 0,
};

pub const SDL_GPUTransferBufferLocation = extern struct {
    transfer_buffer: ?*SDL_GPUTransferBuffer = null,
    offset: u32 = 0,
};

pub const SDL_GPUBufferRegion = extern struct {
    buffer: ?*SDL_GPUBuffer = null,
    offset: u32 = 0,
    size: u32 = 0,
};

pub const SDL_GPUTextureLocation = extern struct {
    texture: ?*SDL_GPUTexture = null,
    mip_level: u32 = 0,
    layer: u32 = 0,
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0,
};

pub const SDL_GPUBufferLocation = extern struct {
    buffer: ?*SDL_GPUBuffer = null,
    offset: u32 = 0,
};

pub const SDL_GPUBlitRegion = extern struct {
    texture: ?*SDL_GPUTexture = null,
    mip_level: u32 = 0,
    layer_or_depth_plane: u32 = 0,
    x: u32 = 0,
    y: u32 = 0,
    w: u32 = 0,
    h: u32 = 0,
};

pub const SDL_GPUBlitInfo = extern struct {
    source: SDL_GPUBlitRegion = @import("std").mem.zeroes(SDL_GPUBlitRegion),
    destination: SDL_GPUBlitRegion = @import("std").mem.zeroes(SDL_GPUBlitRegion),
    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    clear_color: SDL_FColor = @import("std").mem.zeroes(SDL_FColor),
    flip_mode: SDL_FlipMode = @import("std").mem.zeroes(SDL_FlipMode),
    filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
    cycle: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

pub const SDL_FlipMode = enum(c_uint) {
    none = 0,
    horizontal = 1,
    vertical = 2,
    horizontal_and_vertical = 3,
};

pub const SDL_GPUFence = opaque {};

pub const SDL_PixelFormat = enum(c_uint) {
    unknown = 0,
    index1lsb = 286261504,
    index1msb = 287310080,
    index2lsb = 470811136,
    index2msb = 471859712,
    index4lsb = 303039488,
    index4msb = 304088064,
    index8 = 318769153,
    rgb332 = 336660481,
    xrgb4444 = 353504258,
    xbgr4444 = 357698562,
    xrgb1555 = 353570562,
    xbgr1555 = 357764866,
    argb4444 = 355602434,
    rgba4444 = 356651010,
    abgr4444 = 359796738,
    bgra4444 = 360845314,
    argb1555 = 355667970,
    rgba5551 = 356782082,
    abgr1555 = 359862274,
    bgra5551 = 360976386,
    rgb565 = 353701890,
    bgr565 = 357896194,
    rgb24 = 386930691,
    bgr24 = 390076419,
    xrgb8888 = 370546692,
    rgbx8888 = 371595268,
    xbgr8888 = 374740996,
    bgrx8888 = 375789572,
    argb8888 = 372645892,
    rgba8888 = 373694468,
    abgr8888 = 376840196,
    bgra8888 = 377888772,
    xrgb2101010 = 370614276,
    xbgr2101010 = 374808580,
    argb2101010 = 372711428,
    abgr2101010 = 376905732,
    rgb48 = 403714054,
    bgr48 = 406859782,
    rgba64 = 404766728,
    argb64 = 405815304,
    bgra64 = 407912456,
    abgr64 = 408961032,
    rgb48_float = 437268486,
    bgr48_float = 440414214,
    rgba64_float = 438321160,
    argb64_float = 439369736,
    bgra64_float = 441466888,
    abgr64_float = 442515464,
    rgb96_float = 454057996,
    bgr96_float = 457203724,
    rgba128_float = 455114768,
    argb128_float = 456163344,
    bgra128_float = 458260496,
    abgr128_float = 459309072,
    yv12 = 842094169,
    iyuv = 1448433993,
    yuy2 = 844715353,
    uyvy = 1498831189,
    yvyu = 1431918169,
    nv12 = 842094158,
    nv21 = 825382478,
    p010 = 808530000,
    external_oes = 542328143,
    mjpg = 1196444237,
    rgba32 = 376840196,
    argb32 = 377888772,
    bgra32 = 372645892,
    abgr32 = 373694468,
    rgbx32 = 374740996,
    xrgb32 = 375789572,
    bgrx32 = 370546692,
    xbgr32 = 371595268,
};

pub const SDL_GPUComputePass = opaque {
    pub const SDL_BindGPUComputePipeline = __root.SDL_BindGPUComputePipeline;
    pub const SDL_BindGPUComputeSamplers = __root.SDL_BindGPUComputeSamplers;
    pub const SDL_BindGPUComputeStorageTextures = __root.SDL_BindGPUComputeStorageTextures;
    pub const SDL_BindGPUComputeStorageBuffers = __root.SDL_BindGPUComputeStorageBuffers;
    pub const SDL_DispatchGPUCompute = __root.SDL_DispatchGPUCompute;
    pub const SDL_DispatchGPUComputeIndirect = __root.SDL_DispatchGPUComputeIndirect;
    pub const SDL_EndGPUComputePass = __root.SDL_EndGPUComputePass;
    pub const BindGPUComputePipeline = __root.SDL_BindGPUComputePipeline;
    pub const BindGPUComputeSamplers = __root.SDL_BindGPUComputeSamplers;
    pub const BindGPUComputeStorageTextures = __root.SDL_BindGPUComputeStorageTextures;
    pub const BindGPUComputeStorageBuffers = __root.SDL_BindGPUComputeStorageBuffers;
    pub const DispatchGPUCompute = __root.SDL_DispatchGPUCompute;
    pub const DispatchGPUComputeIndirect = __root.SDL_DispatchGPUComputeIndirect;
    pub const EndGPUComputePass = __root.SDL_EndGPUComputePass;
};

pub const SDL_GPUCopyPass = opaque {
    pub const SDL_UploadToGPUTexture = __root.SDL_UploadToGPUTexture;
    pub const SDL_UploadToGPUBuffer = __root.SDL_UploadToGPUBuffer;
    pub const SDL_CopyGPUTextureToTexture = __root.SDL_CopyGPUTextureToTexture;
    pub const SDL_CopyGPUBufferToBuffer = __root.SDL_CopyGPUBufferToBuffer;
    pub const SDL_DownloadFromGPUTexture = __root.SDL_DownloadFromGPUTexture;
    pub const SDL_DownloadFromGPUBuffer = __root.SDL_DownloadFromGPUBuffer;
    pub const SDL_EndGPUCopyPass = __root.SDL_EndGPUCopyPass;
    pub const UploadToGPUTexture = __root.SDL_UploadToGPUTexture;
    pub const UploadToGPUBuffer = __root.SDL_UploadToGPUBuffer;
    pub const CopyGPUTextureToTexture = __root.SDL_CopyGPUTextureToTexture;
    pub const CopyGPUBufferToBuffer = __root.SDL_CopyGPUBufferToBuffer;
    pub const DownloadFromGPUTexture = __root.SDL_DownloadFromGPUTexture;
    pub const DownloadFromGPUBuffer = __root.SDL_DownloadFromGPUBuffer;
    pub const EndGPUCopyPass = __root.SDL_EndGPUCopyPass;
};

pub const SDL_GPUDevice = opaque {
    pub const SDL_DestroyGPUDevice = __root.SDL_DestroyGPUDevice;
    pub const SDL_GetGPUDeviceDriver = __root.SDL_GetGPUDeviceDriver;
    pub const SDL_GetGPUShaderFormats = __root.SDL_GetGPUShaderFormats;
    pub const SDL_GetGPUDeviceProperties = __root.SDL_GetGPUDeviceProperties;
    pub const SDL_CreateGPUComputePipeline = __root.SDL_CreateGPUComputePipeline;
    pub const SDL_CreateGPUGraphicsPipeline = __root.SDL_CreateGPUGraphicsPipeline;
    pub const SDL_CreateGPUSampler = __root.SDL_CreateGPUSampler;
    pub const SDL_CreateGPUShader = __root.SDL_CreateGPUShader;
    pub const SDL_CreateGPUTexture = __root.SDL_CreateGPUTexture;
    pub const SDL_CreateGPUBuffer = __root.SDL_CreateGPUBuffer;
    pub const SDL_CreateGPUTransferBuffer = __root.SDL_CreateGPUTransferBuffer;
    pub const SDL_SetGPUBufferName = __root.SDL_SetGPUBufferName;
    pub const SDL_SetGPUTextureName = __root.SDL_SetGPUTextureName;
    pub const SDL_ReleaseGPUTexture = __root.SDL_ReleaseGPUTexture;
    pub const SDL_ReleaseGPUSampler = __root.SDL_ReleaseGPUSampler;
    pub const SDL_ReleaseGPUBuffer = __root.SDL_ReleaseGPUBuffer;
    pub const SDL_ReleaseGPUTransferBuffer = __root.SDL_ReleaseGPUTransferBuffer;
    pub const SDL_ReleaseGPUComputePipeline = __root.SDL_ReleaseGPUComputePipeline;
    pub const SDL_ReleaseGPUShader = __root.SDL_ReleaseGPUShader;
    pub const SDL_ReleaseGPUGraphicsPipeline = __root.SDL_ReleaseGPUGraphicsPipeline;
    pub const SDL_AcquireGPUCommandBuffer = __root.SDL_AcquireGPUCommandBuffer;
    pub const SDL_MapGPUTransferBuffer = __root.SDL_MapGPUTransferBuffer;
    pub const SDL_UnmapGPUTransferBuffer = __root.SDL_UnmapGPUTransferBuffer;
    pub const SDL_WindowSupportsGPUSwapchainComposition = __root.SDL_WindowSupportsGPUSwapchainComposition;
    pub const SDL_WindowSupportsGPUPresentMode = __root.SDL_WindowSupportsGPUPresentMode;
    pub const SDL_ClaimWindowForGPUDevice = __root.SDL_ClaimWindowForGPUDevice;
    pub const SDL_ReleaseWindowFromGPUDevice = __root.SDL_ReleaseWindowFromGPUDevice;
    pub const SDL_SetGPUSwapchainParameters = __root.SDL_SetGPUSwapchainParameters;
    pub const SDL_SetGPUAllowedFramesInFlight = __root.SDL_SetGPUAllowedFramesInFlight;
    pub const SDL_GetGPUSwapchainTextureFormat = __root.SDL_GetGPUSwapchainTextureFormat;
    pub const SDL_WaitForGPUSwapchain = __root.SDL_WaitForGPUSwapchain;
    pub const SDL_WaitForGPUIdle = __root.SDL_WaitForGPUIdle;
    pub const SDL_WaitForGPUFences = __root.SDL_WaitForGPUFences;
    pub const SDL_QueryGPUFence = __root.SDL_QueryGPUFence;
    pub const SDL_ReleaseGPUFence = __root.SDL_ReleaseGPUFence;
    pub const SDL_GPUTextureSupportsFormat = __root.SDL_GPUTextureSupportsFormat;
    pub const SDL_GPUTextureSupportsSampleCount = __root.SDL_GPUTextureSupportsSampleCount;
    pub const SDL_CreateGPURenderer = __root.SDL_CreateGPURenderer;
    pub const DestroyGPUDevice = __root.SDL_DestroyGPUDevice;
    pub const GetGPUDeviceDriver = __root.SDL_GetGPUDeviceDriver;
    pub const GetGPUShaderFormats = __root.SDL_GetGPUShaderFormats;
    pub const GetGPUDeviceProperties = __root.SDL_GetGPUDeviceProperties;
    pub const CreateGPUComputePipeline = __root.SDL_CreateGPUComputePipeline;
    pub const CreateGPUGraphicsPipeline = __root.SDL_CreateGPUGraphicsPipeline;
    pub const CreateGPUSampler = __root.SDL_CreateGPUSampler;
    pub const CreateGPUShader = __root.SDL_CreateGPUShader;
    pub const CreateGPUTexture = __root.SDL_CreateGPUTexture;
    pub const CreateGPUBuffer = __root.SDL_CreateGPUBuffer;
    pub const CreateGPUTransferBuffer = __root.SDL_CreateGPUTransferBuffer;
    pub const SetGPUBufferName = __root.SDL_SetGPUBufferName;
    pub const SetGPUTextureName = __root.SDL_SetGPUTextureName;
    pub const ReleaseGPUTexture = __root.SDL_ReleaseGPUTexture;
    pub const ReleaseGPUSampler = __root.SDL_ReleaseGPUSampler;
    pub const ReleaseGPUBuffer = __root.SDL_ReleaseGPUBuffer;
    pub const ReleaseGPUTransferBuffer = __root.SDL_ReleaseGPUTransferBuffer;
    pub const ReleaseGPUComputePipeline = __root.SDL_ReleaseGPUComputePipeline;
    pub const ReleaseGPUShader = __root.SDL_ReleaseGPUShader;
    pub const ReleaseGPUGraphicsPipeline = __root.SDL_ReleaseGPUGraphicsPipeline;
    pub const AcquireGPUCommandBuffer = __root.SDL_AcquireGPUCommandBuffer;
    pub const MapGPUTransferBuffer = __root.SDL_MapGPUTransferBuffer;
    pub const UnmapGPUTransferBuffer = __root.SDL_UnmapGPUTransferBuffer;
    pub const WindowSupportsGPUSwapchainComposition = __root.SDL_WindowSupportsGPUSwapchainComposition;
    pub const WindowSupportsGPUPresentMode = __root.SDL_WindowSupportsGPUPresentMode;
    pub const ClaimWindowForGPUDevice = __root.SDL_ClaimWindowForGPUDevice;
    pub const ReleaseWindowFromGPUDevice = __root.SDL_ReleaseWindowFromGPUDevice;
    pub const SetGPUSwapchainParameters = __root.SDL_SetGPUSwapchainParameters;
    pub const SetGPUAllowedFramesInFlight = __root.SDL_SetGPUAllowedFramesInFlight;
    pub const GetGPUSwapchainTextureFormat = __root.SDL_GetGPUSwapchainTextureFormat;
    pub const WaitForGPUSwapchain = __root.SDL_WaitForGPUSwapchain;
    pub const WaitForGPUIdle = __root.SDL_WaitForGPUIdle;
    pub const WaitForGPUFences = __root.SDL_WaitForGPUFences;
    pub const QueryGPUFence = __root.SDL_QueryGPUFence;
    pub const ReleaseGPUFence = __root.SDL_ReleaseGPUFence;
    pub const GPUTextureSupportsFormat = __root.SDL_GPUTextureSupportsFormat;
    pub const GPUTextureSupportsSampleCount = __root.SDL_GPUTextureSupportsSampleCount;
    pub const CreateGPURenderer = __root.SDL_CreateGPURenderer;
};

pub const SDL_GPUBuffer = opaque {};
pub const SDL_GPUTransferBuffer = opaque {};
pub const SDL_GPUTexture = opaque {};
pub const SDL_GPUSampler = opaque {};
pub const SDL_GPUShader = opaque {};
pub const SDL_GPUComputePipeline = opaque {};
pub const SDL_GPUGraphicsPipeline = opaque {};

pub const SDL_GPUCommandBuffer = opaque {
    pub const SDL_InsertGPUDebugLabel = __root.SDL_InsertGPUDebugLabel;
    pub const SDL_PushGPUDebugGroup = __root.SDL_PushGPUDebugGroup;
    pub const SDL_PopGPUDebugGroup = __root.SDL_PopGPUDebugGroup;
    pub const SDL_PushGPUVertexUniformData = __root.SDL_PushGPUVertexUniformData;
    pub const SDL_PushGPUFragmentUniformData = __root.SDL_PushGPUFragmentUniformData;
    pub const SDL_PushGPUComputeUniformData = __root.SDL_PushGPUComputeUniformData;
    pub const SDL_BeginGPURenderPass = __root.SDL_BeginGPURenderPass;
    pub const SDL_BeginGPUComputePass = __root.SDL_BeginGPUComputePass;
    pub const SDL_BeginGPUCopyPass = __root.SDL_BeginGPUCopyPass;
    pub const SDL_GenerateMipmapsForGPUTexture = __root.SDL_GenerateMipmapsForGPUTexture;
    pub const SDL_BlitGPUTexture = __root.SDL_BlitGPUTexture;
    pub const SDL_AcquireGPUSwapchainTexture = __root.SDL_AcquireGPUSwapchainTexture;
    pub const SDL_WaitAndAcquireGPUSwapchainTexture = __root.SDL_WaitAndAcquireGPUSwapchainTexture;
    pub const SDL_SubmitGPUCommandBuffer = __root.SDL_SubmitGPUCommandBuffer;
    pub const SDL_SubmitGPUCommandBufferAndAcquireFence = __root.SDL_SubmitGPUCommandBufferAndAcquireFence;
    pub const SDL_CancelGPUCommandBuffer = __root.SDL_CancelGPUCommandBuffer;
    pub const InsertGPUDebugLabel = __root.SDL_InsertGPUDebugLabel;
    pub const PushGPUDebugGroup = __root.SDL_PushGPUDebugGroup;
    pub const PopGPUDebugGroup = __root.SDL_PopGPUDebugGroup;
    pub const PushGPUVertexUniformData = __root.SDL_PushGPUVertexUniformData;
    pub const PushGPUFragmentUniformData = __root.SDL_PushGPUFragmentUniformData;
    pub const PushGPUComputeUniformData = __root.SDL_PushGPUComputeUniformData;
    pub const BeginGPURenderPass = __root.SDL_BeginGPURenderPass;
    pub const BeginGPUComputePass = __root.SDL_BeginGPUComputePass;
    pub const BeginGPUCopyPass = __root.SDL_BeginGPUCopyPass;
    pub const GenerateMipmapsForGPUTexture = __root.SDL_GenerateMipmapsForGPUTexture;
    pub const BlitGPUTexture = __root.SDL_BlitGPUTexture;
    pub const AcquireGPUSwapchainTexture = __root.SDL_AcquireGPUSwapchainTexture;
    pub const WaitAndAcquireGPUSwapchainTexture = __root.SDL_WaitAndAcquireGPUSwapchainTexture;
    pub const SubmitGPUCommandBuffer = __root.SDL_SubmitGPUCommandBuffer;
    pub const SubmitGPUCommandBufferAndAcquireFence = __root.SDL_SubmitGPUCommandBufferAndAcquireFence;
    pub const CancelGPUCommandBuffer = __root.SDL_CancelGPUCommandBuffer;
};

pub const SDL_GPURenderPass = opaque {
    pub const SDL_BindGPUGraphicsPipeline = __root.SDL_BindGPUGraphicsPipeline;
    pub const SDL_SetGPUViewport = __root.SDL_SetGPUViewport;
    pub const SDL_SetGPUScissor = __root.SDL_SetGPUScissor;
    pub const SDL_SetGPUBlendConstants = __root.SDL_SetGPUBlendConstants;
    pub const SDL_SetGPUStencilReference = __root.SDL_SetGPUStencilReference;
    pub const SDL_BindGPUVertexBuffers = __root.SDL_BindGPUVertexBuffers;
    pub const SDL_BindGPUIndexBuffer = __root.SDL_BindGPUIndexBuffer;
    pub const SDL_BindGPUVertexSamplers = __root.SDL_BindGPUVertexSamplers;
    pub const SDL_BindGPUVertexStorageTextures = __root.SDL_BindGPUVertexStorageTextures;
    pub const SDL_BindGPUVertexStorageBuffers = __root.SDL_BindGPUVertexStorageBuffers;
    pub const SDL_BindGPUFragmentSamplers = __root.SDL_BindGPUFragmentSamplers;
    pub const SDL_BindGPUFragmentStorageTextures = __root.SDL_BindGPUFragmentStorageTextures;
    pub const SDL_BindGPUFragmentStorageBuffers = __root.SDL_BindGPUFragmentStorageBuffers;
    pub const SDL_DrawGPUIndexedPrimitives = __root.SDL_DrawGPUIndexedPrimitives;
    pub const SDL_DrawGPUPrimitives = __root.SDL_DrawGPUPrimitives;
    pub const SDL_DrawGPUPrimitivesIndirect = __root.SDL_DrawGPUPrimitivesIndirect;
    pub const SDL_DrawGPUIndexedPrimitivesIndirect = __root.SDL_DrawGPUIndexedPrimitivesIndirect;
    pub const SDL_EndGPURenderPass = __root.SDL_EndGPURenderPass;
    pub const BindGPUGraphicsPipeline = __root.SDL_BindGPUGraphicsPipeline;
    pub const SetGPUViewport = __root.SDL_SetGPUViewport;
    pub const SetGPUScissor = __root.SDL_SetGPUScissor;
    pub const SetGPUBlendConstants = __root.SDL_SetGPUBlendConstants;
    pub const SetGPUStencilReference = __root.SDL_SetGPUStencilReference;
    pub const BindGPUVertexBuffers = __root.SDL_BindGPUVertexBuffers;
    pub const BindGPUIndexBuffer = __root.SDL_BindGPUIndexBuffer;
    pub const BindGPUVertexSamplers = __root.SDL_BindGPUVertexSamplers;
    pub const BindGPUVertexStorageTextures = __root.SDL_BindGPUVertexStorageTextures;
    pub const BindGPUVertexStorageBuffers = __root.SDL_BindGPUVertexStorageBuffers;
    pub const BindGPUFragmentSamplers = __root.SDL_BindGPUFragmentSamplers;
    pub const BindGPUFragmentStorageTextures = __root.SDL_BindGPUFragmentStorageTextures;
    pub const BindGPUFragmentStorageBuffers = __root.SDL_BindGPUFragmentStorageBuffers;
    pub const DrawGPUIndexedPrimitives = __root.SDL_DrawGPUIndexedPrimitives;
    pub const DrawGPUPrimitives = __root.SDL_DrawGPUPrimitives;
    pub const DrawGPUPrimitivesIndirect = __root.SDL_DrawGPUPrimitivesIndirect;
    pub const DrawGPUIndexedPrimitivesIndirect = __root.SDL_DrawGPUIndexedPrimitivesIndirect;
    pub const EndGPURenderPass = __root.SDL_EndGPURenderPass;
};

pub extern fn SDL_DestroyGPUDevice(device: ?*SDL_GPUDevice) void;
pub extern fn SDL_GetNumGPUDrivers() c_int;
pub extern fn SDL_GetGPUDriver(index: c_int) [*c]const u8;
pub extern fn SDL_GetGPUDeviceDriver(device: ?*SDL_GPUDevice) [*c]const u8;
pub extern fn SDL_GetGPUShaderFormats(device: ?*SDL_GPUDevice) SDL_GPUShaderFormat;
pub extern fn SDL_GetGPUDeviceProperties(device: ?*SDL_GPUDevice) SDL_PropertiesID;
pub extern fn SDL_CreateGPUComputePipeline(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUComputePipelineCreateInfo) ?*SDL_GPUComputePipeline;
pub extern fn SDL_CreateGPUGraphicsPipeline(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUGraphicsPipelineCreateInfo) ?*SDL_GPUGraphicsPipeline;
pub extern fn SDL_CreateGPUSampler(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUSamplerCreateInfo) ?*SDL_GPUSampler;
pub extern fn SDL_CreateGPUShader(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUShaderCreateInfo) ?*SDL_GPUShader;
pub extern fn SDL_CreateGPUTexture(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUTextureCreateInfo) ?*SDL_GPUTexture;
pub extern fn SDL_CreateGPUBuffer(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUBufferCreateInfo) ?*SDL_GPUBuffer;
pub extern fn SDL_CreateGPUTransferBuffer(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUTransferBufferCreateInfo) ?*SDL_GPUTransferBuffer;
pub extern fn SDL_SetGPUBufferName(device: ?*SDL_GPUDevice, buffer: ?*SDL_GPUBuffer, text: [*c]const u8) void;
pub extern fn SDL_SetGPUTextureName(device: ?*SDL_GPUDevice, texture: ?*SDL_GPUTexture, text: [*c]const u8) void;
pub extern fn SDL_InsertGPUDebugLabel(command_buffer: ?*SDL_GPUCommandBuffer, text: [*c]const u8) void;
pub extern fn SDL_PushGPUDebugGroup(command_buffer: ?*SDL_GPUCommandBuffer, name: [*c]const u8) void;
pub extern fn SDL_PopGPUDebugGroup(command_buffer: ?*SDL_GPUCommandBuffer) void;
pub extern fn SDL_ReleaseGPUTexture(device: ?*SDL_GPUDevice, texture: ?*SDL_GPUTexture) void;
pub extern fn SDL_ReleaseGPUSampler(device: ?*SDL_GPUDevice, sampler: ?*SDL_GPUSampler) void;
pub extern fn SDL_ReleaseGPUBuffer(device: ?*SDL_GPUDevice, buffer: ?*SDL_GPUBuffer) void;
pub extern fn SDL_ReleaseGPUTransferBuffer(device: ?*SDL_GPUDevice, transfer_buffer: ?*SDL_GPUTransferBuffer) void;
pub extern fn SDL_ReleaseGPUComputePipeline(device: ?*SDL_GPUDevice, compute_pipeline: ?*SDL_GPUComputePipeline) void;
pub extern fn SDL_ReleaseGPUShader(device: ?*SDL_GPUDevice, shader: ?*SDL_GPUShader) void;
pub extern fn SDL_ReleaseGPUGraphicsPipeline(device: ?*SDL_GPUDevice, graphics_pipeline: ?*SDL_GPUGraphicsPipeline) void;
pub extern fn SDL_AcquireGPUCommandBuffer(device: ?*SDL_GPUDevice) ?*SDL_GPUCommandBuffer;
pub extern fn SDL_PushGPUVertexUniformData(command_buffer: ?*SDL_GPUCommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub extern fn SDL_PushGPUFragmentUniformData(command_buffer: ?*SDL_GPUCommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub extern fn SDL_PushGPUComputeUniformData(command_buffer: ?*SDL_GPUCommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub extern fn SDL_BeginGPURenderPass(command_buffer: ?*SDL_GPUCommandBuffer, color_target_infos: [*c]const SDL_GPUColorTargetInfo, num_color_targets: u32, depth_stencil_target_info: [*c]const SDL_GPUDepthStencilTargetInfo) ?*SDL_GPURenderPass;
pub extern fn SDL_BindGPUGraphicsPipeline(render_pass: ?*SDL_GPURenderPass, graphics_pipeline: ?*SDL_GPUGraphicsPipeline) void;
pub extern fn SDL_SetGPUViewport(render_pass: ?*SDL_GPURenderPass, viewport: [*c]const SDL_GPUViewport) void;
pub extern fn SDL_SetGPUScissor(render_pass: ?*SDL_GPURenderPass, scissor: [*c]const SDL_Rect) void;
pub extern fn SDL_SetGPUBlendConstants(render_pass: ?*SDL_GPURenderPass, blend_constants: SDL_FColor) void;
pub extern fn SDL_SetGPUStencilReference(render_pass: ?*SDL_GPURenderPass, reference: u8) void;
pub extern fn SDL_BindGPUVertexBuffers(render_pass: ?*SDL_GPURenderPass, first_slot: u32, bindings: [*c]const SDL_GPUBufferBinding, num_bindings: u32) void;
pub extern fn SDL_BindGPUIndexBuffer(render_pass: ?*SDL_GPURenderPass, binding: [*c]const SDL_GPUBufferBinding, index_element_size: SDL_GPUIndexElementSize) void;
pub extern fn SDL_BindGPUVertexSamplers(render_pass: ?*SDL_GPURenderPass, first_slot: u32, texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding, num_bindings: u32) void;
pub extern fn SDL_BindGPUVertexStorageTextures(render_pass: ?*SDL_GPURenderPass, first_slot: u32, storage_textures: [*c]const ?*SDL_GPUTexture, num_bindings: u32) void;
pub extern fn SDL_BindGPUVertexStorageBuffers(render_pass: ?*SDL_GPURenderPass, first_slot: u32, storage_buffers: [*c]const ?*SDL_GPUBuffer, num_bindings: u32) void;
pub extern fn SDL_BindGPUFragmentSamplers(render_pass: ?*SDL_GPURenderPass, first_slot: u32, texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding, num_bindings: u32) void;
pub extern fn SDL_BindGPUFragmentStorageTextures(render_pass: ?*SDL_GPURenderPass, first_slot: u32, storage_textures: [*c]const ?*SDL_GPUTexture, num_bindings: u32) void;
pub extern fn SDL_BindGPUFragmentStorageBuffers(render_pass: ?*SDL_GPURenderPass, first_slot: u32, storage_buffers: [*c]const ?*SDL_GPUBuffer, num_bindings: u32) void;
pub extern fn SDL_DrawGPUIndexedPrimitives(render_pass: ?*SDL_GPURenderPass, num_indices: u32, num_instances: u32, first_index: u32, vertex_offset: i32, first_instance: u32) void;
pub extern fn SDL_DrawGPUPrimitives(render_pass: ?*SDL_GPURenderPass, num_vertices: u32, num_instances: u32, first_vertex: u32, first_instance: u32) void;
pub extern fn SDL_DrawGPUPrimitivesIndirect(render_pass: ?*SDL_GPURenderPass, buffer: ?*SDL_GPUBuffer, offset: u32, draw_count: u32) void;
pub extern fn SDL_DrawGPUIndexedPrimitivesIndirect(render_pass: ?*SDL_GPURenderPass, buffer: ?*SDL_GPUBuffer, offset: u32, draw_count: u32) void;
pub extern fn SDL_EndGPURenderPass(render_pass: ?*SDL_GPURenderPass) void;
pub extern fn SDL_BeginGPUComputePass(command_buffer: ?*SDL_GPUCommandBuffer, storage_texture_bindings: [*c]const SDL_GPUStorageTextureReadWriteBinding, num_storage_texture_bindings: u32, storage_buffer_bindings: [*c]const SDL_GPUStorageBufferReadWriteBinding, num_storage_buffer_bindings: u32) ?*SDL_GPUComputePass;
pub extern fn SDL_BindGPUComputePipeline(compute_pass: ?*SDL_GPUComputePass, compute_pipeline: ?*SDL_GPUComputePipeline) void;
pub extern fn SDL_BindGPUComputeSamplers(compute_pass: ?*SDL_GPUComputePass, first_slot: u32, texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding, num_bindings: u32) void;
pub extern fn SDL_BindGPUComputeStorageTextures(compute_pass: ?*SDL_GPUComputePass, first_slot: u32, storage_textures: [*c]const ?*SDL_GPUTexture, num_bindings: u32) void;
pub extern fn SDL_BindGPUComputeStorageBuffers(compute_pass: ?*SDL_GPUComputePass, first_slot: u32, storage_buffers: [*c]const ?*SDL_GPUBuffer, num_bindings: u32) void;
pub extern fn SDL_DispatchGPUCompute(compute_pass: ?*SDL_GPUComputePass, groupcount_x: u32, groupcount_y: u32, groupcount_z: u32) void;
pub extern fn SDL_DispatchGPUComputeIndirect(compute_pass: ?*SDL_GPUComputePass, buffer: ?*SDL_GPUBuffer, offset: u32) void;
pub extern fn SDL_EndGPUComputePass(compute_pass: ?*SDL_GPUComputePass) void;
pub extern fn SDL_MapGPUTransferBuffer(device: ?*SDL_GPUDevice, transfer_buffer: ?*SDL_GPUTransferBuffer, cycle: bool) ?*anyopaque;
pub extern fn SDL_UnmapGPUTransferBuffer(device: ?*SDL_GPUDevice, transfer_buffer: ?*SDL_GPUTransferBuffer) void;
pub extern fn SDL_BeginGPUCopyPass(command_buffer: ?*SDL_GPUCommandBuffer) ?*SDL_GPUCopyPass;
pub extern fn SDL_UploadToGPUTexture(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTextureTransferInfo, destination: [*c]const SDL_GPUTextureRegion, cycle: bool) void;
pub extern fn SDL_UploadToGPUBuffer(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTransferBufferLocation, destination: [*c]const SDL_GPUBufferRegion, cycle: bool) void;
pub extern fn SDL_CopyGPUTextureToTexture(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTextureLocation, destination: [*c]const SDL_GPUTextureLocation, w: u32, h: u32, d: u32, cycle: bool) void;
pub extern fn SDL_CopyGPUBufferToBuffer(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUBufferLocation, destination: [*c]const SDL_GPUBufferLocation, size: u32, cycle: bool) void;
pub extern fn SDL_DownloadFromGPUTexture(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTextureRegion, destination: [*c]const SDL_GPUTextureTransferInfo) void;
pub extern fn SDL_DownloadFromGPUBuffer(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUBufferRegion, destination: [*c]const SDL_GPUTransferBufferLocation) void;
pub extern fn SDL_EndGPUCopyPass(copy_pass: ?*SDL_GPUCopyPass) void;
pub extern fn SDL_GenerateMipmapsForGPUTexture(command_buffer: ?*SDL_GPUCommandBuffer, texture: ?*SDL_GPUTexture) void;
pub extern fn SDL_BlitGPUTexture(command_buffer: ?*SDL_GPUCommandBuffer, info: [*c]const SDL_GPUBlitInfo) void;
pub extern fn SDL_WindowSupportsGPUSwapchainComposition(device: ?*SDL_GPUDevice, window: ?*SDL_Window, swapchain_composition: SDL_GPUSwapchainComposition) bool;
pub extern fn SDL_WindowSupportsGPUPresentMode(device: ?*SDL_GPUDevice, window: ?*SDL_Window, present_mode: SDL_GPUPresentMode) bool;
pub extern fn SDL_ClaimWindowForGPUDevice(device: ?*SDL_GPUDevice, window: ?*SDL_Window) bool;
pub extern fn SDL_ReleaseWindowFromGPUDevice(device: ?*SDL_GPUDevice, window: ?*SDL_Window) void;
pub extern fn SDL_SetGPUSwapchainParameters(device: ?*SDL_GPUDevice, window: ?*SDL_Window, swapchain_composition: SDL_GPUSwapchainComposition, present_mode: SDL_GPUPresentMode) bool;
pub extern fn SDL_SetGPUAllowedFramesInFlight(device: ?*SDL_GPUDevice, allowed_frames_in_flight: u32) bool;
pub extern fn SDL_GetGPUSwapchainTextureFormat(device: ?*SDL_GPUDevice, window: ?*SDL_Window) SDL_GPUTextureFormat;
pub extern fn SDL_AcquireGPUSwapchainTexture(command_buffer: ?*SDL_GPUCommandBuffer, window: ?*SDL_Window, swapchain_texture: [*c]?*SDL_GPUTexture, swapchain_texture_width: [*c]u32, swapchain_texture_height: [*c]u32) bool;
pub extern fn SDL_WaitForGPUSwapchain(device: ?*SDL_GPUDevice, window: ?*SDL_Window) bool;
pub extern fn SDL_WaitAndAcquireGPUSwapchainTexture(command_buffer: ?*SDL_GPUCommandBuffer, window: ?*SDL_Window, swapchain_texture: [*c]?*SDL_GPUTexture, swapchain_texture_width: [*c]u32, swapchain_texture_height: [*c]u32) bool;
pub extern fn SDL_SubmitGPUCommandBuffer(command_buffer: ?*SDL_GPUCommandBuffer) bool;
pub extern fn SDL_SubmitGPUCommandBufferAndAcquireFence(command_buffer: ?*SDL_GPUCommandBuffer) ?*SDL_GPUFence;
pub extern fn SDL_CancelGPUCommandBuffer(command_buffer: ?*SDL_GPUCommandBuffer) bool;
pub extern fn SDL_WaitForGPUIdle(device: ?*SDL_GPUDevice) bool;
pub extern fn SDL_WaitForGPUFences(device: ?*SDL_GPUDevice, wait_all: bool, fences: [*c]const ?*SDL_GPUFence, num_fences: u32) bool;
pub extern fn SDL_QueryGPUFence(device: ?*SDL_GPUDevice, fence: ?*SDL_GPUFence) bool;
pub extern fn SDL_ReleaseGPUFence(device: ?*SDL_GPUDevice, fence: ?*SDL_GPUFence) void;
pub extern fn SDL_GPUTextureFormatTexelBlockSize(format: SDL_GPUTextureFormat) u32;
pub extern fn SDL_GPUTextureSupportsFormat(device: ?*SDL_GPUDevice, format: SDL_GPUTextureFormat, @"type": SDL_GPUTextureType, usage: SDL_GPUTextureUsageFlags) bool;
pub extern fn SDL_GPUTextureSupportsSampleCount(device: ?*SDL_GPUDevice, format: SDL_GPUTextureFormat, sample_count: SDL_GPUSampleCount) bool;
pub extern fn SDL_CalculateGPUTextureFormatSize(format: SDL_GPUTextureFormat, width: u32, height: u32, depth_or_layer_count: u32) u32;
pub extern fn SDL_GetPixelFormatFromGPUTextureFormat(format: SDL_GPUTextureFormat) SDL_PixelFormat;
pub extern fn SDL_GetGPUTextureFormatFromPixelFormat(format: SDL_PixelFormat) SDL_GPUTextureFormat;

pub const SDL_GPUVulkanOptions = extern struct {
    vulkan_api_version: u32 = 0,
    feature_list: ?*anyopaque = null,
    vulkan_10_physical_device_features: ?*anyopaque = null,
    device_extension_count: u32 = 0,
    device_extension_names: [*c][*c]const u8 = null,
    instance_extension_count: u32 = 0,
    instance_extension_names: [*c][*c]const u8 = null,
};

pub extern fn SDL_GPUSupportsShaderFormats(format_flags: SDL_GPUShaderFormat, name: [*c]const u8) bool;
pub extern fn SDL_GPUSupportsProperties(props: SDL_PropertiesID) bool;
pub extern fn SDL_CreateGPUDevice(format_flags: SDL_GPUShaderFormat, debug_mode: bool, name: [*c]const u8) ?*SDL_GPUDevice;
pub extern fn SDL_CreateGPUDeviceWithProperties(props: SDL_PropertiesID) ?*SDL_GPUDevice;

pub const SDL_HintPriority = enum(c_uint) {
    default = 0,
    normal = 1,
    override = 2,
};

pub extern fn SDL_SetHintWithPriority(name: [*c]const u8, value: [*c]const u8, priority: SDL_HintPriority) bool;
pub extern fn SDL_SetHint(name: [*c]const u8, value: [*c]const u8) bool;
pub extern fn SDL_ResetHint(name: [*c]const u8) bool;
pub extern fn SDL_ResetHints() void;
pub extern fn SDL_GetHint(name: [*c]const u8) [*c]const u8;
pub extern fn SDL_GetHintBoolean(name: [*c]const u8, default_value: bool) bool;
pub const SDL_HintCallback = ?*const fn (userdata: ?*anyopaque, name: [*c]const u8, oldValue: [*c]const u8, newValue: [*c]const u8) callconv(.c) void;
pub extern fn SDL_AddHintCallback(name: [*c]const u8, callback: SDL_HintCallback, userdata: ?*anyopaque) bool;
pub extern fn SDL_RemoveHintCallback(name: [*c]const u8, callback: SDL_HintCallback, userdata: ?*anyopaque) void;

pub extern fn SDL_SetAppMetadata(appname: [*c]const u8, appversion: [*c]const u8, appidentifier: [*c]const u8) bool;
pub extern fn SDL_SetAppMetadataProperty(name: [*c]const u8, value: [*c]const u8) bool;
pub extern fn SDL_GetAppMetadataProperty(name: [*c]const u8) [*c]const u8;

pub const SDL_SystemTheme = enum(c_uint) {
    unknown = 0,
    light = 1,
    dark = 2,
};

pub const SDL_DisplayOrientation = enum(c_uint) {
    unknown = 0,
    landscape = 1,
    landscape_flipped = 2,
    portrait = 3,
    portrait_flipped = 4,
};

pub const SDL_DisplayModeData = opaque {};

pub const SDL_DisplayMode = extern struct {
    displayID: SDL_DisplayID = 0,
    format: SDL_PixelFormat = @import("std").mem.zeroes(SDL_PixelFormat),
    w: c_int = 0,
    h: c_int = 0,
    pixel_density: f32 = 0,
    refresh_rate: f32 = 0,
    refresh_rate_numerator: c_int = 0,
    refresh_rate_denominator: c_int = 0,
    internal: ?*SDL_DisplayModeData = null,
};

pub const SDL_Point = extern struct {
    x: c_int = 0,
    y: c_int = 0,
    pub const SDL_PointInRect = __root.SDL_PointInRect;
    pub const SDL_GetRectEnclosingPoints = __root.SDL_GetRectEnclosingPoints;
    pub const SDL_GetDisplayForPoint = __root.SDL_GetDisplayForPoint;
    pub const PointInRect = __root.SDL_PointInRect;
    pub const GetRectEnclosingPoints = __root.SDL_GetRectEnclosingPoints;
    pub const GetDisplayForPoint = __root.SDL_GetDisplayForPoint;
};

pub const SDL_WindowFlags = u64;
pub const SDL_SurfaceFlags = u32;

pub const SDL_Surface = extern struct {
    flags: SDL_SurfaceFlags = 0,
    format: SDL_PixelFormat = @import("std").mem.zeroes(SDL_PixelFormat),
    w: c_int = 0,
    h: c_int = 0,
    pitch: c_int = 0,
    pixels: ?*anyopaque = null,
    refcount: c_int = 0,
    reserved: ?*anyopaque = null,
    pub const SDL_DestroySurface = __root.SDL_DestroySurface;
    pub const SDL_GetSurfaceProperties = __root.SDL_GetSurfaceProperties;
    pub const SDL_SetSurfaceColorspace = __root.SDL_SetSurfaceColorspace;
    pub const SDL_GetSurfaceColorspace = __root.SDL_GetSurfaceColorspace;
    pub const SDL_CreateSurfacePalette = __root.SDL_CreateSurfacePalette;
    pub const SDL_SetSurfacePalette = __root.SDL_SetSurfacePalette;
    pub const SDL_GetSurfacePalette = __root.SDL_GetSurfacePalette;
    pub const SDL_AddSurfaceAlternateImage = __root.SDL_AddSurfaceAlternateImage;
    pub const SDL_SurfaceHasAlternateImages = __root.SDL_SurfaceHasAlternateImages;
    pub const SDL_GetSurfaceImages = __root.SDL_GetSurfaceImages;
    pub const SDL_RemoveSurfaceAlternateImages = __root.SDL_RemoveSurfaceAlternateImages;
    pub const SDL_LockSurface = __root.SDL_LockSurface;
    pub const SDL_UnlockSurface = __root.SDL_UnlockSurface;
    pub const SDL_SaveBMP_IO = __root.SDL_SaveBMP_IO;
    pub const SDL_SaveBMP = __root.SDL_SaveBMP;
    pub const SDL_SavePNG_IO = __root.SDL_SavePNG_IO;
    pub const SDL_SavePNG = __root.SDL_SavePNG;
    pub const SDL_SetSurfaceRLE = __root.SDL_SetSurfaceRLE;
    pub const SDL_SurfaceHasRLE = __root.SDL_SurfaceHasRLE;
    pub const SDL_SetSurfaceColorKey = __root.SDL_SetSurfaceColorKey;
    pub const SDL_SurfaceHasColorKey = __root.SDL_SurfaceHasColorKey;
    pub const SDL_GetSurfaceColorKey = __root.SDL_GetSurfaceColorKey;
    pub const SDL_SetSurfaceColorMod = __root.SDL_SetSurfaceColorMod;
    pub const SDL_GetSurfaceColorMod = __root.SDL_GetSurfaceColorMod;
    pub const SDL_SetSurfaceAlphaMod = __root.SDL_SetSurfaceAlphaMod;
    pub const SDL_GetSurfaceAlphaMod = __root.SDL_GetSurfaceAlphaMod;
    pub const SDL_SetSurfaceBlendMode = __root.SDL_SetSurfaceBlendMode;
    pub const SDL_GetSurfaceBlendMode = __root.SDL_GetSurfaceBlendMode;
    pub const SDL_SetSurfaceClipRect = __root.SDL_SetSurfaceClipRect;
    pub const SDL_GetSurfaceClipRect = __root.SDL_GetSurfaceClipRect;
    pub const SDL_FlipSurface = __root.SDL_FlipSurface;
    pub const SDL_RotateSurface = __root.SDL_RotateSurface;
    pub const SDL_DuplicateSurface = __root.SDL_DuplicateSurface;
    pub const SDL_ScaleSurface = __root.SDL_ScaleSurface;
    pub const SDL_ConvertSurface = __root.SDL_ConvertSurface;
    pub const SDL_ConvertSurfaceAndColorspace = __root.SDL_ConvertSurfaceAndColorspace;
    pub const SDL_PremultiplySurfaceAlpha = __root.SDL_PremultiplySurfaceAlpha;
    pub const SDL_ClearSurface = __root.SDL_ClearSurface;
    pub const SDL_FillSurfaceRect = __root.SDL_FillSurfaceRect;
    pub const SDL_FillSurfaceRects = __root.SDL_FillSurfaceRects;
    pub const SDL_BlitSurface = __root.SDL_BlitSurface;
    pub const SDL_BlitSurfaceUnchecked = __root.SDL_BlitSurfaceUnchecked;
    pub const SDL_BlitSurfaceScaled = __root.SDL_BlitSurfaceScaled;
    pub const SDL_BlitSurfaceUncheckedScaled = __root.SDL_BlitSurfaceUncheckedScaled;
    pub const SDL_StretchSurface = __root.SDL_StretchSurface;
    pub const SDL_BlitSurfaceTiled = __root.SDL_BlitSurfaceTiled;
    pub const SDL_BlitSurfaceTiledWithScale = __root.SDL_BlitSurfaceTiledWithScale;
    pub const SDL_BlitSurface9Grid = __root.SDL_BlitSurface9Grid;
    pub const SDL_MapSurfaceRGB = __root.SDL_MapSurfaceRGB;
    pub const SDL_MapSurfaceRGBA = __root.SDL_MapSurfaceRGBA;
    pub const SDL_ReadSurfacePixel = __root.SDL_ReadSurfacePixel;
    pub const SDL_ReadSurfacePixelFloat = __root.SDL_ReadSurfacePixelFloat;
    pub const SDL_WriteSurfacePixel = __root.SDL_WriteSurfacePixel;
    pub const SDL_WriteSurfacePixelFloat = __root.SDL_WriteSurfacePixelFloat;
    pub const SDL_CreateColorCursor = __root.SDL_CreateColorCursor;
    pub const SDL_CreateSoftwareRenderer = __root.SDL_CreateSoftwareRenderer;
    pub const SDL_CreateTray = __root.SDL_CreateTray;
    pub const DestroySurface = __root.SDL_DestroySurface;
    pub const GetSurfaceProperties = __root.SDL_GetSurfaceProperties;
    pub const SetSurfaceColorspace = __root.SDL_SetSurfaceColorspace;
    pub const GetSurfaceColorspace = __root.SDL_GetSurfaceColorspace;
    pub const CreateSurfacePalette = __root.SDL_CreateSurfacePalette;
    pub const SetSurfacePalette = __root.SDL_SetSurfacePalette;
    pub const GetSurfacePalette = __root.SDL_GetSurfacePalette;
    pub const AddSurfaceAlternateImage = __root.SDL_AddSurfaceAlternateImage;
    pub const SurfaceHasAlternateImages = __root.SDL_SurfaceHasAlternateImages;
    pub const GetSurfaceImages = __root.SDL_GetSurfaceImages;
    pub const RemoveSurfaceAlternateImages = __root.SDL_RemoveSurfaceAlternateImages;
    pub const LockSurface = __root.SDL_LockSurface;
    pub const UnlockSurface = __root.SDL_UnlockSurface;
    pub const IO = __root.SDL_SaveBMP_IO;
    pub const SaveBMP = __root.SDL_SaveBMP;
    pub const SavePNG = __root.SDL_SavePNG;
    pub const SetSurfaceRLE = __root.SDL_SetSurfaceRLE;
    pub const SurfaceHasRLE = __root.SDL_SurfaceHasRLE;
    pub const SetSurfaceColorKey = __root.SDL_SetSurfaceColorKey;
    pub const SurfaceHasColorKey = __root.SDL_SurfaceHasColorKey;
    pub const GetSurfaceColorKey = __root.SDL_GetSurfaceColorKey;
    pub const SetSurfaceColorMod = __root.SDL_SetSurfaceColorMod;
    pub const GetSurfaceColorMod = __root.SDL_GetSurfaceColorMod;
    pub const SetSurfaceAlphaMod = __root.SDL_SetSurfaceAlphaMod;
    pub const GetSurfaceAlphaMod = __root.SDL_GetSurfaceAlphaMod;
    pub const SetSurfaceBlendMode = __root.SDL_SetSurfaceBlendMode;
    pub const GetSurfaceBlendMode = __root.SDL_GetSurfaceBlendMode;
    pub const SetSurfaceClipRect = __root.SDL_SetSurfaceClipRect;
    pub const GetSurfaceClipRect = __root.SDL_GetSurfaceClipRect;
    pub const FlipSurface = __root.SDL_FlipSurface;
    pub const RotateSurface = __root.SDL_RotateSurface;
    pub const DuplicateSurface = __root.SDL_DuplicateSurface;
    pub const ScaleSurface = __root.SDL_ScaleSurface;
    pub const ConvertSurface = __root.SDL_ConvertSurface;
    pub const ConvertSurfaceAndColorspace = __root.SDL_ConvertSurfaceAndColorspace;
    pub const PremultiplySurfaceAlpha = __root.SDL_PremultiplySurfaceAlpha;
    pub const ClearSurface = __root.SDL_ClearSurface;
    pub const FillSurfaceRect = __root.SDL_FillSurfaceRect;
    pub const FillSurfaceRects = __root.SDL_FillSurfaceRects;
    pub const BlitSurface = __root.SDL_BlitSurface;
    pub const BlitSurfaceUnchecked = __root.SDL_BlitSurfaceUnchecked;
    pub const BlitSurfaceScaled = __root.SDL_BlitSurfaceScaled;
    pub const BlitSurfaceUncheckedScaled = __root.SDL_BlitSurfaceUncheckedScaled;
    pub const StretchSurface = __root.SDL_StretchSurface;
    pub const BlitSurfaceTiled = __root.SDL_BlitSurfaceTiled;
    pub const BlitSurfaceTiledWithScale = __root.SDL_BlitSurfaceTiledWithScale;
    pub const BlitSurface9Grid = __root.SDL_BlitSurface9Grid;
    pub const MapSurfaceRGB = __root.SDL_MapSurfaceRGB;
    pub const MapSurfaceRGBA = __root.SDL_MapSurfaceRGBA;
    pub const ReadSurfacePixel = __root.SDL_ReadSurfacePixel;
    pub const ReadSurfacePixelFloat = __root.SDL_ReadSurfacePixelFloat;
    pub const WriteSurfacePixel = __root.SDL_WriteSurfacePixel;
    pub const WriteSurfacePixelFloat = __root.SDL_WriteSurfacePixelFloat;
    pub const CreateColorCursor = __root.SDL_CreateColorCursor;
    pub const CreateSoftwareRenderer = __root.SDL_CreateSoftwareRenderer;
    pub const CreateTray = __root.SDL_CreateTray;
};

pub extern fn SDL_GetNumVideoDrivers() c_int;
pub extern fn SDL_GetVideoDriver(index: c_int) [*c]const u8;
pub extern fn SDL_GetCurrentVideoDriver() [*c]const u8;
pub extern fn SDL_GetSystemTheme() SDL_SystemTheme;
pub extern fn SDL_GetDisplays(count: [*c]c_int) [*c]SDL_DisplayID;
pub extern fn SDL_GetPrimaryDisplay() SDL_DisplayID;
pub extern fn SDL_GetDisplayProperties(displayID: SDL_DisplayID) SDL_PropertiesID;
pub extern fn SDL_GetDisplayName(displayID: SDL_DisplayID) [*c]const u8;
pub extern fn SDL_GetDisplayBounds(displayID: SDL_DisplayID, rect: [*c]SDL_Rect) bool;
pub extern fn SDL_GetDisplayUsableBounds(displayID: SDL_DisplayID, rect: [*c]SDL_Rect) bool;
pub extern fn SDL_GetNaturalDisplayOrientation(displayID: SDL_DisplayID) SDL_DisplayOrientation;
pub extern fn SDL_GetCurrentDisplayOrientation(displayID: SDL_DisplayID) SDL_DisplayOrientation;
pub extern fn SDL_GetDisplayContentScale(displayID: SDL_DisplayID) f32;
pub extern fn SDL_GetFullscreenDisplayModes(displayID: SDL_DisplayID, count: [*c]c_int) [*c][*c]SDL_DisplayMode;
pub extern fn SDL_GetClosestFullscreenDisplayMode(displayID: SDL_DisplayID, w: c_int, h: c_int, refresh_rate: f32, include_high_density_modes: bool, closest: [*c]SDL_DisplayMode) bool;
pub extern fn SDL_GetDesktopDisplayMode(displayID: SDL_DisplayID) [*c]const SDL_DisplayMode;
pub extern fn SDL_GetCurrentDisplayMode(displayID: SDL_DisplayID) [*c]const SDL_DisplayMode;
pub extern fn SDL_GetDisplayForPoint(point: [*c]const SDL_Point) SDL_DisplayID;
pub extern fn SDL_GetDisplayForRect(rect: [*c]const SDL_Rect) SDL_DisplayID;

pub const SDL_GLContextState = opaque {
    pub const SDL_GL_DestroyContext = __root.SDL_GL_DestroyContext;
    pub const DestroyContext = __root.SDL_GL_DestroyContext;
};
pub const SDL_GLContext = ?*SDL_GLContextState;
pub const SDL_EGLSurface = ?*anyopaque;

pub extern fn SDL_GL_CreateContext(window: ?*SDL_Window) SDL_GLContext;
pub extern fn SDL_GL_MakeCurrent(window: ?*SDL_Window, context: SDL_GLContext) bool;
pub extern fn SDL_EGL_GetWindowSurface(window: ?*SDL_Window) SDL_EGLSurface;
pub extern fn SDL_GL_SwapWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_StartTextInput(window: ?*SDL_Window) bool;
pub extern fn SDL_StartTextInputWithProperties(window: ?*SDL_Window, props: SDL_PropertiesID) bool;
pub extern fn SDL_TextInputActive(window: ?*SDL_Window) bool;
pub extern fn SDL_StopTextInput(window: ?*SDL_Window) bool;
pub extern fn SDL_ClearComposition(window: ?*SDL_Window) bool;
pub extern fn SDL_SetTextInputArea(window: ?*SDL_Window, rect: [*c]const SDL_Rect, cursor: c_int) bool;
pub extern fn SDL_GetTextInputArea(window: ?*SDL_Window, rect: [*c]SDL_Rect, cursor: [*c]c_int) bool;

pub extern fn SDL_ScreenKeyboardShown(window: ?*SDL_Window) bool;
pub extern fn SDL_WarpMouseInWindow(window: ?*SDL_Window, x: f32, y: f32) void;
pub extern fn SDL_SetWindowRelativeMouseMode(window: ?*SDL_Window, enabled: bool) bool;
pub extern fn SDL_GetWindowRelativeMouseMode(window: ?*SDL_Window) bool;
pub extern fn SDL_Metal_CreateView(window: ?*SDL_Window) SDL_MetalView;
pub extern fn SDL_CreateRenderer(window: ?*SDL_Window, name: [*c]const u8) ?*SDL_Renderer;
pub extern fn SDL_GetRenderer(window: ?*SDL_Window) ?*SDL_Renderer;

pub const SDL_MetalView = ?*anyopaque;
pub const SDL_Renderer = opaque {};

pub extern fn SDL_GetDisplayForWindow(window: ?*SDL_Window) SDL_DisplayID;
pub extern fn SDL_GetWindowPixelDensity(window: ?*SDL_Window) f32;
pub extern fn SDL_GetWindowDisplayScale(window: ?*SDL_Window) f32;
pub extern fn SDL_SetWindowFullscreenMode(window: ?*SDL_Window, mode: [*c]const SDL_DisplayMode) bool;
pub extern fn SDL_GetWindowFullscreenMode(window: ?*SDL_Window) [*c]const SDL_DisplayMode;
pub extern fn SDL_GetWindowICCProfile(window: ?*SDL_Window, size: [*c]usize) ?*anyopaque;
pub extern fn SDL_GetWindowPixelFormat(window: ?*SDL_Window) SDL_PixelFormat;
pub extern fn SDL_GetWindows(count: [*c]c_int) [*c]?*SDL_Window;
pub extern fn SDL_CreateWindow(title: [*c]const u8, w: c_int, h: c_int, flags: SDL_WindowFlags) ?*SDL_Window;
pub extern fn SDL_CreatePopupWindow(parent: ?*SDL_Window, offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: SDL_WindowFlags) ?*SDL_Window;
pub extern fn SDL_CreateWindowWithProperties(props: SDL_PropertiesID) ?*SDL_Window;
pub extern fn SDL_GetWindowID(window: ?*SDL_Window) SDL_WindowID;
pub extern fn SDL_GetWindowFromID(id: SDL_WindowID) ?*SDL_Window;
pub extern fn SDL_GetWindowParent(window: ?*SDL_Window) ?*SDL_Window;
pub extern fn SDL_GetWindowProperties(window: ?*SDL_Window) SDL_PropertiesID;
pub extern fn SDL_GetWindowFlags(window: ?*SDL_Window) SDL_WindowFlags;
pub extern fn SDL_SetWindowTitle(window: ?*SDL_Window, title: [*c]const u8) bool;
pub extern fn SDL_GetWindowTitle(window: ?*SDL_Window) [*c]const u8;
pub extern fn SDL_SetWindowIcon(window: ?*SDL_Window, icon: [*c]SDL_Surface) bool;
pub extern fn SDL_SetWindowPosition(window: ?*SDL_Window, x: c_int, y: c_int) bool;
pub extern fn SDL_GetWindowPosition(window: ?*SDL_Window, x: [*c]c_int, y: [*c]c_int) bool;
pub extern fn SDL_SetWindowSize(window: ?*SDL_Window, w: c_int, h: c_int) bool;
pub extern fn SDL_GetWindowSize(window: ?*SDL_Window, w: [*c]c_int, h: [*c]c_int) bool;
pub extern fn SDL_GetWindowSafeArea(window: ?*SDL_Window, rect: [*c]SDL_Rect) bool;
pub extern fn SDL_SetWindowAspectRatio(window: ?*SDL_Window, min_aspect: f32, max_aspect: f32) bool;
pub extern fn SDL_GetWindowAspectRatio(window: ?*SDL_Window, min_aspect: [*c]f32, max_aspect: [*c]f32) bool;
pub extern fn SDL_GetWindowBordersSize(window: ?*SDL_Window, top: [*c]c_int, left: [*c]c_int, bottom: [*c]c_int, right: [*c]c_int) bool;
pub extern fn SDL_GetWindowSizeInPixels(window: ?*SDL_Window, w: [*c]c_int, h: [*c]c_int) bool;
pub extern fn SDL_SetWindowMinimumSize(window: ?*SDL_Window, min_w: c_int, min_h: c_int) bool;
pub extern fn SDL_GetWindowMinimumSize(window: ?*SDL_Window, w: [*c]c_int, h: [*c]c_int) bool;
pub extern fn SDL_SetWindowMaximumSize(window: ?*SDL_Window, max_w: c_int, max_h: c_int) bool;
pub extern fn SDL_GetWindowMaximumSize(window: ?*SDL_Window, w: [*c]c_int, h: [*c]c_int) bool;
pub extern fn SDL_SetWindowBordered(window: ?*SDL_Window, bordered: bool) bool;
pub extern fn SDL_SetWindowResizable(window: ?*SDL_Window, resizable: bool) bool;
pub extern fn SDL_SetWindowAlwaysOnTop(window: ?*SDL_Window, on_top: bool) bool;
pub extern fn SDL_SetWindowFillDocument(window: ?*SDL_Window, fill: bool) bool;
pub extern fn SDL_ShowWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_HideWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_RaiseWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_MaximizeWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_MinimizeWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_RestoreWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_SetWindowFullscreen(window: ?*SDL_Window, fullscreen: bool) bool;
pub extern fn SDL_SyncWindow(window: ?*SDL_Window) bool;
pub extern fn SDL_WindowHasSurface(window: ?*SDL_Window) bool;
pub extern fn SDL_GetWindowSurface(window: ?*SDL_Window) [*c]SDL_Surface;
pub extern fn SDL_SetWindowSurfaceVSync(window: ?*SDL_Window, vsync: c_int) bool;
pub extern fn SDL_GetWindowSurfaceVSync(window: ?*SDL_Window, vsync: [*c]c_int) bool;
pub extern fn SDL_UpdateWindowSurface(window: ?*SDL_Window) bool;
pub extern fn SDL_UpdateWindowSurfaceRects(window: ?*SDL_Window, rects: [*c]const SDL_Rect, numrects: c_int) bool;
pub extern fn SDL_DestroyWindowSurface(window: ?*SDL_Window) bool;
pub extern fn SDL_SetWindowKeyboardGrab(window: ?*SDL_Window, grabbed: bool) bool;
pub extern fn SDL_SetWindowMouseGrab(window: ?*SDL_Window, grabbed: bool) bool;
pub extern fn SDL_GetWindowKeyboardGrab(window: ?*SDL_Window) bool;
pub extern fn SDL_GetWindowMouseGrab(window: ?*SDL_Window) bool;
pub extern fn SDL_GetGrabbedWindow() ?*SDL_Window;
pub extern fn SDL_SetWindowMouseRect(window: ?*SDL_Window, rect: [*c]const SDL_Rect) bool;
pub extern fn SDL_GetWindowMouseRect(window: ?*SDL_Window) [*c]const SDL_Rect;
pub extern fn SDL_SetWindowOpacity(window: ?*SDL_Window, opacity: f32) bool;
pub extern fn SDL_GetWindowOpacity(window: ?*SDL_Window) f32;
pub extern fn SDL_SetWindowParent(window: ?*SDL_Window, parent: ?*SDL_Window) bool;
pub extern fn SDL_SetWindowModal(window: ?*SDL_Window, modal: bool) bool;
pub extern fn SDL_SetWindowFocusable(window: ?*SDL_Window, focusable: bool) bool;
pub extern fn SDL_ShowWindowSystemMenu(window: ?*SDL_Window, x: c_int, y: c_int) bool;

pub const SDL_HitTestResult = enum(c_uint) {
    normal = 0,
    draggable = 1,
    resize_topleft = 2,
    resize_top = 3,
    resize_topright = 4,
    resize_right = 5,
    resize_bottomright = 6,
    resize_bottom = 7,
    resize_bottomleft = 8,
    resize_left = 9,
};

pub const SDL_FlashOperation = enum(c_uint) {
    cancel = 0,
    briefly = 1,
    until_focused = 2,
};

pub const SDL_ProgressState = enum(c_int) {
    invalid = -1,
    none = 0,
    indeterminate = 1,
    normal = 2,
    paused = 3,
    state_error = 4,
};

pub const SDL_HitTest = ?*const fn (win: ?*SDL_Window, area: [*c]const SDL_Point, data: ?*anyopaque) callconv(.c) SDL_HitTestResult;
pub extern fn SDL_SetWindowHitTest(window: ?*SDL_Window, callback: SDL_HitTest, callback_data: ?*anyopaque) bool;
pub extern fn SDL_SetWindowShape(window: ?*SDL_Window, shape: [*c]SDL_Surface) bool;
pub extern fn SDL_FlashWindow(window: ?*SDL_Window, operation: SDL_FlashOperation) bool;
pub extern fn SDL_SetWindowProgressState(window: ?*SDL_Window, state: SDL_ProgressState) bool;
pub extern fn SDL_GetWindowProgressState(window: ?*SDL_Window) SDL_ProgressState;
pub extern fn SDL_SetWindowProgressValue(window: ?*SDL_Window, value: f32) bool;
pub extern fn SDL_GetWindowProgressValue(window: ?*SDL_Window) f32;
pub extern fn SDL_DestroyWindow(window: ?*SDL_Window) void;
pub extern fn SDL_ScreenSaverEnabled() bool;
pub extern fn SDL_EnableScreenSaver() bool;
pub extern fn SDL_DisableScreenSaver() bool;

pub const UINT64_C = __helpers.ULL_SUFFIX;
pub inline fn SDL_UINT64_C(c: anytype) @TypeOf(UINT64_C(c)) {
    _ = &c;
    return UINT64_C(c);
}

pub const SDL_WINDOW_FULLSCREEN = SDL_UINT64_C(@as(c_int, 0x0000000000000001));
pub const SDL_WINDOW_OPENGL = SDL_UINT64_C(@as(c_int, 0x0000000000000002));
pub const SDL_WINDOW_OCCLUDED = SDL_UINT64_C(@as(c_int, 0x0000000000000004));
pub const SDL_WINDOW_HIDDEN = SDL_UINT64_C(@as(c_int, 0x0000000000000008));
pub const SDL_WINDOW_BORDERLESS = SDL_UINT64_C(@as(c_int, 0x0000000000000010));
pub const SDL_WINDOW_RESIZABLE = SDL_UINT64_C(@as(c_int, 0x0000000000000020));
pub const SDL_WINDOW_MINIMIZED = SDL_UINT64_C(@as(c_int, 0x0000000000000040));
pub const SDL_WINDOW_MAXIMIZED = SDL_UINT64_C(@as(c_int, 0x0000000000000080));
pub const SDL_WINDOW_MOUSE_GRABBED = SDL_UINT64_C(@as(c_int, 0x0000000000000100));
pub const SDL_WINDOW_INPUT_FOCUS = SDL_UINT64_C(@as(c_int, 0x0000000000000200));
pub const SDL_WINDOW_MOUSE_FOCUS = SDL_UINT64_C(@as(c_int, 0x0000000000000400));
pub const SDL_WINDOW_EXTERNAL = SDL_UINT64_C(@as(c_int, 0x0000000000000800));
pub const SDL_WINDOW_MODAL = SDL_UINT64_C(@as(c_int, 0x0000000000001000));
pub const SDL_WINDOW_HIGH_PIXEL_DENSITY = SDL_UINT64_C(@as(c_int, 0x0000000000002000));
pub const SDL_WINDOW_MOUSE_CAPTURE = SDL_UINT64_C(@as(c_int, 0x0000000000004000));
pub const SDL_WINDOW_MOUSE_RELATIVE_MODE = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000000008000, .hex));
pub const SDL_WINDOW_ALWAYS_ON_TOP = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000000010000, .hex));
pub const SDL_WINDOW_UTILITY = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000000020000, .hex));
pub const SDL_WINDOW_TOOLTIP = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000000040000, .hex));
pub const SDL_WINDOW_POPUP_MENU = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000000080000, .hex));
pub const SDL_WINDOW_KEYBOARD_GRABBED = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000000100000, .hex));
pub const SDL_WINDOW_FILL_DOCUMENT = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000000200000, .hex));
pub const SDL_WINDOW_VULKAN = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000010000000, .hex));
pub const SDL_WINDOW_METAL = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000020000000, .hex));
pub const SDL_WINDOW_TRANSPARENT = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000040000000, .hex));
pub const SDL_WINDOW_NOT_FOCUSABLE = SDL_UINT64_C(__helpers.promoteIntLiteral(c_int, 0x0000000080000000, .hex));
pub const SDL_WINDOWPOS_UNDEFINED_MASK = __helpers.promoteIntLiteral(c_uint, 0x1FFF0000, .hex);

pub const SDL_Time = i64;

pub const SDL_DateTime = extern struct {
    year: c_int = 0,
    month: c_int = 0,
    day: c_int = 0,
    hour: c_int = 0,
    minute: c_int = 0,
    second: c_int = 0,
    nanosecond: c_int = 0,
    day_of_week: c_int = 0,
    utc_offset: c_int = 0,
    pub const SDL_DateTimeToTime = __root.SDL_DateTimeToTime;
    pub const DateTimeToTime = __root.SDL_DateTimeToTime;
};

pub const SDL_DATE_FORMAT_YYYYMMDD: c_int = 0;
pub const SDL_DATE_FORMAT_DDMMYYYY: c_int = 1;
pub const SDL_DATE_FORMAT_MMDDYYYY: c_int = 2;
pub const enum_SDL_DateFormat = c_uint;
pub const SDL_DateFormat = enum_SDL_DateFormat;
pub const SDL_TIME_FORMAT_24HR: c_int = 0;
pub const SDL_TIME_FORMAT_12HR: c_int = 1;
pub const enum_SDL_TimeFormat = c_uint;
pub const SDL_TimeFormat = enum_SDL_TimeFormat;
pub extern fn SDL_GetDateTimeLocalePreferences(dateFormat: [*c]SDL_DateFormat, timeFormat: [*c]SDL_TimeFormat) bool;
pub extern fn SDL_GetCurrentTime(ticks: [*c]SDL_Time) bool;
pub extern fn SDL_TimeToDateTime(ticks: SDL_Time, dt: [*c]SDL_DateTime, localTime: bool) bool;
pub extern fn SDL_DateTimeToTime(dt: [*c]const SDL_DateTime, ticks: [*c]SDL_Time) bool;
pub extern fn SDL_TimeToWindows(ticks: SDL_Time, dwLowDateTime: [*c]u32, dwHighDateTime: [*c]u32) void;
pub extern fn SDL_TimeFromWindows(dwLowDateTime: u32, dwHighDateTime: u32) SDL_Time;
pub extern fn SDL_GetDaysInMonth(year: c_int, month: c_int) c_int;
pub extern fn SDL_GetDayOfYear(year: c_int, month: c_int, day: c_int) c_int;
pub extern fn SDL_GetDayOfWeek(year: c_int, month: c_int, day: c_int) c_int;
pub extern fn SDL_GetTicks() u64;
pub extern fn SDL_GetTicksNS() u64;
pub extern fn SDL_GetPerformanceCounter() u64;
pub extern fn SDL_GetPerformanceFrequency() u64;
pub extern fn SDL_Delay(ms: u32) void;
pub extern fn SDL_DelayNS(ns: u64) void;
pub extern fn SDL_DelayPrecise(ns: u64) void;
pub const SDL_TimerID = u32;
pub const SDL_TimerCallback = ?*const fn (userdata: ?*anyopaque, timerID: SDL_TimerID, interval: u32) callconv(.c) u32;
pub extern fn SDL_AddTimer(interval: u32, callback: SDL_TimerCallback, userdata: ?*anyopaque) SDL_TimerID;
pub const SDL_NSTimerCallback = ?*const fn (userdata: ?*anyopaque, timerID: SDL_TimerID, interval: u64) callconv(.c) u64;
pub extern fn SDL_AddTimerNS(interval: u64, callback: SDL_NSTimerCallback, userdata: ?*anyopaque) SDL_TimerID;
pub extern fn SDL_RemoveTimer(id: SDL_TimerID) bool;

pub const SDL_PI_D = @as(f64, 3.141592653589793238462643383279502884);
pub const SDL_PI_F = @as(f32, 3.141592653589793238462643383279502884);

pub const SDL_CompareCallback = ?*const fn (a: ?*const anyopaque, b: ?*const anyopaque) callconv(.c) c_int;
pub extern fn SDL_qsort(base: ?*anyopaque, nmemb: usize, size: usize, compare: SDL_CompareCallback) void;
pub extern fn SDL_bsearch(key: ?*const anyopaque, base: ?*const anyopaque, nmemb: usize, size: usize, compare: SDL_CompareCallback) ?*anyopaque;
pub const SDL_CompareCallback_r = ?*const fn (userdata: ?*anyopaque, a: ?*const anyopaque, b: ?*const anyopaque) callconv(.c) c_int;
pub extern fn SDL_qsort_r(base: ?*anyopaque, nmemb: usize, size: usize, compare: SDL_CompareCallback_r, userdata: ?*anyopaque) void;
pub extern fn SDL_bsearch_r(key: ?*const anyopaque, base: ?*const anyopaque, nmemb: usize, size: usize, compare: SDL_CompareCallback_r, userdata: ?*anyopaque) ?*anyopaque;
pub extern fn SDL_abs(x: c_int) c_int;
pub extern fn SDL_isalpha(x: c_int) c_int;
pub extern fn SDL_isalnum(x: c_int) c_int;
pub extern fn SDL_isblank(x: c_int) c_int;
pub extern fn SDL_iscntrl(x: c_int) c_int;
pub extern fn SDL_isdigit(x: c_int) c_int;
pub extern fn SDL_isxdigit(x: c_int) c_int;
pub extern fn SDL_ispunct(x: c_int) c_int;
pub extern fn SDL_isspace(x: c_int) c_int;
pub extern fn SDL_isupper(x: c_int) c_int;
pub extern fn SDL_islower(x: c_int) c_int;
pub extern fn SDL_isprint(x: c_int) c_int;
pub extern fn SDL_isgraph(x: c_int) c_int;
pub extern fn SDL_toupper(x: c_int) c_int;
pub extern fn SDL_tolower(x: c_int) c_int;
pub extern fn SDL_crc16(crc: u16, data: ?*const anyopaque, len: usize) u16;
pub extern fn SDL_crc32(crc: u32, data: ?*const anyopaque, len: usize) u32;
pub extern fn SDL_murmur3_32(data: ?*const anyopaque, len: usize, seed: u32) u32;
pub extern fn SDL_memcpy(dst: ?*anyopaque, src: ?*const anyopaque, len: usize) ?*anyopaque;
pub extern fn SDL_memmove(dst: ?*anyopaque, src: ?*const anyopaque, len: usize) ?*anyopaque;
pub extern fn SDL_memset(dst: ?*anyopaque, c: c_int, len: usize) ?*anyopaque;
pub extern fn SDL_memset4(dst: ?*anyopaque, val: u32, dwords: usize) ?*anyopaque;
pub extern fn SDL_memcmp(s1: ?*const anyopaque, s2: ?*const anyopaque, len: usize) c_int;
pub extern fn SDL_wcslen(wstr: [*c]const wchar_t) usize;
pub extern fn SDL_wcsnlen(wstr: [*c]const wchar_t, maxlen: usize) usize;
pub extern fn SDL_wcslcpy(dst: [*c]wchar_t, src: [*c]const wchar_t, maxlen: usize) usize;
pub extern fn SDL_wcslcat(dst: [*c]wchar_t, src: [*c]const wchar_t, maxlen: usize) usize;
pub extern fn SDL_wcsdup(wstr: [*c]const wchar_t) [*c]wchar_t;
pub extern fn SDL_wcsstr(haystack: [*c]const wchar_t, needle: [*c]const wchar_t) [*c]wchar_t;
pub extern fn SDL_wcsnstr(haystack: [*c]const wchar_t, needle: [*c]const wchar_t, maxlen: usize) [*c]wchar_t;
pub extern fn SDL_wcscmp(str1: [*c]const wchar_t, str2: [*c]const wchar_t) c_int;
pub extern fn SDL_wcsncmp(str1: [*c]const wchar_t, str2: [*c]const wchar_t, maxlen: usize) c_int;
pub extern fn SDL_wcscasecmp(str1: [*c]const wchar_t, str2: [*c]const wchar_t) c_int;
pub extern fn SDL_wcsncasecmp(str1: [*c]const wchar_t, str2: [*c]const wchar_t, maxlen: usize) c_int;
pub extern fn SDL_wcstol(str: [*c]const wchar_t, endp: [*c][*c]wchar_t, base: c_int) c_long;
pub extern fn SDL_strlen(str: [*c]const u8) usize;
pub extern fn SDL_strnlen(str: [*c]const u8, maxlen: usize) usize;
pub extern fn SDL_strlcpy(dst: [*c]u8, src: [*c]const u8, maxlen: usize) usize;
pub extern fn SDL_utf8strlcpy(dst: [*c]u8, src: [*c]const u8, dst_bytes: usize) usize;
pub extern fn SDL_strlcat(dst: [*c]u8, src: [*c]const u8, maxlen: usize) usize;
pub extern fn SDL_strdup(str: [*c]const u8) [*c]u8;
pub extern fn SDL_strndup(str: [*c]const u8, maxlen: usize) [*c]u8;
pub extern fn SDL_strrev(str: [*c]u8) [*c]u8;
pub extern fn SDL_strupr(str: [*c]u8) [*c]u8;
pub extern fn SDL_strlwr(str: [*c]u8) [*c]u8;
pub extern fn SDL_strchr(str: [*c]const u8, c: c_int) [*c]u8;
pub extern fn SDL_strrchr(str: [*c]const u8, c: c_int) [*c]u8;
pub extern fn SDL_strstr(haystack: [*c]const u8, needle: [*c]const u8) [*c]u8;
pub extern fn SDL_strnstr(haystack: [*c]const u8, needle: [*c]const u8, maxlen: usize) [*c]u8;
pub extern fn SDL_strcasestr(haystack: [*c]const u8, needle: [*c]const u8) [*c]u8;
pub extern fn SDL_strtok_r(str: [*c]u8, delim: [*c]const u8, saveptr: [*c][*c]u8) [*c]u8;
pub extern fn SDL_utf8strlen(str: [*c]const u8) usize;
pub extern fn SDL_utf8strnlen(str: [*c]const u8, bytes: usize) usize;
pub extern fn SDL_itoa(value: c_int, str: [*c]u8, radix: c_int) [*c]u8;
pub extern fn SDL_uitoa(value: c_uint, str: [*c]u8, radix: c_int) [*c]u8;
pub extern fn SDL_ltoa(value: c_long, str: [*c]u8, radix: c_int) [*c]u8;
pub extern fn SDL_ultoa(value: c_ulong, str: [*c]u8, radix: c_int) [*c]u8;
pub extern fn SDL_lltoa(value: c_longlong, str: [*c]u8, radix: c_int) [*c]u8;
pub extern fn SDL_ulltoa(value: c_ulonglong, str: [*c]u8, radix: c_int) [*c]u8;
pub extern fn SDL_atoi(str: [*c]const u8) c_int;
pub extern fn SDL_atof(str: [*c]const u8) f64;
pub extern fn SDL_strtol(str: [*c]const u8, endp: [*c][*c]u8, base: c_int) c_long;
pub extern fn SDL_strtoul(str: [*c]const u8, endp: [*c][*c]u8, base: c_int) c_ulong;
pub extern fn SDL_strtoll(str: [*c]const u8, endp: [*c][*c]u8, base: c_int) c_longlong;
pub extern fn SDL_strtoull(str: [*c]const u8, endp: [*c][*c]u8, base: c_int) c_ulonglong;
pub extern fn SDL_strtod(str: [*c]const u8, endp: [*c][*c]u8) f64;
pub extern fn SDL_strcmp(str1: [*c]const u8, str2: [*c]const u8) c_int;
pub extern fn SDL_strncmp(str1: [*c]const u8, str2: [*c]const u8, maxlen: usize) c_int;
pub extern fn SDL_strcasecmp(str1: [*c]const u8, str2: [*c]const u8) c_int;
pub extern fn SDL_strncasecmp(str1: [*c]const u8, str2: [*c]const u8, maxlen: usize) c_int;
pub extern fn SDL_strpbrk(str: [*c]const u8, breakset: [*c]const u8) [*c]u8;
pub extern fn SDL_StepUTF8(pstr: [*c][*c]const u8, pslen: [*c]usize) u32;
pub extern fn SDL_StepBackUTF8(start: [*c]const u8, pstr: [*c][*c]const u8) u32;
pub extern fn SDL_UCS4ToUTF8(codepoint: u32, dst: [*c]u8) [*c]u8;
pub extern fn SDL_sscanf(text: [*c]const u8, fmt: [*c]const u8, ...) c_int;
pub extern fn SDL_vsscanf(text: [*c]const u8, fmt: [*c]const u8, ap: va_list) c_int;
pub extern fn SDL_snprintf(text: [*c]u8, maxlen: usize, fmt: [*c]const u8, ...) c_int;
pub extern fn SDL_swprintf(text: [*c]wchar_t, maxlen: usize, fmt: [*c]const wchar_t, ...) c_int;
pub extern fn SDL_vsnprintf(text: [*c]u8, maxlen: usize, fmt: [*c]const u8, ap: va_list) c_int;
pub extern fn SDL_vswprintf(text: [*c]wchar_t, maxlen: usize, fmt: [*c]const wchar_t, ap: va_list) c_int;
pub extern fn SDL_asprintf(strp: [*c][*c]u8, fmt: [*c]const u8, ...) c_int;
pub extern fn SDL_vasprintf(strp: [*c][*c]u8, fmt: [*c]const u8, ap: va_list) c_int;
pub extern fn SDL_srand(seed: u64) void;
pub extern fn SDL_rand(n: i32) i32;
pub extern fn SDL_randf() f32;
pub extern fn SDL_rand_bits() u32;
pub extern fn SDL_rand_r(state: [*c]u64, n: i32) i32;
pub extern fn SDL_randf_r(state: [*c]u64) f32;
pub extern fn SDL_rand_bits_r(state: [*c]u64) u32;
pub extern fn SDL_acos(x: f64) f64;
pub extern fn SDL_acosf(x: f32) f32;
pub extern fn SDL_asin(x: f64) f64;
pub extern fn SDL_asinf(x: f32) f32;
pub extern fn SDL_atan(x: f64) f64;
pub extern fn SDL_atanf(x: f32) f32;
pub extern fn SDL_atan2(y: f64, x: f64) f64;
pub extern fn SDL_atan2f(y: f32, x: f32) f32;
pub extern fn SDL_ceil(x: f64) f64;
pub extern fn SDL_ceilf(x: f32) f32;
pub extern fn SDL_copysign(x: f64, y: f64) f64;
pub extern fn SDL_copysignf(x: f32, y: f32) f32;
pub extern fn SDL_cos(x: f64) f64;
pub extern fn SDL_cosf(x: f32) f32;
pub extern fn SDL_exp(x: f64) f64;
pub extern fn SDL_expf(x: f32) f32;
pub extern fn SDL_fabs(x: f64) f64;
pub extern fn SDL_fabsf(x: f32) f32;
pub extern fn SDL_floor(x: f64) f64;
pub extern fn SDL_floorf(x: f32) f32;
pub extern fn SDL_trunc(x: f64) f64;
pub extern fn SDL_truncf(x: f32) f32;
pub extern fn SDL_fmod(x: f64, y: f64) f64;
pub extern fn SDL_fmodf(x: f32, y: f32) f32;
pub extern fn SDL_isinf(x: f64) c_int;
pub extern fn SDL_isinff(x: f32) c_int;
pub extern fn SDL_isnan(x: f64) c_int;
pub extern fn SDL_isnanf(x: f32) c_int;
pub extern fn SDL_log(x: f64) f64;
pub extern fn SDL_logf(x: f32) f32;
pub extern fn SDL_log10(x: f64) f64;
pub extern fn SDL_log10f(x: f32) f32;
pub extern fn SDL_modf(x: f64, y: [*c]f64) f64;
pub extern fn SDL_modff(x: f32, y: [*c]f32) f32;
pub extern fn SDL_pow(x: f64, y: f64) f64;
pub extern fn SDL_powf(x: f32, y: f32) f32;
pub extern fn SDL_round(x: f64) f64;
pub extern fn SDL_roundf(x: f32) f32;
pub extern fn SDL_lround(x: f64) c_long;
pub extern fn SDL_lroundf(x: f32) c_long;
pub extern fn SDL_scalbn(x: f64, n: c_int) f64;
pub extern fn SDL_scalbnf(x: f32, n: c_int) f32;
pub extern fn SDL_sin(x: f64) f64;
pub extern fn SDL_sinf(x: f32) f32;
pub extern fn SDL_sqrt(x: f64) f64;
pub extern fn SDL_sqrtf(x: f32) f32;
pub extern fn SDL_tan(x: f64) f64;
pub extern fn SDL_tanf(x: f32) f32;
