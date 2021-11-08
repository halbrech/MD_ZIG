const std = @import("std");

const p = @import("Particle.zig");

const c = @import("Constants.zig");

const print = @import("std").debug.print;

const gui = @import("gui.zig");

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
			frame.pos[id] = p.Vec3{.x = rand.float(f64)*@intToFloat(f64, c.BOX_WIDTH), .y = rand.float(f64)*@intToFloat(f64, c.BOX_HEIGHT), .z = rand.float(f64)*@intToFloat(f64, c.BOX_LENGTH)
							};
			frame.vel[id] = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};
			frame.frc[id] = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};
			sys.m[id] = 1.0;
			var valid : bool = true;
			for (frame.pos[0..id]) |p2| {
				var dist = frame.pos[id].periodicDistanceVector(p2).valueSquare();
				if(dist < 1.1) {
					valid = false;
					break;
				}
			}
			if(valid) break;
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


pub fn main() !void {
	try gui.init_gui();
	const win = try gui.Window.create("Hello, World!", 800, 600);
	
	
	win.show();
	gui.Window.clearColor(0.0, 0.3, 0.2, 1.0);
	gui.Window.clear();
	win.swap();

	// Simulation	
	var sys = try initSystem();
	
	var i : u32 = 0;
	var curr: u32 = 0;
	var t1 = std.time.nanoTimestamp();
	var curPro : i8 = -1;
	while (i < c.NUM_STEPS) : (i += 1) {
		p.update(sys, sys.ring[curr], sys.ring[(curr + 1) % 3]);
		
		if(i % c.SNSH_FREQ == 0) {
			// Print process only when it changes:
			var pro : i8 = @floatToInt(i8, 100*@intToFloat(f64, i)/@intToFloat(f64, c.NUM_STEPS));
			if(pro > curPro) {
				curPro = pro;
				print("{}%\n", .{pro});
			}
			sys.snapshots[@divFloor(i,c.SNSH_FREQ)] = sys.ring[curr];
			sys.ring[curr] = try p.newFrame();
		}

		curr = (curr + 1) % 3;
	}
	print("100%\n", .{});

	var t2 = std.time.nanoTimestamp();
	const data = @intCast(u64, c.NUM_STEPS) * @intCast(u64, @sizeOf(p.Frame));
	print("{}B in {}ms: {}GB/s\n", .{data, @intToFloat(f64, t2 - t1) / 1000000.0, @intToFloat(f64, data) / @intToFloat(f64, t2 - t1)});

	const doExport: bool = true;


	if(doExport) {
		// Data
		const csv = try std.fs.cwd().createFile("lj.csv", .{.read = true});
		defer csv.close();
		_ = try csv.write("t, E, px, py, pz, Lx, Ly, Lz\n");

		const xyz = try std.fs.cwd().createFile("sim.xyz", .{.read = true});
		defer xyz.close();

		for(sys.snapshots) |snsh, idx| {
			var currentEnergy: f64 = 0;
			var currentMomentum: p.Vec3 = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};
			var currentAngularMomentum: p.Vec3 = p.Vec3{.x = 0.0, .y = 0.0, .z = 0.0};

			_ = try xyz.writer().print("{}\n Snapshot {} (Frame {})\n", .{c.NUM_PARTICLES + 8, idx, idx * 1000});
			var id: p.ID = 0;
			// Mark the borders with hydrogen:
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{0, 0, 0});
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{0, 0, c.BOX_HEIGHT});
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{0, c.BOX_WIDTH, 0});
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{0, c.BOX_WIDTH, c.BOX_HEIGHT});
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{c.BOX_LENGTH, 0, 0});
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{c.BOX_LENGTH, 0, c.BOX_HEIGHT});
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{c.BOX_LENGTH, c.BOX_WIDTH, 0});
			_ = try xyz.writer().print("H\t{}\t{}\t{}\n", .{c.BOX_LENGTH, c.BOX_WIDTH, c.BOX_HEIGHT});
			while(id < c.NUM_PARTICLES) : (id = id + 1) {
				_ = try xyz.writer().print("Ar\t{}\t{}\t{}\n", .{snsh.pos[id].x, snsh.pos[id].y, snsh.pos[id].z});

				currentEnergy += snsh.vel[id].valueSquare()/(2.0 * sys.m[id]);
				currentMomentum = currentMomentum.scaledAdd(snsh.vel[id], sys.m[id]);
				currentAngularMomentum = currentAngularMomentum.scaledAdd(snsh.vel[id].cross(snsh.pos[id]),sys.m[id]);

			}
			currentEnergy += p.calcTotalPotential(snsh);
			_ = try csv.writer().print("{}, {}, {}, {}, {}, {}, {}, {} \n",
				.{@intToFloat(f64, idx * 1000) * c.DELTA_TIME, currentEnergy,
				currentMomentum.x, currentMomentum.y, currentMomentum.z,
				currentAngularMomentum.x, currentAngularMomentum.y, currentAngularMomentum.z});
		}
	}
}