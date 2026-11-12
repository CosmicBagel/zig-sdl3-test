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

pub const LoadShaderError = error{ BadFilename, UnrecognizedBackendShaderFormat };

pub fn appInitMinimal(io: std.Io, context: *AppContext) !void {
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

    try initializeAssetLoader(io);

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

var base_path_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
pub var base_path: ?[]const u8 = null;
pub var base_dir: ?std.Io.Dir = null;
pub fn initializeAssetLoader(io: std.Io) !void {
    const n = try std.process.currentPath(io, &base_path_buf);
    base_path = base_path_buf[0..n];
    // yes this could be done with cwd, but currently realPath on cwd is
    // broken, so it makes me feel better to start with the path and manually
    // open the cwd
    base_dir = try std.Io.Dir.openDirAbsolute(io, base_path.?, .{});
}

pub fn deinitAssetLoader(io: std.Io) void {
    if (base_dir) |dir| {
        dir.close(io);
    }
}

pub fn appDeinitMinimal(io: std.Io, context: *AppContext) void {
    deinitAssetLoader(io);
    gpuDeinit(context);
}

pub fn gpuDeinit(context: *AppContext) void {
    sdl.gpu.SDL_ReleaseWindowFromGPUDevice(context.device.?, context.window.?);
    sdl.video.SDL_DestroyWindow(context.window.?);
    sdl.gpu.SDL_DestroyGPUDevice(context.device.?);
}

const shader_code_max_size = std.Io.Limit.limited(1024 * 1024 * 2); // about 2MiB

pub fn loadShader(
    io: std.Io,
    gpa: std.mem.Allocator,
    device: *sdl.gpu.SDL_GPUDevice,
    shader_filename: []const u8,
    sampler_count: u32,
    uniform_buffer_count: u32,
    storage_buffer_count: u32,
    storage_texture_count: u32,
) !*sdl.gpu.SDL_GPUShader {
    // Auto-detect the shader stage from the file name for convenience
    const stage: sdl.gpu.SDL_GPUShaderStage =
        if (std.mem.findLast(u8, shader_filename, ".vert")) |_|
            .vertex
        else if (std.mem.findLast(u8, shader_filename, ".frag")) |_|
            .fragment
        else
            return LoadShaderError.BadFilename;

    var shader_rel_path_buf: [std.Io.Dir.max_name_bytes]u8 = undefined;
    var shader_rel_path: [:0]u8 = undefined;
    const backend_formats = sdl.gpu.SDL_GetGPUShaderFormats(device);
    var format: sdl.gpu.SDL_GPUShaderFormat = .invalid;
    var entrypoint: [:0]const u8 = undefined;

    if (backend_formats.spirv) {
        shader_rel_path = try std.fmt.bufPrintSentinel(
            &shader_rel_path_buf,
            "Content/Shaders/Compiled/SPIRV/{s}.spv",
            .{shader_filename},
            0,
        );
        format = .spirv;
        entrypoint = "main";
    } else if (backend_formats.msl) {
        shader_rel_path = try std.fmt.bufPrintSentinel(
            &shader_rel_path_buf,
            "Content/Shaders/Compiled/MSL/{s}.msl",
            .{shader_filename},
            0,
        );
        format = .msl;
        entrypoint = "main0";
    } else if (backend_formats.dxil) {
        shader_rel_path = try std.fmt.bufPrintSentinel(
            &shader_rel_path_buf,
            "Content/Shaders/Compiled/DXIL/{s}.dxil",
            .{shader_filename},
            0,
        );
        format = .dxil;
        entrypoint = "main";
    } else {
        return LoadShaderError.UnrecognizedBackendShaderFormat;
    }

    const code = try base_dir.?.readFileAllocOptions(
        io,
        shader_rel_path,
        gpa,
        shader_code_max_size,
        .of(u8),
        0,
    );
    defer gpa.free(code);
    const code_size = code.len;

    const shader_info: sdl.gpu.SDL_GPUShaderCreateInfo = .{
        .code = code,
        .code_size = code_size,
        .entrypoint = entrypoint,
        .format = format,
        .stage = stage,
        .num_samplers = sampler_count,
        .num_uniform_buffers = uniform_buffer_count,
        .num_storage_buffers = storage_buffer_count,
        .num_storage_textures = storage_texture_count,
        .props = 0,
    };
    const shader = sdl.gpu.SDL_CreateGPUShader(device, &shader_info) orelse {
        sdl.log.SDL_LogError(
            sdl.log.SDL_LogCategory.error_category,
            "Failed to create shader %s due to SDL Error: %s",
            shader_rel_path.ptr,
            sdl.sdl_error.SDL_GetError(),
        );
        return AppError.SdlError;
    };

    sdl.log.SDL_LogInfo(.application, "Loaded shader %s", shader_rel_path.ptr);

    return shader;
}
