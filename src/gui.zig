const print = @import("std").debug.print;
const p = @import("Particle.zig");
const builtin = @import("builtin");
const std = @import("std");
const sphere = @import("sphere.zig");
pub const sdl = @cImport ({
    switch(builtin.os.tag) {
        .windows => {
            @cInclude("SDL.h");
        },
        .linux => {
            @cInclude("SDL2/SDL.h");
        },
        else => {}
    }
	@cInclude("SDL.h");
});

const gl = @import("glad.zig");

const NO_GL_DEBUG_OUTPUT = false;

pub fn initGUI() !void {
    const sdl_init = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    if (sdl_init < 0) {
        // print("Error initializing SDL2: {s}", .{sdl.SDL_GetError()});
    }
}

pub fn quitGUI() void {
    _ = sdl.SDL_Quit();
}

pub const Line = struct {
    VAO: u32,
    VBO: u32,
    color: [3]f32,
    shader: u32,
    pub fn create(start: p.Vec3, end: p.Vec3, color: [3]f32, shader: u32) Line {

        const floats: []f32 = &[_]f32{
            @floatCast(f32, start.x), 
            @floatCast(f32, start.y), 
            @floatCast(f32, start.z), 
            @floatCast(f32, end.x),
            @floatCast(f32, end.y), 
            @floatCast(f32, end.z)
        };

        var vao: u32 = undefined;
        gl.glGenVertexArrays(1, &vao);
        gl.glBindVertexArray(vao);

        var vbo: u32 = undefined;
        gl.glGenBuffers(1, &vbo);
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
        gl.glBufferData(gl.GL_ARRAY_BUFFER, @intCast(c_long, floats.len * @sizeOf(f32)), floats.ptr, gl.GL_STATIC_DRAW);
        
        gl.glEnableVertexAttribArray(0);
        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, @sizeOf(f32)*3, null);

        gl.glBindVertexArray(0);
        
        return Line{ .VAO = vao, .VBO = vbo, .shader = shader, .color = color };
    }

    pub fn draw(self: *const Line, view: *const Mat4, proj: *const Mat4) void {
        gl.glUseProgram(self.shader);
        gl.glUniformMatrix4fv(0, 1, gl.GL_TRUE, &view.a[0]);
        gl.glUniformMatrix4fv(1, 1, gl.GL_TRUE, &proj.a[0]);
        gl.glBindVertexArray(self.VAO);
        
        gl.glUniform3f(2, self.color[0], self.color[1], self.color[2]);
        gl.glDrawArrays(gl.GL_LINES, 0, 2);
        
        gl.glBindVertexArray(0);
        gl.glUseProgram(0);
    }
};

pub fn cube(shader: u32, model: Mat4) !Mesh {
    const verts = [_]sphere.Vertex {
        sphere.Vertex{.pos = p.Vec3{.x = -1.0, .y = -1.0, .z = -1.0}, .norm = p.Vec3{.x = -1.0, .y = -1.0, .z = -1.0}}, // 0  
        sphere.Vertex{.pos = p.Vec3{.x = 1.0, .y = -1.0, .z = -1.0}, .norm = p.Vec3{.x = 1.0, .y = -1.0, .z = -1.0}}, // 1
        sphere.Vertex{.pos = p.Vec3{.x = 1.0, .y = 1.0, .z = -1.0}, .norm = p.Vec3{.x = 1.0, .y = 1.0, .z = -1.0}}, // 2
        sphere.Vertex{.pos = p.Vec3{.x = -1.0, .y = 1.0, .z = -1.0}, .norm = p.Vec3{.x = -1.0, .y = 1.0, .z = -1.0}}, // 3 
        sphere.Vertex{.pos = p.Vec3{.x = -1.0, .y = -1.0, .z = 1.0}, .norm = p.Vec3{.x = -1.0, .y = -1.0, .z = 1.0}}, // 4 
        sphere.Vertex{.pos = p.Vec3{.x = 1.0, .y = -1.0, .z = 1.0}, .norm = p.Vec3{.x = 1.0, .y = -1.0, .z = 1.0}}, // 5
        sphere.Vertex{.pos = p.Vec3{.x = 1.0, .y = 1.0, .z = 1.0}, .norm = p.Vec3{.x = 1.0, .y = 1.0, .z = 1.0}}, // 6
        sphere.Vertex{.pos = p.Vec3{.x = -1.0, .y = 1.0, .z = 1.0}, .norm = p.Vec3{.x = -1.0, .y = 1.0, .z = 1.0}}, // 7
    };
    const indices = [_]sphere.Triangle {
        sphere.Triangle{.v1 = 0, .v2 = 2, .v3 = 1}, // bottom
        sphere.Triangle{.v1 = 0, .v2 = 3, .v3 = 2}, // bottom
        sphere.Triangle{.v1 = 4, .v2 = 5, .v3 = 6}, // top
        sphere.Triangle{.v1 = 4, .v2 = 6, .v3 = 7}, // top
        sphere.Triangle{.v1 = 0, .v2 = 1, .v3 = 5}, // front
        sphere.Triangle{.v1 = 0, .v2 = 5, .v3 = 4}, // front
        sphere.Triangle{.v1 = 3, .v2 = 6, .v3 = 2}, // back
        sphere.Triangle{.v1 = 3, .v2 = 7, .v3 = 6}, // back
        sphere.Triangle{.v1 = 3, .v2 = 4, .v3 = 7}, // left
        sphere.Triangle{.v1 = 3, .v2 = 0, .v3 = 4}, // left
        sphere.Triangle{.v1 = 1, .v2 = 2, .v3 = 6}, // right
        sphere.Triangle{.v1 = 1, .v2 = 6, .v3 = 5}, // right
    };


    return Mesh.create(&verts, &indices, shader, model);
}

fn glDebugMessageCallback(source: c_uint, msg_type: c_uint, id: c_uint, severity: c_uint, length: c_int, msg: [*c]const u8, data: ?*const c_void) callconv(.C) void {
    if(NO_GL_DEBUG_OUTPUT) return;
    print("GL: type: {s}, ", .{(&(switch (msg_type) {
        gl.GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR => "Deprecated Behavior",
        gl.GL_DEBUG_TYPE_ERROR => "Error",
        gl.GL_DEBUG_TYPE_MARKER => "Marker",
        gl.GL_DEBUG_TYPE_OTHER => "Other",
        gl.GL_DEBUG_TYPE_PERFORMANCE => "Performance",
        gl.GL_DEBUG_TYPE_PORTABILITY => "Portability",
        gl.GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR => "Undefined Behavior",
        gl.GL_DEBUG_TYPE_POP_GROUP => "Pop group",
        gl.GL_DEBUG_TYPE_PUSH_GROUP => "Push group",
        else => "Unknown",
    })).*});
    print("id: {}, ", .{id});
    print("source: {s}, ", .{(&(switch(source) {
        gl.GL_DEBUG_SOURCE_API => "API",
        gl.GL_DEBUG_SOURCE_APPLICATION => "Application",
        gl.GL_DEBUG_SOURCE_SHADER_COMPILER => "Shader Compiler",
        gl.GL_DEBUG_SOURCE_WINDOW_SYSTEM => "Window System",
        gl.GL_DEBUG_SOURCE_THIRD_PARTY => "Third Party",
        gl.GL_DEBUG_SOURCE_OTHER => "Other",
        else => "Unknown",
    })).*});
    print("severity: {s}, ", .{(&(switch(severity) {
        gl.GL_DEBUG_SEVERITY_HIGH => "High",
        gl.GL_DEBUG_SEVERITY_MEDIUM, => "Medium",
        gl.GL_DEBUG_SEVERITY_LOW => "Low",
        gl.GL_DEBUG_SEVERITY_NOTIFICATION => "Notification",
        else => "Unknown",
    })).*});
    print(":\n{s}\n", .{msg});
    
    _ = data;
    _ = length;
}

pub const Window = struct {
    width: u64,
    height: u64,
    handle: *sdl.SDL_Window,
    gl_context: *c_void,

    pub fn create(
        title: [*c]const u8,
        width: u64,
        height: u64,
    ) !Window {
        const window = sdl.SDL_CreateWindow(title, sdl.SDL_WINDOWPOS_CENTERED, sdl.SDL_WINDOWPOS_CENTERED, @intCast(i32, width), @intCast(i32, height), sdl.SDL_WINDOW_OPENGL) orelse return error.Error;

        const gl_ctx = sdl.SDL_GL_CreateContext(window) orelse return error.Error;
        // print("{}\n", .{@TypeOf(gl_ctx)});
        _ = gl.gladLoadGLLoader(sdl.SDL_GL_GetProcAddress);

        gl.glEnable(gl.GL_DEBUG_OUTPUT);
        gl.glDebugMessageCallback(glDebugMessageCallback, null);
		gl.glEnable(gl.GL_CULL_FACE);
        // gl.glEnable(gl.GL_DEPTH_TEST);
	    gl.glEnable(gl.GL_BLEND);
        gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);

        return Window{ .width = width, .height = height, .handle = window, .gl_context = gl_ctx };
    }

    pub fn swap(self: *const Window) void {
        gl.glFlush();
        sdl.SDL_GL_SwapWindow(self.handle);
    }

    pub fn clearColor(r: f32, g: f32, b: f32, a: f32) void {
        gl.glClearColor(r, g, b, a);
    }

    pub fn clear() void {
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);
    }

    pub fn show(self: *const Window) void {
        sdl.SDL_ShowWindow(self.handle);
    }

    pub fn hide(self: *const Window) void {
        sdl.SDL_HideWindow(self.handle);
    }
};

pub fn fileToString(path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{ .read = true });
    return file.readToEndAlloc(std.heap.page_allocator, std.math.maxInt(u64));
}

pub fn freeFileString(buf: *[]u8) void {
    std.heap.page_allocator.destroy(buf);
}

pub const ShaderStage = enum {
    VERTEX,
    FRAGMENT,
    GEOMETRY,
    COMPUTE,
};

pub const Shader = struct {
    id: u32,
    
    

    pub fn create() !Shader {
        // var vss = try fileToString(vertex_path);
        // var fss = try fileToString(fragment_path);
// 
        // const vs_ref_buf = [_] [*c]u8 {@ptrCast([*c]u8, vss.ptr)};
        // const fs_ref_buf = [_] [*c]u8 {@ptrCast([*c]u8, fss.ptr)};
        // 
        // 
        // // defer freeFileString(&vss);
        // // defer freeFileString(&fss);
// 
// 
        // // print("Vertex shader({}): \n{s}\n", .{vss.len, vss});
        // // print("Fragment shader({}): \n{s}\n", .{fss.len, fss});
// 
// 
        // const vs = gl.glCreateShader(gl.GL_VERTEX_SHADER);
        // const fs = gl.glCreateShader(gl.GL_FRAGMENT_SHADER);
        // gl.glShaderSource(vs, 1, @ptrCast([*c]const [*c]const u8, &vs_ref_buf[0]), @ptrCast([*c]const c_int, &vss.len));
        // gl.glShaderSource(fs, 1, @ptrCast([*c]const [*c]const u8, &fs_ref_buf[0]), @ptrCast([*c]const c_int, &fss.len));

//        for(vss) |*c| {
//            c.* = ' ';
//        }
//        for(fss) |*c| {
//            c.* = ' ';
//        }
//
//        gl.glGetShaderSource(vs, @intCast(c_int, vss.len), null, @ptrCast([*c]u8, vss.ptr));
//        gl.glGetShaderSource(fs, @intCast(c_int, fss.len), null, @ptrCast([*c]u8, fss.ptr));
//        
//        print("Loaded Vertex shader({}): \n{s}\n", .{vss.len, vss});
//        print("Loaded Fragment shader({}): \n{s}\n", .{fss.len, fss});

        // gl.glCompileShader(vs);
// 
// 
// 
        // var success = gl.GL_FALSE;
        // gl.glGetShaderiv(vs, gl.GL_COMPILE_STATUS, &success);
        // if(success != gl.GL_TRUE) {
        //     var len: u32 = undefined;
        //     gl.glGetShaderiv(vs, gl.GL_INFO_LOG_LENGTH, @ptrCast(*c_int, &len));
        //     var buf: [4096] u8 = undefined;
        //     gl.glGetShaderInfoLog(vs, 4096, @ptrCast(*c_int, &len), &buf);
        //     print("Error compiling vertex shader({}):\n{s}\n", .{len, buf});
        //     return anyerror.Error; 
        // }
        // 
        // gl.glCompileShader(fs);
// 
        // success = gl.GL_FALSE;
        // gl.glGetShaderiv(fs, gl.GL_COMPILE_STATUS, &success);
        // if(success != gl.GL_TRUE) {
        //     var len: u32 = undefined;
        //     gl.glGetShaderiv(fs, gl.GL_INFO_LOG_LENGTH, @ptrCast(*c_int, &len));
        //     var buf: [4096] u8 = undefined;
        //     gl.glGetShaderInfoLog(fs, 4096, @ptrCast(*c_int, &len), &buf);
        //     print("Error compiling vertex shader({}):\n{s}\n", .{len, buf});
        //     return anyerror.Error;
        // }
// 
        // const prog = gl.glCreateProgram();
        // gl.glAttachShader(prog, vs);
        // gl.glAttachShader(prog, fs);
        // gl.glLinkProgram(prog);
        // // gl.glDetachShader(prog, vs);
        // // gl.glDetachShader(prog, fs);
// 
        // success = gl.GL_FALSE;
        // gl.glGetProgramiv(prog, gl.GL_LINK_STATUS, &success);
        // if(success != gl.GL_TRUE) {
        //     var len: u32 = undefined;
        //     gl.glGetProgramiv(prog, gl.GL_INFO_LOG_LENGTH, @ptrCast(*c_int, &len));
        //     var buf: [4096] u8 = undefined;
        //     gl.glGetProgramInfoLog(prog, 4096, @ptrCast(*c_int, &len), &buf);
        //     print("Error Linking Shader program({}):\n{s}\n", .{len, buf});
        //     return anyerror.Error;
        // }

        
        // return prog;
        return Shader{.id = gl.glCreateProgram()};
    }

    pub fn addShader(self: *Shader, filename: []const u8, shader_stage: ShaderStage) !void {
        var source = try fileToString(filename);
        const ref_buffer = [_] [*c]u8 {@ptrCast([*c]u8, source.ptr)};
        const shader = gl.glCreateShader(switch(shader_stage) {
            ShaderStage.VERTEX => gl.GL_VERTEX_SHADER,
            ShaderStage.FRAGMENT => gl.GL_FRAGMENT_SHADER,
            ShaderStage.GEOMETRY => gl.GL_GEOMETRY_SHADER,
            ShaderStage.COMPUTE => gl.GL_COMPUTE_SHADER,
            // else => return anyerror.Error,
        });
        defer gl.glDeleteShader(shader);
        
        gl.glShaderSource(shader, 1, @ptrCast([*c]const [*c]const u8, &ref_buffer[0]), @ptrCast([*c]const c_int, &source.len));
        
        gl.glCompileShader(shader);

        var success = gl.GL_FALSE;
        gl.glGetShaderiv(shader, gl.GL_COMPILE_STATUS, &success);
        if(success != gl.GL_TRUE) {
            var len: u32 = undefined;
            gl.glGetShaderiv(shader, gl.GL_INFO_LOG_LENGTH, @ptrCast(*c_int, &len));
            var buf: [4096] u8 = undefined;
            gl.glGetShaderInfoLog(shader, 4096, @ptrCast(*c_int, &len), &buf);
            print("Error compiling shader {s}({}):\n{s}\n", .{filename, len, buf});
            return anyerror.Error;
        }

        gl.glAttachShader(self.id, shader);
    }

    pub fn compile(self: *Shader) !void {
        gl.glLinkProgram(self.id);
        // gl.glDetachShader(prog, vs);
        // gl.glDetachShader(prog, fs);

        var success = gl.GL_FALSE;
        gl.glGetProgramiv(self.id, gl.GL_LINK_STATUS, &success);
        if(success != gl.GL_TRUE) {
            var len: u32 = undefined;
            gl.glGetProgramiv(self.id, gl.GL_INFO_LOG_LENGTH, @ptrCast(*c_int, &len));
            var buf: [4096] u8 = undefined;
            gl.glGetProgramInfoLog(self.id, 4096, @ptrCast(*c_int, &len), &buf);
            print("Error Linking Shader program({}):\n{s}\n", .{len, buf});
            return anyerror.Error;
        }
    } 
};

pub const Mesh = struct {
    VAO: u32,
    VBO: u32,
    EBO: u32,

    shader: u32,
    model: Mat4,
    size: usize,

    pub fn create(v: []const sphere.Vertex, i: []const sphere.Triangle, shader: u32, model: Mat4) !Mesh {
        var vao: u32 = undefined;
        gl.glGenVertexArrays(1, &vao);
        gl.glBindVertexArray(vao);
        
        var floats = try std.heap.page_allocator.alloc(f32, 6 * v.len);
        defer std.heap.page_allocator.free(floats);

        for(v) |vert, index| {
            floats[6 * index] = @floatCast(f32, vert.pos.x);
            floats[6 * index + 1] = @floatCast(f32, vert.pos.y);
            floats[6 * index + 2] = @floatCast(f32, vert.pos.z);
            floats[6 * index + 3] = @floatCast(f32, vert.norm.x);
            floats[6 * index + 4] = @floatCast(f32, vert.norm.y);
            floats[6 * index + 5] = @floatCast(f32, vert.norm.z);
        }


        var vbo: u32 = undefined;
        var ebo: u32 = undefined;
        gl.glGenBuffers(1, &vbo);
        gl.glGenBuffers(1, &ebo);
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
        gl.glBufferData(gl.GL_ARRAY_BUFFER, @intCast(c_long, floats.len * @sizeOf(f32)), floats.ptr, gl.GL_STATIC_DRAW);
        gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ebo);
        gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, @intCast(c_long, i.len * @sizeOf(sphere.Triangle)), i.ptr, gl.GL_STATIC_DRAW);

        gl.glEnableVertexAttribArray(0);
        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, @sizeOf(f32)*6, null);
        gl.glEnableVertexAttribArray(1);
        gl.glVertexAttribPointer(1, 3, gl.GL_FLOAT, gl.GL_FALSE, @sizeOf(f32)*6, @intToPtr(*const c_void, 3*@sizeOf(f32)));

        gl.glBindVertexArray(0);
        return Mesh{ .VAO = vao, .VBO = vbo, .EBO = ebo, .shader = shader, .model = model, .size = i.len*3 };
    }

    pub fn draw(self: *const Mesh, view: *const Mat4, proj: *const Mat4) void {
        gl.glUseProgram(self.shader);
        gl.glUniformMatrix4fv(0, 1, gl.GL_TRUE, &self.model.a[0]);
        gl.glUniformMatrix4fv(1, 1, gl.GL_TRUE, &view.a[0]);
        gl.glUniformMatrix4fv(2, 1, gl.GL_TRUE, &proj.a[0]);
        gl.glBindVertexArray(self.VAO);
        //print("Drawing {} vertices.\n", .{self.size});
        
        gl.glUniform1i(3, 1);
        gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
        gl.glDrawElements(gl.GL_TRIANGLES, @intCast(c_int, self.size), gl.GL_UNSIGNED_INT, null);
        
        gl.glUniform1i(3, 0);
        gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
        gl.glDrawElements(gl.GL_TRIANGLES, @intCast(c_int, self.size), gl.GL_UNSIGNED_INT, null);
        gl.glBindVertexArray(0);
    }
};

pub const Mat4 = struct {
    a: [16]f32,

    pub fn zeros() Mat4 {
        return Mat4{
            .a = [16]f32{
                0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0,
                0.0, 0.0, 0.0, 0.0,
            },
        };
    }

    pub fn identity() Mat4 {
        return Mat4{
            .a = [16]f32{
                1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                0.0, 0.0, 0.0, 1.0,
            },
        };
    }

    pub fn lookAt(pos: p.Vec3, up: p.Vec3, target: p.Vec3) Mat4 {
        var dir = pos.sub(target).normalize();
        var right = up.cross(dir).normalize();
        const cam_up = dir.cross(right);
        return Mat4{
            .a = [16]f32{
                @floatCast(f32, right.x), @floatCast(f32, right.y), @floatCast(f32, right.z), @floatCast(f32, -right.dot(pos)),
                @floatCast(f32, cam_up.x),  @floatCast(f32, cam_up.y), @floatCast(f32, cam_up.z), @floatCast(f32, -cam_up.dot(pos)),
                @floatCast(f32, dir.x), @floatCast(f32, dir.y), @floatCast(f32, dir.z), @floatCast(f32, -dir.dot(pos)), 
                0.0,     0.0,  0.0,       1.0,
            },
        };
    }

    pub fn perspective(width: f32, height: f32, near: f32, far: f32) Mat4 {
        // const s = 
        return Mat4{
            .a = [16]f32 {
                2.0 / width, 0.0, 0.0, 0.0,
                0.0, 2.0 / height, 0.0, 0.0,
                0.0, 0.0, (-2.0) / (far - near), -(far + near) / (far - near),
                0.0, 0.0, 0.0, 1.0 
            }
        };
    }

    pub fn mul(a: *const Mat4, b: *const Mat4) Mat4 {
        var res: Mat4 = undefined;
        var rowA: u32 = 0;
        while(rowA < 4): (rowA += 1) {
            var colB: u32 = 0;
            while(colB < 4): (colB += 1) {
                var posRes = 4*rowA + colB;
                res.a[posRes] = 0;
                var i: u32 = 0;
                while(i < 4): (i += 1) {
                    res.a[posRes] += a.a[4*rowA + i]*b.a[4*i + colB];
                }
            }
        }
        return res;
    }
};
