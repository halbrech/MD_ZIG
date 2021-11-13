const std = @import("std");
const print = @import("std").debug.print;

const p = @import("particle.zig");
const m = @import("math.zig");
const c = @import("constants.zig");
const gui = @import("gui.zig");
const geometry = @import("geometry.zig");

pub fn initParticles(sys: *p.System) !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = 0x8548294876937;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = &prng.random();

    const frame = sys.ring[0];

    var id: p.ID = 0;
    while (id < c.NUM_PARTICLES) : (id = id + 1) {
        while (true) {
            frame.pos[id] = m.Vec3d{ .x = rand.float(f64) * @intToFloat(f64, c.BOX_WIDTH), .y = rand.float(f64) * @intToFloat(f64, c.BOX_HEIGHT), .z = rand.float(f64) * @intToFloat(f64, c.BOX_LENGTH) };
            frame.vel[id] = m.Vec3d{ .x = 0.0, .y = 0.0, .z = 0.0 };
            frame.frc[id] = m.Vec3d{ .x = 0.0, .y = 0.0, .z = 0.0 };
            sys.m[id] = 1.0;
            var valid: bool = true;
            for (frame.pos[0..id]) |p2| {
                var dist = p.periodicDistanceVector(&frame.pos[id], &p2).valueSquare();
                if (dist < 1.1) {
                    valid = false;
                    break;
                }
            }
            if (valid) break;
        }
    }
    //common debug values
    //frame.pos[0] = p.Vec3{.x = 2.5, .y = 0, .z = 0
    //			  };
    //frame.pos[1] = p.Vec3{.x = 9.5, .y = 0, .z = 0
    //			  };
}

pub fn initSystem() !*p.System {
    var sys: *p.System = try p.page_alloc.create(p.System);
    sys.ring[0] = try p.newFrame();
    sys.ring[1] = try p.newFrame();
    sys.ring[2] = try p.newFrame();

    try initParticles(sys);

    return sys;
}

pub fn exportData(sys: *p.System) !void {
    // Data
    const csv = try std.fs.cwd().createFile("lj.csv", .{ .read = true });
    defer csv.close();
    _ = try csv.write("t, E, px, py, pz, Lx, Ly, Lz\n");

    const xyz = try std.fs.cwd().createFile("sim.xyz", .{ .read = true });
    defer xyz.close();

    for (sys.snapshots) |snsh, idx| {
        var currentEnergy: f64 = 0;
        var currentMomentum: m.Vec3d = m.Vec3d{ .x = 0.0, .y = 0.0, .z = 0.0 };
        var currentAngularMomentum: m.Vec3d = m.Vec3d{ .x = 0.0, .y = 0.0, .z = 0.0 };

        _ = try xyz.writer().print("{}\n Snapshot {} (Frame {})\n", .{ c.NUM_PARTICLES + 8, idx, idx * 1000 });
        var id: p.ID = 0;
        // Mark the borders with hydrogen:
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ 0, 0, 0 });
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ 0, 0, c.BOX_HEIGHT });
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ 0, c.BOX_WIDTH, 0 });
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ 0, c.BOX_WIDTH, c.BOX_HEIGHT });
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ c.BOX_LENGTH, 0, 0 });
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ c.BOX_LENGTH, 0, c.BOX_HEIGHT });
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ c.BOX_LENGTH, c.BOX_WIDTH, 0 });
        _ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{ c.BOX_LENGTH, c.BOX_WIDTH, c.BOX_HEIGHT });
        while (id < c.NUM_PARTICLES) : (id = id + 1) {
            _ = try xyz.writer().print("Ar\t{}\t{}\t{}\n", .{ snsh.pos[id].x, snsh.pos[id].y, snsh.pos[id].z });

            currentEnergy += snsh.vel[id].valueSquare() / (2.0 * sys.m[id]);
            currentMomentum = currentMomentum.scaledAdd(snsh.vel[id], sys.m[id]);
            currentAngularMomentum = currentAngularMomentum.scaledAdd(snsh.vel[id].cross(snsh.pos[id]), sys.m[id]);
        }
        currentEnergy += p.calcTotalPotential(snsh);
        _ = try csv.writer().print("{}, {}, {}, {}, {}, {}, {}, {} \n", .{ @intToFloat(f64, idx * 1000) * c.DELTA_TIME, currentEnergy, currentMomentum.x, currentMomentum.y, currentMomentum.z, currentAngularMomentum.x, currentAngularMomentum.y, currentAngularMomentum.z });
    }
}
pub fn runSimulation() !void {
    // Simulation
    var sys = try initSystem();
    var i: u32 = 0;
    var curr: u32 = 0;
    var t1 = std.time.nanoTimestamp();
    var curPro: i8 = -1;
    while (i < c.NUM_STEPS) : (i += 1) {
        p.update(sys, sys.ring[curr], sys.ring[(curr + 1) % 3]);
        if (i % c.SNSH_FREQ == 0) {
            // Print process only when it changes:
            var pro: i8 = @floatToInt(i8, 100 * @intToFloat(f64, i) / @intToFloat(f64, c.NUM_STEPS));
            if (pro > curPro) {
                curPro = pro;
                print("{}%\n", .{pro});
            }
            sys.snapshots[@divFloor(i, c.SNSH_FREQ)] = sys.ring[curr];
            sys.ring[curr] = try p.newFrame();
        }

        curr = (curr + 1) % 3;
    }
    print("100%\n", .{});

    var t2 = std.time.nanoTimestamp();
    const data = @intCast(u64, c.NUM_STEPS) * @intCast(u64, @sizeOf(p.Frame));
    print("{}B in {}ms: {}GB/s\n", .{ data, @intToFloat(f64, t2 - t1) / 1000000.0, @intToFloat(f64, data) / @intToFloat(f64, t2 - t1) });
}

fn printMe(a: []const u8) void {
    print("{s}", .{a});
}

fn runme(a: []const u8, b: fn([]const u8) void) void {
    b(a);
}

const TEST = true;

fn fac(k: u64) u64 {
    var i: u64 = 2;
    var out: u64 = 1;
    while(i <= k) : (i += 1) {
        out *= i;
    }
    return out;
}

fn choose(n: u64, k: u64) u64 {
    // print("{} over {}: {} / {}", .{n, k, fac(n), fac(k) * fac(n-k)});
    return @divExact(fac(n), fac(k) * fac(n - k));
}

fn chebishev(comptime n: usize, x: f32) f32 {
    var k: usize = 0;
    var out: f32 = 0;
    while(k <= @divFloor(n, 2)) : (k += 1) {
        out += @intToFloat(f32, choose(n, 2 * k)) * std.math.pow(f32, x * x - 1, @intToFloat(f32, k)) * std.math.pow(f32, x, @intToFloat(f32, n - 2 * k));
    }
    return out;
}

fn field(x: f32, y: f32, z: f32) f32 {
    const order = 6;
    _ = x;
    _ = y;
    _ = z;
    // return 10.0;
    // return x * x + y * y + z * z;
    return chebishev(order, x) + chebishev(order, y) + chebishev(order, z);
}

fn field2(x: f32, y: f32, z: f32) f32 {
    const x0 = 0.0;
    const y0 = 0.0;
    const z0 = 0.0;
    const r0 = 1.3;

    const x1 = -0.8;
    const y1 = -0.8;
    const z1 = -0.8;
    const r1 = 1.3;

    return (r0 * r0 + r1 * r1) - (1 / ((x - x0) * (x - x0) + (y - y0) * (y - y0) + (z - z0) * (z - z0))
        + 1 / ((x - x1) * (x - x1) + (y - y1) * (y - y1) + (z - z1) * (z - z1)));
}

pub fn main() !void {


    try gui.initGUI();
    defer gui.quitGUI();
    
    var win = try gui.Window.create("MD_ZIG", 800, 800);

    win.show();
    gui.Window.clearColor(0.0, 0.3, 0.2, 1.0);
 
    const model = m.Mat4.identity();

    var pos = m.Vec3f{.x = 5.0, .y = 0.0, .z = 0.0}; // pos
    var up = m.Vec3f{.x = 0.0, .y = 0.0, .z = 1.0};  // up
    var look_at = m.Vec3f{.x = 0.0, .y = 0.0, .z = 0.0}; // forward
    var view = m.Mat4.lookAt(pos, up, look_at);

    var sh = try gui.Shader.create();//  ("shader.vert", "shader.frag");
    try sh.addShader("shader.vert", gui.ShaderStage.VERTEX);
    try sh.addShader("shader.frag", gui.ShaderStage.FRAGMENT);
    try sh.compile();

    const sphere_struct = geometry.Sphere(2);

    var sphere_data : sphere_struct = undefined;
    sphere_data.init();
    _ = sphere_struct;
    const sphere_mesh = try gui.Mesh.create(&sphere_data.vertices, &sphere_data.indices, sh.id, model);
    // gui.Window.clear();
    // sphere_mesh.draw();
    // win.swap();

    const t1 = std.time.nanoTimestamp();
    const surface1 = try geometry.marchingTetrahedra(&field, 0.0, 100, 100, 100, m.Vec3f{.x = -3.0, .y = -3.0, .z = -3.0}, 0.05);
    const surface2 = try geometry.marchingTetrahedra(&field2, 0.0, 100, 100, 100, m.Vec3f{.x = -3.0, .y = -3.0, .z = -3.0}, 0.05);
    const t2 = std.time.nanoTimestamp();
    print("Generated surface(s) in {} milliseconds.\n", .{@divTrunc(t2 - t1, 1000000)});
    
    const surface1_obj = try gui.Mesh.create(surface1.vs, surface1.ts, sh.id, model);
    const surface2_obj = try gui.Mesh.create(surface2.vs, surface2.ts, sh.id, m.Mat4.translate(m.Vec3f{.x = -1.0, .y = -1.0, .z = 3.0}));


    var line_shader = try gui.Shader.create(); // ("line.vert", "line.frag");
    try line_shader.addShader("line.vert", gui.ShaderStage.VERTEX);
    try line_shader.addShader("line.frag", gui.ShaderStage.FRAGMENT);
    try line_shader.compile();

    const d: f32 = 2.0;
    const xaxis = gui.Line.create(m.Vec3f{.x = -d, .y = 0.0, .z = 0.0}, m.Vec3f{.x = d, .y = 0.0, .z = 0.0}, [3]f32{1.0, 0.0, 0.0}, line_shader.id);
    const yaxis = gui.Line.create(m.Vec3f{.x = 0.0, .y = -d, .z = 0.0}, m.Vec3f{.x = 0.0, .y = d, .z = 0.0}, [3]f32{0.0, 1.0, 0.0}, line_shader.id);
    const zaxis = gui.Line.create(m.Vec3f{.x = 0.0, .y = 0.0, .z = -d}, m.Vec3f{.x = 0.0, .y = 0.0, .z = d}, [3]f32{0.0, 0.0, 1.0}, line_shader.id);

    const cube = try gui.cube(sh.id, model);

    var pressedLeftButton: bool = false;
    var mouseX: c_int = 0;
    var mouseY: c_int = 0;

    var rotX: f32 = 0;
    var rotY: f32 = 0;

    var ev: gui.sdl.SDL_Event = undefined;
    main_loop: while (true) {
        // window event loop
        while (gui.sdl.SDL_PollEvent(&ev) != 0) {
            switch(ev.type) {
                gui.sdl.SDL_QUIT => {
                    break :main_loop;
                },
                gui.sdl.SDL_WINDOWEVENT => {
                    if(ev.window.type == gui.sdl.SDL_WINDOWEVENT_CLOSE) {
                        break :main_loop;
                    }
                    if(ev.window.event == gui.sdl.SDL_WINDOWEVENT_RESIZED) {
                        win.resize(@intCast(u64, ev.window.data1), @intCast(u64, ev.window.data2));
                    }
                },
                gui.sdl.SDL_KEYDOWN => {
                    if((ev.key.keysym.sym == gui.sdl.SDLK_q) or (ev.key.keysym.sym == gui.sdl.SDLK_ESCAPE)) {
                        break :main_loop;
                    }
                },
                gui.sdl.SDL_MOUSEBUTTONDOWN => {
                    if(ev.button.button == gui.sdl.SDL_BUTTON_LEFT) {
                        pressedLeftButton = true;
                    }
                    //var x : i32 = ev.x; 
                },
                gui.sdl.SDL_MOUSEBUTTONUP => {
                    if(ev.button.button == gui.sdl.SDL_BUTTON_LEFT) {
                        pressedLeftButton = false;
                    }
                },
                gui.sdl.SDL_MOUSEMOTION => {
                    var newMouseX = ev.motion.x;
                    var newMouseY = ev.motion.y;
                    if(pressedLeftButton) {
                        // Update camera:
                        rotX += @intToFloat(f32, newMouseX - mouseX)*0.01;
                        rotY += @intToFloat(f32, newMouseY - mouseY)*0.01;
                    }
                    mouseX = newMouseX;
                    mouseY = newMouseY;
                },
                else => {}
            }
        }

        gui.Window.clear();
        _ = xaxis;
        _ = yaxis;
        _ = zaxis;
        xaxis.draw(&view, &win.projection);
        yaxis.draw(&view, &win.projection);
        zaxis.draw(&view, &win.projection);
        _ = sphere_mesh;
        // sphere_mesh.draw(&pos, &view, &win.projection);
        //cube.draw(&view, &win.projection);
        _ = surface1_obj;
        surface1_obj.draw(&pos, &view, &win.projection);
        surface2_obj.draw(&pos, &view, &win.projection);

        _ = cube;
        win.swap();
        // pos.z += 0.5;
        var rotation: m.Mat4 = m.Mat4.rotateZ(-rotX).mul(
            &m.Mat4.rotateY(-rotY));
        view = m.Mat4.lookAt(rotation.mulVec3(&pos), up, look_at);
    }
}