const std = @import("std");
const c = @import("constants.zig");
const m = @import("math.zig");
const print = std.debug.print;
const expect = std.testing.expect;

pub const ID = u64;

pub const page_alloc = std.heap.page_allocator;

pub const System = struct {
	m: [c.NUM_PARTICLES] f64 = undefined,
	snapshots: [c.NUM_STEPS/c.SNSH_FREQ] *Frame = undefined,
	ring: [3] *Frame = undefined,
};


pub const Frame = struct {
	pos : [c.NUM_PARTICLES] m.Vec3d = undefined,
	vel : [c.NUM_PARTICLES] m.Vec3d = undefined,
	frc : [c.NUM_PARTICLES] m.Vec3d = undefined,
	
};

pub fn newFrame() !*Frame {
	var frame: *Frame = try page_alloc.create(Frame);

	try expect(@TypeOf(frame.pos) == [c.NUM_PARTICLES]m.Vec3d);

	for (frame.pos) |*p| {
		p.* = m.Vec3d{.x = 0.0, .y = 0.0, .z = 0.0};
	}
	for (frame.vel) |*v| {
		v.* = m.Vec3d{.x = 0, .y = 0, .z = 0};
	}
	for (frame.frc) |*f| {
		f.* = m.Vec3d{.x = 0, .y = 0, .z = 0};
	}
	return frame;
}


pub fn calcForce(d2: f64) f64 {
	// 𝔽 = 4ε(6σ⁶/R⁸ - 12σ¹²/R¹⁴) ℝ
	const d4 = d2 * d2;
	const d8 = d4 * d4;
	const d14 = d8 * d4 * d2;
	return c.B_FORCE / d8 - c.A_FORCE / d14;
}

pub fn calcPotential(d2 : f64) f64 {
	const d4 = d2 * d2;
	const d8 = d4 * d4;
	const d6 = d4*d2;
	const d12 = d8*d4;
	// U = 4ε((σ/R)¹² - (σ/R)⁶)
	return c.B / d12 - c.A / d6;
}

pub fn calcTotalPotential(fr : *Frame) f64 {
	var potential : f64 = 0;
	var id : ID = 0;
	while (id < c.NUM_PARTICLES) : (id = id + 1) {
		var id2: ID = 0;
		while(id2<id) : (id2 = id2 + 1) {
			potential += calcPotential(periodicDistanceVector(&fr.pos[id], &fr.pos[id2]).valueSquare());
		}
	}
	return potential;
}

pub fn forceBetween(pos: [] m.Vec3d, frc: [] m.Vec3d, a: ID, b: ID) void {
	var dist : m.Vec3d = periodicDistanceVector(&pos[b], &pos[a]);
	var d2 : f64 = dist.valueSquare();
	var force : f64 = calcForce(d2);
	frc[a] = frc[a].scaledAdd(&dist, force);
	frc[b] = frc[b].scaledAdd(&dist, -force);
}

// Verlet propagation
pub fn update(s: *System, old: *Frame, new: *Frame) void {
	// x[t+dt]
	var id: ID = 0;
	while (id < c.NUM_PARTICLES) : (id = id + 1) {
		new.pos[id] = old.pos[id]
			.scaledAdd(&old.vel[id], c.DELTA_TIME)
			.scaledAdd(&old.frc[id], c.DELTA_TIME * c.DELTA_TIME / (2.0 * s.m[id]));
		//Periodic Boundary Conditions

		if (c.PERIODIC_BOUNDARY) {
			new.pos[id].x =  new.pos[id].x - @floor(new.pos[id].x / @intToFloat(f64, c.BOX_LENGTH)) * @intToFloat(f64, c.BOX_LENGTH);
			new.pos[id].y =  new.pos[id].y - @floor(new.pos[id].y / @intToFloat(f64, c.BOX_WIDTH)) * @intToFloat(f64, c.BOX_WIDTH);
			new.pos[id].z =  new.pos[id].z - @floor(new.pos[id].z / @intToFloat(f64, c.BOX_HEIGHT)) * @intToFloat(f64, c.BOX_HEIGHT);
		}
	}

	// a[t+dt]
	id = 0;
	while (id < c.NUM_PARTICLES) : (id = id + 1) {
		new.frc[id] = m.Vec3d{.x = 0.0, .y = 0.0, .z = 0.0};
		var id2: ID = 0;		
		while(id2<id) : (id2 = id2 + 1) {
			forceBetween(new.pos[0..], new.frc[0..], id, id2);
		}
	}

	// v[t+dt]
	id = 0;
	while (id < c.NUM_PARTICLES) : (id = id + 1) {
		new.vel[id] = old.vel[id].scaledAdd(&(old.frc[id].add(&(new.frc[id]))), c.DELTA_TIME / (2.0 * s.m[id]));
	}



//	self.v = self.v.scaledAdd(self.f, c.DELTA_TIME/self.m/2);
//	// xₜ₊₁ = xₜ + vτ + ¹⁄₂aτ² + 𝒪(τ³),	a = ᶠ⁄ₘ
//	self.x = self.x.scaledAdd(self.v, c.DELTA_TIME);
//	self.x = self.x.scaledAdd(self.f, c.DELTA_TIME*c.DELTA_TIME / (2 * self.m));
//	// vₜ₊₁ = vₜ + aτ + 𝒪(τ²),			 a = ᶠ⁄ₘ
//	self.v = self.v.scaledAdd(self.f, c.DELTA_TIME/self.m/2);
//	//if(isConservationFrame) {
//	//	// Eₖᵢₙ = ¹⁄₂mv²
//	//	currentEnergy += self.v.valueSquare()/2*self.m;
//	//	// p = mv
//	//	currentMomentum = currentMomentum.scaledAdd(self.v, self.m);
//	//	// l
//	//	currentAngularMomentum = currentAngularMomentum.scaledAdd(self.v.cross(self.x),self.m);
//	//}
//	// print("New position: {} {} {}, force: {} {} {}, velocity: {} {} {}\n", .{self.x.x, self.x.y, self.x.z, self.f.x, self.f.y, self.f.z, self.v.x, self.v.y, self.v.z});
//	self.f = Vec3{.x = 0, .y = 0, .z = 0};
}

const energy : f64 = 0;
pub var currentEnergy : f64 = 0;
pub var currentMomentum : m.Vec3d = m.Vec3d{.x = 0, .y = 0, .z = 0};
pub var currentAngularMomentum : m.Vec3d = m.Vec3d{.x = 0, .y = 0, .z = 0};



//Periodic Boundary Conditions
pub fn periodicDistance1D(x1 : f64, x2 : f64, comptime boundary : f64) f64 {
	var x = x1 - x2;
	if (c.PERIODIC_BOUNDARY) {
		x = x - @round(x / boundary) * boundary;
	}
	return x;
}

pub fn periodicDistanceVector(u: *const m.Vec3d, v: *const m.Vec3d) m.Vec3d {
			return m.Vec3d{.x = periodicDistance1D(u.x, v.x, c.BOX_LENGTH),
						.y = periodicDistance1D(u.y, v.y, c.BOX_WIDTH),
						.z = periodicDistance1D(u.z, v.z, c.BOX_HEIGHT)};
		}