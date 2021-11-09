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
		neighborIndex : [6]u32 = u32{0xffffffff} ** 6,
		midPointIndex : [6]u32 = u32{0} ** 6,
		neighbors : u32 = 0,
	};

	const mesh = struct {
		var vertices: [12 << iterations] Vertex = undefined;

		var neighborList: [12 << iterations] FractalDeduplicator = undefined;

		var indices: [20 << 2*iterations] Triangle = undefined;

		fn init() void {
			var t : f32 = (1.0 + @sqrt(5.0))/2.0;
			var u : f32 = 1;
			var len : f32 = @sqrt(t*t+u*u);
			t /= len;
			u /= len;
			t *= 400;
			u *= 400;
			vertices[0] = Vertex{.pos = p.Vec3{-u, t, 0}};
			vertices[1] = Vertex{.pos = p.Vec3{u, t, 0}};
			vertices[2] = Vertex{.pos = p.Vec3{-u, -t, 0}};
			vertices[3] = Vertex{.pos = p.Vec3{u, -t, 0}};

			vertices[4] = Vertex{.pos = p.Vec3{0, -u, t}};
			vertices[5] = Vertex{.pos = p.Vec3{0, u, t}};
			vertices[6] = Vertex{.pos = p.Vec3{0, -u, -t}};
			vertices[7] = Vertex{.pos = p.Vec3{0, u, -t}};

			vertices[8] = Vertex{.pos = p.Vec3{t, 0, -u}};
			vertices[9] = Vertex{.pos = p.Vec3{t, 0, u}};
			vertices[10] = Vertex{.pos = p.Vec3{-t, 0, -u}};
			vertices[11] = Vertex{.pos = p.Vec3{-t, 0, u}};

			indices[0] = Triangle{0, 11, 5};
			indices[1] = Triangle{0, 5, 1};
			indices[2] = Triangle{0, 1, 7};
			indices[3] = Triangle{0, 7, 10};
			indices[4] = Triangle{0, 10, 11};
			
			indices[5] = Triangle{1, 5, 9};
			indices[6] = Triangle{5, 11, 4};
			indices[7] = Triangle{11, 10, 2};
			indices[8] = Triangle{10, 7, 6};
			indices[9] = Triangle{7, 1, 8};
			
			indices[10] = Triangle{3, 9, 4};
			indices[11] = Triangle{3, 4, 2};
			indices[12] = Triangle{3, 2, 6};
			indices[13] = Triangle{3, 6, 8};
			indices[14] = Triangle{3, 8, 9};
			
			indices[15] = Triangle{4, 9, 5};
			indices[16] = Triangle{2, 4, 11};
			indices[17] = Triangle{6, 2, 10};
			indices[18] = Triangle{8, 6, 7};
			indices[19] = Triangle{9, 8, 1};

			var currentVertex : u32 = 12;
			var currentIndex : u32 = 20;
			var iteration : u32 = 0;
			while(iteration < iterations) : (iteration += 1) {
				// Init the neighbor list
				for(neighborList[0..currentVertex]) |*neighbor| {
					neighbor.* = FractalDeduplicator{};
				}
				// Go through the algorithm:
				for(indices[0..currentIndex]) |_, i| {
					split(i, &currentVertex, &currentIndex);
				}
			}
		}

		fn getBetween(v1: u32, v2: u32, currentVertex: *u32) u32 {
			// Check if it is already created:
			for(neighborList[v1][0..6]) |val, idx| {
				if(val == v2) {
					return neighborList[v1][idx + 6];
				}
			}
			vertices[currentVertex.*] = Vertex {
				.pos = p.Vec3 {
					.x = (vertices[v1].x + vertices[v2].x)/2.0,
					.y = (vertices[v1].y + vertices[v2].y)/2.0,
					.z = (vertices[v1].z + vertices[v2].z)/2.0,
				},
			};
			neighborList[v1][neighborList[v1][12]] = v2;
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
			indices[currentIndex.*] = Triangle{indices[index].v1, vert12, vert13};
			currentIndex.* += 1;
			indices[currentIndex.*] = Triangle{indices[index].v2, vert12, vert23};
			currentIndex.* += 1;
			indices[currentIndex.*] = Triangle{indices[index].v3, vert13, vert23};
			currentIndex.* += 1;
			indices[index] = Triangle{vert12, vert13, vert23};
		}
	};

	mesh.init();
	return mesh;
}