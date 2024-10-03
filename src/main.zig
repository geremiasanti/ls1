const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // getting
    var args = std.process.args();
    _ = args.skip();
    const first_arg = args.next();

    const dir = if (first_arg != null)
        first_arg
    else
        try std.fs.cwd().realpathAlloc(alloc, ".");

    std.log.info("{s}", .{dir});
}
