// # CategoryStdinc
//
// SDL provides its own implementation of some of the most important C runtime
// functions.
//
// Using these functions allows an app to have access to common C
// functionality without depending on a specific C runtime (or a C runtime at
// all). More importantly, the SDL implementations work identically across
// platforms, so apps can avoid surprises like snprintf() behaving differently
// between Windows and Linux builds, or itoa() only existing on some
// platforms.
//
// For many of the most common functions, like SDL_memcpy, SDL might just call
// through to the usual C runtime behind the scenes, if it makes sense to do
// so (if it's faster and always available/reliable on a given platform),
// reducing library size and offering the most optimized option.
//
// SDL also offers other C-runtime-adjacent functionality in this header that
// either isn't, strictly speaking, part of any C runtime standards, like
// SDL_crc32() and SDL_reinterpret_cast, etc. It also offers a few better
// options, like SDL_strlcpy(), which functions as a safer form of strcpy().

pub const translation_helpers = @import("std").zig.c_translation.helpers;
pub const std = @import("std");

pub const UINT32_C = translation_helpers.U_SUFFIX;

pub const UINT64_C = translation_helpers.ULL_SUFFIX;

pub const INTMAX_C = translation_helpers.L_SUFFIX;

pub const UINTMAX_C = translation_helpers.UL_SUFFIX;

pub const SDL_reinterpret_cast = translation_helpers.cast;
pub const SDL_static_cast = translation_helpers.cast;
pub const SDL_const_cast = translation_helpers.cast;

/// The value of Pi, as a double-precision floating point literal.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_PI_F
pub const SDL_PI_D = @as(f64, 3.141592653589793238462643383279502884);

/// The value of Pi, as a single-precision floating point literal.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_PI_D
pub const SDL_PI_F = @as(f32, 3.141592653589793238462643383279502884);

/// SDL times are signed, 64-bit integers representing nanoseconds since the
/// Unix epoch (Jan 1, 1970).
///
/// They can be converted between POSIX time_t values with SDL_NS_TO_SECONDS()
/// and SDL_SECONDS_TO_NS(), and between Windows FILETIME values with
/// SDL_TimeToWindows() and SDL_TimeFromWindows().
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_MAX_SINT64
/// \sa SDL_MIN_SINT64
pub const SDL_Time = i64;
pub const SDL_MAX_TIME = std.math.maxInt(SDL_Time);
pub const SDL_MIN_TIME = std.math.minInt(SDL_Time);

/// Define a four character code as a Uint32.
///
/// \param A the first ASCII character.
/// \param B the second ASCII character.
/// \param C the third ASCII character.
/// \param D the fourth ASCII character.
/// \returns the four characters converted into a Uint32, one character
///          per-byte.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_FOURCC(
    comptime a: anytype,
    comptime b: anytype,
    comptime c: anytype,
    comptime d: anytype,
) u32 {
    // double cast, truncate to u8 then back to u32
    const a_casted = SDL_static_cast(
        u32,
        SDL_static_cast(u8, a),
    );
    const b_casted = SDL_static_cast(
        u32,
        SDL_static_cast(u8, b),
    );
    const c_casted = SDL_static_cast(
        u32,
        SDL_static_cast(u8, c),
    );
    const d_casted = SDL_static_cast(
        u32,
        SDL_static_cast(u8, d),
    );

    // bitshift each component into place and combine
    return a_casted << 0 | b_casted << 8 | c_casted << 16 | d_casted << 24;
}

/// Copy non-overlapping memory.
///
/// The memory regions must not overlap. If they do, use SDL_memmove() instead.
///
/// \param dst The destination memory region. Must not be NULL, and must not
///            overlap with `src`.
/// \param src The source memory region. Must not be NULL, and must not overlap
///            with `dst`.
/// \param len The length in bytes of both `dst` and `src`.
/// \returns `dst`.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_memmove
pub extern fn SDL_memcpy(dst: *anyopaque, src: *const anyopaque, len: usize) *anyopaque;

/// A generic function pointer.
///
/// In theory, generic function pointers should use this, instead of `void *`,
/// since some platforms could treat code addresses differently than data
/// addresses. Although in current times no popular platforms make this
/// distinction, it is more correct and portable to use the correct type for a
/// generic pointer.
///
/// If for some reason you need to force this typedef to be an actual `void *`,
/// perhaps to work around a compiler or existing code, you can define
/// `SDL_FUNCTION_POINTER_IS_VOID_POINTER` before including any SDL headers.
///
/// \since This datatype is available since SDL 3.2.0.
pub const SDL_FunctionPointer = *const fn () callconv(.c) void;
