const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});

    const reader = file.reader();

    var count: i64 = 0;

    var buf: [100000]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const list = try readLineAlloc(line);

        std.debug.print("\n", .{});
        if (try possibleResult(@floatFromInt(list[0]), list[1..])) {
            count += list[0];
            std.debug.print("works\n", .{});
        } else {
            std.debug.print("does not work\n", .{});
        }
    }
    std.debug.print("count: {d}\n", .{count});
}

pub fn possibleResult(expectedReslut: f64, list: []i64) !bool {
    if (list.len == 1) {
        return expectedReslut == @as(f64, @floatFromInt(list[0]));
    }
    const endNum: f64 = @floatFromInt(list[list.len - 1]);
    const unCatNum = (expectedReslut - endNum) / (std.math.pow(f64, 10, (@trunc(std.math.log10(endNum) + 1))));
    //std.debug.print("uncat: {d}", .{unCatNum});
    return try possibleResult(expectedReslut - endNum, list[0 .. list.len - 1]) or try possibleResult(expectedReslut / endNum, list[0 .. list.len - 1]) or try possibleResult(unCatNum, list[0 .. list.len - 1]);
}

pub fn readLineAlloc(line: []u8) ![]i64 {
    var splits = std.mem.splitAny(u8, line, " ");
    var arrayList = std.ArrayList(i64).init(std.heap.page_allocator);
    defer arrayList.deinit();

    while (splits.next()) |split| {
        const clean = std.mem.trim(u8, split, ": \n\r");
        std.debug.print("{s} ", .{clean});
        const num = try std.fmt.parseInt(i64, clean, 10);
        try arrayList.append(num);
    }

    return try arrayList.toOwnedSlice();
}
