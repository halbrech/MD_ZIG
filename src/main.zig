const std = @import("std");

const p = @import("Particle.zig");

const c = @import("Constants.zig");

const print = @import("std").debug.print;

//var particles = p.Particle {.x = undefined, .y = undefined, .z = undefined} ** (c.NUM_PARTICLES);
// var particles : [c.NUM_PARTICLES] p.Particle = undefined;

pub fn initParticles(sys: *p.System) !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = 0x8548294876937;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = &prng.random();
    
    const frame = sys.ring[0];

    var id: p.ID = 0;
    while(id < c.NUM_PARTICLES) : (id = id + 1) { 
        while(true) {
            frame.pos[id] = p.Vec3{.x = rand.float(f32)*@intToFloat(f32, c.BOX_WIDTH), .y = rand.float(f32)*@intToFloat(f32, c.BOX_HEIGHT), .z = rand.float(f32)*@intToFloat(f32, c.BOX_LENGTH) 
                            };
            frame.vel[id] = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};
            frame.frc[id] = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};
            sys.m[id] = 1.0;
            var valid : bool = true;
            for (frame.pos[0..id]) |p2| {
                var dist = frame.pos[id].distSquare(p2);
                
                if(dist < 3.1) {
                    valid = false;
                    break;
                }
            }
            if(valid) break;
        }
    }
}

pub fn initSystem() !*p.System {
    var sys: *p.System = try p.page_alloc.create(p.System);
    sys.ring[0] = try p.newFrame();
    sys.ring[1] = try p.newFrame();
    sys.ring[2] = try p.newFrame();

    try initParticles(sys);

    return sys;
}


pub fn main() !void {
    // Simulation    
    var sys = try initSystem();

    
    var i : u32 = 0;
    var curr: u32 = 0;
    var t1 = std.time.nanoTimestamp();
    while (i < c.NUM_STEPS) : (i += 1) {
        // print("{}%\n", .{@floatToInt(u32, 100*@intToFloat(f32, i)/@intToFloat(f32, c.NUM_STEPS))});
        
        p.update(sys, sys.ring[curr], sys.ring[(curr + 1) % 3]);
        
        if(i % 1000 == 0) {
            sys.snapshots[@divFloor(i,1000)] = sys.ring[curr];
            sys.ring[curr] = try p.newFrame();
        }

        curr = (curr + 1) % 3;
    }
    var t2 = std.time.nanoTimestamp();
    const data = c.NUM_STEPS * @sizeOf(p.Frame);
    print("{}B in {}ms: {}GB/s\n", .{data, @intToFloat(f32, t2 - t1) / 1000000.0, @intToFloat(f32, data) / @intToFloat(f32, t2 - t1)});

    const doExport: bool = true;


    if(doExport) {
        // Data
        const csv = try std.fs.cwd().createFile("lj.csv", .{.read = true});
        defer csv.close();
        _ = try csv.write("t, T, px, py, pz, Lx, Ly, Lz\n");

        const xyz = try std.fs.cwd().createFile("sim.xyz", .{.read = true});
        defer xyz.close();

        for(sys.snapshots) |snsh, idx| {
            var currentKinEnergy: f32 = 0;
            var currentMomentum: p.Vec3 = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};
            var currentAngularMomentum: p.Vec3 = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};

            _ = try xyz.writer().print("{}\n Snapshot {} (Frame {})\n", .{c.NUM_PARTICLES, idx, idx * 1000});
            var id: p.ID = 0;
            while(id < c.NUM_PARTICLES) : (id = id + 1) {
                _ = try xyz.writer().print("Ar\t{}\t{}\t{}\n", .{snsh.pos[id].x, snsh.pos[id].y, snsh.pos[id].z});

                currentKinEnergy += snsh.vel[id].valueSquare()/(2.0 * sys.m[id]);
                currentMomentum = currentMomentum.scaledAdd(snsh.vel[id], sys.m[id]);
                currentAngularMomentum = currentAngularMomentum.scaledAdd(snsh.vel[id].cross(snsh.pos[id]),sys.m[id]);

            }
            _ = try csv.writer().print("{}, {}, {}, {}, {}, {}, {}, {} \n", 
                .{@intToFloat(f32, idx * 1000) * c.DELTA_TIME, currentKinEnergy, 
                currentMomentum.x, currentMomentum.y, currentMomentum.z, 
                currentAngularMomentum.x, currentAngularMomentum.y, currentAngularMomentum.z});
        }
    }
}