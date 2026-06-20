const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    const n: usize = if (args.len > 1)
        try std.fmt.parseInt(usize, args[1], 10)
    else
        1_000_000;
    
    var map = std.AutoHashMap(usize, usize).init(allocator);
    defer map.deinit();
    
    try map.ensureTotalCapacity(@intCast(n));
    
    // Insertion benchmark
    var timer = try std.time.Timer.start();
    var i: usize = 0;
    while (i < n) : (i += 1) {
        try map.put(i, i * 2);
    }
    const insert_duration = timer.read();
    
    // Lookup benchmark
    timer.reset();
    var sum: usize = 0;
    i = 0;
    while (i < n) : (i += 1) {
        if (map.get(i)) |val| {
            sum += val;
        }
    }
    const lookup_duration = timer.read();
    
    // Mixed workload
    timer.reset();
    i = 0;
    while (i < n / 10) : (i += 1) {
        try map.put(n + i, i);
        _ = map.remove(i * 2);
        _ = map.get(i * 3 % n);
    }
    const mixed_duration = timer.read();
    
    const stdout = std.io.getStdOut().writer();
    try stdout.print("HashMap benchmark ({} items):\n", .{n});
    try stdout.print("  Insert:  {} ns ({d:.0} ops/sec)\n", 
                     .{insert_duration, 
                       @as(f64, @floatFromInt(n)) / (@as(f64, @floatFromInt(insert_duration)) / 1e9)});
    try stdout.print("  Lookup:  {} ns ({d:.0} ops/sec)\n", 
                     .{lookup_duration,
                       @as(f64, @floatFromInt(n)) / (@as(f64, @floatFromInt(lookup_duration)) / 1e9)});
    try stdout.print("  Mixed:   {} ns\n", .{mixed_duration});
    try stdout.print("  Sum:     {} (verification)\n", .{sum});
    try stdout.print("  Final size: {}\n", .{map.count()});
}