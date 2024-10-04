const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    // get first argument
    var args = std.process.args();
    _ = args.skip();
    const path = args.next() orelse ".";

    try ls1(path);
}

fn ls1(path: []const u8) !void {
    // allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // stout writer
    const stout_writer = std.io.getStdOut().writer();

    // get stat file of path
    const cwd = std.fs.cwd();
    const stat = cwd.statFile(path) catch |err| switch (err) {
        std.fs.Dir.StatFileError.FileNotFound => {
            try stout_writer.print("cannot access '{s}': No such file or directory\n", .{path});
            return;
        },
        else => return err,
    };

    // handle different kinds
    switch (stat.kind) {
        // TODO: close dir and file
        .directory => try showDir(alloc, try cwd.openDir(path, .{})),
        .file => showFile(std.fs.path.basename(path), try cwd.openFile(path, .{})),
        else => {
            try stout_writer.print("Weird {s} shit, not currently supported\n", .{@tagName(stat.kind)});
        },
    }
}

// TODO: make this return text
fn showDir(alloc: Allocator, dir: std.fs.Dir) std.fs.Dir.RealPathAllocError!void {
    std.log.info("{s}", .{try dir.realpathAlloc(alloc, ".")});
}

// TODO: make this return text
fn showFile(basename: []const u8, _: std.fs.File) void {
    std.log.info("{s}", .{basename});
}
