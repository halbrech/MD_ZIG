// const std = @import("std");
// 
// fn Vector(comptime T: type, m: usize) type {
//     const iter_i: [m] u32 = [_]u32{undefined} ** m;
//     return packed struct {
//         d: [m]T,
// 
//         pub fn ones() @This() {
//             var ret: @This() = undefined;
//             inline for(iter_i) |_, i| {
//                 ret.d[i] = 1;
//             }
//             return ret;
//         }
// 
//         pub fn zeros() @This() {
//             var ret: @This() = undefined;
//             for(iter_i) |_, i| {
//                 ret.d[i] = 0;
//             }
//             return ret;
//         }
// 
//         pub fn add(a: *const @This(), b: *const @This()) @This() {
//             var ret: @This() = undefined;
//             for(iter_i) |_, i| {
//                 ret.d[i] = a.d[i] + b.d[i];
//             }
//             return ret;
//         }
//         
//         pub fn sub(a: *const @This(), b: *const @This()) @This() {
//             var ret: @This() = undefined;
//             for(iter_i) |_, i| {
//                 ret.d[i] = a.d[i] - b.d[i];
//             }
//             return ret;
//         }
// 
//         pub fn dot(a: *const @This(), b: *const @This()) T {
//             var ret: T = 0;
//             for(iter_i) |_, i| {
//                 ret += a.d[i] * b.d[i];
//             }
//             return ret;
//         }
// 
//         pub fn lensq(a: *const @This()) T {
//             var ret: T = 0;
//             for(iter_i) |_, i| {
//                 ret += a.d[i] * a.d[i];
//             }
//             return ret;
//         }
// 
//         pub fn len(a: *const @This()) T {
//             return @sqrt(a.lensq());
//         }
// 
//         pub fn distsq(a: *const @This(), b: *const @This()) T {
//             return lensq(a.sub(&b));
//         }
// 
//         pub fn dist(a: *const @This(), b: *const @This()) T {
//             return len(a.sub(&b));
//         }
// 
//         // only valid for m=3
//         pub fn cross(a: *const @This(), b: *const @This()) T {
//             var ret: @This() = undefined;
//             ret.d[0] = a.d[1] * b.d[2] - a.d[2] * b.d[1];
//             ret.d[1] = a.d[2] * b.d[0] - a.d[0] * b.d[2];
//             ret.d[2] = a.d[0] * b.d[1] - a.d[1] * b.d[0];
//             return ret;
//         }
//     };
// }
// 
// fn Matrix(comptime T: type, comptime m: usize, comptime n: usize) type {
//     const iter_i: [m] u32 = [_]u32{undefined} ** m;
//     const iter_j: [n] u32 = [_]u32{undefined} ** n;
//     return packed struct {
//         d: [m][n]T,
//         
// 
//         pub fn identity() @This() {
//             comptime {
//                 var ret: @This() = undefined;
//                 inline for(ret.d) |*r, i| {
//                     inline for(r) |_, j| {
//                         if(i == j) {
//                             ret.d[i][j] = 1;
//                         } else {
//                             ret.d[i][j] = 0;
//                         }
//                     }
//                 }
//                 return ret;
//             }
//         }
// 
//         pub fn zeros() @This() {
//             comptime {
//                 var ret: @This() = undefined;
//                 for(ret.d) |*r, i| {
//                     for(r) |_, j| {
//                         ret.d[i][j] = 0;
//                     }
//                 }
//                 return ret;
//             }
//         }
// 
//         pub fn ones() @This() {
//             comptime {
//                 var ret: @This() = undefined;
//                 for(ret.d) |*r, i| {
//                     for(r) |_, j| {
//                         ret.d[i][j] = 1;
//                     }
//                 }
//                 return ret;
//             }
//         }
// 
//         pub fn add(a: *const @This(), b: *const @This()) @This() {
//             var ret: @This() = undefined;
// 
//             inline for(iter_i) |_, i| {
//                 inline for(iter_j) |_, j| {
//                     ret.d[i][j] = a.d[i][j] + b.d[i][j];
//                 }
//             }
//             return ret;
//         }
// 
//         pub fn mul(a: *const @This(), b: *const @This()) void {
//             _ = a;
//             _ = b;
//         }
// 
//         pub fn vmul(mat: *const @This(), vec: *const Vector(T, m)) void {
//             _ = mat;
//             _ = vec;
//         }
//     };
// }
// 
// // pub fn matmul(comptime T: type, comptime m: usize, comptime n: usize, comptime o: usize, a: *const Matrix(T, m, n), b: *const Matrix(T, n, o)) Matrix(T, m, o) {
// //     var ret = Matrix(f32, m, o).zeros();
// //     inline for(a.d) |i| {
// //         var k = 0;
// //         while(k < o) : (k += 1) {
// //             inline for(b.d) |j| {
// //                 ret.d[i][k] += a[i][j] * b[j][k];
// //             }
// //         }
// //     }
// //     return ret;
// // }
// 
// pub const Vec1f = Vector(f32, 1);
// pub const Vec2f = Vector(f32, 2);
// pub const Vec3f = Vector(f32, 3);
// pub const Vec4f = Vector(f32, 4);
// pub const Mat2f = Matrix(f32, 2, 2);
// pub const Mat3f = Matrix(f32, 3, 3);
// pub const Mat4f = Matrix(f32, 4, 4);
// pub const Vec1d = Vector(f64, 1);
// pub const Vec2d = Vector(f64, 2);
// pub const Vec3d = Vector(f64, 3);
// pub const Vec4d = Vector(f64, 4);
// pub const Mat2d = Matrix(f64, 2, 2);
// pub const Mat3d = Matrix(f64, 3, 3);
// pub const Mat4d = Matrix(f64, 4, 4);
