const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // get first argument
    var args = std.process.args();
    _ = args.skip();
    const dir_path = args.next() orelse ".";

    // get dir absolute path
    const dir_absolute_path = std.fs.cwd().realpathAlloc(alloc, dir_path) catch |err| switch (err) {
        std.fs.Dir.RealPathAllocError.FileNotFound => {
            std.log.info("cannot access '{s}': No such file or directory", .{dir_path});
            return;
        },
        else => return err,
    };

    std.log.info("{s}", .{dir_absolute_path});
}
