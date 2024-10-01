const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var args = std.process.args();
    _ = args.skip();
    const first_arg = args.next();

    const cwd = try std.fs.cwd().realpathAlloc(alloc, ".");

    std.log.info("cwd: {s}", .{cwd});
    std.log.info("first_arg: {?s}", .{first_arg});
}
