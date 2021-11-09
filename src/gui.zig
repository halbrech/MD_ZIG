const print = @import("std").debug.print;
const p = @import("Particle.zig");
const std = @import("std");
const sphere = @import("sphere.zig");
const sdl = @cImport ({
	@cInclude("SDL2/SDL.h");
});

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

fn glDebugMessageCallback(source: c_uint, msg_type: c_uint, id: c_uint, severity: c_uint, length: c_int, msg: [*c]const u8, data: ?*const c_void) callconv(.C) void {
    print("GL: type: {}, id: {}, source: {}, severity: {}, msg: {s}", .{msg_type, id, source, severity, msg});
    _ = data;
    _ = length;
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

        gl.glEnable(gl.GL_DEBUG_OUTPUT);
        gl.glDebugMessageCallback(glDebugMessageCallback, null); 

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


pub const Mesh = struct {
    VAO: u32,
    VBO: u32,
    EBO: u32,

    shader: u32,
    model: Mat4,
    size: usize,

    pub fn create(v: [] sphere.Vertex, i: [] sphere.Triangle, shader: u32, model: Mat4) Mesh {
        _ = model;
        _ = shader;
        var vao: u32 = undefined;
        gl.glGenVertexArrays(1, &vao);
        gl.glBindVertexArray(vao);
        var vbo: u32 = undefined;
        var ebo: u32 = undefined;
        gl.glGenBuffers(2, &[_] u32 {vbo, ebo});
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
        gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ebo);
        gl.glBufferData(gl.GL_ARRAY_BUFFER, @intCast(c_long, v.len * @sizeOf(sphere.Vertex)), &(v[0]), gl.GL_STATIC_DRAW);
        gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, @intCast(c_long, i.len * @sizeOf(sphere.Triangle)), &(i[0]), gl.GL_STATIC_DRAW);

        gl.glEnableVertexAttribArray(0);
        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 0, null);
        gl.glEnableVertexAttribArray(1);
        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 0, null);
    
    
        gl.glBindVertexArray(0);
        return Mesh{.VAO = vao, .VBO = vbo, .EBO = ebo, .shader = shader, .model = model, .size = v.len};
    }


    pub fn draw(self: *const Mesh) void {
        gl.glUseProgram(self.shader);
        gl.glUniformMatrix4fv(0, 1, gl.GL_FALSE, &self.model.a[0]);
        gl.glBindVertexArray(self.VAO);
        gl.glDrawElements(gl.GL_TRIANGLES, 0, @intCast(c_uint, self.size), null);
    } 
};

pub const Mat4 = struct {
    a: [16] f32,

    pub fn zeros() Mat4 {
        return Mat4{
            .a = [16]f32 {
                0.0, 0.0, 0.0, 0.0, 
                0.0, 0.0, 0.0, 0.0, 
                0.0, 0.0, 0.0, 0.0, 
                0.0, 0.0, 0.0, 0.0,
            },
        };
    }    
    
    pub fn identity() Mat4 {
        return Mat4{
            .a  = [16]f32 {
                1.0, 0.0, 0.0, 0.0, 
                0.0, 1.0, 0.0, 0.0, 
                0.0, 0.0, 1.0, 0.0, 
                0.0, 0.0, 0.0, 1.0,
            },
        };
    }

    pub fn lookAt(pos: p.Vec3, right: p.Vec3, forward: p.Vec3) Mat4 {
        const up = right.cross(forward);
        return Mat4{
            .a = [16]f32 {
                right.x, up.x, forward.x, pos.x, 
                right.y, up.y, forward.y, pos.y, 
                right.z, up.z, forward.z, pos.z, 
                0.0, 0.0, 0.0, 1.0,
            },
        };
    }

    pub fn mul(a: *const Mat4, b: *const Mat4) Mat4 {
        return Mat4 {
            .a = [16]f32{
                a[0] * b[0] + a[1] * b[4] + a[2] * b[8] + a[3] * b[12],
                a[4] * b[1] + a[5] * b[5] + a[6] * b[9] + a[7] * b[13],
                a[8] * b[2] + a[9] * b[6] + a[10] * b[10] + a[11] * b[14],
                a[12] * b[3] + a[13] * b[7] + a[14] * b[11] + a[15] * b[15]
            },
        };
    }
};
