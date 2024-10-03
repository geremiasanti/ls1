const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // subject dir is: first argument or cwd
    var args = std.process.args();
    _ = args.skip();
    const subject_dir = args.next() orelse try std.fs.cwd().realpathAlloc(alloc, ".");

    std.log.info("{s}", .{subject_dir});
}
