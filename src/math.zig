const std = @import("std");
const math = @import("math");

pub fn Vec3(comptime T: type) type {
return packed struct {
		x: T,
		y: T,
		z: T,

		pub fn add(u: *const @This(), v: *const @This()) @This() {
			return @This(){.x = u.x + v.x, .y = u.y + v.y, .z = u.z + v.z};
		}
		pub fn sub(u: *const @This(), v: *const @This()) @This() {
			return @This(){.x = u.x - v.x, .y = u.y - v.y, .z = u.z - v.z};
		}
		pub fn mul(u: *const @This(), a: T) @This() {
			return @This(){.x = u.x*a, .y = u.y*a, .z = u.z*a};
		}
		pub fn scaledAdd(u: *const @This(), v: *const @This(), scale : T) @This() {
			return @This(){.x = u.x + scale * v.x,
						.y = u.y + scale * v.y,
						.z = u.z + scale * v.z};
		}
		pub fn dist(u: *const @This(), v: *const @This()) T {
			return @sqrt((u.x - v.x) * (u.x - v.x) + (u.y - v.y) * (u.y - v.y) + (u.z - v.z) * (u.z - v.z));
		}

		pub fn distSquare(u: *const @This(), v: *const @This()) T {
			return (u.x - v.x) * (u.x - v.x) + (u.y - v.y) * (u.y - v.y) + (u.z - v.z) * (u.z - v.z);
		}

		

		pub fn valueSquare(u: *const @This()) T {
			return u.x * u.x + u.y * u.y + u.z * u.z;
		}

		pub fn dot(u: *const @This(), v: *const @This()) T {
			return u.x * v.x + u.y * v.y + u.z * v.z;
		}

		pub fn cross(u: *const @This(), v: *const @This()) @This() {
			return @This(){.x = u.y * v.z - u.z * v.y, .y = u.z * v.x - u.x * v.z, .z = u.x * v.y - u.y * v.x};
		}

		pub fn normalize(u: *const @This()) @This() {
			const inv_len = 1.0/@sqrt(u.x * u.x + u.y * u.y + u.z * u.z);
			return @This(){
				.x = u.x * inv_len,
				.y = u.y * inv_len,
				.z = u.z * inv_len,
			};
		}
	};
}

pub const Vec3f = Vec3(f32);
pub const Vec3d = Vec3(f64);
pub const Vec3i = Vec3(isize);
pub const Vec3u = Vec3(usize);


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

    pub fn scale(scl: f32) Mat4 {
        return Mat4{
            .a = [16]f32{
                scl, 0.0, 0.0, 0.0,
                0.0, scl, 0.0, 0.0,
                0.0, 0.0, scl, 0.0,
                0.0, 0.0, 0.0, 1.0,
            },
        };
    }

    pub fn rotateX(rad: f32) Mat4 {
        var s: f32 = @sin(rad);
        var c: f32 = @cos(rad);
        return Mat4{
            .a = [16]f32{
                1,  0,  0, 0,
                0,  c, -s, 0,
                0,  s,  c, 0,
                0,  0,  0, 1,
            },
        };
    }

    pub fn rotateY(rad: f32) Mat4 {
        var s: f32 = @sin(rad);
        var c: f32 = @cos(rad);
        return Mat4{
            .a = [16]f32{
                c, 0, s, 0,
                0, 1, 0, 0,
                -s, 0, c, 0,
                0, 0, 0, 1,
            }
        };
    }

    pub fn rotateZ(rad: f32) Mat4 {
        var s: f32 = @sin(rad);
        var c: f32 = @cos(rad);
        return Mat4{
            .a = [16]f32{
                c, -s, 0, 0,
                s,  c, 0, 0,
                0,  0, 1, 0,
                0,  0, 0, 1,
            }
        };
    }

    pub fn translate(p: Vec3f) Mat4 {
        return Mat4 {
            .a = [16]f32 {
                1, 0, 0, p.x,
                0, 1, 0, p.y,
                0, 0, 1, p.z,
                0, 0, 0, 1,
            }
        };
    }

    pub fn lookAt(pos: Vec3f, up: Vec3f, target: Vec3f) Mat4 {
        var dir = pos.sub(&target).normalize();
        var right = up.cross(&dir).normalize();
        const cam_up = dir.cross(&right);
        return Mat4{
            .a = [16]f32{
                right.x, right.y, right.z, -right.dot(&pos),
                cam_up.x,  cam_up.y, cam_up.z, -cam_up.dot(&pos),
                dir.x, dir.y, dir.z, -dir.dot(&pos), 
                0.0,     0.0,  0.0,       1.0,
            },
        };
    }

    pub fn perspective(tanY: f32, aspect: f32, near: f32, far: f32) Mat4 {
        var tanX: f32 = tanY*aspect;
        return Mat4{
            .a = [16]f32 {
                1.0 / tanX, 0.0, 0.0, 0.0,
                0.0, 1.0 / tanY, 0.0, 0.0,
                0.0, 0.0, -(near + far) / (far - near), -2*near*far/(far - near),
                0.0, 0.0, -1.0, 0.0
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
    pub fn mulVec3(mat: *const Mat4, v: *const Vec3f) Vec3f {
        return Vec3f{
            .x = mat.a[0]*v.x + mat.a[1]*v.y + mat.a[2]*v.z,
            .y = mat.a[4]*v.x + mat.a[5]*v.y + mat.a[6]*v.z,
            .z = mat.a[8]*v.x + mat.a[9]*v.y + mat.a[10]*v.z,
        };
    }
};
