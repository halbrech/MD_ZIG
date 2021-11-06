const std = @import("std");

const p = @import("Particle.zig");

const c = @import("Constants.zig");

const print = @import("std").debug.print;

//var particles = p.Particle {.x = undefined, .y = undefined, .z = undefined} ** (c.NUM_PARTICLES);
var particles : [c.] = p.Particle {.x = undefined} ** (c.NUM_PARTICLES);

pub fn initParticles() !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = 0x8548294876937;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = &prng.random();
    for (particles) |*part, idx| {
        while(true) {
            part.x = p.Vec3{.x = rand.float(f32)*@intToFloat(f32, c.BOX_WIDTH), .y = rand.float(f32)*@intToFloat(f32, c.BOX_HEIGHT), .z = rand.float(f32)*@intToFloat(f32, c.BOX_LENGTH) 
                            };
           // part.v = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};
            part.f = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};                
            var valid : bool = true;
            for (particles) |*part2| {
                if(part2 == part) break;
                var dist = part.x.distSquare(part2.x);
                
                if(dist < 3.1) {
                    valid = false;
                    break;
                }
            }
            if(valid) break;
        }

        print("Particle {}: {} {} {}\n", .{idx, part.x.x, part.x.y, part.x.z});
    }
}

pub fn update(comptime isConservationFrame : bool) void {
    var p1 : u32 = 0;
    while (p1 < c.NUM_PARTICLES) : (p1 += 1) {
        particles[p1].update(isConservationFrame);
    }
    p1 = 0;
    while (p1 < c.NUM_PARTICLES) : (p1 += 1) {
        var p2 : u32 = 0;
        while (p2 < p1) : (p2 += 1) {
            particles[p1].forceBetween(&particles[p2], isConservationFrame);
        }
    }
}

pub fn main() !void {
    print("Hello, {s}!\n", .{"world"});
    try initParticles();
    const csv = try std.fs.cwd().createFile("lj.csv", .{.read = true});
    defer csv.close();
    _ = try csv.write("T, X1, X2, E, px, py, pz, Lx, Ly, Lz\n");

    const xyz = try std.fs.cwd().createFile("sim.xyz", .{.read = true});
    defer xyz.close();
    
    var i : u32 = 0;
    while (i < c.NUM_STEPS) : (i += 1) {
        if (i % 1 == 0) {
            _ = try xyz.writer().print("{}\n\n", .{particles.len});
            for (particles) |part| {
                _ = try xyz.writer().print("Ar\t{}\t{}\t{}\n", .{part.x.x, part.x.y, part.x.z});
            }

            print("{}%\n", .{@floatToInt(u32, 100*@intToFloat(f32, i)/@intToFloat(f32, c.NUM_STEPS))});
            p.currentEnergy = 0;
            p.currentMomentum = p.Vec3{.x = 0, .y = 0, .z = 0};
            p.currentAngularMomentum = p.Vec3{.x = 0, .y = 0, .z = 0};
            update(true);
            _ = try csv.writer().print("{}, {}, {}, {}, {}, {}, {}, {}, {}, {}\n", 
                .{@intToFloat(f32, i) * c.DELTA_TIME, 
                particles[0].x.x, particles[1].x.x, 
                p.currentEnergy, 
                p.currentMomentum.x, p.currentMomentum.y, p.currentMomentum.z, 
                p.currentAngularMomentum.x, p.currentAngularMomentum.y, p.currentAngularMomentum.z});
        }
        update(false);
    }
}