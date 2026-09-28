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
    SDL_PIXELTYPE_UNKNOWN = 0,
    SDL_PIXELTYPE_INDEX1 = 1,
    SDL_PIXELTYPE_INDEX4 = 2,
    SDL_PIXELTYPE_INDEX8 = 3,
    SDL_PIXELTYPE_PACKED8 = 4,
    SDL_PIXELTYPE_PACKED16 = 5,
    SDL_PIXELTYPE_PACKED32 = 6,
    SDL_PIXELTYPE_ARRAYU8 = 7,
    SDL_PIXELTYPE_ARRAYU16 = 8,
    SDL_PIXELTYPE_ARRAYU32 = 9,
    SDL_PIXELTYPE_ARRAYF16 = 10,
    SDL_PIXELTYPE_ARRAYF32 = 11,
    /// appended at the end for compatibility with sdl2-compat:
    SDL_PIXELTYPE_INDEX2 = 12,
};

/// Bitmap pixel order, high bit -> low bit.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_BitmapOrder = enum(c_uint) {
    SDL_BITMAPORDER_NONE = 0,
    SDL_BITMAPORDER_4321 = 1,
    SDL_BITMAPORDER_1234 = 2,
};

/// Packed component order, high bit -> low bit.
///
/// \since This enum is available since SDL 3.2.0.
////
pub const SDL_PackedOrder = enum(c_uint) {
    SDL_PACKEDORDER_NONE = 0,
    SDL_PACKEDORDER_XRGB = 1,
    SDL_PACKEDORDER_RGBX = 2,
    SDL_PACKEDORDER_ARGB = 3,
    SDL_PACKEDORDER_RGBA = 4,
    SDL_PACKEDORDER_XBGR = 5,
    SDL_PACKEDORDER_BGRX = 6,
    SDL_PACKEDORDER_ABGR = 7,
    SDL_PACKEDORDER_BGRA = 8,
};

/// Array component order, low byte -> high byte.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_ArrayOrder = enum(c_uint) {
    SDL_ARRAYORDER_NONE = 0,
    SDL_ARRAYORDER_RGB = 1,
    SDL_ARRAYORDER_RGBA = 2,
    SDL_ARRAYORDER_ARGB = 3,
    SDL_ARRAYORDER_BGR = 4,
    SDL_ARRAYORDER_BGRA = 5,
    SDL_ARRAYORDER_ABGR = 6,
};

/// Packed component layout.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_PackedLayout = enum(c_uint) {
    SDL_PACKEDLAYOUT_NONE = 0,
    SDL_PACKEDLAYOUT_332 = 1,
    SDL_PACKEDLAYOUT_4444 = 2,
    SDL_PACKEDLAYOUT_1555 = 3,
    SDL_PACKEDLAYOUT_5551 = 4,
    SDL_PACKEDLAYOUT_565 = 5,
    SDL_PACKEDLAYOUT_8888 = 6,
    SDL_PACKEDLAYOUT_2101010 = 7,
    SDL_PACKEDLAYOUT_1010102 = 8,
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
pub inline fn SDL_PIXELFLAG(comptime format: anytype) c_uint {
    return (format >> 28) & 0x0F;
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
