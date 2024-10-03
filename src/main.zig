const std = @import("std");

pub fn main() !void {
    // allocator
    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    //const alloc = arena.allocator();

    // stout writer
    const stout_writer = std.io.getStdOut().writer();

    // get first argument
    var args = std.process.args();
    _ = args.skip();
    const dir_path = args.next() orelse ".";

    // is path a folder or a file?
    const stat = std.fs.cwd().statFile(dir_path) catch |err| switch (err) {
        std.fs.Dir.StatFileError.FileNotFound => {
            try stout_writer.print("cannot access '{s}': No such file or directory\n", .{dir_path});
            return;
        },
        else => return err,
    };
    switch (stat.kind) {
        .directory => std.debug.print("dir!\n", .{}),
        .file => std.debug.print("file!\n", .{}),
        else => {
            try stout_writer.print("Weird {s} shit, not currently supported\n", .{@tagName(stat.kind)});
        },
    }

    //std.log.info("{s}", .{dir_absolute_path});
}
