const c = @import("Constants.zig");

pub const Particle = struct {
    x : Vec3 = Vec3{.x = 0, .y = 0, .z = 0},
    v : Vec3 = Vec3{.x = 0, .y = 0, .z = 0},
    f : Vec3 = Vec3{.x = 0, .y = 0, .z = 0},
    m : f32 = c.MASS,
    
    pub fn forceBetween(self: *Particle, other : *Particle, comptime isConservationFrame : bool) void {
        var dist : Vec3 = other.x.sub(self.x);
        var d2 : f32 = dist.valueSquare();
        var force : f32 = calcForce(d2, isConservationFrame);
        self.f = Vec3.scaledAdd(self.f, dist, force);
        other.f = Vec3.scaledAdd(other.f, dist, -force);
    }



    pub fn calcForce(d2: f32, comptime isConservationFrame : bool) f32 {
        // 𝔽 = 4ε(6σ⁶/R⁸ - 12σ¹²/R¹⁴) ℝ
        const d4 = d2 * d2;
        const d8 = d4 * d4;
        const d14 = d8 * d4 * d2;
        if(isConservationFrame) {
            const d6 = d4*d2;
            const d12 = d8*d4;
            // U = 4ε((σ/R)¹² - (σ/R)⁶)
            currentEnergy += c.B / d12 - c.A / d6;
        }
        return c.B_FORCE / d8 - c.A_FORCE / d14;
    }
    

    pub fn update(self: *Particle, comptime isConservationFrame : bool) void {
        // const print = @import("std").debug.print;

        // xₜ₊₁ = xₜ + vτ + ¹⁄₂aτ² + 𝒪(τ³),    a = ᶠ⁄ₘ
        self.x = self.x.scaledAdd(self.v, c.DELTA_TIME);
        self.x = self.x.scaledAdd(self.f, c.DELTA_TIME*c.DELTA_TIME / (2 * self.m));
        // vₜ₊₁ = vₜ + aτ + 𝒪(τ²),             a = ᶠ⁄ₘ
        self.v = self.v.scaledAdd(self.f, c.DELTA_TIME/self.m);
        if(isConservationFrame) {
            // Eₖᵢₙ = ¹⁄₂mv²
            currentEnergy += self.v.valueSquare()/2*self.m;
            // p = mv
            currentMomentum = currentMomentum.scaledAdd(self.v, self.m);
            // l
            currentAngularMomentum = currentAngularMomentum.scaledAdd(self.v.cross(self.x),self.m);
        }
        // print("New position: {} {} {}, force: {} {} {}, velocity: {} {} {}\n", .{self.x.x, self.x.y, self.x.z, self.f.x, self.f.y, self.f.z, self.v.x, self.v.y, self.v.z});
        self.f = Vec3{.x = 0, .y = 0, .z = 0};
    }
};

const energy : f32 = 0;
pub var currentEnergy : f32 = 0;
pub var currentMomentum : Vec3 = Vec3{.x = 0, .y = 0, .z = 0};
pub var currentAngularMomentum : Vec3 = Vec3{.x = 0, .y = 0, .z = 0};




pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn add(u: Vec3, v: Vec3) Vec3 {
        return Vec3{.x = u.x + v.x, .y = u.y + v.y, .z = u.z + v.z};
    }
    pub fn sub(u: Vec3, v: Vec3) Vec3 {
        return Vec3{.x = u.x - v.x, .y = u.y - v.y, .z = u.z - v.z};
    }
    pub fn scaledAdd(u: Vec3, v: Vec3, scale : f32) Vec3 {
        return Vec3{.x = u.x + scale * v.x,
                     .y = u.y + scale * v.y,
                     .z = u.z + scale * v.z};
    }
    pub fn dist(u: Vec3, v: Vec3) f32 {
        return @sqrt((u.x - v.x) * (u.x - v.x) + (u.y - v.y) * (u.y - v.y) + (u.z - v.z) * (u.z - v.z));
    }
    pub fn distSquare(u: Vec3, v: Vec3) f32 {
        return (u.x - v.x) * (u.x - v.x) + (u.y - v.y) * (u.y - v.y) + (u.z - v.z) * (u.z - v.z);
    }
    pub fn valueSquare(u: Vec3) f32 {
        return u.x * u.x + u.y * u.y + u.z * u.z;
    }

    pub fn dot(u: Vec3, v: Vec3) f32 {
        return u.x * v.x + u.y * v.y + u.z * v.z;
    }

    pub fn cross(u: Vec3, v: Vec3) Vec3 {
        return Vec3{.x = u.y * v.z - u.z * v.y, .y = u.z * v.x - u.x * v.z, .z = u.x * v.y - u.y * v.x};
    }
};