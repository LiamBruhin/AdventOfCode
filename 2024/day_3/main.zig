const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const reader = file.reader();

    var sum: i64 = 0;
    var do: bool = true;

    // mul(###,###)
    var buf: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, ')')) |line| {
        std.debug.print("{s}\n", .{line});
        if (line.len >= 3 and line[line.len - 1] == '(') {
            const end = line.len;
            const start = end - 3;
            const doTestSlice = line[start..end];
            if (std.mem.eql(u8, doTestSlice, "do(")) {
                do = true;
            }
        }
        if (line.len >= 6 and line[line.len - 1] == '(') {
            const end = line.len;
            const start = end - 6;
            const dontTestSlice = line[start..end];
            if (std.mem.eql(u8, dontTestSlice, "don't(")) {
                do = false;
            }
        }
        if (line.len >= 7) {
            const res1 = try readNumReverse(line.len - 1, line);
            // std.debug.print("number: {d}\n", .{res1[1]});
            // std.debug.print("endIndex: {d}\n", .{res1[0]});
            if (res1[0] < 1) {
                continue;
            }

            const res2 = try readNumReverse(@as(usize, @intCast(res1[0] - 1)), line);
            // std.debug.print("number: {d}\n", .{res2[1]});
            // std.debug.print("endIndex: {d}\n", .{res2[0]});
            if (res2[0] < 3) {
                continue;
            }

            const mulSlice = line[@as(usize, @intCast(res2[0] - 3))..@as(usize, @intCast(res2[0] + 1))];

            if (std.mem.eql(u8, mulSlice, "mul(") and do) {
                std.debug.print("match\n\n", .{});
                sum += res2[1] * res1[1];
            }
        }
    }

    std.debug.print("sum: {d}\n", .{sum});
}

pub fn readNumReverse(startIndex: usize, buffer: []u8) ![2]i32 {
    var num = std.ArrayList(u8).init(std.heap.page_allocator);
    defer num.deinit();
    var numericalValue: i32 = 0;
    var i: u32 = 0;
    while (i < 3) : (i += 1) {
        const char = buffer[startIndex - i];
        if (std.ascii.isDigit(char)) {
            try num.insert(0, char);
        } else if (char == ',' or num.items.len > 0) {
            break;
        } else {
            numericalValue = -1;
        }
    }

    if (num.items.len > 0 and numericalValue >= 0) {
        numericalValue = try std.fmt.parseInt(i32, num.items, 10);
        return .{ @intCast(startIndex - i), numericalValue };
    } else {
        return .{ -1, -1 };
    }
}
