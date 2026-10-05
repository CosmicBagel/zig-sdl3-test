// # CategoryPixels
//
// SDL offers facilities for pixel management.
//
// Largely these facilities deal with pixel _format_: what does this set of
// bits represent?
//
// If you mostly want to think of a pixel as some combination of red, green,
// blue, and maybe alpha intensities, this is all pretty straightforward, and
// in many cases, is enough information to build a perfectly fine game.
//
// However, the actual definition of a pixel is more complex than that:
//
// Pixels are a representation of a color in a particular color space.
//
// The first characteristic of a color space is the color type. SDL
// understands two different color types, RGB and YCbCr, or in SDL also
// referred to as YUV.
//
// RGB colors consist of red, green, and blue channels of color that are added
// together to represent the colors we see on the screen.
//
// https://en.wikipedia.org/wiki/RGB_color_model
//
// YCbCr colors represent colors as a Y luma brightness component and red and
// blue chroma color offsets. This color representation takes advantage of the
// fact that the human eye is more sensitive to brightness than the color in
// an image. The Cb and Cr components are often compressed and have lower
// resolution than the luma component.
//
// https://en.wikipedia.org/wiki/YCbCr
//
// When the color information in YCbCr is compressed, the Y pixels are left at
// full resolution and each Cr and Cb pixel represents an average of the color
// information in a block of Y pixels. The chroma location determines where in
// that block of pixels the color information is coming from.
//
// The color range defines how much of the pixel to use when converting a
// pixel into a color on the display. When the full color range is used, the
// entire numeric range of the pixel bits is significant. When narrow color
// range is used, for historical reasons, the pixel uses only a portion of the
// numeric range to represent colors.
//
// The color primaries and white point are a definition of the colors in the
// color space relative to the standard XYZ color space.
//
// https://en.wikipedia.org/wiki/CIE_1931_color_space
//
// The transfer characteristic, or opto-electrical transfer function (OETF),
// is the way a color is converted from mathematically linear space into a
// non-linear output signals.
//
// https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics
//
// The matrix coefficients are used to convert between YCbCr and RGB colors.

const builtin = @import("builtin");
const stdinc = @import("stdinc.zig");
const endian = @import("endian.zig");

/// A fully opaque 8-bit alpha value.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_ALPHA_TRANSPARENT
pub const SDL_ALPHA_OPAQUE = 255;

/// A fully opaque floating point alpha value.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_ALPHA_TRANSPARENT_FLOAT
pub const SDL_ALPHA_OPAQUE_FLOAT = 1.0;

/// A fully transparent 8-bit alpha value.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_ALPHA_OPAQUE
pub const SDL_ALPHA_TRANSPARENT = 0;

/// A fully transparent floating point alpha value.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_ALPHA_OPAQUE_FLOAT
pub const SDL_ALPHA_TRANSPARENT_FLOAT = 0.0;

/// Pixel type.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_PixelType = enum(c_uint) {
    unknown = 0,
    index1 = 1,
    index4 = 2,
    index8 = 3,
    packed8 = 4,
    packed16 = 5,
    packed32 = 6,
    arrayu8 = 7,
    arrayu16 = 8,
    arrayu32 = 9,
    arrayf16 = 10,
    arrayf32 = 11,
    /// appended at the end for compatibility with sdl2-compat:
    index2 = 12,
};

/// Bitmap pixel order, high bit -> low bit.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_BitmapOrder = enum(c_uint) {
    none = 0,
    _4321 = 1,
    _1234 = 2,
};

/// Packed component order, high bit -> low bit.
///
/// \since This enum is available since SDL 3.2.0.
////
pub const SDL_PackedOrder = enum(c_uint) {
    none = 0,
    xrgb = 1,
    rgbx = 2,
    argb = 3,
    rgba = 4,
    xbgr = 5,
    bgrx = 6,
    abgr = 7,
    bgra = 8,
};

/// Array component order, low byte -> high byte.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_ArrayOrder = enum(c_uint) {
    none = 0,
    rgb = 1,
    rgba = 2,
    argb = 3,
    bgr = 4,
    bgra = 5,
    abgr = 6,
};

/// Packed component layout.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_PackedLayout = enum(c_uint) {
    none = 0,
    _332 = 1,
    _4444 = 2,
    _1555 = 3,
    _5551 = 4,
    _565 = 5,
    _8888 = 6,
    _2101010 = 7,
    _1010102 = 8,
};

/// A macro for defining custom FourCC pixel formats.
///
/// For example, defining SDL_PIXELFORMAT_YV12 looks like this:
///
/// ```c
/// SDL_DEFINE_PIXELFOURCC('Y', 'V', '1', '2')
/// ```
///
/// \param A the first character of the FourCC code.
/// \param B the second character of the FourCC code.
/// \param C the third character of the FourCC code.
/// \param D the fourth character of the FourCC code.
/// \returns a format value in the style of SDL_PixelFormat.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_DEFINE_PIXELFOURCC(
    comptime a: anytype,
    comptime b: anytype,
    comptime c: anytype,
    comptime d: anytype,
) u32 {
    return stdinc.SDL_FOURCC(a, b, c, d);
}

/// A macro for defining custom non-FourCC pixel formats.
///
/// For example, defining SDL_PIXELFORMAT_RGBA8888 looks like this:
///
/// ```c
/// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4)
/// ```
///
/// \param type the type of the new format, probably a SDL_PixelType value.
/// \param order the order of the new format, probably a SDL_BitmapOrder,
///              SDL_PackedOrder, or SDL_ArrayOrder value.
/// \param layout the layout of the new format, probably an SDL_PackedLayout
///               value or zero.
/// \param bits the number of bits per pixel of the new format.
/// \param bytes the number of bytes per pixel of the new format.
/// \returns a format value in the style of SDL_PixelFormat.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_DEFINE_PIXELFORMAT(
    comptime pixel_type: c_uint,
    comptime order: c_uint,
    comptime layout: c_uint,
    comptime bits: c_uint,
    comptime bytes: c_uint,
) c_uint {
    return (1 << 28) | (pixel_type << 24) | (order << 20) | (layout << 16) | (bits << 8) | (bytes << 0);
}

/// A macro to retrieve the flags of an SDL_PixelFormat.
///
/// This macro is generally not needed directly by an app, which should use
/// specific tests, like SDL_ISPIXELFORMAT_FOURCC, instead.
///
/// \param format an SDL_PixelFormat to check.
/// \returns the flags of `format`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_PIXELFLAG(comptime format: anytype) @TypeOf(format) {
    return (format >> 28) & 0x0F;
}

/// A macro to retrieve the type of an SDL_PixelFormat.
///
/// This is usually a value from the SDL_PixelType enumeration.
///
/// \param format an SDL_PixelFormat to check.
/// \returns the type of `format`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
// #define SDL_PIXELTYPE(format)    (((format) >> 24) & 0x0F)
pub inline fn SDL_PIXELTYPE(comptime format: anytype) @TypeOf(format) {
    return format >> 24 & 0x0F;
}

/// A macro to retrieve the order of an SDL_PixelFormat.
///
/// This is usually a value from the SDL_BitmapOrder, SDL_PackedOrder, or
/// SDL_ArrayOrder enumerations, depending on the format type.
///
/// \param format an SDL_PixelFormat to check.
/// \returns the order of `format`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_PIXELORDER(comptime format: anytype) @TypeOf(format) {
    return (format >> 20) & 0x0F;
}

/// A macro to retrieve the layout of an SDL_PixelFormat.
///
/// This is usually a value from the SDL_PackedLayout enumeration, or zero if a
/// layout doesn't make sense for the format type.
///
/// \param format an SDL_PixelFormat to check.
/// \returns the layout of `format`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_PIXELLAYOUT(comptime format: anytype) @TypeOf(format) {
    return (format >> 16) & 0x0F;
}

/// A macro to determine an SDL_PixelFormat's bits per pixel.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// FourCC formats will report zero here, as it rarely makes sense to measure
/// them per-pixel.
///
/// \param format an SDL_PixelFormat to check.
/// \returns the bits-per-pixel of `format`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_BYTESPERPIXEL
pub inline fn SDL_BITSPERPIXEL(comptime format: anytype) @TypeOf(format) {
    return if (SDL_ISPIXELFORMAT_FOURCC(format)) 0 else (format >> 8) & 0xFF;
}

/// A macro to determine an SDL_PixelFormat's bytes per pixel.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// FourCC formats do their best here, but many of them don't have a meaningful
/// measurement of bytes per pixel.
///
/// \param format an SDL_PixelFormat to check.
/// \returns the bytes-per-pixel of `format`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
///
/// \sa SDL_BITSPERPIXEL
pub inline fn SDL_BYTESPERPIXEL(comptime format: anytype) @TypeOf(format) {
    const yuy2 = format == SDL_PixelFormat.yuy2;
    const uyvy = format == SDL_PixelFormat.uyvy;
    const yvyu = format == SDL_PixelFormat.yvyu;
    const p010 = if (format == SDL_PixelFormat.p010) 2 else 1;
    return if (SDL_ISPIXELFORMAT_FOURCC(format)) (yuy2 || uyvy || yvyu || p010) else (format >> 0) & 0xFF;
}

/// A macro to determine if an SDL_PixelFormat is an indexed format.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param format an SDL_PixelFormat to check.
/// \returns true if the format is indexed, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISPIXELFORMAT_INDEXED(comptime format: anytype) bool {
    const index1 = SDL_PIXELTYPE(format) == SDL_PixelType.index1;
    const index2 = SDL_PIXELTYPE(format) == SDL_PixelType.index2;
    const index4 = SDL_PIXELTYPE(format) == SDL_PixelType.index4;
    const index8 = SDL_PIXELTYPE(format) == SDL_PixelType.index8;
    return !SDL_ISPIXELFORMAT_FOURCC(format) and (index1 or index2 or index4 or index8);
}

/// A macro to determine if an SDL_PixelFormat is a packed format.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param format an SDL_PixelFormat to check.
/// \returns true if the format is packed, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISPIXELFORMAT_PACKED(comptime format: anytype) bool {
    return (!SDL_ISPIXELFORMAT_FOURCC(format) and
        SDL_PIXELTYPE(format) == SDL_PixelType.packed8 or
        SDL_PIXELTYPE(format) == SDL_PixelType.packed16 or
        SDL_PIXELTYPE(format) == SDL_PixelType.packed32);
}

/// A macro to determine if an SDL_PixelFormat is an array format.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param format an SDL_PixelFormat to check.
/// \returns true if the format is an array, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISPIXELFORMAT_ARRAY(comptime format: anytype) bool {
    return (!SDL_ISPIXELFORMAT_FOURCC(format) and
        SDL_PIXELTYPE(format) == SDL_PixelType.arrayu8 or
        SDL_PIXELTYPE(format) == SDL_PixelType.arrayu16 or
        SDL_PIXELTYPE(format) == SDL_PixelType.arrayu32 or
        SDL_PIXELTYPE(format) == SDL_PixelType.arrayf16 or
        SDL_PIXELTYPE(format) == SDL_PixelType.arrayf32);
}

/// A macro to determine if an SDL_PixelFormat is a 10-bit format.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param format an SDL_PixelFormat to check.
/// \returns true if the format is 10-bit, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISPIXELFORMAT_10BIT(comptime format: anytype) bool {
    return (!SDL_ISPIXELFORMAT_FOURCC(format) and
        (SDL_PIXELTYPE(format) == SDL_PixelType.packed32 and
            SDL_PIXELLAYOUT(format) == SDL_PackedLayout._2101010));
}

/// A macro to determine if an SDL_PixelFormat is a floating point format.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param format an SDL_PixelFormat to check.
/// \returns true if the format is a floating point, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISPIXELFORMAT_FLOAT(comptime format: anytype) bool {
    return (!SDL_ISPIXELFORMAT_FOURCC(format) and
        (SDL_PIXELTYPE(format) == SDL_PixelType.SDL_PIXELTYPE_ARRAYF16 or
            SDL_PIXELTYPE(format) == SDL_PixelType.SDL_PIXELTYPE_ARRAYF16));
}

/// A macro to determine if an SDL_PixelFormat has an alpha channel.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param format an SDL_PixelFormat to check.
/// \returns true if the format has alpha, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISPIXELFORMAT_ALPHA(comptime format: anytype) bool {
    return SDL_ISPIXELFORMAT_PACKED(format) and (SDL_PIXELORDER(format) == SDL_PackedOrder.ARGB or
        SDL_PIXELORDER(format) == SDL_PackedOrder.RGBA or
        SDL_PIXELORDER(format) == SDL_PackedOrder.ABGR or
        SDL_PIXELORDER(format) == SDL_PackedOrder.BGRA) or (SDL_ISPIXELFORMAT_ARRAY(format) and
        (SDL_PIXELORDER(format) == SDL_ArrayOrder.ARGB or
            SDL_PIXELORDER(format) == SDL_ArrayOrder.RGBA or
            SDL_PIXELORDER(format) == SDL_ArrayOrder.ABGR or
            SDL_PIXELORDER(format) == SDL_ArrayOrder.BGRA));
}

/// A macro to determine if an SDL_PixelFormat is a "FourCC" format.
///
/// This covers custom and other unusual formats.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param format an SDL_PixelFormat to check.
/// \returns true if the format has alpha, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISPIXELFORMAT_FOURCC(comptime format: anytype) bool {
    // The flag is set to 1 because 0x1? is not in the printable ASCII range
    return format and SDL_PIXELFLAG(format) != 1;
}

/// Pixel format.
///
/// SDL's pixel formats have the following naming convention:
///
/// - Names with a list of components and a single bit count, such as RGB24 and
///   ABGR32, define a platform-independent encoding into bytes in the order
///   specified. For example, in RGB24 data, each pixel is encoded in 3 bytes
///   (red, green, blue) in that order, and in ABGR32 data, each pixel is
///   encoded in 4 bytes (alpha, blue, green, red) in that order. Use these
///   names if the property of a format that is important to you is the order
///   of the bytes in memory or on disk.
/// - Names with a bit count per component, such as ARGB8888 and XRGB1555, are
///   "packed" into an appropriately-sized integer in the platform's native
///   endianness. For example, ARGB8888 is a sequence of 32-bit integers; in
///   each integer, the most significant bits are alpha, and the least
///   significant bits are blue. On a little-endian CPU such as x86, the least
///   significant bits of each integer are arranged first in memory, but on a
///   big-endian CPU such as s390x, the most significant bits are arranged
///   first. Use these names if the property of a format that is important to
///   you is the meaning of each bit position within a native-endianness
///   integer.
/// - In indexed formats such as INDEX4LSB, each pixel is represented by
///   encoding an index into the palette into the indicated number of bits,
///   with multiple pixels packed into each byte if appropriate. In LSB
///   formats, the first (leftmost) pixel is stored in the least-significant
///   bits of the byte; in MSB formats, it's stored in the most-significant
///   bits. INDEX8 does not need LSB/MSB variants, because each pixel exactly
///   fills one byte.
///
/// The 32-bit byte-array encodings such as RGBA32 are aliases for the
/// appropriate 8888 encoding for the current platform. For example, RGBA32 is
/// an alias for ABGR8888 on little-endian CPUs like x86, or an alias for
/// RGBA8888 on big-endian CPUs.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_PixelFormat = enum(c_uint) {
    unknown = 0,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_4321, 0, 1, 0)
    index1lsb = 0x11100100,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_1234, 0, 1, 0)
    index1msb = 0x11200100,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_4321, 0, 2, 0)
    index2lsb = 0x1c100200,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_1234, 0, 2, 0)
    index2msb = 0x1c200200,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_4321, 0, 4, 0)
    index4lsb = 0x12100400,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_1234, 0, 4, 0)
    index4msb = 0x12200400,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX8, 0, 0, 8, 1)
    index8 = 0x13000801,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED8, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_332, 8, 1)
    rgb332 = 0x14110801,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_4444, 12, 2)
    xrgb4444 = 0x15120c02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_4444, 12, 2)
    xbgr4444 = 0x15520c02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_1555, 15, 2)
    xrgb1555 = 0x15130f02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_1555, 15, 2)
    xbgr1555 = 0x15530f02,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_4444, 16, 2)
    argb4444 = 0x15321002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_4444, 16, 2)
    rgba4444 = 0x15421002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_4444, 16, 2)
    abgr4444 = 0x15721002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_4444, 16, 2)
    bgra4444 = 0x15821002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_1555, 16, 2)
    argb1555 = 0x15331002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_5551, 16, 2)
    rgba5551 = 0x15441002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_1555, 16, 2)
    abgr1555 = 0x15731002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_5551, 16, 2)
    bgra5551 = 0x15841002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_565, 16, 2)
    rgb565 = 0x15151002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_565, 16, 2)
    bgr565 = 0x15551002,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_RGB, 0, 24, 3)
    rgb24 = 0x17101803,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_BGR, 0, 24, 3)
    bgr24 = 0x17401803,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_8888, 24, 4)
    xrgb8888 = 0x16161804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBX, SDL_PACKEDLAYOUT_8888, 24, 4)
    rgbx8888 = 0x16261804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_8888, 24, 4)
    xbgr8888 = 0x16561804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRX, SDL_PACKEDLAYOUT_8888, 24, 4)
    bgrx8888 = 0x16661804,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_8888, 32, 4)
    argb8888 = 0x16362004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4)
    rgba8888 = 0x16462004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_8888, 32, 4)
    abgr8888 = 0x16762004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_8888, 32, 4)
    bgra8888 = 0x16862004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_2101010, 32, 4)
    xrgb2101010 = 0x16172004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_2101010, 32, 4)
    xbgr2101010 = 0x16572004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_2101010, 32, 4)
    argb2101010 = 0x16372004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_2101010, 32, 4)
    abgr2101010 = 0x16772004,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGB, 0, 48, 6)
    rgb48 = 0x18103006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGR, 0, 48, 6)
    bgr48 = 0x18403006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGBA, 0, 64, 8)
    rgba64 = 0x18204008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ARGB, 0, 64, 8)
    argb64 = 0x18304008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGRA, 0, 64, 8)
    bgra64 = 0x18504008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ABGR, 0, 64, 8)
    abgr64 = 0x18604008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGB, 0, 48, 6)
    rgb48_float = 0x1a103006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGR, 0, 48, 6)
    bgr48_float = 0x1a403006,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGBA, 0, 64, 8)
    rgba64_float = 0x1a204008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ARGB, 0, 64, 8)
    argb64_float = 0x1a304008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGRA, 0, 64, 8)
    bgra64_float = 0x1a504008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ABGR, 0, 64, 8)
    abgr64_float = 0x1a604008,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGB, 0, 96, 12)
    rgb96_float = 0x1b10600c,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGR, 0, 96, 12)
    bgr96_float = 0x1b40600c,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGBA, 0, 128, 16)
    rgba128_float = 0x1b208010,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ARGB, 0, 128, 16)
    argb128_float = 0x1b308010,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGRA, 0, 128, 16)
    bgra128_float = 0x1b508010,
    /// SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ABGR, 0, 128, 16)
    abgr128_float = 0x1b608010,

    /// Planar mode: Y + V + U  (3 planes)
    /// SDL_DEFINE_PIXELFOURCC('Y', 'V', '1', '2')
    yv12 = 0x32315659,
    /// Planar mode: Y + U + V  (3 planes)
    /// SDL_DEFINE_PIXELFOURCC('I', 'Y', 'U', 'V')
    iyuv = 0x56555949,
    /// Packed mode: Y0+U0+Y1+V0 (1 plane)
    /// SDL_DEFINE_PIXELFOURCC('Y', 'U', 'Y', '2')
    yuy2 = 0x32595559,
    /// Packed mode: U0+Y0+V0+Y1 (1 plane)
    /// SDL_DEFINE_PIXELFOURCC('U', 'Y', 'V', 'Y')
    uyvy = 0x59565955,
    /// Packed mode: Y0+U0+Y1+V0 (1 plane)
    /// SDL_DEFINE_PIXELFOURCC('Y', 'V', 'Y', 'U')
    yvyu = 0x55595659,
    /// Planar mode: Y + U/V interleaved  (2 planes)
    /// SDL_DEFINE_PIXELFOURCC('N', 'V', '1', '2')
    nv12 = 0x3231564e,
    /// Planar mode: Y + V/U interleaved  (2 planes)
    /// SDL_DEFINE_PIXELFOURCC('N', 'V', '2', '1')
    nv21 = 0x3132564e,
    /// Planar mode: Y + U/V interleaved  (2 planes)
    /// SDL_DEFINE_PIXELFOURCC('P', '0', '1', '0'
    p010 = 0x30313050,
    /// Android video texture format
    /// SDL_DEFINE_PIXELFOURCC('O', 'E', 'S', ' ')
    external_oes = 0x2053454f,

    /// Motion JPEG
    /// SDL_DEFINE_PIXELFOURCC('M', 'J', 'P', 'G')
    mjpg = 0x47504a4d,

    // Aliases for RGBA byte arrays of color data, for the current platform
    // TODO: probably will have to make this a separate enum to make zig happy
    rgba32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.rgba8888 else SDL_PixelFormat.abgr8888,
    argb32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.argb8888 else SDL_PixelFormat.bgra8888,
    bgra32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.bgra8888 else SDL_PixelFormat.argb8888,
    abgr32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.abgr8888 else SDL_PixelFormat.rgba8888,
    rgbx32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.rgbx8888 else SDL_PixelFormat.xbgr8888,
    xrgb32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.xrgb8888 else SDL_PixelFormat.bgrx8888,
    bgrx32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.bgrx8888 else SDL_PixelFormat.xrgb8888,
    xbgr32 = if (builtin.cpu.arch.endian() == .big) SDL_PixelFormat.xbgr8888 else SDL_PixelFormat.rgbx8888,
};

/// Colorspace color type.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_ColorType = enum(c_uint) { unknown = 0, rgb = 1, ycbcr = 2 };

/// Colorspace color range, as described by
/// https://www.itu.int/rec/R-REC-BT.2100-2-201807-I/en
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_ColorRange = enum(c_uint) {
    unknown = 0,
    /// Narrow range, e.g. 16-235 for 8-bit RGB and luma, and 16-240 for 8-bit chroma
    limited = 1,
    /// Full range, e.g. 0-255 for 8-bit RGB and luma, and 1-255 for 8-bit chroma
    full = 2,
};

/// Colorspace color primaries, as described by
/// https://www.itu.int/rec/T-REC-H.273-201612-S/en
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_ColorPrimaries = enum(c_uint) {
    unknown = 0,
    /// ITU-R BT.709-6
    bt709 = 1,
    unspecified = 2,
    /// ITU-R BT.470-6 System M
    bt470m = 4,
    /// ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625
    bt470bg = 5,
    /// ITU-R BT.601-7 525, SMPTE 170M
    bt601 = 6,
    /// SMPTE 240M, functionally the same as SDL_COLOR_PRIMARIES_BT601
    smpte240 = 7,
    /// Generic film (color filters using Illuminant C)
    generic_film = 8,
    /// ITU-R BT.2020-2 / ITU-R BT.2100-0
    bt2020 = 9,
    /// SMPTE ST 428-1
    xyz = 10,
    /// SMPTE RP 431-2
    smpte431 = 11,
    /// SMPTE EG 432-1 / DCI P3
    smpte432 = 12,
    /// EBU Tech. 3213-E
    ebu3213 = 22,
    custom = 31,
};

/// Colorspace transfer characteristics.
///
/// These are as described by https://www.itu.int/rec/T-REC-H.273-201612-S/en
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_TransferCharacteristics = enum(c_uint) {
    unknown = 0,
    /// Rec. ITU-R BT.709-6 / ITU-R BT1361
    bt709 = 1,
    unspecified = 2,
    /// ITU-R BT.470-6 System M / ITU-R BT1700 625 PAL & SECAM
    gamma22 = 4,
    /// ITU-R BT.470-6 System B, G
    gamma28 = 5,
    /// SMPTE ST 170M / ITU-R BT.601-7 525 or 625
    bt601 = 6,
    /// SMPTE ST 240M
    smpte240 = 7,
    linear = 8,
    log100 = 9,
    log100_sqrt10 = 10,
    /// IEC 61966-2-4
    iec61966 = 11,
    /// ITU-R BT1361 Extended Colour Gamut
    bt1361 = 12,
    /// IEC 61966-2-1 (sRGB or sYCC)
    srgb = 13,
    /// ITU-R BT2020 for 10-bit system
    bt2020_10bit = 14,
    /// ITU-R BT2020 for 12-bit system
    bt2020_12bit = 15,
    /// SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems
    pq = 16,
    /// SMPTE ST 428-1
    smpte428 = 17,
    /// ARIB STD-B67, known as "hybrid log-gamma" (HLG)
    hlg = 18,
    custom = 31,
};

/// Colorspace matrix coefficients.
///
/// These are as described by https://www.itu.int/rec/T-REC-H.273-201612-S/en
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_MatrixCoefficients = enum(c_uint) {
    identity = 0,
    /// ITU-R BT.709-6
    bt709 = 1,
    unspecified = 2,
    /// US FCC Title 47
    fcc = 4,
    /// ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625, functionally the same
    /// as SDL_MATRIX_COEFFICIENTS_BT601
    bt470bg = 5,
    /// ITU-R BT.601-7 525
    bt601 = 6,
    /// SMPTE 240M
    smpte240 = 7,
    ycgco = 8,
    /// ITU-R BT.2020-2 non-constant luminance
    bt2020_ncl = 9,
    /// ITU-R BT.2020-2 constant luminance
    bt2020_cl = 10,
    /// SMPTE ST 2085
    smpte2085 = 11,
    chroma_derived_ncl = 12,
    chroma_derived_cl = 13,
    /// ITU-R BT.2100-0 ICTCP
    ictcp = 14,
    custom = 31,
};

/// Colorspace chroma sample location.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_ChromaLocation = enum(c_uint) {
    /// RGB, no chroma sampling
    none = 0,
    /// In MPEG-2, MPEG-4, and AVC, Cb and Cr are taken on midpoint of the
    /// left-edge of the 2x2 square. In other words, they have the same
    /// horizontal location as the top-left pixel, but is shifted one-half
    /// pixel down vertically.
    left = 1,
    /// In JPEG/JFIF, H.261, and MPEG-1, Cb and Cr are taken at the center of
    /// the 2x2 square. In other words, they are offset one-half pixel to the
    /// right and one-half pixel down compared to the top-left pixel.
    center = 2,
    /// In HEVC for BT.2020 and BT.2100 content (in particular on Blu-rays), Cb
    /// and Cr are sampled at the same location as the group's top-left Y pixel
    /// ("co-sited", "co-located").
    topleft = 3,
};

/////////////////////////////
// Colorspace definition
/////////////////////////////

/// A macro for defining custom SDL_Colorspace formats.
///
/// For example, defining SDL_COLORSPACE_SRGB looks like this:
///
/// ```c
/// SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
///                       SDL_COLOR_RANGE_FULL,
///                       SDL_COLOR_PRIMARIES_BT709,
///                       SDL_TRANSFER_CHARACTERISTICS_SRGB,
///                       SDL_MATRIX_COEFFICIENTS_IDENTITY,
///                       SDL_CHROMA_LOCATION_NONE)
/// ```
///
/// \param type the type of the new format, probably an SDL_ColorType value.
/// \param range the range of the new format, probably a SDL_ColorRange value.
/// \param primaries the primaries of the new format, probably an
///                  SDL_ColorPrimaries value.
/// \param transfer the transfer characteristics of the new format, probably an
///                 SDL_TransferCharacteristics value.
/// \param matrix the matrix coefficients of the new format, probably an
///               SDL_MatrixCoefficients value.
/// \param chroma the chroma sample location of the new format, probably an
///               SDL_ChromaLocation value.
/// \returns a format value in the style of SDL_Colorspace.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
// #define SDL_DEFINE_COLORSPACE(type, range, primaries, transfer, matrix, chroma) \
//     (((Uint32)(type) << 28) | ((Uint32)(range) << 24) | ((Uint32)(chroma) << 20) | \
//     ((Uint32)(primaries) << 10) | ((Uint32)(transfer) << 5) | ((Uint32)(matrix) << 0))
pub inline fn SDL_DEFINE_COLORSPACE(
    comptime colorType: anytype,
    comptime range: anytype,
    comptime primaries: anytype,
    comptime transfer: anytype,
    comptime matrix: anytype,
    comptime chroma: anytype,
) c_uint {
    const colorType_shifted = @as(u32, @bitCast(colorType)) << 28;
    const range_shifted = @as(u32, @bitCast(range)) << 24;
    const chroma_shifted = @as(u32, @bitCast(chroma)) << 20;
    const primaries_shifted = @as(u32, @bitCast(primaries)) << 10;
    const transfer_shifted = @as(u32, @bitCast(transfer)) << 5;
    const matrix_shifted = @as(u32, @bitCast(matrix)) << 0;

    return colorType_shifted | range_shifted | chroma_shifted |
        primaries_shifted | transfer_shifted | matrix_shifted;
}

/// A macro to retrieve the type of an SDL_Colorspace.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns the SDL_ColorType for `cspace`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_COLORSPACETYPE(comptime cspace: anytype) SDL_ColorType {
    const casted: u32 = @bitCast(cspace);
    return @enumFromInt((casted >> 28) & 0x0F);
}

/// A macro to retrieve the range of an SDL_Colorspace.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns the SDL_ColorRange of `cspace`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_COLORSPACERANGE(comptime cspace: anytype) SDL_ColorRange {
    const casted: u32 = @bitCast(cspace);
    return @enumFromInt((casted >> 24) & 0x0F);
}

/// A macro to retrieve the chroma sample location of an SDL_Colorspace.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns the SDL_ChromaLocation of `cspace`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_COLORSPACECHROMA(comptime cspace: anytype) SDL_ChromaLocation {
    const casted: u32 = @bitCast(cspace);
    return @enumFromInt((casted >> 20) & 0x0F);
}

/// A macro to retrieve the primaries of an SDL_Colorspace.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns the SDL_ColorPrimaries of `cspace`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_COLORSPACEPRIMARIES(comptime cspace: anytype) SDL_ColorPrimaries {
    const casted: u32 = @bitCast(cspace);
    return @enumFromInt((casted >> 10) & 0x0F);
}

/// A macro to retrieve the transfer characteristics of an SDL_Colorspace.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns the SDL_TransferCharacteristics of `cspace`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_COLORSPACETRANSFER(comptime cspace: anytype) SDL_TransferCharacteristics {
    const casted: u32 = @bitCast(cspace);
    return @enumFromInt((casted >> 5) & 0x1F);
}

/// A macro to retrieve the matrix coefficients of an SDL_Colorspace.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns the SDL_MatrixCoefficients of `cspace`.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_COLORSPACEMATRIX(comptime cspace: anytype) SDL_MatrixCoefficients {
    const casted: u32 = @bitCast(cspace);
    return @enumFromInt(casted & 0x1F);
}

/// A macro to determine if an SDL_Colorspace uses BT601 (or BT470BG) matrix
/// coefficients.
///
/// Note that this macro double-evaluates its parameter, so do not use
/// expressions with side-effects here.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns true if BT601 or BT470BG, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISCOLORSPACE_MATRIX_BT601(comptime cspace: anytype) bool {
    return SDL_COLORSPACEMATRIX(cspace) == SDL_MatrixCoefficients.bt601 or
        SDL_COLORSPACEMATRIX(cspace) == .bt470bg;
}

/// A macro to determine if an SDL_Colorspace uses BT709 matrix coefficients.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns true if BT709, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISCOLORSPACE_MATRIX_BT709(comptime cspace: anytype) bool {
    return SDL_COLORSPACEMATRIX(cspace) == .bt709;
}

/// A macro to determine if an SDL_Colorspace uses BT2020_NCL matrix
/// coefficients.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns true if BT2020_NCL, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISCOLORSPACE_MATRIX_BT2020_NCL(comptime cspace: anytype) bool {
    return SDL_COLORSPACEMATRIX(cspace) == .bt2020_ncl;
}

/// A macro to determine if an SDL_Colorspace has a limited range.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns true if limited range, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISCOLORSPACE_LIMITED_RANGE(comptime cspace: anytype) bool {
    return SDL_COLORSPACERANGE(cspace) != .full;
}

/// A macro to determine if an SDL_Colorspace has a full range.
///
/// \param cspace an SDL_Colorspace to check.
/// \returns true if full range, false otherwise.
///
/// \threadsafety It is safe to call this macro from any thread.
///
/// \since This macro is available since SDL 3.2.0.
pub inline fn SDL_ISCOLORSPACE_FULL_RANGE(comptime cspace: anytype) bool {
    return SDL_COLORSPACERANGE(cspace) == .full;
}

/// Colorspace definitions.
///
/// Since similar colorspaces may vary in their details (matrix, transfer
/// function, etc.), this is not an exhaustive list, but rather a
/// representative sample of the kinds of colorspaces supported in SDL.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_ColorPrimaries
/// \sa SDL_ColorRange
/// \sa SDL_ColorType
/// \sa SDL_MatrixCoefficients
/// \sa SDL_TransferCharacteristics
pub const SDL_Colorspace = enum(c_uint) {
    unknown = 0,

    // sRGB is a gamma corrected colorspace, and the default colorspace for SDL rendering and 8-bit RGB surfaces */

    /// Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709
    srgb = 0x120005a0,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
    //                       SDL_COLOR_RANGE_FULL,
    //                       SDL_COLOR_PRIMARIES_BT709,
    //                       SDL_TRANSFER_CHARACTERISTICS_SRGB,
    //                       SDL_MATRIX_COEFFICIENTS_IDENTITY,
    //                       SDL_CHROMA_LOCATION_NONE),

    // This is a linear colorspace and the default colorspace for floating point surfaces. On Windows this is the scRGB colorspace, and on Apple platforms this is kCGColorSpaceExtendedLinearSRGB for EDR content */

    /// Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709
    srgb_linear = 0x12000500,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
    //                       SDL_COLOR_RANGE_FULL,
    //                       SDL_COLOR_PRIMARIES_BT709,
    //                       SDL_TRANSFER_CHARACTERISTICS_LINEAR,
    //                       SDL_MATRIX_COEFFICIENTS_IDENTITY,
    //                       SDL_CHROMA_LOCATION_NONE),

    // HDR10 is a non-linear HDR colorspace and the default colorspace for 10-bit surfaces

    /// Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020
    hdr10 = 0x12002600,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_RGB,
    //                       SDL_COLOR_RANGE_FULL,
    //                       SDL_COLOR_PRIMARIES_BT2020,
    //                       SDL_TRANSFER_CHARACTERISTICS_PQ,
    //                       SDL_MATRIX_COEFFICIENTS_IDENTITY,
    //                       SDL_CHROMA_LOCATION_NONE),

    /// Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_NONE_P709_X601
    jpeg = 0x220004c6,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    //                       SDL_COLOR_RANGE_FULL,
    //                       SDL_COLOR_PRIMARIES_BT709,
    //                       SDL_TRANSFER_CHARACTERISTICS_BT601,
    //                       SDL_MATRIX_COEFFICIENTS_BT601,
    //                       SDL_CHROMA_LOCATION_NONE),

    /// Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601
    bt601_limited = 0x211018c6,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    //                       SDL_COLOR_RANGE_LIMITED,
    //                       SDL_COLOR_PRIMARIES_BT601,
    //                       SDL_TRANSFER_CHARACTERISTICS_BT601,
    //                       SDL_MATRIX_COEFFICIENTS_BT601,
    //                       SDL_CHROMA_LOCATION_LEFT),

    /// Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601
    bt601_full = 0x221018c6,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    //                       SDL_COLOR_RANGE_FULL,
    //                       SDL_COLOR_PRIMARIES_BT601,
    //                       SDL_TRANSFER_CHARACTERISTICS_BT601,
    //                       SDL_MATRIX_COEFFICIENTS_BT601,
    //                       SDL_CHROMA_LOCATION_LEFT),

    /// Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709
    bt709_limited = 0x21100421,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    //                       SDL_COLOR_RANGE_LIMITED,
    //                       SDL_COLOR_PRIMARIES_BT709,
    //                       SDL_TRANSFER_CHARACTERISTICS_BT709,
    //                       SDL_MATRIX_COEFFICIENTS_BT709,
    //                       SDL_CHROMA_LOCATION_LEFT),

    /// Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709
    bt709_full = 0x22100421,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    //                       SDL_COLOR_RANGE_FULL,
    //                       SDL_COLOR_PRIMARIES_BT709,
    //                       SDL_TRANSFER_CHARACTERISTICS_BT709,
    //                       SDL_MATRIX_COEFFICIENTS_BT709,
    //                       SDL_CHROMA_LOCATION_LEFT),

    /// Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P2020 */
    bt2020_limited = 0x21102609,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    //                       SDL_COLOR_RANGE_LIMITED,
    //                       SDL_COLOR_PRIMARIES_BT2020,
    //                       SDL_TRANSFER_CHARACTERISTICS_PQ,
    //                       SDL_MATRIX_COEFFICIENTS_BT2020_NCL,
    //                       SDL_CHROMA_LOCATION_LEFT),

    /// Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P2020
    bt2020_full = 0x22102609,
    // SDL_DEFINE_COLORSPACE(SDL_COLOR_TYPE_YCBCR,
    //                       SDL_COLOR_RANGE_FULL,
    //                       SDL_COLOR_PRIMARIES_BT2020,
    //                       SDL_TRANSFER_CHARACTERISTICS_PQ,
    //                       SDL_MATRIX_COEFFICIENTS_BT2020_NCL,
    //                       SDL_CHROMA_LOCATION_LEFT),

    /// The default colorspace for RGB surfaces if no colorspace is specified
    rgb_default = .srgb,
    /// The default colorspace for YUV surfaces if no colorspace is specified
    yuv_default = .bt601_limited,
};

/// A structure that represents a color as RGBA components.
///
/// The bits of this structure can be directly reinterpreted as an
/// integer-packed color which uses the SDL_PIXELFORMAT_RGBA32 format
/// (SDL_PIXELFORMAT_ABGR8888 on little-endian systems and
/// SDL_PIXELFORMAT_RGBA8888 on big-endian systems).
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

/// The bits of this structure can be directly reinterpreted as a float-packed
/// color which uses the SDL_PIXELFORMAT_RGBA128_FLOAT format
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_FColor = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

/// A set of indexed colors representing a palette.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_SetPaletteColors
pub const SDL_Palette = extern struct {
    /// number of elements in `colors`.
    ncolors: c_int,
    /// an array of colors, `ncolors` long.
    colors: *SDL_Color,
    /// internal use only, do not touch.
    version: u32,
    /// internal use only, do not touch.
    refcount: c_int,
};

/// Details about the format of a pixel.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_PixelFormatDetails = extern struct {
    format: SDL_PixelFormat,
    bits_per_pixel: u8,
    bytes_per_pixel: u8,
    padding: u8[2],
    Rmask: u32,
    Gmask: u32,
    Bmask: u32,
    Amask: u32,
    Rbits: u8,
    Gbits: u8,
    Bbits: u8,
    Abits: u8,
    Rshift: u8,
    Gshift: u8,
    Bshift: u8,
    Ashift: u8,
};
