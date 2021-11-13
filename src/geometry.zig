const std = @import("std");
const print = std.debug.print;

const m = @import("math.zig");


pub const Vertex = struct {
    pos: m.Vec3f = undefined,
    norm: m.Vec3f = undefined,
};
pub const Triangle = packed struct {
    v1: u32,
    v2: u32,
    v3: u32,
};

pub const MeshData = struct {
    vs: []Vertex,
    ts: []Triangle,
};


pub fn lerp(a: *const m.Vec3f, b: *const m.Vec3f, va: f32, vb: f32, level: f32) m.Vec3f {
    if(std.math.fabs(level - va) < 0.00001) return a.*;
    if(std.math.fabs(level - vb) < 0.00001) return b.*;
    if(std.math.fabs(va - vb) < 0.00001) return a.*;
    const mu = (level - va) / (vb - va);
    return m.Vec3f{.x = a.x + mu * (b.x - a.x), .y = a.y + mu * (b.y - a.y), .z = a.z + mu * (b.z - a.z)};
    // return a.scaledAdd(&b.sub(a), mu);
}


const GridCell = struct {
    positions: [8] m.Vec3f,
    values: [8] f32,
};

pub fn polygonizeTetrahedron(cell: *const GridCell, level: f32, vertex_buffer: *std.ArrayList(Vertex), v0: usize, v1: usize, v2: usize, v3: usize) !void {
    var idx: u8 = 0;
    if(cell.values[v0] < level) idx = idx | 1;
    if(cell.values[v1] < level) idx = idx | 2;
    if(cell.values[v2] < level) idx = idx | 4;
    if(cell.values[v3] < level) idx = idx | 8;
    _ = vertex_buffer;

    switch(idx) {
        0x00, 0x0F => {},
        0x01 => {
            const a = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const b = lerp(&cell.positions[v0], &cell.positions[v3], cell.values[v0], cell.values[v3], level);
            const c = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
        
        },
        0x0E => {
            const a = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const b = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const c = lerp(&cell.positions[v0], &cell.positions[v3], cell.values[v0], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
        },

        0x02 => {
            const a = lerp(&cell.positions[v1], &cell.positions[v0], cell.values[v1], cell.values[v0], level);
            const b = lerp(&cell.positions[v1], &cell.positions[v2], cell.values[v1], cell.values[v2], level);
            const c = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});

        },
        0x0D => {
            const a = lerp(&cell.positions[v1], &cell.positions[v0], cell.values[v1], cell.values[v0], level);
            const b = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const c = lerp(&cell.positions[v1], &cell.positions[v2], cell.values[v1], cell.values[v2], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
        },

        0x03 => {
            const a = lerp(&cell.positions[v0], &cell.positions[v3], cell.values[v0], cell.values[v3], level);
            const b = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const c = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});

            const d = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const e = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const f = lerp(&cell.positions[v1], &cell.positions[v2], cell.values[v1], cell.values[v2], level);
            const norm2 = e.sub(&d).cross(&f.sub(&d)).normalize();
            try vertex_buffer.append(Vertex{.pos = d, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = e, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = f, .norm = norm2});
        },
        0x0C => {
            const a = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const b = lerp(&cell.positions[v0], &cell.positions[v3], cell.values[v0], cell.values[v3], level);
            const c = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
            
            const d = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const e = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const f = lerp(&cell.positions[v1], &cell.positions[v2], cell.values[v1], cell.values[v2], level);
            const norm2 = e.sub(&d).cross(&f.sub(&d)).normalize();
            try vertex_buffer.append(Vertex{.pos = d, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = e, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = f, .norm = norm2});
        },

        0x04 => {
            const a = lerp(&cell.positions[v2], &cell.positions[v0], cell.values[v2], cell.values[v0], level);
            const b = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const c = lerp(&cell.positions[v2], &cell.positions[v1], cell.values[v2], cell.values[v1], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
        },
        0x0B => {
            const a = lerp(&cell.positions[v2], &cell.positions[v0], cell.values[v2], cell.values[v0], level);
            const b = lerp(&cell.positions[v2], &cell.positions[v1], cell.values[v2], cell.values[v1], level);
            const c = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
        },

        0x05 => {
            const a = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const b = lerp(&cell.positions[v0], &cell.positions[v3], cell.values[v0], cell.values[v3], level);
            const c = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});

            const d = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const e = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const f = lerp(&cell.positions[v1], &cell.positions[v2], cell.values[v1], cell.values[v2], level);
            const norm2 = e.sub(&d).cross(&f.sub(&d)).normalize();
            try vertex_buffer.append(Vertex{.pos = d, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = e, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = f, .norm = norm2});
        },
        0x0A => {
            const a = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const b = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const c = lerp(&cell.positions[v0], &cell.positions[v3], cell.values[v0], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});

            const d = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const e = lerp(&cell.positions[v1], &cell.positions[v2], cell.values[v1], cell.values[v2], level);
            const f = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const norm2 = e.sub(&d).cross(&f.sub(&d)).normalize();
            try vertex_buffer.append(Vertex{.pos = d, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = e, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = f, .norm = norm2});
        },
        

        0x06 => {
            const a = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const b = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const c = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});  
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
            
            const d = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const e = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const f = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const norm2 = e.sub(&d).cross(&f.sub(&d)).normalize();
            try vertex_buffer.append(Vertex{.pos = d, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = e, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = f, .norm = norm2});
        },
        0x09 => {
            const a = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const b = lerp(&cell.positions[v1], &cell.positions[v3], cell.values[v1], cell.values[v3], level);
            const c = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});  

            const d = lerp(&cell.positions[v0], &cell.positions[v1], cell.values[v0], cell.values[v1], level);
            const e = lerp(&cell.positions[v2], &cell.positions[v3], cell.values[v2], cell.values[v3], level);
            const f = lerp(&cell.positions[v0], &cell.positions[v2], cell.values[v0], cell.values[v2], level);
            const norm2 = e.sub(&d).cross(&f.sub(&d)).normalize();
            try vertex_buffer.append(Vertex{.pos = d, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = e, .norm = norm2});
            try vertex_buffer.append(Vertex{.pos = f, .norm = norm2});
        },

        0x07 => {
            const a = lerp(&cell.positions[v3], &cell.positions[v0], cell.values[v3], cell.values[v0], level);
            const b = lerp(&cell.positions[v3], &cell.positions[v2], cell.values[v3], cell.values[v2], level);
            const c = lerp(&cell.positions[v3], &cell.positions[v1], cell.values[v3], cell.values[v1], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
        },
        0x08 => {
            const a = lerp(&cell.positions[v3], &cell.positions[v0], cell.values[v3], cell.values[v0], level);
            const b = lerp(&cell.positions[v3], &cell.positions[v1], cell.values[v3], cell.values[v1], level);
            const c = lerp(&cell.positions[v3], &cell.positions[v2], cell.values[v3], cell.values[v2], level);
            const norm = b.sub(&a).cross(&c.sub(&a)).normalize();
            try vertex_buffer.append(Vertex{.pos = a, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = b, .norm = norm});
            try vertex_buffer.append(Vertex{.pos = c, .norm = norm});
        },
        else => {
            print("Hit else case!", .{});
        }

    }
    // return num_triangles;
}

pub fn marchingTetrahedra(f: *const fn(f32, f32, f32) f32, level: f32, num_x: usize, num_y: usize, num_z: usize, start: m.Vec3f, step_size: f32) !MeshData{
    // _ = start;
    // _ = step_size;
    // return anyerror.Error;

    // precalculate main grid;
    var grid: [] f32 = try std.heap.page_allocator.alloc(f32, num_x * num_y * num_z);

    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while(k < num_z) : (k += 1) {
        j = 0;
        while(j < num_y) : (j += 1) {
            i = 0;
            while(i < num_x) : (i += 1) {
                grid[k * num_y * num_x + j * num_x + i] = 
                    f.*(start.x + step_size * @intToFloat(f32, i), 
                        start.y + step_size * @intToFloat(f32, j), 
                        start.z + step_size * @intToFloat(f32, k));
                // print("{}\n", .{grid[k * num_y * num_x + j * num_x + i]});

            }
        }
    }
    
    var vertex_buffer: std.ArrayList(Vertex) = std.ArrayList(Vertex).init(std.heap.page_allocator);
    try vertex_buffer.ensureTotalCapacity(1000);
    
    // try vertex_buffer.append(Vertex{.pos = m.Vec3f{.x = 0.0, .y = 0.0, .z = 0.0}});
    // try vertex_buffer.append(Vertex{.pos = m.Vec3f{.x = 0.0, .y = 0.5, .z = 0.0}});
    // try vertex_buffer.append(Vertex{.pos = m.Vec3f{.x = 0.5, .y = 0.5, .z = 0.0}});

    var cell: GridCell = undefined;
    k = 0;
    while(k < (num_z - 1)) : (k += 1) {
        j = 0;
        while(j < (num_y - 1)) : (j += 1) {
            i = 0;
            while(i < (num_x - 1)) : (i += 1) {
                cell.positions[0] = m.Vec3f{.x = start.x + @intToFloat(f32, i) * step_size, .y = start.y + @intToFloat(f32, j) * step_size, .z = start.z + @intToFloat(f32, k) * step_size};
                cell.positions[1] = m.Vec3f{.x = start.x + @intToFloat(f32, i+1) * step_size, .y = start.y + @intToFloat(f32, j) * step_size, .z = start.z + @intToFloat(f32, k) * step_size};
                cell.positions[2] = m.Vec3f{.x = start.x + @intToFloat(f32, i) * step_size, .y = start.y + @intToFloat(f32, j+1) * step_size, .z = start.z + @intToFloat(f32, k) * step_size};
                cell.positions[3] = m.Vec3f{.x = start.x + @intToFloat(f32, i+1) * step_size, .y = start.y + @intToFloat(f32, j+1) * step_size, .z = start.z + @intToFloat(f32, k) * step_size};
                cell.positions[4] = m.Vec3f{.x = start.x + @intToFloat(f32, i) * step_size, .y = start.y + @intToFloat(f32, j) * step_size, .z = start.z + @intToFloat(f32, k+1) * step_size};
                cell.positions[5] = m.Vec3f{.x = start.x + @intToFloat(f32, i+1) * step_size, .y = start.y + @intToFloat(f32, j) * step_size, .z = start.z + @intToFloat(f32, k+1) * step_size};
                cell.positions[6] = m.Vec3f{.x = start.x + @intToFloat(f32, i) * step_size, .y = start.y + @intToFloat(f32, j+1) * step_size, .z = start.z + @intToFloat(f32, k+1) * step_size};
                cell.positions[7] = m.Vec3f{.x = start.x + @intToFloat(f32, i+1) * step_size, .y = start.y + @intToFloat(f32, j+1) * step_size, .z = start.z + @intToFloat(f32, k+1) * step_size};
                
                cell.values[0] = grid[(k) * num_y * num_x + (j) * num_x + i];
                cell.values[1] = grid[(k) * num_y * num_x + (j) * num_x + i+1];
                cell.values[2] = grid[(k) * num_y * num_x + (j+1) * num_x + i];
                cell.values[3] = grid[(k) * num_y * num_x + (j+1) * num_x + i+1];
                cell.values[4] = grid[(k+1) * num_y * num_x + (j) * num_x + i];
                cell.values[5] = grid[(k+1) * num_y * num_x + (j) * num_x + i+1];
                cell.values[6] = grid[(k+1) * num_y * num_x + (j+1) * num_x + i];
                cell.values[7] = grid[(k+1) * num_y * num_x + (j+1) * num_x + i+1];
                
                try polygonizeTetrahedron(&cell, level, &vertex_buffer, 0, 3, 1, 5);
                try polygonizeTetrahedron(&cell, level, &vertex_buffer, 0, 3, 5, 7);
                try polygonizeTetrahedron(&cell, level, &vertex_buffer, 0, 4, 7, 5);
                try polygonizeTetrahedron(&cell, level, &vertex_buffer, 0, 7, 2, 3);
                try polygonizeTetrahedron(&cell, level, &vertex_buffer, 0, 7, 4, 2);
                try polygonizeTetrahedron(&cell, level, &vertex_buffer, 6, 7, 2, 4);
            }
        }
    }

    print("Generated {} vertices\n", .{vertex_buffer.items.len});

    var triangle_buffer: std.ArrayList(Triangle) = std.ArrayList(Triangle).init(std.heap.page_allocator);
    try triangle_buffer.ensureTotalCapacity(vertex_buffer.items.len);

    var n: u32 = 0;
    while(n < vertex_buffer.items.len) : (n += 1) {
        if(n % 3 == 0){
        try triangle_buffer.append(Triangle{.v1 = n, .v2 = n + 1, .v3 = n + 2});
        }
    }

    return MeshData{.vs = vertex_buffer.items, .ts = triangle_buffer.items};
}


pub fn Sphere(comptime iterations: u32) type {
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
            self.vertices[0] = Vertex{ .pos = m.Vec3f{ .x = -u, .y = t, .z = 0 } };
            self.vertices[1] = Vertex{ .pos = m.Vec3f{ .x = u, .y = t, .z = 0 } };
            self.vertices[2] = Vertex{ .pos = m.Vec3f{ .x = -u, .y = -t, .z = 0 } };
            self.vertices[3] = Vertex{ .pos = m.Vec3f{ .x = u, .y = -t, .z = 0 } };

            self.vertices[4] = Vertex{ .pos = m.Vec3f{ .x = 0, .y = -u, .z = t } };
            self.vertices[5] = Vertex{ .pos = m.Vec3f{ .x = 0, .y = u, .z = t } };
            self.vertices[6] = Vertex{ .pos = m.Vec3f{ .x = 0, .y = -u, .z = -t } };
            self.vertices[7] = Vertex{ .pos = m.Vec3f{ .x = 0, .y = u, .z = -t } };

            self.vertices[8] = Vertex{ .pos = m.Vec3f{ .x = t, .y = 0, .z = -u } };
            self.vertices[9] = Vertex{ .pos = m.Vec3f{ .x = t, .y = 0, .z = u } };
            self.vertices[10] = Vertex{ .pos = m.Vec3f{ .x = -t, .y = 0, .z = -u } };
            self.vertices[11] = Vertex{ .pos = m.Vec3f{ .x = -t, .y = 0, .z = u } };

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
                .pos = m.Vec3f{
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
