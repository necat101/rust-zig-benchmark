const std = @import("std");

const Node = struct {
    left: ?*Node,
    right: ?*Node,
    
    fn init(allocator: std.mem.Allocator, depth: usize) !*Node {
        const node = try allocator.create(Node);
        if (depth == 0) {
            node.* = .{ .left = null, .right = null };
        } else {
            node.* = .{
                .left = try init(allocator, depth - 1),
                .right = try init(allocator, depth - 1),
            };
        }
        return node;
    }
    
    fn deinit(self: *Node, allocator: std.mem.Allocator) void {
        if (self.left) |left| {
            left.deinit(allocator);
            allocator.destroy(left);
        }
        if (self.right) |right| {
            right.deinit(allocator);
            allocator.destroy(right);
        }
    }
    
    fn check(self: *const Node) i32 {
        if (self.left == null and self.right == null) {
            return 1;
        } else {
            return 1 + self.left.?.check() + self.right.?.check();
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    const n: usize = if (args.len > 1)
        try std.fmt.parseInt(usize, args[1], 10)
    else
        20;
    
    const stdout = std.io.getStdOut().writer();
    const min_depth = 4;
    const max_depth = @max(min_depth + 2, n);
    
    const stretch_depth = max_depth + 1;
    const stretch_tree = try Node.init(allocator, stretch_depth);
    defer {
        stretch_tree.deinit(allocator);
        allocator.destroy(stretch_tree);
    }
    try stdout.print("stretch tree of depth {}\t check: {}\n", 
                     .{stretch_depth, stretch_tree.check()});
    
    const long_lived_tree = try Node.init(allocator, max_depth);
    defer {
        long_lived_tree.deinit(allocator);
        allocator.destroy(long_lived_tree);
    }
    
    var depth: usize = min_depth;
    while (depth <= max_depth) : (depth += 2) {
        const iterations = @as(usize, 1) << @intCast(max_depth - depth + min_depth);
        var check: i32 = 0;
        
        var i: usize = 0;
        while (i < iterations) : (i += 1) {
            const tree = try Node.init(allocator, depth);
            check += tree.check();
            tree.deinit(allocator);
            allocator.destroy(tree);
        }
        
        try stdout.print("{}\t trees of depth {}\t check: {}\n", 
                         .{iterations, depth, check});
    }
    
    try stdout.print("long lived tree of depth {}\t check: {}\n", 
                     .{max_depth, long_lived_tree.check()});
}