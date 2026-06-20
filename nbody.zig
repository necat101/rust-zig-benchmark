const std = @import("std");
const math = std.math;

const SOLAR_MASS: f64 = 4.0 * math.pi * math.pi;
const DAYS_PER_YEAR: f64 = 365.24;

const Body = struct {
    x: f64,
    y: f64,
    z: f64,
    vx: f64,
    vy: f64,
    vz: f64,
    mass: f64,
};

fn advance(bodies: []Body, dt: f64) void {
    const n = bodies.len;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var j: usize = i + 1;
        while (j < n) : (j += 1) {
            const dx = bodies[i].x - bodies[j].x;
            const dy = bodies[i].y - bodies[j].y;
            const dz = bodies[i].z - bodies[j].z;
            
            const dist_sq = dx * dx + dy * dy + dz * dz;
            const dist = @sqrt(dist_sq);
            const mag = dt / (dist_sq * dist);
            
            bodies[i].vx -= dx * bodies[j].mass * mag;
            bodies[i].vy -= dy * bodies[j].mass * mag;
            bodies[i].vz -= dz * bodies[j].mass * mag;
            
            bodies[j].vx += dx * bodies[i].mass * mag;
            bodies[j].vy += dy * bodies[i].mass * mag;
            bodies[j].vz += dz * bodies[i].mass * mag;
        }
    }
    
    for (bodies) |*body| {
        body.x += dt * body.vx;
        body.y += dt * body.vy;
        body.z += dt * body.vz;
    }
}

fn energy(bodies: []const Body) f64 {
    var e: f64 = 0.0;
    const n = bodies.len;
    
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const bi = &bodies[i];
        e += 0.5 * bi.mass * (bi.vx * bi.vx + bi.vy * bi.vy + bi.vz * bi.vz);
        
        var j: usize = i + 1;
        while (j < n) : (j += 1) {
            const bj = &bodies[j];
            const dx = bi.x - bj.x;
            const dy = bi.y - bj.y;
            const dz = bi.z - bj.z;
            const dist = @sqrt(dx * dx + dy * dy + dz * dz);
            e -= bi.mass * bj.mass / dist;
        }
    }
    
    return e;
}

fn offsetMomentum(bodies: []Body) void {
    var px: f64 = 0.0;
    var py: f64 = 0.0;
    var pz: f64 = 0.0;
    
    for (bodies[0..4]) |body| {
        px += body.vx * body.mass;
        py += body.vy * body.mass;
        pz += body.vz * body.mass;
    }
    
    bodies[4].vx = -px / SOLAR_MASS;
    bodies[4].vy = -py / SOLAR_MASS;
    bodies[4].vz = -pz / SOLAR_MASS;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    const n: usize = if (args.len > 1) 
        try std.fmt.parseInt(usize, args[1], 10) 
    else 
        1000000;
    
    var bodies = [_]Body{
        // Sun
        .{ .x = 0.0, .y = 0.0, .z = 0.0, .vx = 0.0, .vy = 0.0, .vz = 0.0, .mass = SOLAR_MASS },
        // Jupiter
        .{
            .x = 4.841431442464721,
            .y = -1.1603200440274284,
            .z = -0.10362204447112311,
            .vx = 0.0016600764578451321,
            .vy = 0.007699011184197091,
            .vz = -0.00006904600108300421,
            .mass = 0.0009547919384243274,
        },
        // Saturn
        .{
            .x = 8.343366718244578,
            .y = 4.124798564124305,
            .z = -0.40352341711432277,
            .vx = -0.0027674251075562036,
            .vy = 0.004998528012349172,
            .vz = 0.000023041729564993395,
            .mass = 0.0002858859806661308,
        },
        // Uranus
        .{
            .x = 12.894369562139131,
            .y = -15.1111514016986,
            .z = -0.22330757889265573,
            .vx = 0.002964243688581652,
            .vy = 0.0023784717395940443,
            .vz = -0.0000296589569679825,
            .mass = 0.00004366244043351492,
        },
        // Neptune
        .{
            .x = 15.379697114850916,
            .y = -25.91931460998798,
            .z = 0.17925877295037118,
            .vx = 0.002680677724903865,
            .vy = 0.0016282417029464133,
            .vz = -0.00009515922545186363,
            .mass = 0.00005151389020466227,
        },
    };
    
    offsetMomentum(&bodies);
    
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d:.9}\n", .{energy(&bodies)});
    
    const dt = 0.01;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        advance(&bodies, dt);
    }
    
    try stdout.print("{d:.9}\n", .{energy(&bodies)});
}