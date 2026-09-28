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

/////////////////////////////
// Type declarations
/////////////////////////////

/// An opaque handle representing the SDL_GPU context.
///
/// \since This struct is available since SDL 3.2.0.
pub const SDL_GPUDevice = opaque {};

/// An opaque handle representing a buffer.
///
/// Used for vertices, indices, indirect draw commands, and general compute
/// data.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUBuffer
/// \sa SDL_UploadToGPUBuffer
/// \sa SDL_DownloadFromGPUBuffer
/// \sa SDL_CopyGPUBufferToBuffer
/// \sa SDL_BindGPUVertexBuffers
/// \sa SDL_BindGPUIndexBuffer
/// \sa SDL_BindGPUVertexStorageBuffers
/// \sa SDL_BindGPUFragmentStorageBuffers
/// \sa SDL_DrawGPUPrimitivesIndirect
/// \sa SDL_DrawGPUIndexedPrimitivesIndirect
/// \sa SDL_BindGPUComputeStorageBuffers
/// \sa SDL_DispatchGPUComputeIndirect
/// \sa SDL_ReleaseGPUBuffer
pub const SDL_GPUBuffer = opaque {};

/// An opaque handle representing a transfer buffer.
///
/// Used for transferring data to and from the device.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTransferBuffer
/// \sa SDL_MapGPUTransferBuffer
/// \sa SDL_UnmapGPUTransferBuffer
/// \sa SDL_UploadToGPUBuffer
/// \sa SDL_UploadToGPUTexture
/// \sa SDL_DownloadFromGPUBuffer
/// \sa SDL_DownloadFromGPUTexture
/// \sa SDL_ReleaseGPUTransferBuffer
pub const SDL_GPUTransferBuffer = opaque {};

/// An opaque handle representing a texture.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTexture
/// \sa SDL_UploadToGPUTexture
/// \sa SDL_DownloadFromGPUTexture
/// \sa SDL_CopyGPUTextureToTexture
/// \sa SDL_BindGPUVertexSamplers
/// \sa SDL_BindGPUVertexStorageTextures
/// \sa SDL_BindGPUFragmentSamplers
/// \sa SDL_BindGPUFragmentStorageTextures
/// \sa SDL_BindGPUComputeStorageTextures
/// \sa SDL_GenerateMipmapsForGPUTexture
/// \sa SDL_BlitGPUTexture
/// \sa SDL_ReleaseGPUTexture
pub const SDL_GPUTexture = opaque {};

/// An opaque handle representing a sampler.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUSampler
/// \sa SDL_BindGPUVertexSamplers
/// \sa SDL_BindGPUFragmentSamplers
/// \sa SDL_ReleaseGPUSampler
pub const SDL_GPUSampler = opaque {};

/// An opaque handle representing a compiled shader object.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
/// \sa SDL_CreateGPUGraphicsPipeline
/// \sa SDL_ReleaseGPUShader
pub const SDL_GPUShader = opaque {};

/// An opaque handle representing a compute pipeline.
///
/// Used during compute passes.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUComputePipeline
/// \sa SDL_BindGPUComputePipeline
/// \sa SDL_ReleaseGPUComputePipeline
pub const SDL_GPUComputePipeline = opaque {};

/// An opaque handle representing a graphics pipeline.
///
/// Used during render passes.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
/// \sa SDL_BindGPUGraphicsPipeline
/// \sa SDL_ReleaseGPUGraphicsPipeline
pub const SDL_GPUGraphicsPipeline = opaque {};

/// An opaque handle representing a command buffer.
///
/// Most state is managed via command buffers. When setting state using a
/// command buffer, that state is local to the command buffer.
///
/// Commands only begin execution on the GPU once SDL_SubmitGPUCommandBuffer is
/// called. Once the command buffer is submitted, it is no longer valid to use
/// it.
///
/// Command buffers are executed in submission order. If you submit command
/// buffer A and then command buffer B all commands in A will begin executing
/// before any command in B begins executing.
///
/// In multi-threading scenarios, you should only access a command buffer on
/// the thread you acquired it from.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_AcquireGPUCommandBuffer
/// \sa SDL_SubmitGPUCommandBuffer
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
pub const SDL_GPUCommandBuffer = opaque {};

/// An opaque handle representing a render pass.
///
/// This handle is transient and should not be held or referenced after
/// SDL_EndGPURenderPass is called.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPURenderPass
/// \sa SDL_EndGPURenderPass
pub const SDL_GPURenderPass = opaque {};

/// An opaque handle representing a compute pass.
///
/// This handle is transient and should not be held or referenced after
/// SDL_EndGPUComputePass is called.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPUComputePass
/// \sa SDL_EndGPUComputePass
pub const SDL_GPUComputePass = opaque {};

/// An opaque handle representing a copy pass.
///
/// This handle is transient and should not be held or referenced after
/// SDL_EndGPUCopyPass is called.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPUCopyPass
/// \sa SDL_EndGPUCopyPass
pub const SDL_GPUCopyPass = opaque {};

/// An opaque handle representing a fence.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
/// \sa SDL_QueryGPUFence
/// \sa SDL_WaitForGPUFences
/// \sa SDL_ReleaseGPUFence
pub const SDL_GPUFence = opaque {};

/// Specifies the primitive topology of a graphics pipeline.
///
/// If you are using POINTLIST you must include a point size output in the
/// vertex shader.
///
/// - For HLSL compiling to SPIRV you must decorate a float output with
///   [[vk::builtin("PointSize")]].
/// - For GLSL you must set the gl_PointSize builtin.
/// - For MSL you must include a float output with the [[point_size]]
///   decorator.
///
/// Note that sized point topology is totally unsupported on D3D12. Any size
/// other than 1 will be ignored. In general, you should avoid using point
/// topology for both compatibility and performance reasons. You WILL regret
/// using it.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUPrimitiveType = enum(c_uint) {
    /// A series of separate triangles.
    trianglelist = 0,
    /// A series of connected triangles.
    trianglestrip = 1,
    /// A series of separate lines.
    linelist = 2,
    /// A series of connected lines.
    linestrip = 3,
    /// A series of separate points.
    pointlist = 4,
};

/// Specifies how the contents of a texture attached to a render pass are
/// treated at the beginning of the render pass.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPURenderPass
pub const SDL_GPULoadOp = enum(c_uint) {
    /// The previous contents of the texture will be preserved.
    load = 0,
    /// The contents of the texture will be cleared to a color.
    clear = 1,
    /// The previous contents of the texture need not be preserved. The contents will be undefined.
    dont_care = 2,
};

/// Specifies how the contents of a texture attached to a render pass are
/// treated at the end of the render pass.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPURenderPass
pub const SDL_GPUStoreOp = enum(c_uint) {
    /// The contents generated during the render pass will be written to memory.
    store = 0,
    /// The contents generated during the render pass are not needed and may be
    /// discarded. The contents will be undefined.
    dont_care = 1,
    /// The multisample contents generated during the render pass will be
    /// resolved to a non-multisample texture. The contents in the multisample
    /// texture may then be discarded and will be undefined.
    resolve = 2,
    /// The multisample contents generated during the render pass will be
    /// resolved to a non-multisample texture. The contents in the multisample
    /// texture will be written to memory.
    resolve_and_store = 3,
};

/// Specifies the size of elements in an index buffer.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUIndexElementSize = enum(c_uint) {
    /// The index elements are 16-bit.
    size_16bit = 0,
    /// The index elements are 32-bit.
    size_32bit = 1,
};

/// Specifies the pixel format of a texture.
///
/// Texture format support varies depending on driver, hardware, and usage
/// flags. In general, you should use SDL_GPUTextureSupportsFormat to query if
/// a format is supported before using it. However, there are a few guaranteed
/// formats.
///
/// FIXME: Check universal support for 32-bit component formats FIXME: Check
/// universal support for SIMULTANEOUS_READ_WRITE
///
/// For SAMPLER usage, the following formats are universally supported:
///
/// - R8G8B8A8_UNORM
/// - B8G8R8A8_UNORM
/// - R8_UNORM
/// - R8_SNORM
/// - R8G8_UNORM
/// - R8G8_SNORM
/// - R8G8B8A8_SNORM
/// - R16_FLOAT
/// - R16G16_FLOAT
/// - R16G16B16A16_FLOAT
/// - R32_FLOAT
/// - R32G32_FLOAT
/// - R32G32B32A32_FLOAT
/// - R11G11B10_UFLOAT
/// - R8G8B8A8_UNORM_SRGB
/// - B8G8R8A8_UNORM_SRGB
/// - D16_UNORM
///
/// For COLOR_TARGET usage, the following formats are universally supported:
///
/// - R8G8B8A8_UNORM
/// - B8G8R8A8_UNORM
/// - R8_UNORM
/// - R16_FLOAT
/// - R16G16_FLOAT
/// - R16G16B16A16_FLOAT
/// - R32_FLOAT
/// - R32G32_FLOAT
/// - R32G32B32A32_FLOAT
/// - R8_UINT
/// - R8G8_UINT
/// - R8G8B8A8_UINT
/// - R16_UINT
/// - R16G16_UINT
/// - R16G16B16A16_UINT
/// - R8_INT
/// - R8G8_INT
/// - R8G8B8A8_INT
/// - R16_INT
/// - R16G16_INT
/// - R16G16B16A16_INT
/// - R8G8B8A8_UNORM_SRGB
/// - B8G8R8A8_UNORM_SRGB
///
/// For STORAGE usages, the following formats are universally supported:
///
/// - R8G8B8A8_UNORM
/// - R8G8B8A8_SNORM
/// - R16G16B16A16_FLOAT
/// - R32_FLOAT
/// - R32G32_FLOAT
/// - R32G32B32A32_FLOAT
/// - R8G8B8A8_UINT
/// - R16G16B16A16_UINT
/// - R8G8B8A8_INT
/// - R16G16B16A16_INT
///
/// For DEPTH_STENCIL_TARGET usage, the following formats are universally
/// supported:
///
/// - D16_UNORM
/// - Either (but not necessarily both!) D24_UNORM or D32_FLOAT
/// - Either (but not necessarily both!) D24_UNORM_S8_UINT or D32_FLOAT_S8_UINT
///
/// Unless D16_UNORM is sufficient for your purposes, always check which of
/// D24/D32 is supported before creating a depth-stencil texture!
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTexture
/// \sa SDL_GPUTextureSupportsFormat
pub const SDL_GPUTextureFormat = enum(c_uint) {
    invalid = 0,

    // Unsigned Normalized Float Color Formats
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
    // Compressed Unsigned Normalized Float Color Formats
    bc1_rgba_unorm = 13,
    bc2_rgba_unorm = 14,
    bc3_rgba_unorm = 15,
    bc4_r_unorm = 16,
    bc5_rg_unorm = 17,
    bc7_rgba_unorm = 18,
    // Compressed Signed Float Color Formats
    bc6h_rgb_float = 19,
    // Compressed Unsigned Float Color Formats
    bc6h_rgb_ufloat = 20,
    // Signed Normalized Float Color Formats
    r8_snorm = 21,
    r8g8_snorm = 22,
    r8g8b8a8_snorm = 23,
    r16_snorm = 24,
    r16g16_snorm = 25,
    r16g16b16a16_snorm = 26,
    // Signed Float Color Formats
    r16_float = 27,
    r16g16_float = 28,
    r16g16b16a16_float = 29,
    r32_float = 30,
    r32g32_float = 31,
    r32g32b32a32_float = 32,
    // Unsigned Float Color Formats
    r11g11b10_ufloat = 33,
    // Unsigned Integer Color Formats
    r8_uint = 34,
    r8g8_uint = 35,
    r8g8b8a8_uint = 36,
    r16_uint = 37,
    r16g16_uint = 38,
    r16g16b16a16_uint = 39,
    r32_uint = 40,
    r32g32_uint = 41,
    r32g32b32a32_uint = 42,
    // Signed Integer Color Formats
    r8_int = 43,
    r8g8_int = 44,
    r8g8b8a8_int = 45,
    r16_int = 46,
    r16g16_int = 47,
    r16g16b16a16_int = 48,
    r32_int = 49,
    r32g32_int = 50,
    r32g32b32a32_int = 51,
    // SRGB Unsigned Normalized Color Formats
    r8g8b8a8_unorm_srgb = 52,
    b8g8r8a8_unorm_srgb = 53,
    // Compressed SRGB Unsigned Normalized Color Formats
    bc1_rgba_unorm_srgb = 54,
    bc2_rgba_unorm_srgb = 55,
    bc3_rgba_unorm_srgb = 56,
    bc7_rgba_unorm_srgb = 57,
    // Depth Formats
    d16_unorm = 58,
    d24_unorm = 59,
    d32_float = 60,
    d24_unorm_s8_uint = 61,
    d32_float_s8_uint = 62,
    // Compressed ASTC Normalized Float Color Formats
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
    // Compressed SRGB ASTC Normalized Float Color Formats
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
    // Compressed ASTC Signed Float Color Formats
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

/// Specifies how a texture is intended to be used by the client.
///
/// A texture must have at least one usage flag. Note that some usage flag
/// combinations are invalid.
///
/// With regards to compute storage usage, READ | WRITE means that you can have
/// shader A that only writes into the texture and shader B that only reads
/// from the texture and bind the same texture to either shader respectively.
/// SIMULTANEOUS means that you can do reads and writes within the same shader
/// or compute pass. It also implies that atomic ops can be used, since those
/// are read-modify-write operations. If you use SIMULTANEOUS, you are
/// responsible for avoiding data races, as there is no data synchronization
/// within a compute pass. Note that SIMULTANEOUS usage is only supported by a
/// limited number of texture formats.
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTexture
pub const SDL_GPUTextureUsageFlags = packed struct(u32) {
    /// Texture supports sampling.
    sampler: bool, // bit 0
    /// Texture is a color render target.
    color_target: bool, // bit 1
    /// Texture is a depth stencil target.
    depth_stencil_target: bool, // bit 2
    /// Texture supports storage reads in graphics stages.
    graphics_storage_read: bool, // bit 3
    /// Texture supports storage reads in the compute stage.
    compute_storage_read: bool, // bit 4
    /// Texture supports storage writes in the compute stage.
    compute_storage_write: bool, // bit 5
    /// Texture supports reads and writes in the same compute shader. This is
    /// NOT equivalent to READ | WRITE.
    compute_storage_simultaneous_read_write: bool, // bit 6
};

/// Specifies the type of a texture.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTexture
pub const SDL_GPUTextureType = enum(c_uint) {
    /// The texture is a 2-dimensional image.
    texturetype_2d = 0,
    /// The texture is a 2-dimensional array image.
    texturetype_2d_array = 1,
    /// The texture is a 3-dimensional image.
    texturetype_3d = 2,
    /// The texture is a cube image.
    texturetype_cube = 3,
    /// The texture is a cube array image.
    texturetype_cube_array = 4,
};

/// Specifies the sample count of a texture.
///
/// Used in multisampling. Note that this value only applies when the texture
/// is used as a render target.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTexture
/// \sa SDL_GPUTextureSupportsSampleCount
pub const SDL_GPUSampleCount = enum(c_uint) {
    /// No multisampling.
    samplecount_1 = 0,
    /// MSAA 2x
    samplecount_2 = 1,
    /// MSAA 4x
    samplecount_4 = 2,
    /// MSAA 8x
    samplecount_8 = 3,
};

/// Specifies the face of a cube map.
///
/// Can be passed in as the layer field in texture-related structs.
///
/// \since This enum is available since SDL 3.2.0.
pub const SDL_GPUCubeMapFace = enum(c_uint) {
    positivex = 0,
    negativex = 1,
    positivey = 2,
    negativey = 3,
    positivez = 4,
    negativez = 5,
};

/// Specifies how a buffer is intended to be used by the client.
///
/// A buffer must have at least one usage flag. Note that some usage flag
/// combinations are invalid.
///
/// Unlike textures, READ | WRITE can be used for simultaneous read-write
/// usage. The same data synchronization concerns as textures apply.
///
/// If you use a STORAGE flag, the data in the buffer must respect std140
/// layout conventions. In practical terms this means you must ensure that vec3
/// and vec4 fields are 16-byte aligned.
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUBuffer
pub const SDL_GPUBufferUsageFlags = packed struct(u32) {
    /// Buffer is a vertex buffer.
    vertex: bool,
    /// Buffer is an index buffer.
    index: bool,
    /// Buffer is an indirect buffer.
    indirect: bool,
    /// Buffer supports storage reads in graphics stages.
    graphics_storage_read: bool,
    /// Buffer supports storage reads in the compute stage.
    compute_storage_read: bool,
    /// Buffer supports storage writes in the compute stage.
    compute_storage_write: bool,
};

/// Specifies how a transfer buffer is intended to be used by the client.
///
/// Note that mapping and copying FROM an upload transfer buffer or TO a
/// download transfer buffer is undefined behavior.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTransferBuffer
pub const SDL_GPUTransferBufferUsage = enum(c_uint) {
    upload = 0,
    download = 1,
};

/// Specifies which stage a shader program corresponds to.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub const SDL_GPUShaderStage = enum(c_uint) {
    vertex = 0,
    fragment = 1,
};

/// Specifies the format of shader code.
///
/// Each format corresponds to a specific backend that accepts it.
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub const SDL_GPUShaderFormat = enum(u32) {
    invalid = 0,
    /// Shaders for NDA'd platforms.
    private = 1 << 0,
    /// SPIR-V shaders for Vulkan.
    spirv = 1 << 1,
    /// DXBC SM5_1 shaders for D3D12.
    dxbc = 1 << 2,
    /// DXIL SM6_0 shaders for D3D12.
    dxil = 1 << 3,
    /// MSL shaders for Metal.
    msl = 1 << 4,
    /// Precompiled metallib shaders for Metal.
    metallib = 1 << 5,
};

/// Specifies the format of a vertex attribute.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUVertexElementFormat = enum(c_uint) {
    invalid = 0,

    // 32-bit Signed Integers
    int = 1,
    int2 = 2,
    int3 = 3,
    int4 = 4,
    // 32-bit Unsigned Integers
    uint = 5,
    uint2 = 6,
    uint3 = 7,
    uint4 = 8,
    // 32-bit Floats
    float = 9,
    float2 = 10,
    float3 = 11,
    float4 = 12,
    // 8-bit Signed Integers
    byte2 = 13,
    byte4 = 14,
    // 8-bit Unsigned Integers
    ubyte2 = 15,
    ubyte4 = 16,
    // 8-bit Signed Normalized
    byte2_norm = 17,
    byte4_norm = 18,
    // 8-bit Unsigned Normalized
    ubyte2_norm = 19,
    ubyte4_norm = 20,
    // 16-bit Signed Integers
    short2 = 21,
    short4 = 22,
    // 16-bit Unsigned Integers
    ushort2 = 23,
    ushort4 = 24,
    // 16-bit Signed Normalized
    short2_norm = 25,
    short4_norm = 26,
    // 16-bit Unsigned Normalized
    ushort2_norm = 27,
    ushort4_norm = 28,
    // 16-bit Floats
    half2 = 29,
    half4 = 30,
};

/// Specifies the rate at which vertex attributes are pulled from buffers.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUVertexInputRate = enum(c_uint) {
    /// Attribute addressing is a function of the vertex index.
    vertex = 0,
    /// Attribute addressing is a function of the instance index.
    instance = 1,
};

/// Specifies the fill mode of the graphics pipeline.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUFillMode = enum(c_uint) {
    /// Polygons will be rendered via rasterization.
    fill = 0,
    /// Polygon edges will be drawn as line segments.
    line = 1,
};

/// Specifies the facing direction in which triangle faces will be culled.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUCullMode = enum(c_uint) {
    /// No triangles are culled.
    none = 0,
    /// Front-facing triangles are culled.
    front = 1,
    /// Back-facing triangles are culled.
    back = 2,
};

/// Specifies the vertex winding that will cause a triangle to be determined to
/// be front-facing.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUFrontFace = enum(c_uint) {
    /// A triangle with counter-clockwise vertex winding will be considered front-facing.
    counter_clockwise = 0,
    /// A triangle with clockwise vertex winding will be considered front-facing.
    clockwise = 1,
};

/// Specifies a comparison operator for depth, stencil and sampler operations.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUCompareOp = enum(c_uint) {
    invalid = 0,
    /// The comparison always evaluates false.
    never = 1,
    /// The comparison evaluates reference < test.
    less = 2,
    /// The comparison evaluates reference == test.
    equal = 3,
    /// The comparison evaluates reference <= test.
    less_or_equal = 4,
    /// The comparison evaluates reference > test.
    greater = 5,
    /// The comparison evaluates reference != test.
    not_equal = 6,
    /// The comparison evaluates reference >= test.
    greater_or_equal = 7,
    /// The comparison always evaluates true.
    always = 8,
};

/// Specifies what happens to a stored stencil value if stencil tests fail or
/// pass.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUStencilOp = enum(c_uint) {
    invalid = 0,
    /// Keeps the current value.
    keep = 1,
    /// Sets the value to 0.
    zero = 2,
    /// Sets the value to reference.
    replace = 3,
    /// Increments the current value and clamps to the maximum value.
    increment_and_clamp = 4,
    /// Decrements the current value and clamps to 0.
    decrement_and_clamp = 5,
    /// Bitwise-inverts the current value.
    invert = 6,
    /// Increments the current value and wraps back to 0.
    increment_and_wrap = 7,
    /// Decrements the current value and wraps to the maximum value.
    decrement_and_wrap = 8,
};

/// Specifies the operator to be used when pixels in a render target are
/// blended with existing pixels in the texture.
///
/// The source color is the value written by the fragment shader. The
/// destination color is the value currently existing in the texture.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUBlendOp = enum(c_uint) {
    invalid = 0,
    /// (source * source_factor) + (destination * destination_factor)
    add = 1,
    /// (source * source_factor) - (destination * destination_factor)
    subtract = 2,
    /// (destination * destination_factor) - (source * source_factor)
    reverse_subtract = 3,
    // min(source, destination)
    min = 4,
    /// max(source, destination)
    max = 5,
};

/// Specifies a blending factor to be used when pixels in a render target are
/// blended with existing pixels in the texture.
///
/// The source color is the value written by the fragment shader. The
/// destination color is the value currently existing in the texture.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUBlendFactor = enum(c_uint) {
    invalid = 0,
    /// 0
    zero = 1,
    /// 1
    one = 2,
    /// source color
    src_color = 3,
    /// 1 - source color
    one_minus_src_color = 4,
    /// destination color
    dst_color = 5,
    /// 1 - destination color
    one_minus_dst_color = 6,
    /// source alpha
    src_alpha = 7,
    /// 1 - source alpha
    one_minus_src_alpha = 8,
    /// destination alpha
    dst_alpha = 9,
    /// 1 - destination alpha
    one_minus_dst_alpha = 10,
    /// blend constant
    constant_color = 11,
    /// 1 - blend constant
    one_minus_constant_color = 12,
    /// min(source alpha, 1 - destination alpha)
    src_alpha_saturate = 13,
};

/// Specifies which color components are written in a graphics pipeline.
///
/// \since This datatype is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
pub const SDL_GPUColorComponentFlags = packed struct(u8) {
    /// the red component
    R: bool, // bit 0
    /// the green component
    G: bool, // bit 1
    /// the blue component */
    B: bool, // bit 2
    /// the alpha component */
    A: bool, // bit 3
};

/// Specifies a filter operation used by a sampler.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUSampler
pub const SDL_GPUFilter = enum(c_uint) {
    /// Point filtering.
    nearest = 0,
    /// Linear filtering.
    linear = 1,
};

/// Specifies a mipmap mode used by a sampler.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUSampler
pub const SDL_GPUSamplerMipmapMode = enum(c_uint) {
    /// Point filtering.
    nearest = 0,
    /// Linear filtering.
    linear = 1,
};

/// Specifies behavior of texture sampling when the coordinates exceed the 0-1
/// range.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUSampler
pub const SDL_GPUSamplerAddressMode = enum(c_uint) {
    /// Specifies that the coordinates will wrap around.
    repeat = 0,
    /// Specifies that the coordinates will wrap around mirrored.
    mirrored_repeat = 1,
    /// Specifies that the coordinates will clamp to the 0-1 range.
    clamp_to_edge = 2,
};

/// Specifies the timing that will be used to present swapchain textures to the
/// OS.
///
/// VSYNC mode will always be supported. IMMEDIATE and MAILBOX modes may not be
/// supported on certain systems.
///
/// It is recommended to query SDL_WindowSupportsGPUPresentMode after claiming
/// the window if you wish to change the present mode to IMMEDIATE or MAILBOX.
///
/// - VSYNC: Waits for vblank before presenting. No tearing is possible. If
///   there is a pending image to present, the new image is enqueued for
///   presentation. Disallows tearing at the cost of visual latency.
/// - IMMEDIATE: Immediately presents. Lowest latency option, but tearing may
///   occur.
/// - MAILBOX: Waits for vblank before presenting. No tearing is possible. If
///   there is a pending image to present, the pending image is replaced by the
///   new image. Similar to VSYNC, but with reduced visual latency.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_SetGPUSwapchainParameters
/// \sa SDL_WindowSupportsGPUPresentMode
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
pub const SDL_GPUPresentMode = enum(c_uint) {
    vsync = 0,
    immediate = 1,
    mailbox = 2,
};

/// Specifies the texture format and colorspace of the swapchain textures.
///
/// SDR will always be supported. Other compositions may not be supported on
/// certain systems.
///
/// It is recommended to query SDL_WindowSupportsGPUSwapchainComposition after
/// claiming the window if you wish to change the swapchain composition from
/// SDR.
///
/// - SDR: B8G8R8A8 or R8G8B8A8 swapchain. Pixel values are in sRGB encoding.
/// - SDR_LINEAR: B8G8R8A8_SRGB or R8G8B8A8_SRGB swapchain. Pixel values are
///   stored in memory in sRGB encoding but accessed in shaders in "linear
///   sRGB" encoding which is sRGB but with a linear transfer function.
/// - HDR_EXTENDED_LINEAR: R16G16B16A16_FLOAT swapchain. Pixel values are in
///   extended linear sRGB encoding and permits values outside of the [0, 1]
///   range.
/// - HDR10_ST2084: A2R10G10B10 or A2B10G10R10 swapchain. Pixel values are in
///   BT.2020 ST2084 (PQ) encoding.
///
/// \since This enum is available since SDL 3.2.0.
///
/// \sa SDL_SetGPUSwapchainParameters
/// \sa SDL_WindowSupportsGPUSwapchainComposition
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
pub const SDL_GPUSwapchainComposition = enum(c_uint) {
    sdr = 0,
    sdr_linear = 1,
    hdr_extended_linear = 2,
    hdr10_st2084 = 3,
};

/////////////////////////////
// Structures
/////////////////////////////

/// A structure specifying a viewport.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_SetGPUViewport
pub const SDL_GPUViewport = extern struct {
    /// The left offset of the viewport.
    x: f32 = 0,
    /// The top offset of the viewport.
    y: f32 = 0,
    /// The width of the viewport.
    w: f32 = 0,
    /// The height of the viewport.
    h: f32 = 0,
    /// The minimum depth of the viewport.
    min_depth: f32 = 0,
    /// The maximum depth of the viewport.
    max_depth: f32 = 0,
};

/// A structure specifying parameters related to transferring data to or from a
/// texture.
///
/// If either of `pixels_per_row` or `rows_per_layer` is zero, then width and
/// height of passed SDL_GPUTextureRegion to SDL_UploadToGPUTexture or
/// SDL_DownloadFromGPUTexture are used as default values respectively and data
/// is considered to be tightly packed.
///
/// **WARNING**: On some older/integrated hardware, Direct3D 12 requires
/// texture data row pitch to be 256 byte aligned, and offsets to be aligned to
/// 512 bytes. If they are not, SDL will make a temporary copy of the data that
/// is properly aligned, but this adds overhead to the transfer process. Apps
/// can avoid this by aligning their data appropriately, or using a different
/// GPU backend than Direct3D 12.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUTexture
/// \sa SDL_DownloadFromGPUTexture
pub const SDL_GPUTextureTransferInfo = extern struct {
    /// The transfer buffer used in the transfer operation.
    transfer_buffer: ?*SDL_GPUTransferBuffer = null,
    /// The starting byte of the image data in the transfer buffer.
    offset: u32 = 0,
    /// The number of pixels from one row to the next.
    pixels_per_row: u32 = 0,
    /// The number of rows from one layer/depth-slice to the next.
    rows_per_layer: u32 = 0,
};

/// A structure specifying a location in a transfer buffer.
///
/// Used when transferring buffer data to or from a transfer buffer.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUBuffer
/// \sa SDL_DownloadFromGPUBuffer
pub const SDL_GPUTransferBufferLocation = extern struct {
    transfer_buffer: ?*SDL_GPUTransferBuffer = null,
    offset: u32 = 0,
};

/// A structure specifying a location in a texture.
///
/// Used when copying data from one texture to another.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CopyGPUTextureToTexture
pub const SDL_GPUTextureLocation = extern struct {
    /// The texture used in the copy operation.
    texture: ?*SDL_GPUTexture = null,
    /// The mip level index of the location.
    mip_level: u32 = 0,
    /// The layer index of the location.
    layer: u32 = 0,
    /// The left offset of the location.
    x: u32 = 0,
    /// The top offset of the location.
    y: u32 = 0,
    /// The front offset of the location.
    z: u32 = 0,
};

/// A structure specifying a region of a texture.
///
/// Used when transferring data to or from a texture.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUTexture
/// \sa SDL_DownloadFromGPUTexture
/// \sa SDL_CreateGPUTexture
pub const SDL_GPUTextureRegion = extern struct {
    /// The texture used in the copy operation.
    texture: ?*SDL_GPUTexture = null,
    /// The mip level index to transfer.
    mip_level: u32 = 0,
    /// The layer index to transfer.
    layer: u32 = 0,
    /// The left offset of the region.
    x: u32 = 0,
    /// The top offset of the region.
    y: u32 = 0,
    /// The front offset of the region.
    z: u32 = 0,
    /// The width of the region.
    w: u32 = 0,
    /// The height of the region.
    h: u32 = 0,
    /// The depth of the region.
    d: u32 = 0,
};

/// A structure specifying a region of a texture used in the blit operation.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BlitGPUTexture
pub const SDL_GPUBlitRegion = extern struct {
    /// The texture.
    texture: ?*SDL_GPUTexture = null,
    /// The mip level index of the region.
    mip_level: u32 = 0,
    /// The layer index or depth plane of the region. This value is treated as
    /// a layer index on 2D array and cube textures, and as a depth plane on 3D
    /// textures.
    layer_or_depth_plane: u32 = 0,
    /// The left offset of the region.
    x: u32 = 0,
    /// The top offset of the region.
    y: u32 = 0,
    /// The width of the region.
    w: u32 = 0,
    /// The height of the region.
    h: u32 = 0,
};

/// A structure specifying a location in a buffer.
///
/// Used when copying data between buffers.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CopyGPUBufferToBuffer
pub const SDL_GPUBufferLocation = extern struct {
    /// The buffer.
    buffer: ?*SDL_GPUBuffer = null,
    /// The starting byte within the buffer.
    offset: u32 = 0,
};

/// A structure specifying a region of a buffer.
///
/// Used when transferring data to or from buffers.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUBuffer
/// \sa SDL_DownloadFromGPUBuffer
pub const SDL_GPUBufferRegion = extern struct {
    /// The buffer.
    buffer: ?*SDL_GPUBuffer = null,
    /// The starting byte within the buffer.
    offset: u32 = 0,
    /// The size in bytes of the region.
    size: u32 = 0,
};

/// A structure specifying the parameters of an indirect draw command.
///
/// Note that the `first_vertex` and `first_instance` parameters are NOT
/// compatible with built-in vertex/instance ID variables in shaders (for
/// example, SV_VertexID); GPU APIs and shader languages do not define these
/// built-in variables consistently, so if your shader depends on them, the
/// only way to keep behavior consistent and portable is to always pass 0 for
/// the correlating parameter in the draw calls.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_DrawGPUPrimitivesIndirect
pub const SDL_GPUIndirectDrawCommand = extern struct {
    /// The number of vertices to draw.
    num_vertices: u32,
    /// The number of instances to draw.
    num_instances: u32,
    /// The index of the first vertex to draw.
    first_vertex: u32,
    /// The ID of the first instance to draw.
    first_instance: u32,
};

/// A structure specifying the parameters of an indexed indirect draw command.
///
/// Note that the `first_vertex` and `first_instance` parameters are NOT
/// compatible with built-in vertex/instance ID variables in shaders (for
/// example, SV_VertexID); GPU APIs and shader languages do not define these
/// built-in variables consistently, so if your shader depends on them, the
/// only way to keep behavior consistent and portable is to always pass 0 for
/// the correlating parameter in the draw calls.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_DrawGPUIndexedPrimitivesIndirect
pub const SDL_GPUIndexedIndirectDrawCommand = extern struct {
    /// The number of indices to draw per instance.
    num_indices: u32,
    /// The number of instances to draw.
    num_instances: u32,
    /// The base index within the index buffer.
    first_index: u32,
    /// The value added to the vertex index before indexing into the vertex buffer.
    vertex_offset: i32,
    /// The ID of the first instance to draw.
    first_instance: u32,
};

/// A structure specifying the parameters of an indexed dispatch command.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_DispatchGPUComputeIndirect
pub const SDL_GPUIndirectDispatchCommand = extern struct {
    ///  The number of local workgroups to dispatch in the X dimension.
    groupcount_x: u32,
    /// The number of local workgroups to dispatch in the Y dimension.
    groupcount_y: u32,
    /// The number of local workgroups to dispatch in the Z dimension.
    groupcount_z: u32,
};

/////////////////////////////
// State structures
/////////////////////////////

/// A structure specifying the parameters of a sampler.
///
/// Note that mip_lod_bias is a no-op for the Metal driver. For Metal, LOD bias
/// must be applied via shader instead.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUSampler
/// \sa SDL_GPUFilter
/// \sa SDL_GPUSamplerMipmapMode
/// \sa SDL_GPUSamplerAddressMode
/// \sa SDL_GPUCompareOp
pub const SDL_GPUSamplerCreateInfo = extern struct {
    /// The minification filter to apply to lookups.
    min_filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
    /// The magnification filter to apply to lookups.
    mag_filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
    /// The mipmap filter to apply to lookups.
    mipmap_mode: SDL_GPUSamplerMipmapMode = @import("std").mem.zeroes(SDL_GPUSamplerMipmapMode),
    /// The addressing mode for U coordinates outside [0, 1).
    address_mode_u: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
    /// The addressing mode for V coordinates outside [0, 1).
    address_mode_v: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
    /// The addressing mode for W coordinates outside [0, 1).
    address_mode_w: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
    /// The bias to be added to mipmap LOD calculation.
    mip_lod_bias: f32 = 0,
    /// The anisotropy value clamp used by the sampler.
    max_anisotropy: f32 = 0,
    /// The comparison operator to apply to fetched data before filtering.
    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
    /// Clamps the minimum of the computed LOD value.
    min_lod: f32 = 0,
    /// Clamps the maximum of the computed LOD value.
    max_lod: f32 = 0,
    /// true to enable anisotropic filtering.
    enable_anisotropy: bool = false,
    /// true to enable comparison against a reference value during lookups.
    enable_compare: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    /// A properties ID for extensions. Should be 0 if no extensions are needed.
    props: properties.SDL_PropertiesID = 0,
};

/// A structure specifying the parameters of vertex buffers used in a graphics
/// pipeline.
///
/// When you call SDL_BindGPUVertexBuffers, you specify the binding slots of
/// the vertex buffers. For example if you called SDL_BindGPUVertexBuffers with
/// a first_slot of 2 and num_bindings of 3, the binding slots 2, 3, 4 would be
/// used by the vertex buffers you pass in.
///
/// Vertex attributes are linked to buffers via the buffer_slot field of
/// SDL_GPUVertexAttribute. For example, if an attribute has a buffer_slot of
/// 0, then that attribute belongs to the vertex buffer bound at slot 0.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUVertexAttribute
/// \sa SDL_GPUVertexInputRate
pub const SDL_GPUVertexBufferDescription = extern struct {
    /// The binding slot of the vertex buffer.
    slot: u32 = 0,
    /// The size of a single element + the offset between elements.
    pitch: u32 = 0,
    /// Whether attribute addressing is a function of the vertex index or instance index.
    input_rate: SDL_GPUVertexInputRate = @import("std").mem.zeroes(SDL_GPUVertexInputRate),
    /// Reserved for future use. Must be set to 0.
    instance_step_rate: u32 = 0,
};

/// A structure specifying a vertex attribute.
///
/// All vertex attribute locations provided to an SDL_GPUVertexInputState must
/// be unique.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUVertexBufferDescription
/// \sa SDL_GPUVertexInputState
/// \sa SDL_GPUVertexElementFormat
pub const SDL_GPUVertexAttribute = extern struct {
    /// The shader input location index.
    location: u32 = 0,
    /// The binding slot of the associated vertex buffer.
    buffer_slot: u32 = 0,
    /// The size and type of the attribute data.
    format: SDL_GPUVertexElementFormat = @import("std").mem.zeroes(SDL_GPUVertexElementFormat),
    /// The byte offset of this attribute relative to the start of the vertex element.
    offset: u32 = 0,
};

/// A structure specifying the parameters of a graphics pipeline vertex input
/// state.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUGraphicsPipelineCreateInfo
/// \sa SDL_GPUVertexBufferDescription
/// \sa SDL_GPUVertexAttribute
pub const SDL_GPUVertexInputState = extern struct {
    /// A pointer to an array of vertex buffer descriptions.
    vertex_buffer_descriptions: [*c]const SDL_GPUVertexBufferDescription = null,
    /// The number of vertex buffer descriptions in the above array.
    num_vertex_buffers: u32 = 0,
    /// A pointer to an array of vertex attribute descriptions.
    vertex_attributes: [*c]const SDL_GPUVertexAttribute = null,
    /// The number of vertex attribute descriptions in the above array.
    num_vertex_attributes: u32 = 0,
};

/// A structure specifying the stencil operation state of a graphics pipeline.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUDepthStencilState
pub const SDL_GPUStencilOpState = extern struct {
    /// The action performed on samples that fail the stencil test.
    fail_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
    /// The action performed on samples that pass the depth and stencil tests.
    pass_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
    /// The action performed on samples that pass the stencil test and fail the depth test.
    depth_fail_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
    /// The comparison operator used in the stencil test.
    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
};

/// A structure specifying the blend state of a color target.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUColorTargetDescription
/// \sa SDL_GPUBlendFactor
/// \sa SDL_GPUBlendOp
/// \sa SDL_GPUColorComponentFlags
pub const SDL_GPUColorTargetBlendState = extern struct {
    /// The value to be multiplied by the source RGB value.
    src_color_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    /// The value to be multiplied by the destination RGB value.
    dst_color_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    /// The blend operation for the RGB components.
    color_blend_op: SDL_GPUBlendOp = @import("std").mem.zeroes(SDL_GPUBlendOp),
    /// The value to be multiplied by the source alpha.
    src_alpha_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    /// The value to be multiplied by the destination alpha.
    dst_alpha_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
    /// The blend operation for the alpha component.
    alpha_blend_op: SDL_GPUBlendOp = @import("std").mem.zeroes(SDL_GPUBlendOp),
    /// A bitmask specifying which of the RGBA components are enabled for
    /// writing. Writes to all channels if enable_color_write_mask is false.
    color_write_mask: SDL_GPUColorComponentFlags = 0,
    // Whether blending is enabled for the color target.
    enable_blend: bool = false,
    /// Whether the color write mask is enabled.
    enable_color_write_mask: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

/// A structure specifying code and metadata for creating a shader object.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
/// \sa SDL_GPUShaderFormat
/// \sa SDL_GPUShaderStage
pub const SDL_GPUShaderCreateInfo = extern struct {
    /// The size in bytes of the code pointed to.
    code_size: usize = 0,
    /// A pointer to shader code.
    code: [*c]const u8 = null,
    /// A pointer to a null-terminated UTF-8 string specifying the entry point
    /// function name for the shader.
    entrypoint: [*c]const u8 = null,
    /// The format of the shader code.
    format: SDL_GPUShaderFormat = .invalid,
    /// The stage the shader program corresponds to.
    stage: SDL_GPUShaderStage = @import("std").mem.zeroes(SDL_GPUShaderStage),
    /// The number of samplers defined in the shader.
    num_samplers: u32 = 0,
    /// The number of storage textures defined in the shader.
    num_storage_textures: u32 = 0,
    /// The number of storage buffers defined in the shader.
    num_storage_buffers: u32 = 0,
    /// The number of uniform buffers defined in the shader.
    num_uniform_buffers: u32 = 0,
    /// A properties ID for extensions. Should be 0 if no extensions are needed.
    props: properties.SDL_PropertiesID = 0,
};

/// A structure specifying the parameters of a texture.
///
/// Usage flags can be bitwise OR'd together for combinations of usages. Note
/// that certain usage combinations are invalid, for example SAMPLER and
/// GRAPHICS_STORAGE.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTexture
/// \sa SDL_GPUTextureType
/// \sa SDL_GPUTextureFormat
/// \sa SDL_GPUTextureUsageFlags
/// \sa SDL_GPUSampleCount
pub const SDL_GPUTextureCreateInfo = extern struct {
    /// The base dimensionality of the texture.
    type: SDL_GPUTextureType = @import("std").mem.zeroes(SDL_GPUTextureType),
    /// The pixel format of the texture.
    format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
    /// How the texture is intended to be used by the client.
    usage: SDL_GPUTextureUsageFlags = 0,
    /// The width of the texture.
    width: u32 = 0,
    /// The height of the texture.
    height: u32 = 0,
    /// The layer count or depth of the texture. This value is treated as a
    /// layer count on 2D array textures, and as a depth value on 3D textures.
    layer_count_or_depth: u32 = 0,
    /// The number of mip levels in the texture.
    num_levels: u32 = 0,
    /// The number of samples per texel. Only applies if the texture is used as a render target.
    sample_count: SDL_GPUSampleCount = @import("std").mem.zeroes(SDL_GPUSampleCount),
    /// A properties ID for extensions. Should be 0 if no extensions are needed.
    props: properties.SDL_PropertiesID = 0,
};

/// A structure specifying the parameters of a buffer.
///
/// Usage flags can be bitwise OR'd together for combinations of usages. Note
/// that certain combinations are invalid, for example VERTEX and INDEX.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUBuffer
/// \sa SDL_GPUBufferUsageFlags
pub const SDL_GPUBufferCreateInfo = extern struct {
    /// How the buffer is intended to be used by the client.
    usage: SDL_GPUBufferUsageFlags = 0,
    /// The size in bytes of the buffer.
    size: u32 = 0,
    /// A properties ID for extensions. Should be 0 if no extensions are needed.
    props: properties.SDL_PropertiesID = 0,
};

/// A structure specifying the parameters of a transfer buffer.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTransferBuffer
pub const SDL_GPUTransferBufferCreateInfo = extern struct {
    /// How the transfer buffer is intended to be used by the client.
    usage: SDL_GPUTransferBufferUsage = @import("std").mem.zeroes(SDL_GPUTransferBufferUsage),
    /// The size in bytes of the transfer buffer.
    size: u32 = 0,
    /// A properties ID for extensions. Should be 0 if no extensions are needed.
    props: properties.SDL_PropertiesID = 0,
};

/////////////////////////////
// Pipeline state structures
/////////////////////////////

/// A structure specifying the parameters of the graphics pipeline rasterizer
/// state.
///
/// Note that SDL_GPU_FILLMODE_LINE is not supported on many Android devices.
/// For those devices, the fill mode will automatically fall back to FILL.
///
/// Also note that the D3D12 driver will enable depth clamping even if
/// enable_depth_clip is true. If you need this clamp+clip behavior, consider
/// enabling depth clip and then manually clamping depth in your fragment
/// shaders on Metal and Vulkan.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUGraphicsPipelineCreateInfo
pub const SDL_GPURasterizerState = extern struct {
    /// Whether polygons will be filled in or drawn as lines.
    fill_mode: SDL_GPUFillMode = @import("std").mem.zeroes(SDL_GPUFillMode),
    /// The facing direction in which triangles will be culled.
    cull_mode: SDL_GPUCullMode = @import("std").mem.zeroes(SDL_GPUCullMode),
    /// The vertex winding that will cause a triangle to be determined as front-facing.
    front_face: SDL_GPUFrontFace = @import("std").mem.zeroes(SDL_GPUFrontFace),
    /// A scalar factor controlling the depth value added to each fragment.
    depth_bias_constant_factor: f32 = 0,
    /// The maximum depth bias of a fragment.
    depth_bias_clamp: f32 = 0,
    /// A scalar factor applied to a fragment's slope in depth calculations.
    depth_bias_slope_factor: f32 = 0,
    /// true to bias fragment depth values.
    enable_depth_bias: bool = false,
    /// true to enable depth clip, false to enable depth clamp.
    enable_depth_clip: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

/// A structure specifying the parameters of the graphics pipeline multisample
/// state.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUGraphicsPipelineCreateInfo
pub const SDL_GPUMultisampleState = extern struct {
    /// The number of samples to be used in rasterization.
    sample_count: SDL_GPUSampleCount = @import("std").mem.zeroes(SDL_GPUSampleCount),
    /// Reserved for future use. Must be set to 0.
    sample_mask: u32 = 0,
    /// Reserved for future use. Must be set to false.
    enable_mask: bool = false,
    /// true enables the alpha-to-coverage feature.
    enable_alpha_to_coverage: bool = false,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/// A structure specifying the parameters of the graphics pipeline depth
/// stencil state.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUGraphicsPipelineCreateInfo
pub const SDL_GPUDepthStencilState = extern struct {
    /// The comparison operator used for depth testing.
    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
    /// The stencil op state for back-facing triangles.
    back_stencil_state: SDL_GPUStencilOpState = @import("std").mem.zeroes(SDL_GPUStencilOpState),
    /// The stencil op state for front-facing triangles.
    front_stencil_state: SDL_GPUStencilOpState = @import("std").mem.zeroes(SDL_GPUStencilOpState),
    /// Selects the bits of the stencil values participating in the stencil test.
    compare_mask: u8 = 0,
    /// Selects the bits of the stencil values updated by the stencil test.
    write_mask: u8 = 0,
    /// true enables the depth test.
    enable_depth_test: bool = false,
    /// true enables depth writes. Depth writes are always disabled when enable_depth_test is false.
    enable_depth_write: bool = false,
    /// true enables the stencil test.
    enable_stencil_test: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/// A structure specifying the parameters of color targets used in a graphics
/// pipeline.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUGraphicsPipelineTargetInfo
pub const SDL_GPUColorTargetDescription = extern struct {
    /// The pixel format of the texture to be used as a color target.
    format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
    /// The blend state to be used for the color target.
    blend_state: SDL_GPUColorTargetBlendState = @import("std").mem.zeroes(SDL_GPUColorTargetBlendState),
};

/// A structure specifying the descriptions of render targets used in a
/// graphics pipeline.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_GPUGraphicsPipelineCreateInfo
/// \sa SDL_GPUColorTargetDescription
/// \sa SDL_GPUTextureFormat
pub const SDL_GPUGraphicsPipelineTargetInfo = extern struct {
    /// A pointer to an array of color target descriptions.
    color_target_descriptions: [*c]const SDL_GPUColorTargetDescription = null,
    /// The number of color target descriptions in the above array.
    num_color_targets: u32 = 0,
    /// The pixel format of the depth-stencil target. Ignored if has_depth_stencil_target is false.
    depth_stencil_format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
    /// true specifies that the pipeline uses a depth-stencil target.
    has_depth_stencil_target: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/// A structure specifying the parameters of a graphics pipeline state.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
/// \sa SDL_GPUShader
/// \sa SDL_GPUVertexInputState
/// \sa SDL_GPUPrimitiveType
/// \sa SDL_GPURasterizerState
/// \sa SDL_GPUMultisampleState
/// \sa SDL_GPUDepthStencilState
/// \sa SDL_GPUGraphicsPipelineTargetInfo
pub const SDL_GPUGraphicsPipelineCreateInfo = extern struct {
    /// The vertex shader used by the graphics pipeline.
    vertex_shader: ?*SDL_GPUShader = null,
    /// The fragment shader used by the graphics pipeline.
    fragment_shader: ?*SDL_GPUShader = null,
    /// The vertex layout of the graphics pipeline.
    vertex_input_state: SDL_GPUVertexInputState = @import("std").mem.zeroes(SDL_GPUVertexInputState),
    /// The primitive topology of the graphics pipeline.
    primitive_type: SDL_GPUPrimitiveType = @import("std").mem.zeroes(SDL_GPUPrimitiveType),
    /// The rasterizer state of the graphics pipeline.
    rasterizer_state: SDL_GPURasterizerState = @import("std").mem.zeroes(SDL_GPURasterizerState),
    /// The multisample state of the graphics pipeline.
    multisample_state: SDL_GPUMultisampleState = @import("std").mem.zeroes(SDL_GPUMultisampleState),
    /// The depth-stencil state of the graphics pipeline.
    depth_stencil_state: SDL_GPUDepthStencilState = @import("std").mem.zeroes(SDL_GPUDepthStencilState),
    /// Formats and blend modes for the render targets of the graphics pipeline.
    target_info: SDL_GPUGraphicsPipelineTargetInfo = @import("std").mem.zeroes(SDL_GPUGraphicsPipelineTargetInfo),
    /// A properties ID for extensions. Should be 0 if no extensions are needed.
    props: properties.SDL_PropertiesID = 0,
};

/// A structure specifying the parameters of a compute pipeline state.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUComputePipeline
/// \sa SDL_GPUShaderFormat
pub const SDL_GPUComputePipelineCreateInfo = extern struct {
    /// The size in bytes of the compute shader code pointed to.
    code_size: usize = 0,
    /// A pointer to compute shader code.
    code: [*c]const u8 = null,
    /// A pointer to a null-terminated UTF-8 string specifying the entry point
    /// function name for the shader.
    entrypoint: [*c]const u8 = null,
    /// The format of the compute shader code.
    format: SDL_GPUShaderFormat = 0,
    /// The number of samplers defined in the shader.
    num_samplers: u32 = 0,
    /// The number of readonly storage textures defined in the shader.
    num_readonly_storage_textures: u32 = 0,
    /// The number of readonly storage buffers defined in the shader.
    num_readonly_storage_buffers: u32 = 0,
    /// The number of read-write storage textures defined in the shader.
    num_readwrite_storage_textures: u32 = 0,
    /// The number of read-write storage buffers defined in the shader.
    num_readwrite_storage_buffers: u32 = 0,
    /// The number of uniform buffers defined in the shader.
    num_uniform_buffers: u32 = 0,
    /// The number of threads in the X dimension. This should match the value in the shader.
    threadcount_x: u32 = 0,
    /// The number of threads in the Y dimension. This should match the value in the shader.
    threadcount_y: u32 = 0,
    /// The number of threads in the Z dimension. This should match the value in the shader.
    threadcount_z: u32 = 0,
    /// A properties ID for extensions. Should be 0 if no extensions are needed.
    props: properties.SDL_PropertiesID = 0,
};

/// A structure specifying the parameters of a color target used by a render
/// pass.
///
/// The load_op field determines what is done with the texture at the beginning
/// of the render pass.
///
/// - LOAD: Loads the data currently in the texture. Not recommended for
///   multisample textures as it requires significant memory bandwidth.
/// - CLEAR: Clears the texture to a single color.
/// - DONT_CARE: The driver will do whatever it wants with the texture memory.
///   This is a good option if you know that every single pixel will be touched
///   in the render pass.
///
/// The store_op field determines what is done with the color results of the
/// render pass.
///
/// - STORE: Stores the results of the render pass in the texture. Not
///   recommended for multisample textures as it requires significant memory
///   bandwidth.
/// - DONT_CARE: The driver will do whatever it wants with the texture memory.
///   This is often a good option for depth/stencil textures.
/// - RESOLVE: Resolves a multisample texture into resolve_texture, which must
///   have a sample count of 1. Then the driver may discard the multisample
///   texture memory. This is the most performant method of resolving a
///   multisample target.
/// - RESOLVE_AND_STORE: Resolves a multisample texture into the
///   resolve_texture, which must have a sample count of 1. Then the driver
///   stores the multisample texture's contents. Not recommended as it requires
///   significant memory bandwidth.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPURenderPass
/// \sa SDL_FColor
pub const SDL_GPUColorTargetInfo = extern struct {
    /// The texture that will be used as a color target by a render pass.
    texture: ?*SDL_GPUTexture = null,
    /// The mip level to use as a color target.
    mip_level: u32 = 0,
    /// The layer index or depth plane to use as a color target. This value is
    /// treated as a layer index on 2D array and cube textures, and as a depth
    /// plane on 3D textures.
    layer_or_depth_plane: u32 = 0,
    /// The color to clear the color target to at the start of the render pass.
    /// Ignored if SDL_GPULoadOp.clear is not used.
    clear_color: pixels.SDL_FColor = @import("std").mem.zeroes(pixels.DL_FColor),
    /// What is done with the contents of the color target at the beginning of the render pass.
    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    /// What is done with the results of the render pass.
    store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
    /// The texture that will receive the results of a multisample resolve
    /// operation. Ignored if a RESOLVE* store_op is not used.
    resolve_texture: ?*SDL_GPUTexture = null,
    /// The mip level of the resolve texture to use for the resolve operation.
    /// Ignored if a RESOLVE* store_op is not used.
    resolve_mip_level: u32 = 0,
    /// The layer index of the resolve texture to use for the resolve
    /// operation. Ignored if a RESOLVE* store_op is not used.
    resolve_layer: u32 = 0,
    /// true cycles the texture if the texture is bound and load_op is not LOAD
    cycle: bool = false,
    /// true cycles the resolve texture if the resolve texture is bound.
    /// Ignored if a RESOLVE* store_op is not used.
    cycle_resolve_texture: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
};

/// A structure specifying the parameters of a depth-stencil target used by a
/// render pass.
///
/// The load_op field determines what is done with the depth contents of the
/// texture at the beginning of the render pass.
///
/// - LOAD: Loads the depth values currently in the texture.
/// - CLEAR: Clears the texture to a single depth.
/// - DONT_CARE: The driver will do whatever it wants with the memory. This is
///   a good option if you know that every single pixel will be touched in the
///   render pass.
///
/// The store_op field determines what is done with the depth results of the
/// render pass.
///
/// - STORE: Stores the depth results in the texture.
/// - DONT_CARE: The driver will do whatever it wants with the depth results.
///   This is often a good option for depth/stencil textures that don't need to
///   be reused again.
///
/// The stencil_load_op field determines what is done with the stencil contents
/// of the texture at the beginning of the render pass.
///
/// - LOAD: Loads the stencil values currently in the texture.
/// - CLEAR: Clears the stencil values to a single value.
/// - DONT_CARE: The driver will do whatever it wants with the memory. This is
///   a good option if you know that every single pixel will be touched in the
///   render pass.
///
/// The stencil_store_op field determines what is done with the stencil results
/// of the render pass.
///
/// - STORE: Stores the stencil results in the texture.
/// - DONT_CARE: The driver will do whatever it wants with the stencil results.
///   This is often a good option for depth/stencil textures that don't need to
///   be reused again.
///
/// Note that depth/stencil targets do not support multisample resolves.
///
/// Due to ABI limitations, depth textures with more than 255 layers are not
/// supported.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPURenderPass
pub const SDL_GPUDepthStencilTargetInfo = extern struct {
    /// The texture that will be used as the depth stencil target by the render pass.
    texture: ?*SDL_GPUTexture = null,
    /// The value to clear the depth component to at the beginning of the
    /// render pass. Ignored if SDL_GPULoadOp.clear is not used.
    clear_depth: f32 = 0,
    /// What is done with the depth contents at the beginning of the render pass.
    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    /// What is done with the depth results of the render pass.
    store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
    /// What is done with the stencil contents at the beginning of the render pass.
    stencil_load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    /// What is done with the stencil results of the render pass.
    stencil_store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
    /// true cycles the texture if the texture is bound and any load ops are not LOAD
    cycle: bool = false,
    /// The value to clear the stencil component to at the beginning of the
    /// render pass. Ignored if SDL_GPULoadOp.clear is not used.
    clear_stencil: u8 = 0,
    /// The mip level to use as the depth stencil target.
    mip_level: u8 = 0,
    /// The layer index to use as the depth stencil target.
    layer: u8 = 0,
};

/// A structure containing parameters for a blit command.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BlitGPUTexture
pub const SDL_GPUBlitInfo = extern struct {
    /// The source region for the blit.
    source: SDL_GPUBlitRegion = @import("std").mem.zeroes(SDL_GPUBlitRegion),
    /// The destination region for the blit.
    destination: SDL_GPUBlitRegion = @import("std").mem.zeroes(SDL_GPUBlitRegion),
    /// What is done with the contents of the destination before the blit.
    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
    /// The color to clear the destination region to before the blit. Ignored
    /// if load_op is not SDL_GPULoadOp.clear.
    clear_color: pixels.SDL_FColor = @import("std").mem.zeroes(pixels.SDL_FColor),
    /// The flip mode for the source region.
    flip_mode: surface.SDL_FlipMode = @import("std").mem.zeroes(surface.SDL_FlipMode),
    /// The filter mode used when blitting.
    filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
    /// true cycles the destination texture if it is already bound.
    cycle: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/////////////////////////////
// Binding structs
/////////////////////////////

/// A structure specifying parameters in a buffer binding call.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BindGPUVertexBuffers
/// \sa SDL_BindGPUIndexBuffer
pub const SDL_GPUBufferBinding = extern struct {
    /// The buffer to bind. Must have been created with
    /// SDL_GPU_BUFFERUSAGE_VERTEX for SDL_BindGPUVertexBuffers, or
    /// SDL_GPU_BUFFERUSAGE_INDEX for SDL_BindGPUIndexBuffer.
    buffer: ?*SDL_GPUBuffer = null,
    /// The starting byte of the data to bind in the buffer.
    offset: u32 = 0,
};

/// A structure specifying parameters in a sampler binding call.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BindGPUVertexSamplers
/// \sa SDL_BindGPUFragmentSamplers
/// \sa SDL_GPUTexture
/// \sa SDL_GPUSampler
pub const SDL_GPUTextureSamplerBinding = extern struct {
    /// The texture to bind. Must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
    texture: ?*SDL_GPUTexture = null,
    /// The sampler to bind.
    sampler: ?*SDL_GPUSampler = null,
};

/// A structure specifying parameters related to binding buffers in a compute
/// pass.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPUComputePass
pub const SDL_GPUStorageBufferReadWriteBinding = extern struct {
    /// The buffer to bind. Must have been created with
    /// SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE.
    buffer: ?*SDL_GPUBuffer = null,
    /// true cycles the buffer if it is already bound.
    cycle: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/// A structure specifying parameters related to binding textures in a compute
/// pass.
///
/// \since This struct is available since SDL 3.2.0.
///
/// \sa SDL_BeginGPUComputePass
pub const SDL_GPUStorageTextureReadWriteBinding = extern struct {
    /// The texture to bind. Must have been created with
    /// SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE or
    /// SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE.
    texture: ?*SDL_GPUTexture = null,
    /// The mip level index to bind.
    mip_level: u32 = 0,
    /// The layer index to bind.
    layer: u32 = 0,
    /// true cycles the texture if it is already bound.
    cycle: bool = false,
    padding1: u8 = 0,
    padding2: u8 = 0,
    padding3: u8 = 0,
};

/////////////////////////////
// Functions - Device
/////////////////////////////

/// Checks for GPU runtime support.
///
/// \param format_flags a bitflag indicating which shader formats the app is
///                     able to provide.
/// \param name the preferred GPU driver, or NULL to let SDL pick the optimal
///             driver.
/// \returns true if supported, false otherwise.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUDevice
pub extern fn SDL_GPUSupportsShaderFormats(
    format_flags: SDL_GPUShaderFormat,
    name: [*c]const u8,
) bool;

/// Checks for GPU runtime support.
///
/// \param props the properties to use.
/// \returns true if supported, false otherwise.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUDeviceWithProperties
pub extern fn SDL_GPUSupportsProperties(props: properties.SDL_PropertiesID) bool;

/// Creates a GPU context.
///
/// The GPU driver name can be one of the following:
///
/// - "vulkan": [Vulkan](CategoryGPU#vulkan)
/// - "direct3d12": [D3D12](CategoryGPU#d3d12)
/// - "metal": [Metal](CategoryGPU#metal)
/// - NULL: let SDL pick the optimal driver
///
/// \param format_flags a bitflag indicating which shader formats the app is
///                     able to provide.
/// \param debug_mode enable debug mode properties and validations.
/// \param name the preferred GPU driver, or NULL to let SDL pick the optimal
///             driver.
/// \returns a GPU context on success or NULL on failure; call SDL_GetError()
///          for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUDeviceWithProperties
/// \sa SDL_GetGPUShaderFormats
/// \sa SDL_GetGPUDeviceDriver
/// \sa SDL_DestroyGPUDevice
/// \sa SDL_GPUSupportsShaderFormats
pub extern fn SDL_CreateGPUDevice(
    format_flags: SDL_GPUShaderFormat,
    debug_mode: bool,
    name: [*c]const u8,
) ?*SDL_GPUDevice;

/// Creates a GPU context.
///
/// These are the supported properties:
///
/// - `SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN`: enable debug mode
///   properties and validations, defaults to true.
/// - `SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN`: enable to prefer
///   energy efficiency over maximum GPU performance, defaults to false.
/// - `SDL_PROP_GPU_DEVICE_CREATE_VERBOSE_BOOLEAN`: enable to automatically log
///   useful debug information on device creation, defaults to true.
/// - `SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING`: the name of the GPU driver to
///   use, if a specific one is desired.
/// - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_CLIP_DISTANCE_BOOLEAN`: Enable Vulkan
///   device feature shaderClipDistance. If disabled, clip distances are not
///   supported in shader code: gl_ClipDistance[] built-ins of GLSL,
///   SV_ClipDistance0/1 semantics of HLSL and [[clip_distance]] attribute of
///   Metal. Disabling optional features allows the application to run on some
///   older Android devices. Defaults to true.
/// - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_DEPTH_CLAMPING_BOOLEAN`: Enable
///   Vulkan device feature depthClamp. If disabled, there is no depth clamp
///   support and enable_depth_clip in SDL_GPURasterizerState must always be
///   set to true. Disabling optional features allows the application to run on
///   some older Android devices. Defaults to true.
/// - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_INDIRECT_DRAW_FIRST_INSTANCE_BOOLEAN`:
///   Enable Vulkan device feature drawIndirectFirstInstance. If disabled, the
///   argument first_instance of SDL_GPUIndirectDrawCommand must be set to
///   zero. Disabling optional features allows the application to run on some
///   older Android devices. Defaults to true.
/// - `SDL_PROP_GPU_DEVICE_CREATE_FEATURE_ANISOTROPY_BOOLEAN`: Enable Vulkan
///   device feature samplerAnisotropy. If disabled, enable_anisotropy of
///   SDL_GPUSamplerCreateInfo must be set to false. Disabling optional
///   features allows the application to run on some older Android devices.
///   Defaults to true.
///
/// These are the current shader format properties:
///
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN`: The app is able to
///   provide shaders for an NDA platform.
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN`: The app is able to
///   provide SPIR-V shaders if applicable.
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN`: The app is able to
///   provide DXBC shaders if applicable
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN`: The app is able to
///   provide DXIL shaders if applicable.
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN`: The app is able to
///   provide MSL shaders if applicable.
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN`: The app is able to
///   provide Metal shader libraries if applicable.
///
/// With the D3D12 backend:
///
/// - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING`: the prefix to
///   use for all vertex semantics, default is "TEXCOORD".
/// - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_ALLOW_FEWER_RESOURCE_SLOTS_BOOLEAN`: By
///   default, Resourcing Binding Tier 2 is required for D3D12 support.
///   However, an application can set this property to true to enable Tier 1
///   support, if (and only if) the application uses 8 or fewer storage
///   resources across all shader stages. As of writing, this property is
///   useful for targeting Intel Haswell and Broadwell GPUs; other hardware
///   either supports Tier 2 Resource Binding or does not support D3D12 in any
///   capacity. Defaults to false.
/// - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_VERSION_NUMBER`: Certain
///   feature checks are only possible on Windows 11 by default. By setting
///   this alongside `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_PATH_STRING`
///   and vendoring D3D12Core.dll from the D3D12 Agility SDK, you can make
///   those feature checks possible on older platforms. The version you provide
///   must match the one given in the DLL.
/// - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_PATH_STRING`: Certain
///   feature checks are only possible on Windows 11 by default. By setting
///   this alongside
///   `SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_VERSION_NUMBER` and
///   vendoring D3D12Core.dll from the D3D12 Agility SDK, you can make those
///   feature checks possible on older platforms. The path you provide must be
///   relative to the executable path of your app. Be sure not to put the DLL
///   in the same directory as the exe; Microsoft strongly advises against
///   this!
///
/// With the Vulkan backend:
///
/// - `SDL_PROP_GPU_DEVICE_CREATE_VULKAN_REQUIRE_HARDWARE_ACCELERATION_BOOLEAN`:
///   By default, Vulkan device enumeration includes drivers of all types,
///   including software renderers (for example, the Lavapipe Mesa driver).
///   This can be useful if your application _requires_ SDL_GPU, but if you can
///   provide your own fallback renderer (for example, an OpenGL renderer) this
///   property can be set to true. Defaults to false.
/// - `SDL_PROP_GPU_DEVICE_CREATE_VULKAN_OPTIONS_POINTER`: a pointer to an
///   SDL_GPUVulkanOptions structure to be processed during device creation.
///   This allows configuring a variety of Vulkan-specific options such as
///   increasing the API version and opting into extensions aside from the
///   minimal set SDL requires.
///
/// With the Metal backend: -
/// `SDL_PROP_GPU_DEVICE_CREATE_METAL_ALLOW_MACFAMILY1_BOOLEAN`: By default,
/// macOS support requires what Apple calls "MTLGPUFamilyMac2" hardware or
/// newer. However, an application can set this property to true to enable
/// support for "MTLGPUFamilyMac1" hardware, if (and only if) the application
/// does not write to sRGB textures. (For history's sake: MacFamily1 also does
/// not support indirect command buffers, MSAA depth resolve, and stencil
/// resolve/feedback, but these are not exposed features in SDL_GPU.)
///
/// \param props the properties to use.
/// \returns a GPU context on success or NULL on failure; call SDL_GetError()
///          for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GetGPUShaderFormats
/// \sa SDL_GetGPUDeviceDriver
/// \sa SDL_DestroyGPUDevice
/// \sa SDL_GPUSupportsProperties
pub extern fn SDL_CreateGPUDeviceWithProperties(
    props: properties.SDL_PropertiesID,
) ?*SDL_GPUDevice;

pub const SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN = "SDL.gpu.device.create.debugmode";
pub const SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN = "SDL.gpu.device.create.preferlowpower";
pub const SDL_PROP_GPU_DEVICE_CREATE_VERBOSE_BOOLEAN = "SDL.gpu.device.create.verbose";
pub const SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING = "SDL.gpu.device.create.name";
pub const SDL_PROP_GPU_DEVICE_CREATE_FEATURE_CLIP_DISTANCE_BOOLEAN = "SDL.gpu.device.create.feature.clip_distance";
pub const SDL_PROP_GPU_DEVICE_CREATE_FEATURE_DEPTH_CLAMPING_BOOLEAN = "SDL.gpu.device.create.feature.depth_clamping";
pub const SDL_PROP_GPU_DEVICE_CREATE_FEATURE_INDIRECT_DRAW_FIRST_INSTANCE_BOOLEAN = "SDL.gpu.device.create.feature.indirect_draw_first_instance";
pub const SDL_PROP_GPU_DEVICE_CREATE_FEATURE_ANISOTROPY_BOOLEAN = "SDL.gpu.device.create.feature.anisotropy";
pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN = "SDL.gpu.device.create.shaders.private";
pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN = "SDL.gpu.device.create.shaders.spirv";
pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN = "SDL.gpu.device.create.shaders.dxbc";
pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN = "SDL.gpu.device.create.shaders.dxil";
pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN = "SDL.gpu.device.create.shaders.msl";
pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN = "SDL.gpu.device.create.shaders.metallib";
pub const SDL_PROP_GPU_DEVICE_CREATE_D3D12_ALLOW_FEWER_RESOURCE_SLOTS_BOOLEAN = "SDL.gpu.device.create.d3d12.allowtier1resourcebinding";
pub const SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING = "SDL.gpu.device.create.d3d12.semantic";
pub const SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_VERSION_NUMBER = "SDL.gpu.device.create.d3d12.agility_sdk_version";
pub const SDL_PROP_GPU_DEVICE_CREATE_D3D12_AGILITY_SDK_PATH_STRING = "SDL.gpu.device.create.d3d12.agility_sdk_path";
pub const SDL_PROP_GPU_DEVICE_CREATE_VULKAN_REQUIRE_HARDWARE_ACCELERATION_BOOLEAN = "SDL.gpu.device.create.vulkan.requirehardwareacceleration";
pub const SDL_PROP_GPU_DEVICE_CREATE_VULKAN_OPTIONS_POINTER = "SDL.gpu.device.create.vulkan.options";
pub const SDL_PROP_GPU_DEVICE_CREATE_METAL_ALLOW_MACFAMILY1_BOOLEAN = "SDL.gpu.device.create.metal.allowmacfamily1";

/// A structure specifying additional options when using Vulkan.
///
/// When no such structure is provided, SDL will use Vulkan API version 1.0 and
/// a minimal set of features. The requested API version influences how the
/// feature_list is processed by SDL. When requesting API version 1.0, the
/// feature_list is ignored. Only the vulkan_10_physical_device_features and
/// the extension lists are used. When requesting API version 1.1, the
/// feature_list is scanned for feature structures introduced in Vulkan 1.1.
/// When requesting Vulkan 1.2 or higher, the feature_list is additionally
/// scanned for compound feature structs such as
/// VkPhysicalDeviceVulkan11Features. The device and instance extension lists,
/// as well as vulkan_10_physical_device_features, are always processed.
///
/// \since This struct is available since SDL 3.4.0.
pub const SDL_GPUVulkanOptions = extern struct {
    /// The Vulkan API version to request for the instance. Use Vulkan's
    /// VK_MAKE_VERSION or VK_MAKE_API_VERSION.
    vulkan_api_version: u32 = 0,
    /// Pointer to the first element of a chain of Vulkan feature structs.
    /// (Requires API version 1.1 or higher.)
    feature_list: ?*anyopaque = null,
    /// Pointer to a VkPhysicalDeviceFeatures struct to enable additional Vulkan 1.0 features.
    vulkan_10_physical_device_features: ?*anyopaque = null,
    /// Number of additional device extensions to require.
    device_extension_count: u32 = 0,
    /// Pointer to a list of additional device extensions to require.
    device_extension_names: [*c][*c]const u8 = null,
    /// Number of additional instance extensions to require.
    instance_extension_count: u32 = 0,
    /// Pointer to a list of additional instance extensions to require.
    instance_extension_names: [*c][*c]const u8 = null,
};

/// Destroys a GPU context previously returned by SDL_CreateGPUDevice.
///
/// \param device a GPU Context to destroy.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUDevice
pub extern fn SDL_DestroyGPUDevice(device: ?*SDL_GPUDevice) void;

/// Get the number of GPU drivers compiled into SDL.
///
/// \returns the number of built in GPU drivers.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GetGPUDriver
pub extern fn SDL_GetNumGPUDrivers() c_int;

/// Get the name of a built in GPU driver.
///
/// The GPU drivers are presented in the order in which they are normally
/// checked during initialization.
///
/// The names of drivers are all simple, low-ASCII identifiers, like "vulkan",
/// "metal" or "direct3d12". These never have Unicode characters, and are not
/// meant to be proper names.
///
/// \param index the index of a GPU driver.
/// \returns the name of the GPU driver with the given **index**.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GetNumGPUDrivers
pub extern fn SDL_GetGPUDriver(index: c_int) [*c]const u8;

/// Returns the name of the backend used to create this GPU context.
///
/// \param device a GPU context to query.
/// \returns the name of the device's driver, or NULL on error.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetGPUDeviceDriver(device: ?*SDL_GPUDevice) [*c]const u8;

/// Returns the supported shader formats for this GPU context.
///
/// \param device a GPU context to query.
/// \returns a bitflag indicating which shader formats the driver is able to
///          consume.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetGPUShaderFormats(device: ?*SDL_GPUDevice) SDL_GPUShaderFormat;

/// Get the properties associated with a GPU device.
///
/// All properties are optional and may differ between GPU backends and SDL
/// versions.
///
/// The following properties are provided by SDL:
///
/// `SDL_PROP_GPU_DEVICE_NAME_STRING`: Contains the name of the underlying
/// device as reported by the system driver. This string has no standardized
/// format, is highly inconsistent between hardware devices and drivers, and is
/// able to change at any time. Do not attempt to parse this string as it is
/// bound to fail at some point in the future when system drivers are updated,
/// new hardware devices are introduced, or when SDL adds new GPU backends or
/// modifies existing ones.
///
/// Strings that have been found in the wild include:
///
/// - GTX 970
/// - GeForce GTX 970
/// - NVIDIA GeForce GTX 970
/// - Microsoft Direct3D12 (NVIDIA GeForce GTX 970)
/// - NVIDIA Graphics Device
/// - GeForce GPU
/// - P106-100
/// - AMD 15D8:C9
/// - AMD Custom GPU 0405
/// - AMD Radeon (TM) Graphics
/// - ASUS Radeon RX 470 Series
/// - Intel(R) Arc(tm) A380 Graphics (DG2)
/// - Virtio-GPU Venus (NVIDIA TITAN V)
/// - SwiftShader Device (LLVM 16.0.0)
/// - llvmpipe (LLVM 15.0.4, 256 bits)
/// - Microsoft Basic Render Driver
/// - unknown device
///
/// The above list shows that the same device can have different formats, the
/// vendor name may or may not appear in the string, the included vendor name
/// may not be the vendor of the chipset on the device, some manufacturers
/// include pseudo-legal marks while others don't, some devices may not use a
/// marketing name in the string, the device string may be wrapped by the name
/// of a translation interface, the device may be emulated in software, or the
/// string may contain generic text that does not identify the device at all.
///
/// `SDL_PROP_GPU_DEVICE_DRIVER_NAME_STRING`: Contains the self-reported name
/// of the underlying system driver.
///
/// Strings that have been found in the wild include:
///
/// - Intel Corporation
/// - Intel open-source Mesa driver
/// - Qualcomm Technologies Inc. Adreno Vulkan Driver
/// - MoltenVK
/// - Mali-G715
/// - venus
///
/// `SDL_PROP_GPU_DEVICE_DRIVER_VERSION_STRING`: Contains the self-reported
/// version of the underlying system driver. This is a relatively short version
/// string in an unspecified format. If SDL_PROP_GPU_DEVICE_DRIVER_INFO_STRING
/// is available then that property should be preferred over this one as it may
/// contain additional information that is useful for identifying the exact
/// driver version used.
///
/// Strings that have been found in the wild include:
///
/// - 53.0.0
/// - 0.405.2463
/// - 32.0.15.6614
///
/// `SDL_PROP_GPU_DEVICE_DRIVER_INFO_STRING`: Contains the detailed version
/// information of the underlying system driver as reported by the driver. This
/// is an arbitrary string with no standardized format and it may contain
/// newlines. This property should be preferred over
/// SDL_PROP_GPU_DEVICE_DRIVER_VERSION_STRING if it is available as it usually
/// contains the same information but in a format that is easier to read.
///
/// Strings that have been found in the wild include:
///
/// - 101.6559
/// - 1.2.11
/// - Mesa 21.2.2 (LLVM 12.0.1)
/// - Mesa 22.2.0-devel (git-f226222 2022-04-14 impish-oibaf-ppa)
/// - v1.r53p0-00eac0.824c4f31403fb1fbf8ee1042422c2129
///
/// This string has also been observed to be a multiline string (which has a
/// trailing newline):
///
/// ```
/// Driver Build: 85da404, I46ff5fc46f, 1606794520
/// Date: 11/30/20
/// Compiler Version: EV031.31.04.01
/// Driver Branch: promo490_3_Google
/// ```
///
/// \param device a GPU context to query.
/// \returns a valid property ID on success or 0 on failure; call
///          SDL_GetError() for more information.
///
/// \threadsafety It is safe to call this function from any thread.
///
/// \since This function is available since SDL 3.4.0.
pub extern fn SDL_GetGPUDeviceProperties(device: ?*SDL_GPUDevice) properties.SDL_PropertiesID;

pub const SDL_PROP_GPU_DEVICE_NAME_STRING = "SDL.gpu.device.name";
pub const SDL_PROP_GPU_DEVICE_DRIVER_NAME_STRING = "SDL.gpu.device.driver_name";
pub const SDL_PROP_GPU_DEVICE_DRIVER_VERSION_STRING = "SDL.gpu.device.driver_version";
pub const SDL_PROP_GPU_DEVICE_DRIVER_INFO_STRING = "SDL.gpu.device.driver_info";

/////////////////////////////
// Functions - State Creation
/////////////////////////////

/// Creates a pipeline object to be used in a compute workflow.
///
/// Shader resource bindings must be authored to follow a particular order
/// depending on the shader format.
///
/// For SPIR-V shaders, use the following resource sets:
///
/// - 0: Sampled textures, followed by read-only storage textures, followed by
///   read-only storage buffers
/// - 1: Read-write storage textures, followed by read-write storage buffers
/// - 2: Uniform buffers
///
/// For DXBC and DXIL shaders, use the following register order:
///
/// - (t[n], space0): Sampled textures, followed by read-only storage textures,
///   followed by read-only storage buffers
/// - (u[n], space1): Read-write storage textures, followed by read-write
///   storage buffers
/// - (b[n], space2): Uniform buffers
///
/// For MSL/metallib, use the following order:
///
/// - [[buffer]]: Uniform buffers, followed by read-only storage buffers,
///   followed by read-write storage buffers
/// - [[texture]]: Sampled textures, followed by read-only storage textures,
///   followed by read-write storage textures
///
/// There are optional properties that can be provided through `props`. These
/// are the supported properties:
///
/// - `SDL_PROP_GPU_COMPUTEPIPELINE_CREATE_NAME_STRING`: a name that can be
///   displayed in debugging tools.
///
/// \param device a GPU Context.
/// \param createinfo a struct describing the state of the compute pipeline to
///                   create.
/// \returns a compute pipeline object on success, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_BindGPUComputePipeline
/// \sa SDL_ReleaseGPUComputePipeline
pub extern fn SDL_CreateGPUComputePipeline(
    device: ?*SDL_GPUDevice,
    createinfo: [*c]const SDL_GPUComputePipelineCreateInfo,
) ?*SDL_GPUComputePipeline;

pub const SDL_PROP_GPU_COMPUTEPIPELINE_CREATE_NAME_STRING = "SDL.gpu.computepipeline.create.name";

/// Creates a pipeline object to be used in a graphics workflow.
///
/// There are optional properties that can be provided through `props`. These
/// are the supported properties:
///
/// - `SDL_PROP_GPU_GRAPHICSPIPELINE_CREATE_NAME_STRING`: a name that can be
///   displayed in debugging tools.
///
/// \param device a GPU Context.
/// \param createinfo a struct describing the state of the graphics pipeline to
///                   create.
/// \returns a graphics pipeline object on success, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
/// \sa SDL_BindGPUGraphicsPipeline
/// \sa SDL_ReleaseGPUGraphicsPipeline
pub extern fn SDL_CreateGPUGraphicsPipeline(
    device: ?*SDL_GPUDevice,
    createinfo: [*c]const SDL_GPUGraphicsPipelineCreateInfo,
) ?*SDL_GPUGraphicsPipeline;

pub const SDL_PROP_GPU_GRAPHICSPIPELINE_CREATE_NAME_STRING = "SDL.gpu.graphicspipeline.create.name";

/// Creates a sampler object to be used when binding textures in a graphics
/// workflow.
///
/// There are optional properties that can be provided through `props`. These
/// are the supported properties:
///
/// - `SDL_PROP_GPU_SAMPLER_CREATE_NAME_STRING`: a name that can be displayed
///   in debugging tools.
///
/// \param device a GPU Context.
/// \param createinfo a struct describing the state of the sampler to create.
/// \returns a sampler object on success, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_BindGPUVertexSamplers
/// \sa SDL_BindGPUFragmentSamplers
/// \sa SDL_ReleaseGPUSampler
pub extern fn SDL_CreateGPUSampler(
    device: ?*SDL_GPUDevice,
    createinfo: [*c]const SDL_GPUSamplerCreateInfo,
) ?*SDL_GPUSampler;

pub const SDL_PROP_GPU_SAMPLER_CREATE_NAME_STRING = "SDL.gpu.sampler.create.name";

/// Creates a shader to be used when creating a graphics pipeline.
///
/// Shader resource bindings must be authored to follow a particular order
/// depending on the shader format.
///
/// For SPIR-V shaders, use the following resource sets:
///
/// For vertex shaders:
///
/// - 0: Sampled textures, followed by storage textures, followed by storage
///   buffers
/// - 1: Uniform buffers
///
/// For fragment shaders:
///
/// - 2: Sampled textures, followed by storage textures, followed by storage
///   buffers
/// - 3: Uniform buffers
///
/// For DXBC and DXIL shaders, use the following register order:
///
/// For vertex shaders:
///
/// - (t[n], space0): Sampled textures, followed by storage textures, followed
///   by storage buffers
/// - (s[n], space0): Samplers with indices corresponding to the sampled
///   textures
/// - (b[n], space1): Uniform buffers
///
/// For pixel shaders:
///
/// - (t[n], space2): Sampled textures, followed by storage textures, followed
///   by storage buffers
/// - (s[n], space2): Samplers with indices corresponding to the sampled
///   textures
/// - (b[n], space3): Uniform buffers
///
/// For MSL/metallib, use the following order:
///
/// - [[texture]]: Sampled textures, followed by storage textures
/// - [[sampler]]: Samplers with indices corresponding to the sampled textures
/// - [[buffer]]: Uniform buffers, followed by storage buffers. Vertex buffer 0
///   is bound at [[buffer(14)]], vertex buffer 1 at [[buffer(15)]], and so on.
///   Rather than manually authoring vertex buffer indices, use the
///   [[stage_in]] attribute which will automatically use the vertex input
///   information from the SDL_GPUGraphicsPipeline.
///
/// Shader semantics other than system-value semantics do not matter in D3D12
/// and for ease of use the SDL implementation assumes that non system-value
/// semantics will all be TEXCOORD. If you are using HLSL as the shader source
/// language, your vertex semantics should start at TEXCOORD0 and increment
/// like so: TEXCOORD1, TEXCOORD2, etc. If you wish to change the semantic
/// prefix to something other than TEXCOORD you can use
/// SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING with
/// SDL_CreateGPUDeviceWithProperties().
///
/// There are optional properties that can be provided through `props`. These
/// are the supported properties:
///
/// - `SDL_PROP_GPU_SHADER_CREATE_NAME_STRING`: a name that can be displayed in
///   debugging tools.
///
/// \param device a GPU Context.
/// \param createinfo a struct describing the state of the shader to create.
/// \returns a shader object on success, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUGraphicsPipeline
/// \sa SDL_ReleaseGPUShader
pub extern fn SDL_CreateGPUShader(
    device: ?*SDL_GPUDevice,
    createinfo: [*c]const SDL_GPUShaderCreateInfo,
) ?*SDL_GPUShader;

pub const SDL_PROP_GPU_SHADER_CREATE_NAME_STRING = "SDL.gpu.shader.create.name";

/// Creates a texture object to be used in graphics or compute workflows.
///
/// The contents of this texture are undefined until data is written to the
/// texture, either via SDL_UploadToGPUTexture or by performing a render or
/// compute pass with this texture as a target.
///
/// Note that certain combinations of usage flags are invalid. For example, a
/// texture cannot have both the SAMPLER and GRAPHICS_STORAGE_READ flags.
///
/// If you request a sample count higher than the hardware supports, the
/// implementation will automatically fall back to the highest available sample
/// count.
///
/// There are optional properties that can be provided through
/// SDL_GPUTextureCreateInfo's `props`. These are the supported properties:
///
/// - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_R_FLOAT`: (Direct3D 12 only) if
///   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
///   to a color with this red intensity. Defaults to zero.
/// - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_G_FLOAT`: (Direct3D 12 only) if
///   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
///   to a color with this green intensity. Defaults to zero.
/// - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_B_FLOAT`: (Direct3D 12 only) if
///   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
///   to a color with this blue intensity. Defaults to zero.
/// - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_A_FLOAT`: (Direct3D 12 only) if
///   the texture usage is SDL_GPU_TEXTUREUSAGE_COLOR_TARGET, clear the texture
///   to a color with this alpha intensity. Defaults to zero.
/// - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_DEPTH_FLOAT`: (Direct3D 12 only)
///   if the texture usage is SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET, clear
///   the texture to a depth of this value. Defaults to zero.
/// - `SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_STENCIL_NUMBER`: (Direct3D 12
///   only) if the texture usage is SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET,
///   clear the texture to a stencil of this Uint8 value. Defaults to zero.
/// - `SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING`: a name that can be displayed
///   in debugging tools.
///
/// \param device a GPU Context.
/// \param createinfo a struct describing the state of the texture to create.
/// \returns a texture object on success, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUTexture
/// \sa SDL_DownloadFromGPUTexture
/// \sa SDL_BeginGPURenderPass
/// \sa SDL_BeginGPUComputePass
/// \sa SDL_BindGPUVertexSamplers
/// \sa SDL_BindGPUVertexStorageTextures
/// \sa SDL_BindGPUFragmentSamplers
/// \sa SDL_BindGPUFragmentStorageTextures
/// \sa SDL_BindGPUComputeStorageTextures
/// \sa SDL_BlitGPUTexture
/// \sa SDL_ReleaseGPUTexture
/// \sa SDL_GPUTextureSupportsFormat
pub extern fn SDL_CreateGPUTexture(
    device: ?*SDL_GPUDevice,
    createinfo: [*c]const SDL_GPUTextureCreateInfo,
) ?*SDL_GPUTexture;

pub const SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_R_FLOAT = "SDL.gpu.texture.create.d3d12.clear.r";
pub const SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_G_FLOAT = "SDL.gpu.texture.create.d3d12.clear.g";
pub const SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_B_FLOAT = "SDL.gpu.texture.create.d3d12.clear.b";
pub const SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_A_FLOAT = "SDL.gpu.texture.create.d3d12.clear.a";
pub const SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_DEPTH_FLOAT = "SDL.gpu.texture.create.d3d12.clear.depth";
pub const SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_STENCIL_NUMBER = "SDL.gpu.texture.create.d3d12.clear.stencil";
pub const SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING = "SDL.gpu.texture.create.name";

/// Creates a buffer object to be used in graphics or compute workflows.
///
/// The contents of this buffer are undefined until data is written to the
/// buffer.
///
/// Note that certain combinations of usage flags are invalid. For example, a
/// buffer cannot have both the VERTEX and INDEX flags.
///
/// If you use a STORAGE flag, the data in the buffer must respect std140
/// layout conventions. In practical terms this means you must ensure that vec3
/// and vec4 fields are 16-byte aligned.
///
/// For better understanding of underlying concepts and memory management with
/// SDL GPU API, you may refer
/// [this blog post](https://moonside.games/posts/sdl-gpu-concepts-cycling/)
/// .
///
/// There are optional properties that can be provided through `props`. These
/// are the supported properties:
///
/// - `SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING`: a name that can be displayed in
///   debugging tools.
///
/// \param device a GPU Context.
/// \param createinfo a struct describing the state of the buffer to create.
/// \returns a buffer object on success, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUBuffer
/// \sa SDL_DownloadFromGPUBuffer
/// \sa SDL_CopyGPUBufferToBuffer
/// \sa SDL_BindGPUVertexBuffers
/// \sa SDL_BindGPUIndexBuffer
/// \sa SDL_BindGPUVertexStorageBuffers
/// \sa SDL_BindGPUFragmentStorageBuffers
/// \sa SDL_DrawGPUPrimitivesIndirect
/// \sa SDL_DrawGPUIndexedPrimitivesIndirect
/// \sa SDL_BindGPUComputeStorageBuffers
/// \sa SDL_DispatchGPUComputeIndirect
/// \sa SDL_ReleaseGPUBuffer
pub extern fn SDL_CreateGPUBuffer(
    device: ?*SDL_GPUDevice,
    createinfo: [*c]const SDL_GPUBufferCreateInfo,
) ?*SDL_GPUBuffer;

pub const SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING = "SDL.gpu.buffer.create.name";

/// Creates a transfer buffer to be used when uploading to or downloading from
/// graphics resources.
///
/// Download buffers can be particularly expensive to create, so it is good
/// practice to reuse them if data will be downloaded regularly.
///
/// There are optional properties that can be provided through `props`. These
/// are the supported properties:
///
/// - `SDL_PROP_GPU_TRANSFERBUFFER_CREATE_NAME_STRING`: a name that can be
///   displayed in debugging tools.
///
/// \param device a GPU Context.
/// \param createinfo a struct describing the state of the transfer buffer to
///                   create.
/// \returns a transfer buffer on success, or NULL on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUBuffer
/// \sa SDL_DownloadFromGPUBuffer
/// \sa SDL_UploadToGPUTexture
/// \sa SDL_DownloadFromGPUTexture
/// \sa SDL_ReleaseGPUTransferBuffer
pub extern fn SDL_CreateGPUTransferBuffer(
    device: ?*SDL_GPUDevice,
    createinfo: [*c]const SDL_GPUTransferBufferCreateInfo,
) ?*SDL_GPUTransferBuffer;

pub const SDL_PROP_GPU_TRANSFERBUFFER_CREATE_NAME_STRING = "SDL.gpu.transferbuffer.create.name";

/////////////////////////////
// Functions - Debug Naming
/////////////////////////////

/// Sets an arbitrary string constant to label a buffer.
///
/// You should use SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING with
/// SDL_CreateGPUBuffer instead of this function to avoid thread safety issues.
///
/// \param device a GPU Context.
/// \param buffer a buffer to attach the name to.
/// \param text a UTF-8 string constant to mark as the name of the buffer.
///
/// \threadsafety This function is not thread safe, you must make sure the
///               buffer is not simultaneously used by any other thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUBuffer
pub extern fn SDL_SetGPUBufferName(
    device: ?*SDL_GPUDevice,
    buffer: ?*SDL_GPUBuffer,
    text: [*c]const u8,
) void;

/// Sets an arbitrary string constant to label a texture.
///
/// You should use SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING with
/// SDL_CreateGPUTexture instead of this function to avoid thread safety
/// issues.
///
/// \param device a GPU Context.
/// \param texture a texture to attach the name to.
/// \param text a UTF-8 string constant to mark as the name of the texture.
///
/// \threadsafety This function is not thread safe, you must make sure the
///               texture is not simultaneously used by any other thread.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUTexture
pub extern fn SDL_SetGPUTextureName(
    device: ?*SDL_GPUDevice,
    texture: ?*SDL_GPUTexture,
    text: [*c]const u8,
) void;

/// Inserts an arbitrary string label into the command buffer callstream.
///
/// Useful for debugging.
///
/// On Direct3D 12, using SDL_InsertGPUDebugLabel requires
/// WinPixEventRuntime.dll to be in your PATH or in the same directory as your
/// executable. See
/// [here](https://devblogs.microsoft.com/pix/winpixeventruntime/)
/// for instructions on how to obtain it.
///
/// \param command_buffer a command buffer.
/// \param text a UTF-8 string constant to insert as the label.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_InsertGPUDebugLabel(
    command_buffer: ?*SDL_GPUCommandBuffer,
    text: [*c]const u8,
) void;

/// Begins a debug group with an arbitrary name.
///
/// Used for denoting groups of calls when viewing the command buffer
/// callstream in a graphics debugging tool.
///
/// Each call to SDL_PushGPUDebugGroup must have a corresponding call to
/// SDL_PopGPUDebugGroup.
///
/// On Direct3D 12, using SDL_PushGPUDebugGroup requires WinPixEventRuntime.dll
/// to be in your PATH or in the same directory as your executable. See
/// [here](https://devblogs.microsoft.com/pix/winpixeventruntime/)
/// for instructions on how to obtain it.
///
/// On some backends (e.g. Metal), pushing a debug group during a
/// render/blit/compute pass will create a group that is scoped to the native
/// pass rather than the command buffer. For best results, if you push a debug
/// group during a pass, always pop it in the same pass.
///
/// \param command_buffer a command buffer.
/// \param name a UTF-8 string constant that names the group.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PopGPUDebugGroup
pub extern fn SDL_PushGPUDebugGroup(
    command_buffer: ?*SDL_GPUCommandBuffer,
    name: [*c]const u8,
) void;

/// Ends the most-recently pushed debug group.
///
/// On Direct3D 12, using SDL_PopGPUDebugGroup requires WinPixEventRuntime.dll
/// to be in your PATH or in the same directory as your executable. See
/// [here](https://devblogs.microsoft.com/pix/winpixeventruntime/)
/// for instructions on how to obtain it.
///
/// \param command_buffer a command buffer.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_PushGPUDebugGroup
pub extern fn SDL_PopGPUDebugGroup(command_buffer: ?*SDL_GPUCommandBuffer) void;

/////////////////////////////
// Functions - Disposal
/////////////////////////////

/// Frees the given texture as soon as it is safe to do so.
///
/// You must not reference the texture after calling this function.
///
/// \param device a GPU context.
/// \param texture a texture to be destroyed.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_ReleaseGPUTexture(
    device: ?*SDL_GPUDevice,
    texture: ?*SDL_GPUTexture,
) void;

/// Frees the given sampler as soon as it is safe to do so.
///
/// You must not reference the sampler after calling this function.
///
/// \param device a GPU context.
/// \param sampler a sampler to be destroyed.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_ReleaseGPUSampler(
    device: ?*SDL_GPUDevice,
    sampler: ?*SDL_GPUSampler,
) void;

/// Frees the given buffer as soon as it is safe to do so.
///
/// You must not reference the buffer after calling this function.
///
/// \param device a GPU context.
/// \param buffer a buffer to be destroyed.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_ReleaseGPUBuffer(
    device: ?*SDL_GPUDevice,
    buffer: ?*SDL_GPUBuffer,
) void;

/// Frees the given transfer buffer as soon as it is safe to do so.
///
/// You must not reference the transfer buffer after calling this function.
///
/// \param device a GPU context.
/// \param transfer_buffer a transfer buffer to be destroyed.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_ReleaseGPUTransferBuffer(
    device: ?*SDL_GPUDevice,
    transfer_buffer: ?*SDL_GPUTransferBuffer,
) void;

/// Frees the given compute pipeline as soon as it is safe to do so.
///
/// You must not reference the compute pipeline after calling this function.
///
/// \param device a GPU context.
/// \param compute_pipeline a compute pipeline to be destroyed.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_ReleaseGPUComputePipeline(
    device: ?*SDL_GPUDevice,
    compute_pipeline: ?*SDL_GPUComputePipeline,
) void;

/// Frees the given shader as soon as it is safe to do so.
///
/// You must not reference the shader after calling this function.
///
/// \param device a GPU context.
/// \param shader a shader to be destroyed.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_ReleaseGPUShader(
    device: ?*SDL_GPUDevice,
    shader: ?*SDL_GPUShader,
) void;

/// Frees the given graphics pipeline as soon as it is safe to do so.
///
/// You must not reference the graphics pipeline after calling this function.
///
/// \param device a GPU context.
/// \param graphics_pipeline a graphics pipeline to be destroyed.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_ReleaseGPUGraphicsPipeline(
    device: ?*SDL_GPUDevice,
    graphics_pipeline: ?*SDL_GPUGraphicsPipeline,
) void;

/// Acquire a command buffer.
///
/// This command buffer is managed by the implementation and should not be
/// freed by the user. The command buffer may only be used on the thread it was
/// acquired on. The command buffer should be submitted on the thread it was
/// acquired on.
///
/// It is valid to acquire multiple command buffers on the same thread at once.
/// In fact a common design pattern is to acquire two command buffers per frame
/// where one is dedicated to render and compute passes and the other is
/// dedicated to copy passes and other preparatory work such as generating
/// mipmaps. Interleaving commands between the two command buffers reduces the
/// total amount of passes overall which improves rendering performance.
///
/// \param device a GPU context.
/// \returns a command buffer, or NULL on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SubmitGPUCommandBuffer
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
pub extern fn SDL_AcquireGPUCommandBuffer(device: ?*SDL_GPUDevice) ?*SDL_GPUCommandBuffer;

/////////////////////////////
// Functions - Uniform Data
/////////////////////////////

/// Pushes data to a vertex uniform slot on the command buffer.
///
/// Subsequent draw calls in this command buffer will use this uniform data.
///
/// The data being pushed must respect std140 layout conventions. In practical
/// terms this means you must ensure that vec3 and vec4 fields are 16-byte
/// aligned.
///
/// For detailed information about accessing uniform data from a shader, please
/// refer to SDL_CreateGPUShader.
///
/// \param command_buffer a command buffer.
/// \param slot_index the vertex uniform slot to push data to.
/// \param data client data to write.
/// \param length the length of the data to write.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_PushGPUVertexUniformData(
    command_buffer: ?*SDL_GPUCommandBuffer,
    slot_index: u32,
    data: ?*const anyopaque,
    length: u32,
) void;

/// Pushes data to a fragment uniform slot on the command buffer.
///
/// Subsequent draw calls in this command buffer will use this uniform data.
///
/// The data being pushed must respect std140 layout conventions. In practical
/// terms this means you must ensure that vec3 and vec4 fields are 16-byte
/// aligned.
///
/// \param command_buffer a command buffer.
/// \param slot_index the fragment uniform slot to push data to.
/// \param data client data to write.
/// \param length the length of the data to write.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_PushGPUFragmentUniformData(
    command_buffer: ?*SDL_GPUCommandBuffer,
    slot_index: u32,
    data: ?*const anyopaque,
    length: u32,
) void;

/// Pushes data to a uniform slot on the command buffer.
///
/// Subsequent draw calls in this command buffer will use this uniform data.
///
/// The data being pushed must respect std140 layout conventions. In practical
/// terms this means you must ensure that vec3 and vec4 fields are 16-byte
/// aligned.
///
/// \param command_buffer a command buffer.
/// \param slot_index the uniform slot to push data to.
/// \param data client data to write.
/// \param length the length of the data to write.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_PushGPUComputeUniformData(
    command_buffer: ?*SDL_GPUCommandBuffer,
    slot_index: u32,
    data: ?*const anyopaque,
    length: u32,
) void;

/////////////////////////////
// Functions - Graphics State
/////////////////////////////

/// Begins a render pass on a command buffer.
///
/// A render pass consists of a set of texture subresources (or depth slices in
/// the 3D texture case) which will be rendered to during the render pass,
/// along with corresponding clear values and load/store operations. All
/// operations related to graphics pipelines must take place inside of a render
/// pass. A default viewport and scissor state are automatically set when this
/// is called. You cannot begin another render pass, or begin a compute pass or
/// copy pass until you have ended the render pass.
///
/// Using SDL_GPU_LOADOP_LOAD before any contents have been written to the
/// texture subresource will result in undefined behavior. SDL_GPU_LOADOP_CLEAR
/// will set the contents of the texture subresource to a single value before
/// any rendering is performed. It's fine to do an empty render pass using
/// SDL_GPU_STOREOP_STORE to clear a texture, but in general it's better to
/// think of clearing not as an independent operation but as something that's
/// done as the beginning of a render pass.
///
/// \param command_buffer a command buffer.
/// \param color_target_infos an array of texture subresources with
///                           corresponding clear values and load/store ops.
/// \param num_color_targets the number of color targets in the
///                          color_target_infos array.
/// \param depth_stencil_target_info a texture subresource with corresponding
///                                  clear value and load/store ops, may be
///                                  NULL.
/// \returns a render pass handle.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_EndGPURenderPass
pub extern fn SDL_BeginGPURenderPass(
    command_buffer: ?*SDL_GPUCommandBuffer,
    color_target_infos: [*c]const SDL_GPUColorTargetInfo,
    num_color_targets: u32,
    depth_stencil_target_info: [*c]const SDL_GPUDepthStencilTargetInfo,
) ?*SDL_GPURenderPass;

/// Binds a graphics pipeline on a render pass to be used in rendering.
///
/// A graphics pipeline must be bound before making any draw calls.
///
/// \param render_pass a render pass handle.
/// \param graphics_pipeline the graphics pipeline to bind.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_BindGPUGraphicsPipeline(
    render_pass: ?*SDL_GPURenderPass,
    graphics_pipeline: ?*SDL_GPUGraphicsPipeline,
) void;

/// Sets the current viewport state on a command buffer.
///
/// \param render_pass a render pass handle.
/// \param viewport the viewport to set.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_SetGPUViewport(
    render_pass: ?*SDL_GPURenderPass,
    viewport: [*c]const SDL_GPUViewport,
) void;

/// Sets the current scissor state on a command buffer.
///
/// \param render_pass a render pass handle.
/// \param scissor the scissor area to set.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_SetGPUScissor(
    render_pass: ?*SDL_GPURenderPass,
    scissor: [*c]const rect.SDL_Rect,
) void;

/// Sets the current blend constants on a command buffer.
///
/// \param render_pass a render pass handle.
/// \param blend_constants the blend constant color.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_GPU_BLENDFACTOR_CONSTANT_COLOR
/// \sa SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR
pub extern fn SDL_SetGPUBlendConstants(
    render_pass: ?*SDL_GPURenderPass,
    blend_constants: pixels.SDL_FColor,
) void;

/// Sets the current stencil reference value on a command buffer.
///
/// \param render_pass a render pass handle.
/// \param reference the stencil reference value to set.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_SetGPUStencilReference(render_pass: ?*SDL_GPURenderPass, reference: u8) void;

/// Binds vertex buffers on a command buffer for use with subsequent draw
/// calls.
///
/// \param render_pass a render pass handle.
/// \param first_slot the vertex buffer slot to begin binding from.
/// \param bindings an array of SDL_GPUBufferBinding structs containing vertex
///                 buffers and offset values.
/// \param num_bindings the number of bindings in the bindings array.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_BindGPUVertexBuffers(
    render_pass: ?*SDL_GPURenderPass,
    first_slot: u32,
    bindings: [*c]const SDL_GPUBufferBinding,
    num_bindings: u32,
) void;

/// Binds an index buffer on a command buffer for use with subsequent draw
/// calls.
///
/// \param render_pass a render pass handle.
/// \param binding a pointer to a struct containing an index buffer and offset.
/// \param index_element_size whether the index values in the buffer are 16- or
///                           32-bit.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_BindGPUIndexBuffer(
    render_pass: ?*SDL_GPURenderPass,
    binding: [*c]const SDL_GPUBufferBinding,
    index_element_size: SDL_GPUIndexElementSize,
) void;

/// Binds texture-sampler pairs for use on the vertex shader.
///
/// The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUShader().
///
/// \param render_pass a render pass handle.
/// \param first_slot the vertex sampler slot to begin binding from.
/// \param texture_sampler_bindings an array of texture-sampler binding
///                                 structs.
/// \param num_bindings the number of texture-sampler pairs to bind from the
///                     array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub extern fn SDL_BindGPUVertexSamplers(
    render_pass: ?*SDL_GPURenderPass,
    first_slot: u32,
    texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding,
    num_bindings: u32,
) void;

/// Binds storage textures for use on the vertex shader.
///
/// These textures must have been created with
/// SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUShader().
///
/// \param render_pass a render pass handle.
/// \param first_slot the vertex storage texture slot to begin binding from.
/// \param storage_textures an array of storage textures.
/// \param num_bindings the number of storage texture to bind from the array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub extern fn SDL_BindGPUVertexStorageTextures(
    render_pass: ?*SDL_GPURenderPass,
    first_slot: u32,
    storage_textures: [*c]const ?*SDL_GPUTexture,
    num_bindings: u32,
) void;

/// Binds storage buffers for use on the vertex shader.
///
/// These buffers must have been created with
/// SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUShader().
///
/// \param render_pass a render pass handle.
/// \param first_slot the vertex storage buffer slot to begin binding from.
/// \param storage_buffers an array of buffers.
/// \param num_bindings the number of buffers to bind from the array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub extern fn SDL_BindGPUVertexStorageBuffers(
    render_pass: ?*SDL_GPURenderPass,
    first_slot: u32,
    storage_buffers: [*c]const ?*SDL_GPUBuffer,
    num_bindings: u32,
) void;

/// Binds texture-sampler pairs for use on the fragment shader.
///
/// The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUShader().
///
/// \param render_pass a render pass handle.
/// \param first_slot the fragment sampler slot to begin binding from.
/// \param texture_sampler_bindings an array of texture-sampler binding
///                                 structs.
/// \param num_bindings the number of texture-sampler pairs to bind from the
///                     array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub extern fn SDL_BindGPUFragmentSamplers(
    render_pass: ?*SDL_GPURenderPass,
    first_slot: u32,
    texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding,
    num_bindings: u32,
) void;

/// Binds storage textures for use on the fragment shader.
///
/// These textures must have been created with
/// SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUShader().
///
/// \param render_pass a render pass handle.
/// \param first_slot the fragment storage texture slot to begin binding from.
/// \param storage_textures an array of storage textures.
/// \param num_bindings the number of storage textures to bind from the array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub extern fn SDL_BindGPUFragmentStorageTextures(
    render_pass: ?*SDL_GPURenderPass,
    first_slot: u32,
    storage_textures: [*c]const ?*SDL_GPUTexture,
    num_bindings: u32,
) void;

/// Binds storage buffers for use on the fragment shader.
///
/// These buffers must have been created with
/// SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUShader().
///
/// \param render_pass a render pass handle.
/// \param first_slot the fragment storage buffer slot to begin binding from.
/// \param storage_buffers an array of storage buffers.
/// \param num_bindings the number of storage buffers to bind from the array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUShader
pub extern fn SDL_BindGPUFragmentStorageBuffers(
    render_pass: ?*SDL_GPURenderPass,
    first_slot: u32,
    storage_buffers: [*c]const ?*SDL_GPUBuffer,
    num_bindings: u32,
) void;

/////////////////////////////
// Functions - Drawing
/////////////////////////////

/// Draws data using bound graphics state with an index buffer and instancing
/// enabled.
///
/// You must not call this function before binding a graphics pipeline.
///
/// Note that the `first_vertex` and `first_instance` parameters are NOT
/// compatible with built-in vertex/instance ID variables in shaders (for
/// example, SV_VertexID); GPU APIs and shader languages do not define these
/// built-in variables consistently, so if your shader depends on them, the
/// only way to keep behavior consistent and portable is to always pass 0 for
/// the correlating parameter in the draw calls.
///
/// \param render_pass a render pass handle.
/// \param num_indices the number of indices to draw per instance.
/// \param num_instances the number of instances to draw.
/// \param first_index the starting index within the index buffer.
/// \param vertex_offset value added to vertex index before indexing into the
///                      vertex buffer.
/// \param first_instance the ID of the first instance to draw.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DrawGPUIndexedPrimitives(
    render_pass: ?*SDL_GPURenderPass,
    num_indices: u32,
    num_instances: u32,
    first_index: u32,
    vertex_offset: i32,
    first_instance: u32,
) void;

/// Draws data using bound graphics state.
///
/// You must not call this function before binding a graphics pipeline.
///
/// Note that the `first_vertex` and `first_instance` parameters are NOT
/// compatible with built-in vertex/instance ID variables in shaders (for
/// example, SV_VertexID); GPU APIs and shader languages do not define these
/// built-in variables consistently, so if your shader depends on them, the
/// only way to keep behavior consistent and portable is to always pass 0 for
/// the correlating parameter in the draw calls.
///
/// \param render_pass a render pass handle.
/// \param num_vertices the number of vertices to draw.
/// \param num_instances the number of instances that will be drawn.
/// \param first_vertex the index of the first vertex to draw.
/// \param first_instance the ID of the first instance to draw.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DrawGPUPrimitives(
    render_pass: ?*SDL_GPURenderPass,
    num_vertices: u32,
    num_instances: u32,
    first_vertex: u32,
    first_instance: u32,
) void;

/// Draws data using bound graphics state and with draw parameters set from a
/// buffer.
///
/// The buffer must consist of tightly-packed draw parameter sets that each
/// match the layout of SDL_GPUIndirectDrawCommand. You must not call this
/// function before binding a graphics pipeline.
///
/// \param render_pass a render pass handle.
/// \param buffer a buffer containing draw parameters.
/// \param offset the offset to start reading from the draw buffer.
/// \param draw_count the number of draw parameter sets that should be read
///                   from the draw buffer.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DrawGPUPrimitivesIndirect(
    render_pass: ?*SDL_GPURenderPass,
    buffer: ?*SDL_GPUBuffer,
    offset: u32,
    draw_count: u32,
) void;

/// Draws data using bound graphics state with an index buffer enabled and with
/// draw parameters set from a buffer.
///
/// The buffer must consist of tightly-packed draw parameter sets that each
/// match the layout of SDL_GPUIndexedIndirectDrawCommand. You must not call
/// this function before binding a graphics pipeline.
///
/// \param render_pass a render pass handle.
/// \param buffer a buffer containing draw parameters.
/// \param offset the offset to start reading from the draw buffer.
/// \param draw_count the number of draw parameter sets that should be read
///                   from the draw buffer.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DrawGPUIndexedPrimitivesIndirect(
    render_pass: ?*SDL_GPURenderPass,
    buffer: ?*SDL_GPUBuffer,
    offset: u32,
    draw_count: u32,
) void;

/// Ends the given render pass.
///
/// All bound graphics state on the render pass command buffer is unset. The
/// render pass handle is now invalid.
///
/// \param render_pass a render pass handle.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_EndGPURenderPass(render_pass: ?*SDL_GPURenderPass) void;

/////////////////////////////
// Functions - Compute Pass
/////////////////////////////

/// Begins a compute pass on a command buffer.
///
/// A compute pass is defined by a set of texture subresources and buffers that
/// may be written to by compute pipelines. These textures and buffers must
/// have been created with the COMPUTE_STORAGE_WRITE bit or the
/// COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE bit. If you do not create a texture
/// with COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE, you must not read from the
/// texture in the compute pass. All operations related to compute pipelines
/// must take place inside of a compute pass. You must not begin another
/// compute pass, or a render pass or copy pass before ending the compute pass.
///
/// A VERY IMPORTANT NOTE - Reads and writes in compute passes are NOT
/// implicitly synchronized. This means you may cause data races by both
/// reading and writing a resource region in a compute pass, or by writing
/// multiple times to a resource region. If your compute work depends on
/// reading the completed output from a previous dispatch, you MUST end the
/// current compute pass and begin a new one before you can safely access the
/// data. Otherwise you will receive unexpected results. Reading and writing a
/// texture in the same compute pass is only supported by specific texture
/// formats. Make sure you check the format support!
///
/// \param command_buffer a command buffer.
/// \param storage_texture_bindings an array of writeable storage texture
///                                 binding structs.
/// \param num_storage_texture_bindings the number of storage textures to bind
///                                     from the array.
/// \param storage_buffer_bindings an array of writeable storage buffer binding
///                                structs.
/// \param num_storage_buffer_bindings the number of storage buffers to bind
///                                    from the array.
/// \returns a compute pass handle.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_EndGPUComputePass
pub extern fn SDL_BeginGPUComputePass(
    command_buffer: ?*SDL_GPUCommandBuffer,
    storage_texture_bindings: [*c]const SDL_GPUStorageTextureReadWriteBinding,
    num_storage_texture_bindings: u32,
    storage_buffer_bindings: [*c]const SDL_GPUStorageBufferReadWriteBinding,
    num_storage_buffer_bindings: u32,
) ?*SDL_GPUComputePass;

/// Binds a compute pipeline on a command buffer for use in compute dispatch.
///
/// \param compute_pass a compute pass handle.
/// \param compute_pipeline a compute pipeline to bind.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_BindGPUComputePipeline(
    compute_pass: ?*SDL_GPUComputePass,
    compute_pipeline: ?*SDL_GPUComputePipeline,
) void;

/// Binds texture-sampler pairs for use on the compute shader.
///
/// The textures must have been created with SDL_GPU_TEXTUREUSAGE_SAMPLER.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUComputePipeline().
///
/// \param compute_pass a compute pass handle.
/// \param first_slot the compute sampler slot to begin binding from.
/// \param texture_sampler_bindings an array of texture-sampler binding
///                                 structs.
/// \param num_bindings the number of texture-sampler bindings to bind from the
///                     array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUComputePipeline
pub extern fn SDL_BindGPUComputeSamplers(
    compute_pass: ?*SDL_GPUComputePass,
    first_slot: u32,
    texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding,
    num_bindings: u32,
) void;

/// Binds storage textures as readonly for use on the compute pipeline.
///
/// These textures must have been created with
/// SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUComputePipeline().
///
/// \param compute_pass a compute pass handle.
/// \param first_slot the compute storage texture slot to begin binding from.
/// \param storage_textures an array of storage textures.
/// \param num_bindings the number of storage textures to bind from the array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUComputePipeline
pub extern fn SDL_BindGPUComputeStorageTextures(
    compute_pass: ?*SDL_GPUComputePass,
    first_slot: u32,
    storage_textures: [*c]const ?*SDL_GPUTexture,
    num_bindings: u32,
) void;

/// Binds storage buffers as readonly for use on the compute pipeline.
///
/// These buffers must have been created with
/// SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ.
///
/// Be sure your shader is set up according to the requirements documented in
/// SDL_CreateGPUComputePipeline().
///
/// \param compute_pass a compute pass handle.
/// \param first_slot the compute storage buffer slot to begin binding from.
/// \param storage_buffers an array of storage buffer binding structs.
/// \param num_bindings the number of storage buffers to bind from the array.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_CreateGPUComputePipeline
pub extern fn SDL_BindGPUComputeStorageBuffers(
    compute_pass: ?*SDL_GPUComputePass,
    first_slot: u32,
    storage_buffers: [*c]const ?*SDL_GPUBuffer,
    num_bindings: u32,
) void;

/// Dispatches compute work.
///
/// You must not call this function before binding a compute pipeline.
///
/// A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
/// the dispatches write to the same resource region as each other, there is no
/// guarantee of which order the writes will occur. If the write order matters,
/// you MUST end the compute pass and begin another one.
///
/// \param compute_pass a compute pass handle.
/// \param groupcount_x number of local workgroups to dispatch in the X
///                     dimension.
/// \param groupcount_y number of local workgroups to dispatch in the Y
///                     dimension.
/// \param groupcount_z number of local workgroups to dispatch in the Z
///                     dimension.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DispatchGPUCompute(
    compute_pass: ?*SDL_GPUComputePass,
    groupcount_x: u32,
    groupcount_y: u32,
    groupcount_z: u32,
) void;

/// Dispatches compute work with parameters set from a buffer.
///
/// The buffer layout should match the layout of
/// SDL_GPUIndirectDispatchCommand. You must not call this function before
/// binding a compute pipeline.
///
/// A VERY IMPORTANT NOTE If you dispatch multiple times in a compute pass, and
/// the dispatches write to the same resource region as each other, there is no
/// guarantee of which order the writes will occur. If the write order matters,
/// you MUST end the compute pass and begin another one.
///
/// \param compute_pass a compute pass handle.
/// \param buffer a buffer containing dispatch parameters.
/// \param offset the offset to start reading from the dispatch buffer.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DispatchGPUComputeIndirect(
    compute_pass: ?*SDL_GPUComputePass,
    buffer: ?*SDL_GPUBuffer,
    offset: u32,
) void;

/// Ends the current compute pass.
///
/// All bound compute state on the command buffer is unset. The compute pass
/// handle is now invalid.
///
/// \param compute_pass a compute pass handle.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_EndGPUComputePass(compute_pass: ?*SDL_GPUComputePass) void;

/////////////////////////////
// Functions - TransferBuffer Data
/////////////////////////////

/// Maps a transfer buffer into application address space.
///
/// You must unmap the transfer buffer before encoding upload commands. The
/// memory is owned by the graphics driver - do NOT call SDL_free() on the
/// returned pointer.
///
/// \param device a GPU context.
/// \param transfer_buffer a transfer buffer.
/// \param cycle if true, cycles the transfer buffer if it is already bound.
/// \returns the address of the mapped transfer buffer memory, or NULL on
///          failure; call SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_MapGPUTransferBuffer(
    device: ?*SDL_GPUDevice,
    transfer_buffer: ?*SDL_GPUTransferBuffer,
    cycle: bool,
) ?*anyopaque;

/// Unmaps a previously mapped transfer buffer.
///
/// \param device a GPU context.
/// \param transfer_buffer a previously mapped transfer buffer.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_UnmapGPUTransferBuffer(
    device: ?*SDL_GPUDevice,
    transfer_buffer: ?*SDL_GPUTransferBuffer,
) void;

/////////////////////////////
// Functions - Copy Pass
/////////////////////////////

/// Begins a copy pass on a command buffer.
///
/// All operations related to copying to or from buffers or textures take place
/// inside a copy pass. You must not begin another copy pass, or a render pass
/// or compute pass before ending the copy pass.
///
/// \param command_buffer a command buffer.
/// \returns a copy pass handle.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_EndGPUCopyPass
pub extern fn SDL_BeginGPUCopyPass(command_buffer: ?*SDL_GPUCommandBuffer) ?*SDL_GPUCopyPass;

/// Uploads data from a transfer buffer to a texture.
///
/// The upload occurs on the GPU timeline. You may assume that the upload has
/// finished in subsequent commands.
///
/// You must align the data in the transfer buffer to a multiple of the texel
/// size of the texture format.
///
/// \param copy_pass a copy pass handle.
/// \param source the source transfer buffer with image layout information.
/// \param destination the destination texture region.
/// \param cycle if true, cycles the texture if the texture is bound, otherwise
///              overwrites the data.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_UploadToGPUTexture(
    copy_pass: ?*SDL_GPUCopyPass,
    source: [*c]const SDL_GPUTextureTransferInfo,
    destination: [*c]const SDL_GPUTextureRegion,
    cycle: bool,
) void;

/// Uploads data from a transfer buffer to a buffer.
///
/// The upload occurs on the GPU timeline. You may assume that the upload has
/// finished in subsequent commands.
///
/// \param copy_pass a copy pass handle.
/// \param source the source transfer buffer with offset.
/// \param destination the destination buffer with offset and size.
/// \param cycle if true, cycles the buffer if it is already bound, otherwise
///              overwrites the data.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_UploadToGPUBuffer(
    copy_pass: ?*SDL_GPUCopyPass,
    source: [*c]const SDL_GPUTransferBufferLocation,
    destination: [*c]const SDL_GPUBufferRegion,
    cycle: bool,
) void;

/// Performs a texture-to-texture copy.
///
/// This copy occurs on the GPU timeline. You may assume the copy has finished
/// in subsequent commands.
///
/// This function does not support copying between depth and color textures.
/// For those, copy the texture to a buffer and then to the destination
/// texture.
///
/// \param copy_pass a copy pass handle.
/// \param source a source texture region.
/// \param destination a destination texture region.
/// \param w the width of the region to copy.
/// \param h the height of the region to copy.
/// \param d the depth of the region to copy.
/// \param cycle if true, cycles the destination texture if the destination
///              texture is bound, otherwise overwrites the data.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_CopyGPUTextureToTexture(
    copy_pass: ?*SDL_GPUCopyPass,
    source: [*c]const SDL_GPUTextureLocation,
    destination: [*c]const SDL_GPUTextureLocation,
    w: u32,
    h: u32,
    d: u32,
    cycle: bool,
) void;

/// Performs a buffer-to-buffer copy.
///
/// This copy occurs on the GPU timeline. You may assume the copy has finished
/// in subsequent commands.
///
/// \param copy_pass a copy pass handle.
/// \param source the buffer and offset to copy from.
/// \param destination the buffer and offset to copy to.
/// \param size the length of the buffer to copy.
/// \param cycle if true, cycles the destination buffer if it is already bound,
///              otherwise overwrites the data.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_CopyGPUBufferToBuffer(
    copy_pass: ?*SDL_GPUCopyPass,
    source: [*c]const SDL_GPUBufferLocation,
    destination: [*c]const SDL_GPUBufferLocation,
    size: u32,
    cycle: bool,
) void;

/// Copies data from a texture to a transfer buffer on the GPU timeline.
///
/// This data is not guaranteed to be copied until the command buffer fence is
/// signaled.
///
/// \param copy_pass a copy pass handle.
/// \param source the source texture region.
/// \param destination the destination transfer buffer with image layout
///                    information.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DownloadFromGPUTexture(
    copy_pass: ?*SDL_GPUCopyPass,
    source: [*c]const SDL_GPUTextureRegion,
    destination: [*c]const SDL_GPUTextureTransferInfo,
) void;

/// Copies data from a buffer to a transfer buffer on the GPU timeline.
///
/// This data is not guaranteed to be copied until the command buffer fence is
/// signaled.
///
/// \param copy_pass a copy pass handle.
/// \param source the source buffer with offset and size.
/// \param destination the destination transfer buffer with offset.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_DownloadFromGPUBuffer(
    copy_pass: ?*SDL_GPUCopyPass,
    source: [*c]const SDL_GPUBufferRegion,
    destination: [*c]const SDL_GPUTransferBufferLocation,
) void;

/// Ends the current copy pass.
///
/// \param copy_pass a copy pass handle.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_EndGPUCopyPass(copy_pass: ?*SDL_GPUCopyPass) void;

/// Generates mipmaps for the given texture.
///
/// This function must not be called inside of any pass.
///
/// \param command_buffer a command_buffer.
/// \param texture a texture with more than 1 mip level.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GenerateMipmapsForGPUTexture(
    command_buffer: ?*SDL_GPUCommandBuffer,
    texture: ?*SDL_GPUTexture,
) void;

/// Blits from a source texture region to a destination texture region.
///
/// This function must not be called inside of any pass.
///
/// \param command_buffer a command buffer.
/// \param info the blit info struct containing the blit parameters.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_BlitGPUTexture(
    command_buffer: ?*SDL_GPUCommandBuffer,
    info: [*c]const SDL_GPUBlitInfo,
) void;

/////////////////////////////
// Functions - Submission/Presentation
/////////////////////////////

/// Determines whether a swapchain composition is supported by the window.
///
/// The window must be claimed before calling this function.
///
/// \param device a GPU context.
/// \param window an SDL_Window.
/// \param swapchain_composition the swapchain composition to check.
/// \returns true if supported, false if unsupported.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_ClaimWindowForGPUDevice
pub extern fn SDL_WindowSupportsGPUSwapchainComposition(
    device: ?*SDL_GPUDevice,
    window: ?*video.SDL_Window,
    swapchain_composition: SDL_GPUSwapchainComposition,
) bool;

/// Determines whether a presentation mode is supported by the window.
///
/// The window must be claimed before calling this function.
///
/// \param device a GPU context.
/// \param window an SDL_Window.
/// \param present_mode the presentation mode to check.
/// \returns true if supported, false if unsupported.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_ClaimWindowForGPUDevice
pub extern fn SDL_WindowSupportsGPUPresentMode(
    device: ?*SDL_GPUDevice,
    window: ?*video.SDL_Window,
    present_mode: SDL_GPUPresentMode,
) bool;

/// Claims a window, creating a swapchain structure for it.
///
/// This must be called before SDL_AcquireGPUSwapchainTexture is called using
/// the window. You should only call this function from the thread that created
/// the window.
///
/// The swapchain will be created with SDL_GPU_SWAPCHAINCOMPOSITION_SDR and
/// SDL_GPU_PRESENTMODE_VSYNC. If you want to have different swapchain
/// parameters, you must call SDL_SetGPUSwapchainParameters after claiming the
/// window.
///
/// \param device a GPU context.
/// \param window an SDL_Window.
/// \returns true on success, or false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should only be called from the thread that
///               created the window.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
/// \sa SDL_ReleaseWindowFromGPUDevice
/// \sa SDL_WindowSupportsGPUPresentMode
/// \sa SDL_WindowSupportsGPUSwapchainComposition
pub extern fn SDL_ClaimWindowForGPUDevice(
    device: ?*SDL_GPUDevice,
    window: ?*video.SDL_Window,
) bool;

/// Unclaims a window, destroying its swapchain structure.
///
/// \param device a GPU context.
/// \param window an SDL_Window that has been claimed.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_ClaimWindowForGPUDevice
pub extern fn SDL_ReleaseWindowFromGPUDevice(
    device: ?*SDL_GPUDevice,
    window: ?*video.SDL_Window,
) void;

/// Changes the swapchain parameters for the given claimed window.
///
/// This function will fail if the requested present mode or swapchain
/// composition are unsupported by the device. Check if the parameters are
/// supported via SDL_WindowSupportsGPUPresentMode /
/// SDL_WindowSupportsGPUSwapchainComposition prior to calling this function.
///
/// SDL_GPU_PRESENTMODE_VSYNC with SDL_GPU_SWAPCHAINCOMPOSITION_SDR is always
/// supported.
///
/// \param device a GPU context.
/// \param window an SDL_Window that has been claimed.
/// \param swapchain_composition the desired composition of the swapchain.
/// \param present_mode the desired present mode for the swapchain.
/// \returns true if successful, false on error; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_WindowSupportsGPUPresentMode
/// \sa SDL_WindowSupportsGPUSwapchainComposition
pub extern fn SDL_SetGPUSwapchainParameters(
    device: ?*SDL_GPUDevice,
    window: ?*video.SDL_Window,
    swapchain_composition: SDL_GPUSwapchainComposition,
    present_mode: SDL_GPUPresentMode,
) bool;

/// Configures the maximum allowed number of frames in flight.
///
/// The default value when the device is created is 2. This means that after
/// you have submitted 2 frames for presentation, if the GPU has not finished
/// working on the first frame, SDL_AcquireGPUSwapchainTexture() will fill the
/// swapchain texture pointer with NULL, and
/// SDL_WaitAndAcquireGPUSwapchainTexture() will block.
///
/// Higher values increase throughput at the expense of visual latency. Lower
/// values decrease visual latency at the expense of throughput.
///
/// Note that calling this function will stall and flush the command queue to
/// prevent synchronization issues.
///
/// The minimum value of allowed frames in flight is 1, and the maximum is 3.
///
/// \param device a GPU context.
/// \param allowed_frames_in_flight the maximum number of frames that can be
///                                 pending on the GPU.
/// \returns true if successful, false on error; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_SetGPUAllowedFramesInFlight(
    device: ?*SDL_GPUDevice,
    allowed_frames_in_flight: u32,
) bool;

/// Obtains the texture format of the swapchain for the given window.
///
/// Note that this format can change if the swapchain parameters change.
///
/// \param device a GPU context.
/// \param window an SDL_Window that has been claimed.
/// \returns the texture format of the swapchain.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GetGPUSwapchainTextureFormat(
    device: ?*SDL_GPUDevice,
    window: ?*video.SDL_Window,
) SDL_GPUTextureFormat;

/// Acquire a texture to use in presentation.
///
/// When a swapchain texture is acquired on a command buffer, it will
/// automatically be submitted for presentation when the command buffer is
/// submitted. The swapchain texture should only be referenced by the command
/// buffer used to acquire it.
///
/// This function will fill the swapchain texture handle with NULL if too many
/// frames are in flight. This is not an error. This NULL pointer should not be
/// passed back into SDL. Instead, it should be considered as an indication to
/// wait until the swapchain is available.
///
/// If you use this function, it is possible to create a situation where many
/// command buffers are allocated while the rendering context waits for the GPU
/// to catch up, which will cause memory usage to grow. You should use
/// SDL_WaitAndAcquireGPUSwapchainTexture() unless you know what you are doing
/// with timing.
///
/// The swapchain texture is managed by the implementation and must not be
/// freed by the user. You MUST NOT call this function from any thread other
/// than the one that created the window.
///
/// \param command_buffer a command buffer.
/// \param window a window that has been claimed.
/// \param swapchain_texture a pointer filled in with a swapchain texture
///                          handle.
/// \param swapchain_texture_width a pointer filled in with the swapchain
///                                texture width, may be NULL.
/// \param swapchain_texture_height a pointer filled in with the swapchain
///                                 texture height, may be NULL.
/// \returns true on success, false on error; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should only be called from the thread that
///               created the window.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_ClaimWindowForGPUDevice
/// \sa SDL_SubmitGPUCommandBuffer
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
/// \sa SDL_CancelGPUCommandBuffer
/// \sa SDL_GetWindowSizeInPixels
/// \sa SDL_WaitForGPUSwapchain
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
/// \sa SDL_SetGPUAllowedFramesInFlight
pub extern fn SDL_AcquireGPUSwapchainTexture(
    command_buffer: ?*SDL_GPUCommandBuffer,
    window: ?*video.SDL_Window,
    swapchain_texture: [*c]?*SDL_GPUTexture,
    swapchain_texture_width: [*c]u32,
    swapchain_texture_height: [*c]u32,
) bool;

/// Blocks the thread until a swapchain texture is available to be acquired.
///
/// \param device a GPU context.
/// \param window a window that has been claimed.
/// \returns true on success, false on failure; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should only be called from the thread that
///               created the window.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_AcquireGPUSwapchainTexture
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
/// \sa SDL_SetGPUAllowedFramesInFlight
pub extern fn SDL_WaitForGPUSwapchain(
    device: ?*SDL_GPUDevice,
    window: ?*video.SDL_Window,
) bool;

/// Blocks the thread until a swapchain texture is available to be acquired,
/// and then acquires it.
///
/// When a swapchain texture is acquired on a command buffer, it will
/// automatically be submitted for presentation when the command buffer is
/// submitted. The swapchain texture should only be referenced by the command
/// buffer used to acquire it. It is an error to call
/// SDL_CancelGPUCommandBuffer() after a swapchain texture is acquired.
///
/// This function can fill the swapchain texture handle with NULL in certain
/// cases, for example if the window is minimized. This is not an error. You
/// should always make sure to check whether the pointer is NULL before
/// actually using it.
///
/// The swapchain texture is managed by the implementation and must not be
/// freed by the user. You MUST NOT call this function from any thread other
/// than the one that created the window.
///
/// The swapchain texture is write-only and cannot be used as a sampler or for
/// another reading operation.
///
/// \param command_buffer a command buffer.
/// \param window a window that has been claimed.
/// \param swapchain_texture a pointer filled in with a swapchain texture
///                          handle.
/// \param swapchain_texture_width a pointer filled in with the swapchain
///                                texture width, may be NULL.
/// \param swapchain_texture_height a pointer filled in with the swapchain
///                                 texture height, may be NULL.
/// \returns true on success, false on error; call SDL_GetError() for more
///          information.
///
/// \threadsafety This function should only be called from the thread that
///               created the window.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SubmitGPUCommandBuffer
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
/// \sa SDL_AcquireGPUSwapchainTexture
pub extern fn SDL_WaitAndAcquireGPUSwapchainTexture(
    command_buffer: ?*SDL_GPUCommandBuffer,
    window: ?*video.SDL_Window,
    swapchain_texture: [*c]?*SDL_GPUTexture,
    swapchain_texture_width: [*c]u32,
    swapchain_texture_height: [*c]u32,
) bool;

/// Submits a command buffer so its commands can be processed on the GPU.
///
/// It is invalid to use the command buffer after this is called.
///
/// This must be called from the thread the command buffer was acquired on.
///
/// All commands in the submission are guaranteed to begin executing before any
/// command in a subsequent submission begins executing.
///
/// \param command_buffer a command buffer.
/// \returns true on success, false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_AcquireGPUCommandBuffer
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
/// \sa SDL_AcquireGPUSwapchainTexture
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
pub extern fn SDL_SubmitGPUCommandBuffer(command_buffer: ?*SDL_GPUCommandBuffer) bool;

/// Submits a command buffer so its commands can be processed on the GPU, and
/// acquires a fence associated with the command buffer.
///
/// You must release this fence when it is no longer needed or it will cause a
/// leak. It is invalid to use the command buffer after this is called.
///
/// This must be called from the thread the command buffer was acquired on.
///
/// All commands in the submission are guaranteed to begin executing before any
/// command in a subsequent submission begins executing.
///
/// \param command_buffer a command buffer.
/// \returns a fence associated with the command buffer, or NULL on failure;
///          call SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_AcquireGPUCommandBuffer
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
/// \sa SDL_AcquireGPUSwapchainTexture
/// \sa SDL_SubmitGPUCommandBuffer
/// \sa SDL_ReleaseGPUFence
pub extern fn SDL_SubmitGPUCommandBufferAndAcquireFence(
    command_buffer: ?*SDL_GPUCommandBuffer,
) ?*SDL_GPUFence;

/// Cancels a command buffer.
///
/// None of the enqueued commands are executed.
///
/// It is an error to call this function after a swapchain texture has been
/// acquired.
///
/// This must be called from the thread the command buffer was acquired on.
///
/// You must not reference the command buffer after calling this function.
///
/// \param command_buffer a command buffer.
/// \returns true on success, false on error; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_WaitAndAcquireGPUSwapchainTexture
/// \sa SDL_AcquireGPUCommandBuffer
/// \sa SDL_AcquireGPUSwapchainTexture
pub extern fn SDL_CancelGPUCommandBuffer(command_buffer: ?*SDL_GPUCommandBuffer) bool;

/// Blocks the thread until the GPU is completely idle.
///
/// \param device a GPU context.
/// \returns true on success, false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_WaitForGPUFences
pub extern fn SDL_WaitForGPUIdle(device: ?*SDL_GPUDevice) bool;

/// Blocks the thread until the given fences are signaled.
///
/// \param device a GPU context.
/// \param wait_all if 0, wait for any fence to be signaled, if 1, wait for all
///                 fences to be signaled.
/// \param fences an array of fences to wait on.
/// \param num_fences the number of fences in the fences array.
/// \returns true on success, false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
/// \sa SDL_WaitForGPUIdle
pub extern fn SDL_WaitForGPUFences(
    device: ?*SDL_GPUDevice,
    wait_all: bool,
    fences: [*c]const ?*SDL_GPUFence,
    num_fences: u32,
) bool;

/// Checks the status of a fence.
///
/// \param device a GPU context.
/// \param fence a fence.
/// \returns true if the fence is signaled, false if it is not.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
pub extern fn SDL_QueryGPUFence(device: ?*SDL_GPUDevice, fence: ?*SDL_GPUFence) bool;

/// Releases a fence obtained from SDL_SubmitGPUCommandBufferAndAcquireFence.
///
/// You must not reference the fence after calling this function.
///
/// \param device a GPU context.
/// \param fence a fence.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_SubmitGPUCommandBufferAndAcquireFence
pub extern fn SDL_ReleaseGPUFence(device: ?*SDL_GPUDevice, fence: ?*SDL_GPUFence) void;

/////////////////////////////
// Functions - Format Info
/////////////////////////////

/// Obtains the texel block size for a texture format.
///
/// \param format the texture format you want to know the texel size of.
/// \returns the texel block size of the texture format.
///
/// \since This function is available since SDL 3.2.0.
///
/// \sa SDL_UploadToGPUTexture
pub extern fn SDL_GPUTextureFormatTexelBlockSize(format: SDL_GPUTextureFormat) u32;

/// Determines whether a texture format is supported for a given type and
/// usage.
///
/// \param device a GPU context.
/// \param format the texture format to check.
/// \param type the type of texture (2D, 3D, Cube).
/// \param usage a bitmask of all usage scenarios to check.
/// \returns whether the texture format is supported for this type and usage.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GPUTextureSupportsFormat(
    device: ?*SDL_GPUDevice,
    format: SDL_GPUTextureFormat,
    @"type": SDL_GPUTextureType,
    usage: SDL_GPUTextureUsageFlags,
) bool;

/// Determines if a sample count for a texture format is supported.
///
/// \param device a GPU context.
/// \param format the texture format to check.
/// \param sample_count the sample count to check.
/// \returns whether the sample count is supported for this texture format.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_GPUTextureSupportsSampleCount(
    device: ?*SDL_GPUDevice,
    format: SDL_GPUTextureFormat,
    sample_count: SDL_GPUSampleCount,
) bool;

/// Calculate the size in bytes of a texture format with dimensions.
///
/// \param format a texture format.
/// \param width width in pixels.
/// \param height height in pixels.
/// \param depth_or_layer_count depth for 3D textures or layer count otherwise.
/// \returns the size of a texture with this format and dimensions.
///
/// \since This function is available since SDL 3.2.0.
pub extern fn SDL_CalculateGPUTextureFormatSize(
    format: SDL_GPUTextureFormat,
    width: u32,
    height: u32,
    depth_or_layer_count: u32,
) u32;

/// Get the SDL pixel format corresponding to a GPU texture format.
///
/// \param format a texture format.
/// \returns the corresponding pixel format, or SDL_PIXELFORMAT_UNKNOWN if
///          there is no corresponding pixel format.
///
/// \since This function is available since SDL 3.4.0.
pub extern fn SDL_GetPixelFormatFromGPUTextureFormat(
    format: SDL_GPUTextureFormat,
) pixels.SDL_PixelFormat;

// Get the GPU texture format corresponding to an SDL pixel format.
//
// \param format a pixel format.
// \returns the corresponding GPU texture format, or
//          SDL_GPU_TEXTUREFORMAT_INVALID if there is no corresponding GPU
//          texture format.
//
// \since This function is available since SDL 3.4.0.
pub extern fn SDL_GetGPUTextureFormatFromPixelFormat(
    format: pixels.SDL_PixelFormat,
) SDL_GPUTextureFormat;
