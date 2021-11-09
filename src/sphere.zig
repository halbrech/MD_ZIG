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

    const mesh = struct {
        var vertices: [12 << iterations]Vertex = undefined;

        var neighborList: [12 << iterations]FractalDeduplicator = undefined;

        var indices: [20 << 2 * iterations]Triangle = undefined;

        fn init() void {
            var t: f32 = (1.0 + @sqrt(5.0)) / 2.0;
            var u: f32 = 1;
            var len: f32 = @sqrt(t * t + u * u);
            t /= len;
            u /= len;
            t *= 400;
            u *= 400;
            vertices[0] = Vertex{ .pos = p.Vec3{ .x = -u, .y = t, .z = 0 } };
            vertices[1] = Vertex{ .pos = p.Vec3{ .x = u, .y = t, .z = 0 } };
            vertices[2] = Vertex{ .pos = p.Vec3{ .x = -u, .y = -t, .z = 0 } };
            vertices[3] = Vertex{ .pos = p.Vec3{ .x = u, .y = -t, .z = 0 } };

            vertices[4] = Vertex{ .pos = p.Vec3{ .x = 0, .y = -u, .z = t } };
            vertices[5] = Vertex{ .pos = p.Vec3{ .x = 0, .y = u, .z = t } };
            vertices[6] = Vertex{ .pos = p.Vec3{ .x = 0, .y = -u, .z = -t } };
            vertices[7] = Vertex{ .pos = p.Vec3{ .x = 0, .y = u, .z = -t } };

            vertices[8] = Vertex{ .pos = p.Vec3{ .x = t, .y = 0, .z = -u } };
            vertices[9] = Vertex{ .pos = p.Vec3{ .x = t, .y = 0, .z = u } };
            vertices[10] = Vertex{ .pos = p.Vec3{ .x = -t, .y = 0, .z = -u } };
            vertices[11] = Vertex{ .pos = p.Vec3{ .x = -t, .y = 0, .z = u } };

            indices[0] = Triangle{ .v1 = 0, .v2 = 11, .v3 = 5 };
            indices[1] = Triangle{ .v1 = 0, .v2 = 5, .v3 = 1 };
            indices[2] = Triangle{ .v1 = 0, .v2 = 1, .v3 = 7 };
            indices[3] = Triangle{ .v1 = 0, .v2 = 7, .v3 = 10 };
            indices[4] = Triangle{ .v1 = 0, .v2 = 10, .v3 = 11 };

            indices[5] = Triangle{ .v1 = 1, .v2 = 5, .v3 = 9 };
            indices[6] = Triangle{ .v1 = 5, .v2 = 11, .v3 = 4 };
            indices[7] = Triangle{ .v1 = 11, .v2 = 10, .v3 = 2 };
            indices[8] = Triangle{ .v1 = 10, .v2 = 7, .v3 = 6 };
            indices[9] = Triangle{ .v1 = 7, .v2 = 1, .v3 = 8 };

            indices[10] = Triangle{ .v1 = 3, .v2 = 9, .v3 = 4 };
            indices[11] = Triangle{ .v1 = 3, .v2 = 4, .v3 = 2 };
            indices[12] = Triangle{ .v1 = 3, .v2 = 2, .v3 = 6 };
            indices[13] = Triangle{ .v1 = 3, .v2 = 6, .v3 = 8 };
            indices[14] = Triangle{ .v1 = 3, .v2 = 8, .v3 = 9 };

            indices[15] = Triangle{ .v1 = 4, .v2 = 9, .v3 = 5 };
            indices[16] = Triangle{ .v1 = 2, .v2 = 4, .v3 = 11 };
            indices[17] = Triangle{ .v1 = 6, .v2 = 2, .v3 = 10 };
            indices[18] = Triangle{ .v1 = 8, .v2 = 6, .v3 = 7 };
            indices[19] = Triangle{ .v1 = 9, .v2 = 8, .v3 = 1 };

            var currentVertex: u32 = 12;
            var currentIndex: u32 = 20;
            var iteration: u32 = 0;
            while (iteration < iterations) : (iteration += 1) {
                // Init the neighbor list
                for (neighborList[0..currentVertex]) |*neighbor| {
                    neighbor.* = FractalDeduplicator{};
                }
                // Go through the algorithm:
                for (indices[0..currentIndex]) |_, i| {
                    split(@intCast(usize, i), &currentVertex, &currentIndex);
                }
            }
        }

        fn getBetween(v1: u32, v2: u32, currentVertex: *u32) u32 {
            // Check if it is already created:
            // NOTE(Janis): @Jannis ist das hier richtig? Ich hab versucht, das zu fixen.
            // Der originalcode hatte keinen Sinn ergeben...(array oob access), wir können
            // das sonst auch reverten.
            for (neighborList[v1].neighborIndex) |val| {
                if (val == v2) {
                    return neighborList[v1].neighborIndex[val];
                }
            }
            vertices[currentVertex.*] = Vertex{
                .pos = p.Vec3{
                    .x = (vertices[v1].x + vertices[v2].x) / 2.0,
                    .y = (vertices[v1].y + vertices[v2].y) / 2.0,
                    .z = (vertices[v1].z + vertices[v2].z) / 2.0,
                },
            };
            // NOTE(Janis): auch hier, neighborList ist ein 1D Array... (hab's nicht verändert)
            neighborList[v1][6 + neighborList[v1][12]] = v2;
            neighborList[v1][6 + neighborList[v1][12]] = currentVertex.*;
            neighborList[v2][neighborList[v2][12]] = v1;
            neighborList[v2][6 + neighborList[v2][12]] = currentVertex.*;

            currentVertex.* += 1;
            return currentVertex.* - 1;
        }

        fn split(index: u32, currentVertex: *u32, currentIndex: *u32) void {
            var vert12: u32 = getBetween(indices[index].v1, indices[index].v2, currentVertex);
            var vert13: u32 = getBetween(indices[index].v1, indices[index].v3, currentVertex);
            var vert23: u32 = getBetween(indices[index].v2, indices[index].v3, currentVertex);
            indices[currentIndex.*] = Triangle{ indices[index].v1, vert12, vert13 };
            currentIndex.* += 1;
            indices[currentIndex.*] = Triangle{ indices[index].v2, vert12, vert23 };
            currentIndex.* += 1;
            indices[currentIndex.*] = Triangle{ indices[index].v3, vert13, vert23 };
            currentIndex.* += 1;
            indices[index] = Triangle{ vert12, vert13, vert23 };
        }
    };

    mesh.init();
    return mesh;
}
