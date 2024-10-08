const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;

pub fn main() !void {
    // generate output
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    var args = std.process.args();
    _ = args.skip();

    const out = try ls1(alloc, args.next());

    // print to stout
    const stout_writer = std.io.getStdOut().writer();
    try stout_writer.print("{s}", .{out});
}

fn ls1(alloc: Allocator, path_opt: ?([:0]const u8)) ![]u8 {
    const path = path_opt orelse ".";

    // get stat file of path
    const cwd = std.fs.cwd();
    const stat = cwd.statFile(path) catch |err| switch (err) {
        std.fs.Dir.StatFileError.FileNotFound => return try std.fmt.allocPrint(
            alloc,
            "cannot access '{s}': No such file or directory\n",
            .{path},
        ),
        else => return err,
    };

    // handle different kinds
    switch (stat.kind) {
        // TODO: close dir and file
        .directory => {
            var dir = try cwd.openDir(path, .{});
            defer dir.close();

            return try getDirOutput(alloc, dir);
        },
        .file => {
            var file = try cwd.openFile(path, .{});
            defer file.close();

            return try getFileOutput(alloc, std.fs.path.basename(path), file);
        },
        else => {
            return try std.fmt.allocPrint(
                alloc,
                "Weird {s} shit, not currently supported\n",
                .{@tagName(stat.kind)},
            );
        },
    }
}

test "ls1 null path input prints cwd" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const out = try ls1(alloc, null);
    try expect(std.mem.indexOf(u8, out, "dir: /") != null);
    try expect(std.mem.indexOf(u8, out, "\n") != null);
}

test "ls1 dir output" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const out = try ls1(alloc, ".");
    try expect(std.mem.indexOf(u8, out, "dir: /") != null);
    try expect(std.mem.indexOf(u8, out, "\n") != null);

    const out1 = try ls1(alloc, "./src");
    try expect(std.mem.indexOf(u8, out1, "dir: /") != null);
    try expect(std.mem.indexOf(u8, out1, "/src\n") != null);
}

test "ls1 file output" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const out = try ls1(alloc, "src/main.zig");
    try expect(std.mem.eql(u8, out, "file: main.zig\n"));

    const out1 = try ls1(alloc, "./src/main.zig");
    try expect(std.mem.eql(u8, out1, "file: main.zig\n"));
}

test "ls1 non-existent input file" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const out = try ls1(alloc, "src/main.zigg");
    try expect(std.mem.indexOf(u8, out, "cannot access '") != null);
    try expect(std.mem.indexOf(u8, out, "': No such file or directory\n") != null);
}

test "ls1 non-existent input dir" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const out = try ls1(alloc, "srcc/");
    try expect(std.mem.indexOf(u8, out, "cannot access '") != null);
    try expect(std.mem.indexOf(u8, out, "': No such file or directory\n") != null);
}

const ShowDirError = std.fs.Dir.RealPathAllocError || std.fmt.AllocPrintError;
fn getDirOutput(alloc: Allocator, dir: std.fs.Dir) ShowDirError![]u8 {
    return try std.fmt.allocPrint(
        alloc,
        "dir: {s}\n",
        .{try dir.realpathAlloc(alloc, ".")},
    );
}

fn getFileOutput(alloc: Allocator, basename: []const u8, _: std.fs.File) std.fmt.AllocPrintError![]u8 {
    return try std.fmt.allocPrint(
        alloc,
        "file: {s}\n",
        .{basename},
    );
}
