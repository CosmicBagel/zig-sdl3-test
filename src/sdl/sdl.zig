pub const main = @import("main.zig");
pub const stdinc = @import("stdinc.zig");
pub const assert = @import("assert.zig");
pub const asyncio = @import("asyncio.zig");
pub const atomic = @import("atomic.zig");
pub const audio = @import("audio.zig");
pub const bits = @import("bits.zig");
pub const blendmode = @import("blendmode.zig");
pub const camera = @import("camera.zig");
pub const clipboard = @import("clipboard.zig");
pub const cpuinfo = @import("cpuinfo.zig");
pub const dialog = @import("dialog.zig");
pub const dlopennote = @import("dlopennote.zig");
pub const endian = @import("endian.zig");
pub const @"error" = @import("error.zig");
pub const events = @import("events.zig");
pub const filesystem = @import("filesystem.zig");
pub const gamepad = @import("gamepad.zig");
pub const gpu = @import("gpu.zig");
pub const guid = @import("guid.zig");
pub const haptic = @import("haptic.zig");
pub const hidapi = @import("hidapi.zig");
pub const hints = @import("hints.zig");
pub const init = @import("init.zig");
pub const iostream = @import("iostream.zig");
pub const joystick = @import("joystick.zig");
pub const keyboard = @import("keyboard.zig");
pub const keycode = @import("keycode.zig");
pub const loadso = @import("loadso.zig");
pub const locale = @import("locale.zig");
pub const log = @import("log.zig");
pub const messagebox = @import("messagebox.zig");
pub const metal = @import("metal.zig");
pub const misc = @import("misc.zig");
pub const mouse = @import("mouse.zig");
pub const mutex = @import("mutex.zig");
pub const pen = @import("pen.zig");
pub const pixels = @import("pixels.zig");
pub const platform = @import("platform.zig");
pub const power = @import("power.zig");
pub const process = @import("process.zig");
pub const properties = @import("properties.zig");
pub const rect = @import("rect.zig");
pub const render = @import("render.zig");
pub const scancode = @import("scancode.zig");
pub const sensor = @import("sensor.zig");
pub const storage = @import("storage.zig");
pub const surface = @import("surface.zig");
pub const system = @import("system.zig");
pub const thread = @import("thread.zig");
pub const time = @import("time.zig");
pub const timer = @import("timer.zig");
pub const tray = @import("tray.zig");
pub const touch = @import("touch.zig");
pub const version = @import("version.zig");
pub const video = @import("video.zig");

const std = @import("std");
const __helpers = std.zig.c_translation.helpers;

pub const SDL_SurfaceFlags = u32;

pub const SDL_Surface = extern struct {
    flags: SDL_SurfaceFlags = 0,
    format: pixels.SDL_PixelFormat = @import("std").mem.zeroes(pixels.SDL_PixelFormat),
    w: c_int = 0,
    h: c_int = 0,
    pitch: c_int = 0,
    pixels: ?*anyopaque = null,
    refcount: c_int = 0,
    reserved: ?*anyopaque = null,
};

pub extern fn SDL_WarpMouseInWindow(window: ?*SDL_Window, x: f32, y: f32) void;
pub extern fn SDL_SetWindowRelativeMouseMode(window: ?*SDL_Window, enabled: bool) bool;
pub extern fn SDL_GetWindowRelativeMouseMode(window: ?*SDL_Window) bool;
pub extern fn SDL_Metal_CreateView(window: ?*SDL_Window) SDL_MetalView;
pub extern fn SDL_CreateRenderer(window: ?*SDL_Window, name: [*c]const u8) ?*SDL_Renderer;
pub extern fn SDL_GetRenderer(window: ?*SDL_Window) ?*SDL_Renderer;

pub const SDL_MetalView = ?*anyopaque;
pub const SDL_Renderer = opaque {};

pub const UINT64_C = __helpers.ULL_SUFFIX;
pub inline fn SDL_UINT64_C(c: anytype) @TypeOf(UINT64_C(c)) {
    _ = &c;
    return UINT64_C(c);
}
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
pub extern fn SDL_wcslen(wstr: [*c]const c_int) usize;
pub extern fn SDL_wcsnlen(wstr: [*c]const c_int, maxlen: usize) usize;
pub extern fn SDL_wcslcpy(dst: [*c]c_int, src: [*c]const c_int, maxlen: usize) usize;
pub extern fn SDL_wcslcat(dst: [*c]c_int, src: [*c]const c_int, maxlen: usize) usize;
pub extern fn SDL_wcsdup(wstr: [*c]const c_int) [*c]c_int;
pub extern fn SDL_wcsstr(haystack: [*c]const c_int, needle: [*c]const c_int) [*c]c_int;
pub extern fn SDL_wcsnstr(haystack: [*c]const c_int, needle: [*c]const c_int, maxlen: usize) [*c]c_int;
pub extern fn SDL_wcscmp(str1: [*c]const c_int, str2: [*c]const c_int) c_int;
pub extern fn SDL_wcsncmp(str1: [*c]const c_int, str2: [*c]const c_int, maxlen: usize) c_int;
pub extern fn SDL_wcscasecmp(str1: [*c]const c_int, str2: [*c]const c_int) c_int;
pub extern fn SDL_wcsncasecmp(str1: [*c]const c_int, str2: [*c]const c_int, maxlen: usize) c_int;
pub extern fn SDL_wcstol(str: [*c]const c_int, endp: [*c][*c]c_int, base: c_int) c_long;
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
pub extern fn SDL_vsscanf(text: [*c]const u8, fmt: [*c]const u8, ap: [*c]u8) c_int;
pub extern fn SDL_snprintf(text: [*c]u8, maxlen: usize, fmt: [*c]const u8, ...) c_int;
pub extern fn SDL_swprintf(text: [*c]c_int, maxlen: usize, fmt: [*c]const c_int, ...) c_int;
pub extern fn SDL_vsnprintf(text: [*c]u8, maxlen: usize, fmt: [*c]const u8, ap: [*c]u8) c_int;
pub extern fn SDL_vswprintf(text: [*c]c_int, maxlen: usize, fmt: [*c]const c_int, ap: [*c]u8) c_int;
pub extern fn SDL_asprintf(strp: [*c][*c]u8, fmt: [*c]const u8, ...) c_int;
pub extern fn SDL_vasprintf(strp: [*c][*c]u8, fmt: [*c]const u8, ap: [*c]u8) c_int;
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
