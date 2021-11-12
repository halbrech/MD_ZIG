const std = @import("std");

const p = @import("Particle.zig");

pub const Vertex = packed struct {
    pos: p.Vec3,
    norm: p.Vec3 = undefined,
};
pub const Triangle = packed struct {
    v1: u32,
    v2: u32,
    v3: u32,
};

pub fn sphere(comptime iterations: u32) type {
    const FractalDeduplicator = struct {
        neighborIndex: [6]u32 = [_]u32{0xffffffff} ** 6,
        midPointIndex: [6]u32 = [_]u32{0} ** 6,
        neighbors: u32 = 0,
    };

    const Mesh = struct {
        vertices: [10*(1<<(2*iterations)) + 2]Vertex = undefined,

        neighborList: [10*(1<<(2*iterations)) + 2]FractalDeduplicator = undefined,

        indices: [20 << 2 * iterations]Triangle = undefined,

        pub fn init(self: *@This()) void {
            //self.vertices[0] = Vertex{ .pos = p.Vec3{ .x = -1, .y = 0, .z = 0 } };
            //self.vertices[1] = Vertex{ .pos = p.Vec3{ .x = 1, .y = 0, .z = 0 } };
            //self.vertices[2] = Vertex{ .pos = p.Vec3{ .x = 0, .y = -1, .z = 0 } };
            //self.vertices[3] = Vertex{ .pos = p.Vec3{ .x = 0, .y = 1, .z = 0 } };
//
            //self.vertices[4] = Vertex{ .pos = p.Vec3{ .x = 0, .y = 0, .z = -1 } };
            //self.vertices[5] = Vertex{ .pos = p.Vec3{ .x = 0, .y = 0, .z = 1 } };
            //self.indices[0] = Triangle{.v1 = 0, .v2 = 4, .v3 = 2};
            //self.indices[1] = Triangle{.v1 = 0, .v2 = 2, .v3 = 5};
            //self.indices[2] = Triangle{.v1 = 0, .v2 = 3, .v3 = 4};
            //self.indices[3] = Triangle{.v1 = 0, .v2 = 5, .v3 = 3};
            //self.indices[4] = Triangle{.v1 = 1, .v2 = 2, .v3 = 4};
            //self.indices[5] = Triangle{.v1 = 1, .v2 = 5, .v3 = 2};
            //self.indices[6] = Triangle{.v1 = 1, .v2 = 4, .v3 = 3};
            //self.indices[7] = Triangle{.v1 = 1, .v2 = 3, .v3 = 5};
            var t: f32 = (1.0 + @sqrt(5.0)) / 2.0;
            var u: f32 = 1;
            var len: f32 = @sqrt(t * t + u * u);
            t /= len;
            u /= len;
            t *= 400;
            u *= 400;
            self.vertices[0] = Vertex{ .pos = p.Vec3{ .x = -u, .y = t, .z = 0 } };
            self.vertices[1] = Vertex{ .pos = p.Vec3{ .x = u, .y = t, .z = 0 } };
            self.vertices[2] = Vertex{ .pos = p.Vec3{ .x = -u, .y = -t, .z = 0 } };
            self.vertices[3] = Vertex{ .pos = p.Vec3{ .x = u, .y = -t, .z = 0 } };

            self.vertices[4] = Vertex{ .pos = p.Vec3{ .x = 0, .y = -u, .z = t } };
            self.vertices[5] = Vertex{ .pos = p.Vec3{ .x = 0, .y = u, .z = t } };
            self.vertices[6] = Vertex{ .pos = p.Vec3{ .x = 0, .y = -u, .z = -t } };
            self.vertices[7] = Vertex{ .pos = p.Vec3{ .x = 0, .y = u, .z = -t } };

            self.vertices[8] = Vertex{ .pos = p.Vec3{ .x = t, .y = 0, .z = -u } };
            self.vertices[9] = Vertex{ .pos = p.Vec3{ .x = t, .y = 0, .z = u } };
            self.vertices[10] = Vertex{ .pos = p.Vec3{ .x = -t, .y = 0, .z = -u } };
            self.vertices[11] = Vertex{ .pos = p.Vec3{ .x = -t, .y = 0, .z = u } };

            self.indices[0] = Triangle{.v1 = 0, .v2 = 11, .v3 = 5};
            self.indices[1] = Triangle{.v1 = 0, .v2 = 5, .v3 = 1};
            self.indices[2] = Triangle{.v1 = 0, .v2 = 1, .v3 = 7};
            self.indices[3] = Triangle{.v1 = 0, .v2 = 7, .v3 = 10};
            self.indices[4] = Triangle{.v1 = 0, .v2 = 10, .v3 = 11};

            self.indices[5] = Triangle{.v1 = 1, .v2 = 5, .v3 = 9};
            self.indices[6] = Triangle{.v1 = 5, .v2 = 11, .v3 = 4};
            self.indices[7] = Triangle{.v1 = 11, .v2 = 10, .v3 = 2};
            self.indices[8] = Triangle{.v1 = 10, .v2 = 7, .v3 = 6};
            self.indices[9] = Triangle{.v1 = 7, .v2 = 1, .v3 = 8};

            self.indices[10] = Triangle{.v1 = 3, .v2 = 9, .v3 = 4};
            self.indices[11] = Triangle{.v1 = 3, .v2 = 4, .v3 = 2};
            self.indices[12] = Triangle{.v1 = 3, .v2 = 2, .v3 = 6};
            self.indices[13] = Triangle{.v1 = 3, .v2 = 6, .v3 = 8};
            self.indices[14] = Triangle{.v1 = 3, .v2 = 8, .v3 = 9};

            self.indices[15] = Triangle{.v1 = 4, .v2 = 9, .v3 = 5};
            self.indices[16] = Triangle{.v1 = 2, .v2 = 4, .v3 = 11};
            self.indices[17] = Triangle{.v1 = 6, .v2 = 2, .v3 = 10};
            self.indices[18] = Triangle{.v1 = 8, .v2 = 6, .v3 = 7};
            self.indices[19] = Triangle{.v1 = 9, .v2 = 8, .v3 = 1};

            var currentVertex: u32 = 12;
            var currentIndex: u32 = 20;
            //var currentVertex: u32 = 6;
            //var currentIndex: u32 = 8;
            var iteration: u32 = 0;
            while (iteration < iterations) : (iteration += 1) {
                // Init the neighbor list
                for (self.neighborList[0..currentVertex]) |*neighbor| {
                    neighbor.* = FractalDeduplicator{};
                }
                // Go through the algorithm:
                for (self.indices[0..currentIndex]) |_, i| {
                    self.split(@intCast(u32, i), &currentVertex, &currentIndex);
                }
            }

            // Scale the vertices to radius 1:
            for (self.vertices) |_, i| {
                self.vertices[i].pos = self.vertices[i].pos.mul(1/@sqrt(self.vertices[i].pos.valueSquare()));
                self.vertices[i].norm = self.vertices[i].pos;
            }
        }

        fn getBetween(self: *@This(), v1: u32, v2: u32, currentVertex: *u32) u32 {
            // Check if it is already created:
            for (self.neighborList[v1].neighborIndex) |val, idx| {
                if (val == v2) {
                    return self.neighborList[v1].midPointIndex[idx];
                }
            }
            self.vertices[currentVertex.*] = Vertex{
                .pos = p.Vec3{
                    .x = (self.vertices[v1].pos.x + self.vertices[v2].pos.x) / 2.0,
                    .y = (self.vertices[v1].pos.y + self.vertices[v2].pos.y) / 2.0,
                    .z = (self.vertices[v1].pos.z + self.vertices[v2].pos.z) / 2.0,
                },
            };
            
            self.neighborList[v1].neighborIndex[self.neighborList[v1].neighbors] = v2;
            self.neighborList[v1].midPointIndex[self.neighborList[v1].neighbors] = currentVertex.*;
            self.neighborList[v1].neighbors += 1;
            self.neighborList[v2].neighborIndex[self.neighborList[v2].neighbors] = v1;
            self.neighborList[v2].midPointIndex[self.neighborList[v2].neighbors] = currentVertex.*;
            self.neighborList[v2].neighbors += 1;

            currentVertex.* += 1;
            return currentVertex.* - 1;
        }

        fn split(self: *@This(), index: u32, currentVertex: *u32, currentIndex: *u32) void {
            var vert12: u32 = self.getBetween(self.indices[index].v1, self.indices[index].v2, currentVertex);
            var vert13: u32 = self.getBetween(self.indices[index].v1, self.indices[index].v3, currentVertex);
            var vert23: u32 = self.getBetween(self.indices[index].v2, self.indices[index].v3, currentVertex);
            self.indices[currentIndex.*] = Triangle{.v1 = self.indices[index].v1, .v2 = vert12, .v3 = vert13};
            currentIndex.* += 1;
            self.indices[currentIndex.*] = Triangle{.v1 = self.indices[index].v2, .v2 = vert23, .v3 = vert12};
            currentIndex.* += 1;
            self.indices[currentIndex.*] = Triangle{.v1 = self.indices[index].v3, .v2 = vert13, .v3 = vert23};
            currentIndex.* += 1;
            self.indices[index] = Triangle{.v1 = vert12, .v2 = vert23, .v3 = vert13};
        }
    };

    return Mesh;
}