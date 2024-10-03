const std = @import("std");

pub fn main() !void {
    // allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // stout writer
    const stdout_writer = std.io.getStdOut().writer();

    // get first argument
    var args = std.process.args();
    _ = args.skip();
    const dir_path = args.next() orelse ".";

    // get dir absolute path
    const dir_absolute_path = std.fs.cwd().realpathAlloc(alloc, dir_path) catch |err| switch (err) {
        std.fs.Dir.RealPathAllocError.FileNotFound => {
            try stdout_writer.print("cannot access '{s}': No such file or directory\n", .{dir_path});
            return;
        },
        else => return err,
    };

    std.log.info("{s}", .{dir_absolute_path});
}
