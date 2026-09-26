// # CategoryGPU
//
// The GPU API offers a cross-platform way for apps to talk to modern graphics
// hardware. It offers both 3D graphics and compute support, in the style of
// Metal, Vulkan, and Direct3D 12.
//
// A basic workflow might be something like this:
//
// The app creates a GPU device with SDL_CreateGPUDevice(), and assigns it to
// a window with SDL_ClaimWindowForGPUDevice()--although strictly speaking you
// can render offscreen entirely, perhaps for image processing, and not use a
// window at all.
//
// Next, the app prepares static data (things that are created once and used
// over and over). For example:
//
// - Shaders (programs that run on the GPU): use SDL_CreateGPUShader().
// - Vertex buffers (arrays of geometry data) and other rendering data: use
//   SDL_CreateGPUBuffer() and SDL_UploadToGPUBuffer().
// - Textures (images): use SDL_CreateGPUTexture() and
//   SDL_UploadToGPUTexture().
// - Samplers (how textures should be read from): use SDL_CreateGPUSampler().
// - Render pipelines (precalculated rendering state): use
//   SDL_CreateGPUGraphicsPipeline()
//
// To render, the app creates one or more command buffers, with
// SDL_AcquireGPUCommandBuffer(). Command buffers collect rendering
// instructions that will be submitted to the GPU in batch. Complex scenes can
// use multiple command buffers, maybe configured across multiple threads in
// parallel, as long as they are submitted in the correct order, but many apps
// will just need one command buffer per frame.
//
// Rendering can happen to a texture (what other APIs call a "render target")
// or it can happen to the swapchain texture (which is just a special texture
// that represents a window's contents). The app can use
// SDL_WaitAndAcquireGPUSwapchainTexture() to render to the window.
//
// Rendering actually happens in a Render Pass, which is encoded into a
// command buffer. One can encode multiple render passes (or alternate between
// render and compute passes) in a single command buffer, but many apps might
// simply need a single render pass in a single command buffer. Render Passes
// can render to up to four color textures and one depth texture
// simultaneously. If the set of textures being rendered to needs to change,
// the Render Pass must be ended and a new one must be begun.
//
// The app calls SDL_BeginGPURenderPass(). Then it sets states it needs for
// each draw:
//
// - SDL_BindGPUGraphicsPipeline()
// - SDL_SetGPUViewport()
// - SDL_BindGPUVertexBuffers()
// - SDL_BindGPUVertexSamplers()
// - etc
//
// Then, make the actual draw commands with these states:
//
// - SDL_DrawGPUPrimitives()
// - SDL_DrawGPUPrimitivesIndirect()
// - SDL_DrawGPUIndexedPrimitivesIndirect()
// - etc
//
// After all the drawing commands for a pass are complete, the app should call
// SDL_EndGPURenderPass(). Once a render pass ends all render-related state is
// reset.
//
// The app can begin new Render Passes and make new draws in the same command
// buffer until the entire scene is rendered.
//
// Once all of the render commands for the scene are complete, the app calls
// SDL_SubmitGPUCommandBuffer() to send it to the GPU for processing.
//
// If the app needs to read back data from texture or buffers, the API has an
// efficient way of doing this, provided that the app is willing to tolerate
// some latency. When the app uses SDL_DownloadFromGPUTexture() or
// SDL_DownloadFromGPUBuffer(), submitting the command buffer with
// SDL_SubmitGPUCommandBufferAndAcquireFence() will return a fence handle that
// the app can poll or wait on in a thread. Once the fence indicates that the
// command buffer is done processing, it is safe to read the downloaded data.
// Make sure to call SDL_ReleaseGPUFence() when done with the fence.
//
// The API also has "compute" support. The app calls SDL_BeginGPUComputePass()
// with compute-writeable textures and/or buffers, which can be written to in
// a compute shader. Then it sets states it needs for the compute dispatches:
//
// - SDL_BindGPUComputePipeline()
// - SDL_BindGPUComputeStorageBuffers()
// - SDL_BindGPUComputeStorageTextures()
//
// Then, dispatch compute work:
//
// - SDL_DispatchGPUCompute()
//
// For advanced users, this opens up powerful GPU-driven workflows.
//
// Graphics and compute pipelines require the use of shaders, which as
// mentioned above are small programs executed on the GPU. Each backend
// (Vulkan, Metal, D3D12) requires a different shader format. When the app
// creates the GPU device, the app lets the device know which shader formats
// the app can provide. It will then select the appropriate backend depending
// on the available shader formats and the backends available on the platform.
// When creating shaders, the app must provide the correct shader format for
// the selected backend. If you would like to learn more about why the API
// works this way, there is a detailed
// [blog post](https://moonside.games/posts/layers-all-the-way-down/)
// explaining this situation.
//
// It is optimal for apps to pre-compile the shader formats they might use,
// but for ease of use SDL provides a separate project,
// [SDL_shadercross](https://github.com/libsdl-org/SDL_shadercross)
// , for performing runtime shader cross-compilation. It also has a CLI
// interface for offline precompilation as well.
//
// This is an extremely quick overview that leaves out several important
// details. Already, though, one can see that GPU programming can be quite
// complex! If you just need simple 2D graphics, the
// [Render API](https://wiki.libsdl.org/SDL3/CategoryRender)
// is much easier to use but still hardware-accelerated. That said, even for
// 2D applications the performance benefits and expressiveness of the GPU API
// are significant.
//
// The GPU API targets a feature set with a wide range of hardware support and
// ease of portability. It is designed so that the app won't have to branch
// itself by querying feature support. If you need cutting-edge features with
// limited hardware support, this API is probably not for you.
//
// Examples demonstrating proper usage of this API can be found
// [here](https://github.com/TheSpydog/SDL_gpu_examples)
// .
//
// ## Performance considerations
//
// Here are some basic tips for maximizing your rendering performance.
//
// - Beginning a new render pass is relatively expensive. Use as few render
//   passes as you can.
// - Minimize the amount of state changes. For example, binding a pipeline is
//   relatively cheap, but doing it hundreds of times when you don't need to
//   will slow the performance significantly.
// - Perform your data uploads as early as possible in the frame.
// - Don't churn resources. Creating and releasing resources is expensive.
//   It's better to create what you need up front and cache it.
// - Don't use uniform buffers for large amounts of data (more than a matrix
//   or so). Use a storage buffer instead.
// - Use cycling correctly. There is a detailed explanation of cycling further
//   below.
// - Use culling techniques to minimize pixel writes. The less writing the GPU
//   has to do the better. Culling can be a very advanced topic but even
//   simple culling techniques can boost performance significantly.
//
// In general try to remember the golden rule of performance: doing things is
// more expensive than not doing things. Don't Touch The Driver!
//
// ## FAQ
//
// **Question: When are you adding more advanced features, like ray tracing or
// mesh shaders?**
//
// Answer: We don't have immediate plans to add more bleeding-edge features,
// but we certainly might in the future, when these features prove worthwhile,
// and reasonable to implement across several platforms and underlying APIs.
// So while these things are not in the "never" category, they are definitely
// not "near future" items either.
//
// **Question: Why is my shader not working?**
//
// Answer: A common oversight when using shaders is not properly laying out
// the shader resources/registers correctly. The GPU API is very strict with
// how it wants resources to be laid out and it's difficult for the API to
// automatically validate shaders to see if they have a compatible layout. See
// the documentation for SDL_CreateGPUShader() and
// SDL_CreateGPUComputePipeline() for information on the expected layout.
//
// Another common issue is not setting the correct number of samplers,
// textures, and buffers in SDL_GPUShaderCreateInfo. If possible use shader
// reflection to extract the required information from the shader
// automatically instead of manually filling in the struct's values.
//
// **Question: My application isn't performing very well. Is this the GPU
// API's fault?**
//
// Answer: No. Long answer: The GPU API is a relatively thin layer over the
// underlying graphics API. While it's possible that we have done something
// inefficiently, it's very unlikely especially if you are relatively
// inexperienced with GPU rendering. Please see the performance tips above and
// make sure you are following them. Additionally, tools like
// [RenderDoc](https://renderdoc.org/)
// can be very helpful for diagnosing incorrect behavior and performance
// issues.
//
// ## System Requirements
//
// ### Vulkan
//
// SDL driver name: "vulkan" (for use in SDL_CreateGPUDevice() and
// SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING)
//
// Supported on Windows, Linux, Nintendo Switch, and certain Android devices.
// Requires Vulkan 1.0 with the following extensions and device features:
//
// - `VK_KHR_swapchain`
// - `VK_KHR_maintenance1`
// - `independentBlend`
// - `imageCubeArray`
// - `depthClamp`
// - `shaderClipDistance`
// - `drawIndirectFirstInstance`
// - `sampleRateShading`
//
// You can remove some of these requirements to increase compatibility with
// Android devices by using these properties when creating the GPU device with
// SDL_CreateGPUDeviceWithProperties():
//
// - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_CLIP_DISTANCE_BOOLEAN
// - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_DEPTH_CLAMPING_BOOLEAN
// - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_INDIRECT_DRAW_FIRST_INSTANCE_BOOLEAN
// - SDL_PROP_GPU_DEVICE_CREATE_FEATURE_ANISOTROPY_BOOLEAN
//
// ### D3D12
//
// SDL driver name: "direct3d12"
//
// Supported on Windows 10 or newer, Xbox One (GDK), and Xbox Series X|S
// (GDK). Requires a GPU that supports DirectX 12 Feature Level 11_0 and
// Resource Binding Tier 2 or above.
//
// You can remove the Tier 2 resource binding requirement to support Intel
// Haswell and Broadwell GPUs by using this property when creating the GPU
// device with SDL_CreateGPUDeviceWithProperties():
//
// - SDL_PROP_GPU_DEVICE_CREATE_D3D12_ALLOW_FEWER_RESOURCE_SLOTS_BOOLEAN
//
// ### Metal
//
// SDL driver name: "metal"
//
// Supported on macOS 10.14+ and iOS/tvOS 13.0+. Hardware requirements vary by
// operating system:
//
// - macOS requires an Apple Silicon or
//   [Intel Mac2 family](https://developer.apple.com/documentation/metal/mtlfeatureset/mtlfeatureset_macos_gpufamily2_v1?language=objc)
//   GPU
// - iOS/tvOS requires an A9 GPU or newer
// - iOS Simulator and tvOS Simulator are unsupported
//
// ## Coordinate System
//
// The GPU API uses a left-handed coordinate system, following the convention
// of D3D12 and Metal. Specifically:
//
// - **Normalized Device Coordinates:** The lower-left corner has an x,y
//   coordinate of `(-1.0, -1.0)`. The upper-right corner is `(1.0, 1.0)`. Z
//   values range from `[0.0, 1.0]` where 0 is the near plane.
// - **Viewport Coordinates:** The top-left corner has an x,y coordinate of
//   `(0, 0)` and extends to the bottom-right corner at `(viewportWidth,
//   viewportHeight)`. +Y is down.
// - **Texture Coordinates:** The top-left corner has an x,y coordinate of
//   `(0, 0)` and extends to the bottom-right corner at `(1.0, 1.0)`. +Y is
//   down.
//
// If the backend driver differs from this convention (e.g. Vulkan, which has
// an NDC that assumes +Y is down), SDL will automatically convert the
// coordinate system behind the scenes, so you don't need to perform any
// coordinate flipping logic in your shaders.
//
// ## Uniform Data
//
// Uniforms are for passing data to shaders. The uniform data will be constant
// across all executions of the shader.
//
// There are 4 available uniform slots per shader stage (where the stages are
// vertex, fragment, and compute). Uniform data pushed to a slot on a stage
// keeps its value throughout the command buffer until you call the relevant
// Push function on that slot again.
//
// For example, you could write your vertex shaders to read a camera matrix
// from uniform binding slot 0, push the camera matrix at the start of the
// command buffer, and that data will be used for every subsequent draw call.
//
// It is valid to push uniform data during a render or compute pass.
//
// Uniforms are best for pushing small amounts of data. If you are pushing
// more than a matrix or two per call you should consider using a storage
// buffer instead.
//
// ## A Note On Cycling
//
// When using a command buffer, operations do not occur immediately - they
// occur some time after the command buffer is submitted.
//
// When a resource is used in a pending or active command buffer, it is
// considered to be "bound". When a resource is no longer used in any pending
// or active command buffers, it is considered to be "unbound".
//
// If data resources are bound, it is unspecified when that data will be
// unbound unless you acquire a fence when submitting the command buffer and
// wait on it. However, this doesn't mean you need to track resource usage
// manually.
//
// All of the functions and structs that involve writing to a resource have a
// "cycle" bool. SDL_GPUTransferBuffer, SDL_GPUBuffer, and SDL_GPUTexture all
// effectively function as ring buffers on internal resources. When cycle is
// true, if the resource is bound, the cycle rotates to the next unbound
// internal resource, or if none are available, a new one is created. This
// means you don't have to worry about complex state tracking and
// synchronization as long as cycling is correctly employed.
//
// For example: you can call SDL_MapGPUTransferBuffer(), write texture data,
// SDL_UnmapGPUTransferBuffer(), and then SDL_UploadToGPUTexture(). The next
// time you write texture data to the transfer buffer, if you set the cycle
// param to true, you don't have to worry about overwriting any data that is
// not yet uploaded.
//
// Another example: If you are using a texture in a render pass every frame,
// this can cause a data dependency between frames. If you set cycle to true
// in the SDL_GPUColorTargetInfo struct, you can prevent this data dependency.
//
// Cycling will never undefine already bound data. When cycling, all data in
// the resource is considered to be undefined for subsequent commands until
// that data is written again. You must take care not to read undefined data.
//
// Note that when cycling a texture, the entire texture will be cycled, even
// if only part of the texture is used in the call, so you must consider the
// entire texture to contain undefined data after cycling.
//
// You must also take care not to overwrite a section of data that has been
// referenced in a command without cycling first. It is OK to overwrite
// unreferenced data in a bound resource without cycling, but overwriting a
// section of data that has already been referenced will produce unexpected
// results.
//
// ## Debugging
//
// At some point of your GPU journey, you will probably encounter issues that
// are not traceable with regular debugger - for example, your code compiles
// but you get an empty screen, or your shader fails in runtime.
//
// For debugging such cases, there are tools that allow visually inspecting
// the whole GPU frame, every drawcall, every bound resource, memory buffers,
// etc. They are the following, per platform:
//
// * For Windows/Linux, use
//   [RenderDoc](https://renderdoc.org/)
// * For MacOS (Metal), use Xcode built-in debugger (Open XCode, go to Debug >
//   Debug Executable..., select your application, set "GPU Frame Capture" to
//   "Metal" in scheme "Options" window, run your app, and click the small
//   Metal icon on the bottom to capture a frame)
//
// Aside from that, you may want to enable additional debug layers to receive
// more detailed error messages, based on your GPU backend:
//
// * For D3D12, the debug layer is an optional feature that can be installed
//   via "Windows Settings -> System -> Optional features" and adding the
//   "Graphics Tools" optional feature.
// * For Vulkan, you will need to install Vulkan SDK on Windows, and on Linux,
//   you usually have some sort of `vulkan-validation-layers` system package
//   that should be installed.
// * For Metal, it should be enough just to run the application from XCode to
//   receive detailed errors or warnings in the output.
//
// Don't hesitate to use tools as RenderDoc when encountering runtime issues
// or unexpected output on screen, quick GPU frame inspection can usually help
// you fix the majority of such problems.

const pixels = @import("pixels.zig");
const properties = @import("properties.zig");
const rect = @import("rect.zig");
const surface = @import("surface.zig");
const video = @import("video.zig");

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

pub const SDL_GPUFence = opaque {};

pub const SDL_GPUComputePass = opaque {};

pub const SDL_GPUCopyPass = opaque {};

pub const SDL_GPUDevice = opaque {};

pub const SDL_GPUBuffer = opaque {};
pub const SDL_GPUTransferBuffer = opaque {};
pub const SDL_GPUTexture = opaque {};
pub const SDL_GPUSampler = opaque {};
pub const SDL_GPUShader = opaque {};
pub const SDL_GPUComputePipeline = opaque {};
pub const SDL_GPUGraphicsPipeline = opaque {};

pub const SDL_GPUCommandBuffer = opaque {};

pub const SDL_GPURenderPass = opaque {};

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
