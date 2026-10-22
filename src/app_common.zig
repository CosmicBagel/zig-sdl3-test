const std = @import("std");
const sdl = @import("sdl/sdl.zig");

pub const AppContext = struct {
    name: [:0]const u8,
    device: ?*sdl.gpu.SDL_GPUDevice = null,
    window: ?*sdl.video.SDL_Window = null,
    last_time: u64 = 0,
};

pub const AppError = error{
    SdlError,
};

pub fn appInitMinimal(context: *AppContext) !void {
    sdl.log.SDL_SetLogPriorities(.verbose);
    sdl.log.SDL_Log(context.name);

    var buf: [256]u8 = undefined;
    const app_id = try std.fmt.bufPrintSentinel(
        &buf,
        "{s}{s}",
        .{ "com.cosmicbagel.com", context.name },
        0,
    );
    if (!sdl.init.SDL_SetAppMetadata(
        context.name,
        "0.0.1",
        app_id,
    )) {
        return AppError.SdlError;
    }

    if (!sdl.init.SDL_Init(.{ .video = true })) {
        sdl.log.SDL_Log("Failed to initialize SDL: %s", sdl.sdl_error.SDL_GetError());
        return AppError.SdlError;
    }

    try InitializeAssetLoader();

    std.debug.print("base_path: {s}\n", .{base_path.?});

    try gpuInit(context);
}

pub fn gpuInit(context: *AppContext) AppError!void {
    context.device = sdl.gpu.SDL_CreateGPUDevice(
        .{ .spirv = true, .dxil = true, .msl = true },
        true,
        null,
    );

    if (context.device == null) {
        sdl.log.SDL_Log("GPUCreateDevice failed");
        return error.SdlError;
    }

    context.window = sdl.video.SDL_CreateWindow(context.name, 640, 480, .{});
    if (context.window == null) {
        sdl.log.SDL_Log("CreateWindow failed: %s", sdl.sdl_error.SDL_GetError());
        return error.SdlError;
    }

    if (!sdl.gpu.SDL_ClaimWindowForGPUDevice(context.device.?, context.window.?)) {
        sdl.log.SDL_Log("GPUClaimWindow failed");
        return error.SdlError;
    }
}

pub var base_path: ?[*:0]const u8 = null;
pub fn InitializeAssetLoader() error{SdlError}!void {
    if (sdl.filesystem.SDL_GetBasePath()) |path| {
        base_path = path;
    } else {
        return error.SdlError;
    }
}

pub fn appDeinitMinimal(context: *AppContext) void {
    gpuDeinit(context);
}

pub fn gpuDeinit(context: *AppContext) void {
    sdl.gpu.SDL_ReleaseWindowFromGPUDevice(context.device.?, context.window.?);
    sdl.video.SDL_DestroyWindow(context.window.?);
    sdl.gpu.SDL_DestroyGPUDevice(context.device.?);
}
