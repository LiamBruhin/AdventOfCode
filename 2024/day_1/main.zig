const std = @import("std");
const split = std.mem.split;
const parse = std.fmt.parseUnsigned;
const strip = std.mem.trim;

pub fn part1(leftCol: std.ArrayList, rightCol: std.ArrayList) void {
    var count: u64 = 0;
    for (0..leftCol.items.len) |_| {
        count += @abs(leftCol.pop() - rightCol.pop());
    }
    std.debug.print("{d}\n", .{count});
}

pub fn countApperances(value: i64, list: []i64, memo: *std.AutoHashMap(i64, i64)) i64 {
    if (memo.get(value) != null) {
        return memo.get(value).?;
    }
    var count: i64 = 0;
    for (list) |num| {
        if (num == value) {
            count += 1;
        }
    }

    memo.put(value, count) catch @panic("oh no");
    return count;
}

pub fn main() !void {
    const fileName = "day_1.txt";

    var file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var leftCol = std.ArrayList(i64).init(std.heap.page_allocator);
    var rightCol = std.ArrayList(i64).init(std.heap.page_allocator);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splits = split(u8, line, "   ");
        const leftNum: i64 = try parse(i64, strip(u8, splits.next().?, " \r"), 10);
        const rightNum: i64 = try parse(i64, strip(u8, splits.next().?, " \r"), 10);
        try leftCol.append(leftNum);
        try rightCol.append(rightNum);
    }

    std.sort.insertion(i64, leftCol.items, {}, std.sort.asc(i64));
    std.sort.insertion(i64, rightCol.items, {}, std.sort.asc(i64));

    var res: i64 = 0;
    var map = std.AutoHashMap(i64, i64).init(std.heap.page_allocator);
    for (0..leftCol.items.len) |_| {
        const curr = leftCol.pop();
        const appearances = countApperances(curr, rightCol.items, &map);
        res += curr * appearances;
    }

    std.debug.print("{d}", .{res});
}
