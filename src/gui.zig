const print = @import("std").debug.print;

const sdl = @cImport ({
	@cInclude("SDL2/SDL.h");
});

// const gl = @cImport ({
    // @cInclude("../lib/glad/include/glad/glad.h");
    // @cInclude("main.zig");
    //@cInclude("../lib/glad/src/glad.c");
// });

const gl = @import("glad.zig");

pub fn init_gui() !void {
	const sdl_init = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
	if(sdl_init < 0) {
		// print("Error initializing SDL2: {s}", .{sdl.SDL_GetError()});
	}
}

pub fn quit_gui() void {
    _ = sdl.SDL_Quit();
}


pub const Window = struct {
    width: u64,
    height: u64,
    handle: *sdl.SDL_Window,
    gl_context: *c_void,

    pub fn create(title: [*c] const u8, width: u64, height: u64, ) !Window {
	    const window = sdl.SDL_CreateWindow(title, 
            sdl.SDL_WINDOWPOS_CENTERED, 
            sdl.SDL_WINDOWPOS_CENTERED,  
            @intCast(i32, width), 
            @intCast(i32, height), 
            sdl.SDL_WINDOW_OPENGL) orelse return error.Error;

        const gl_ctx = sdl.SDL_GL_CreateContext(window) orelse return error.Error;
        print("{}\n", .{@TypeOf(gl_ctx)});

        _ = gl.gladLoadGLLoader(sdl.SDL_GL_GetProcAddress);


        return Window{.width = width, .height = height, .handle = window, .gl_context = gl_ctx};
    }

    pub fn swap(self: *const Window) void {
        sdl.SDL_GL_SwapWindow(self.handle);
    }

    pub fn clearColor(r: f32, g: f32, b: f32, a: f32) void {
        gl.glClearColor(r, g, b, a);
    }

    pub fn clear() void {
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
    }

    pub fn show(self: *const Window) void {
        sdl.SDL_ShowWindow(self.handle);
    }

    pub fn hide(self: *const Window) void {
        sdl.SDL_HideWindow(self.handle);
    }
};


