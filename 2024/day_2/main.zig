const std = @import("std");

const direction = enum {
    increaseing,
    decreasing,
    indeterminate,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const reader = file.reader();

    var buf: [1024]u8 = undefined;

    var unsafe: u64 = 0;
    var totalLines: u64 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var splits = std.mem.split(u8, line, " ");

        var lastNum = try std.fmt.parseInt(i32, splits.next().?, 10);
        var increasing: direction = direction.indeterminate;
        std.debug.print("\n", .{});

        var problemDampener: bool = false;
        while (splits.next()) |split| {
            const currentNum = try std.fmt.parseInt(i32, split, 10);
            std.debug.print("lastNum: {d}\n", .{lastNum});
            std.debug.print("currentNum: {d}\n", .{currentNum});

            const diff = currentNum - lastNum;
            if (currentNum == lastNum) {
                if (problemDampener) {
                    unsafe += 1;
                    std.debug.print("unsafe - equal \n", .{});
                    break;
                } else {
                    problemDampener = true;
                }
            } else if (@abs(diff) > 3) {
                if (problemDampener) {
                    unsafe += 1;
                    std.debug.print("unsafe - too big\n", .{});
                    break;
                } else {
                    problemDampener = true;
                }
            } else if (diff < 0) {
                // decreasing
                if (increasing == direction.increaseing) {
                    if (problemDampener) {
                        unsafe += 1;
                        std.debug.print("unsafe - wrong direction\n", .{});
                        break;
                    } else {
                        problemDampener = true;
                    }
                } else {
                    increasing = direction.decreasing;
                }
            } else if (diff > 0) {
                if (increasing == direction.decreasing) {
                    if (problemDampener) {
                        unsafe += 1;
                        std.debug.print("unsafe - wrong direction\n", .{});
                        break;
                    } else {
                        problemDampener = true;
                    }
                } else {
                    increasing = direction.increaseing;
                }
            }
            lastNum = currentNum;
        }
        totalLines += 1;
    }
    std.debug.print("{d}\n", .{totalLines - unsafe});
}
