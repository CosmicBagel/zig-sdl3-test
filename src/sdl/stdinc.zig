pub const translation_helpers = @import("std").zig.c_translation.helpers;

pub const UINT32_C = translation_helpers.U_SUFFIX;

pub const UINT64_C = translation_helpers.ULL_SUFFIX;

pub const INTMAX_C = translation_helpers.L_SUFFIX;

pub const UINTMAX_C = translation_helpers.UL_SUFFIX;

pub const SDL_reinterpret_cast = translation_helpers.cast;
pub const SDL_static_cast = translation_helpers.cast;
pub const SDL_const_cast = translation_helpers.cast;

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
