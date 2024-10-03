const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // get args and skip command
    var args = std.process.args();
    _ = args.skip();

    const dir_absolute_path = try std.fs.cwd().realpathAlloc(
        alloc,
        args.next() orelse ".",
    );

    std.log.info("{s}", .{dir_absolute_path});
}
