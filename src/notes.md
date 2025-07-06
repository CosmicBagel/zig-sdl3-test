Exploratory proj to test the viability of replacing Raylib rendering with
SDL3 GPU api

note: @cimport and @cinclude will be deprecated in favour of c-translate
library that extends the build system, this way the c-translate can be
developed and released independently of the compiler
https://github.com/ziglang/zig/issues/20630
https://github.com/ziglang/translate-c
at some point I'll have to change this over, I suspect @cimport and @cinclude

note: currently using https://github.com/castholm/SDL/
a port of SDL to the zig build system, should be a reasonably stable
approach.
alternative library:
https://github.com/ikskuh/SDL.zig to work
SDL is looking at generating API bindings which would allow ikskuh's library
to progress in development for sdl3.
see: https://github.com/libsdl-org/SDL/issues/6337
Once this library was working, it may be preferable to the build system
port, or used in conjunction with build system port

todo: reads
- DONE https://moonside.games/posts/introducing-sdl-shadercross/
- DONE https://hamdy-elzanqali.medium.com/let-there-be-triangles-sdl-gpu-edition-bd82cf2ef615
- https://moonside.games/posts/sdl-gpu-sprite-batcher/
- https://moonside.games/posts/sdl-gpu-concepts-cycling/
- https://examples.libsdl.org/SDL3/
- https://github.com/TheSpydog/SDL_gpu_examples

note: high-level goal: render sprites efficiently cross-platform (replace raylib rendering)
should reduce overhead, improve software longevity (raylib is currently on
opengl, which is losing platform support), and opens up avenues to move into
3d rendering using modern graphics pipelines and command buffers

todo: tasks
- error helper functions
  - DONE turn sdl errors into zig errors
  - misc sdl error check func
- clearing screen with gpu api, rendering api calls removed
- triangle (HUGE WIN IF DO!)
  - setup gpu debugging for macos
  - graphics pipeline
    - rewrite example glsl shaders as shader-lang (aka slang: basically hlsl with some extra bits)
    - gpu vertex shader (metal bytecode from slang)
    - gpu frag shader (metal bytecode from slang)
  - upload verts
  - render pass
    - upload uniforms (or potentially storage buffers)
      - time
- quad (just need sprites for now)
- can move quad with wasd (uniform upload or storage buffer)
- many sprites, resize, scaling, rotation
- dynamically link sdl3 lib
- cross-platform shaders using slang or SDL_shadercross
  - slang is a c++ lib, so working with it will be tricky
  - SDL_shadercross might be easier to integrate, but limited to HLSL, no shader-lang

todo: cross-platform checklist
- dynamically compiling shaders per-platform
- cross-compilation via zig from macos or linux (arm and x64, many OSes)
- windows (x64) 11 via dx12
- raspberry pi 4 (arm) via vulkan and spir-v
- steamdeck (x64) via vulkan and spir-v
- macos (arm) via metal and msl
- bonus: android - pixel 7a

todo: bonus
- imgui (via cimgui) or another immediate mode UI lib
- hot-reload ui (imgui) -> reload on dll/so/dylib file change
- hot-reload shaders (using slang)
- scene / transform tree
- edit scene from ui
- marshal scene data in/out as json
- edit scene via object select
- blender file direct loading
- blender file hot-reloading
- psd file direct loading as texture
- psd file hot-reloading
- various image file loading
