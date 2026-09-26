// # CategoryScancode
//
// Defines keyboard scancodes.
//
// Please refer to the Best Keyboard Practices document for details on what
// this information means and how best to use it.
//
// https://wiki.libsdl.org/SDL3/BestKeyboardPractices

/// The SDL keyboard scancode representation.
///
/// An SDL scancode is the physical representation of a key on the keyboard,
/// independent of language and keyboard mapping.
///
/// Values of this type are used to represent keyboard keys, among other places
/// in the `scancode` field of the SDL_KeyboardEvent structure.
///
/// The values in this enumeration are based on the USB usage page standard:
/// https://usb.org/sites/default/files/hut1_5.pdf
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_Scancode = enum(u32) {
    unknown = 0,

    // These values are from usage page 0x07 (USB keyboard page).
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
    /// Located at the lower left of the return key on ISO keyboards and at the
    /// right end of the QWERTY row on ANSI keyboards. Produces REVERSE SOLIDUS
    /// (backslash) and  VERTICAL LINE in a US layout, REVERSE SOLIDUS and
    /// VERTICAL LINE in a UK Mac layout, NUMBER SIGN and TILDE in a UK Windows
    /// layout, DOLLAR SIGN and POUND SIGN in a Swiss German layout, NUMBER
    /// SIGN and APOSTROPHE in a German layout, GRAVE ACCENT and POUND SIGN in
    /// a French Mac layout, and ASTERISK and MICRO SIGN in a French Windows
    /// layout.
    backslash = 49,
    /// ISO USB keyboards actually use this code instead of 49 for the same
    /// key, but all OSes I've seen treat the two codes identically. So, as an
    /// implementor, unless your keyboard generates both of those codes and
    /// your OS treats them differently, you should generate
    /// SDL_SCANCODE_BACKSLASH instead of this code. As a user, you should not
    /// rely on this code because SDL will never generate it with most (all?)
    /// keyboards.
    nonushash = 50,
    semicolon = 51,
    apostrophe = 52,
    /// Located in the top left corner (on both ANSI and ISO keyboards).
    /// Produces GRAVE ACCENT and TILDE in a US Windows layout and in US and UK
    /// Mac layouts on ANSI keyboards, GRAVE ACCENT and NOT SIGN in a UK
    /// Windows layout, SECTION SIGN and PLUS-MINUS SIGN in US and UK Mac
    /// layouts on ISO keyboards, SECTION SIGN and DEGREE SIGN in a Swiss
    /// German layout (Mac: only on ISO keyboards), CIRCUMFLEX ACCENT and
    /// DEGREE SIGN in a German layout (Mac: only on ISO keyboards),
    /// SUPERSCRIPT TWO and TILDE in a French Windows layout, COMMERCIAL AT and
    /// NUMBER SIGN in a French Mac layout on ISO keyboards, and LESS-THAN SIGN
    /// and GREATER-THAN SIGN in a Swiss German, German, or French Mac layout
    /// on ANSI keyboards.
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
    /// insert on PC, help on some Mac keyboards (but does send code 73, not 117)
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
    /// num lock on PC, clear on Mac keyboards
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

    /// This is the additional key that ISO keyboards have over ANSI ones,
    /// located between left shift and Z. Produces GRAVE ACCENT and TILDE in a
    /// US or UK Mac layout, REVERSE SOLIDUS (backslash) and VERTICAL LINE in a
    /// US or UK Windows layout, and LESS-THAN SIGN and GREATER-THAN SIGN in a
    /// Swiss German, German, or French layout.
    nonusbackslash = 100,
    /// windows contextual menu, compose
    application = 101,
    /// The USB document says this is a status flag, not a physical key - but
    /// some Mac keyboards do have a power key.
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
    /// AL Integrated Help Center
    help = 117,
    /// Menu (show menu)
    menu = 118,
    select = 119,
    /// AC Stop 
    stop = 120,
    /// AC Redo/Repeat
    again = 121,
    /// AC Undo
    undo = 122,
    /// AC Cut
    cut = 123,
    /// AC Copy
    copy = 124,
    /// AC Paste
    paste = 125,
    /// AC Find
    find = 126,
    mute = 127,
    volumeup = 128,
    volumedown = 129,
    // not sure whether there's a reason to enable these
    // lockingcapslock = 130,
    // lockingnumlock = 131,
    // lockingscrolllock = 132,
    kp_comma = 133,
    kp_equalsas400 = 134,

    /// used on Asian keyboards, see footnotes in USB doc
    international1 = 135,
    international2 = 136,
    /// Yen
    international3 = 137,
    international4 = 138,
    international5 = 139,
    international6 = 140,
    international7 = 141,
    international8 = 142,
    international9 = 143,
    /// Hangul/English toggle
    lang1 = 144,
    /// Hanja conversion
    lang2 = 145,
    /// Katakana
    lang3 = 146,
    /// Hiragana 
    lang4 = 147,
    /// Zenkaku/Hankaku
    lang5 = 148,
    /// reserved
    lang6 = 149,
    /// reserved
    lang7 = 150,
    /// reserved
    lang8 = 151,
    /// reserved
    lang9 = 152,

    /// Erase-Eaze 
    alterase = 153,
    sysreq = 154,
    /// AC Cancel
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
    /// alt, option
    lalt = 226,
    /// windows, command (apple), meta
    lgui = 227,
    rctrl = 228,
    rshift = 229,
    /// alt gr, option
    ralt = 230,
    /// windows, command (apple), meta
    rgui = 231,
    /// I'm not sure if this is really not covered by any of the above, but
    /// since there's a special SDL_KMOD_MODE for it I'm adding it here
    mode = 257,

    // End of USB usage page 0x07

    
    // These values are mapped from usage page 0x0C (USB consumer page).
    // 
    // There are way more keys in the spec than we can represent in the
    // current scancode range, so pick the ones that commonly come up in
    // real world usage.

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

    // End of usage page 0x0C

    //These are values that are often used on mobile phones.

    /// Usually situated below the display on phones and used as a
    /// multi-function feature key for selecting a software defined function
    /// shown on the bottom left of the display.
    softleft = 287,
    /// Usually situated below the display on phones and used as a
    /// multi-function feature key for selecting a software defined function
    /// shown on the bottom right of the display.
    softright = 288,
    /// Used for accepting phone calls.
    call = 289,
    /// Used for rejecting phone calls.
    endcall = 290,

    // End of mobile keys

    /// 400-500 reserved for dynamic keycodes 
    reserved = 400,

    /// not a key, just marks the number of scancodes for array bounds
    count = 512,
};
