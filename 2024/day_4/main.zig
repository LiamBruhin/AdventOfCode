const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});

    const reader = file.reader();

    var grid = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer grid.deinit();

    var buf: [1000000]u8 = undefined;
    const size = try reader.readAll(&buf);

    // XMAS
    var count: i32 = 0;
    var count2: i32 = 0;
    const reasonable = buf[0..size];
    var splits = std.mem.split(u8, reasonable, "\n");
    const pitch = splits.next().?.len + 1;
    //const cols = pitch - 1;
    const rows = std.mem.count(u8, reasonable, "\n");
    std.debug.print("size: {d}\n", .{size});
    std.debug.print("rows: {d}\n", .{rows});
    std.debug.print("pitch: {d}\n", .{pitch});
    for (0..rows) |y| {
        for (0..pitch) |x| {
            const signedY = @as(i32, @intCast(y));
            const signedX = @as(i32, @intCast(x));
            const index = y * pitch + x;
            const char = buf[index];
            if (char == 'X') {
                std.debug.print("({d},{d})\n", .{ x, y });
                // right
                if (signedX + 3 <= pitch) {
                    const slice = reasonable[index .. index + 4];
                    std.debug.print("{s}\n", .{slice});
                    if (std.mem.eql(u8, slice, "XMAS")) {
                        count += 1;
                        std.debug.print("right\n", .{});
                    }
                }
                // left
                if (signedX - 3 >= 0) {
                    const slice = reasonable[index - 3 .. index + 1];
                    std.debug.print("{s}\n", .{slice});
                    if (std.mem.eql(u8, slice, "SAMX")) {
                        count += 1;
                        std.debug.print("left\n", .{});
                    }
                }
                // up
                if (0 <= signedY - 3) {
                    const up1 = reasonable[index - pitch];
                    const up2 = reasonable[index - 2 * pitch];
                    const up3 = reasonable[index - 3 * pitch];
                    std.debug.print("X{c}{c}{c}\n", .{ up1, up2, up3 });
                    if (up1 == 'M' and up2 == 'A' and up3 == 'S') {
                        count += 1;
                        std.debug.print("up\n", .{});
                    }
                }
                // Down
                if (signedY + 4 <= rows) {
                    const down1 = reasonable[index + pitch];
                    const down2 = reasonable[index + (2 * pitch)];
                    const down3 = reasonable[index + (3 * pitch)];
                    std.debug.print("X{c}{c}{c}\n", .{ down1, down2, down3 });
                    if (down1 == 'M' and down2 == 'A' and down3 == 'S') {
                        count += 1;
                        std.debug.print("down\n", .{});
                    }
                }

                // up->right
                if (signedY - 3 >= 0 and signedX + 3 <= pitch) {
                    const d1 = reasonable[index - pitch + 1];
                    const d2 = reasonable[index - 2 * pitch + 2];
                    const d3 = reasonable[index - 3 * pitch + 3];
                    std.debug.print("X{c}{c}{c}\n", .{ d1, d2, d3 });
                    if (d1 == 'M' and d2 == 'A' and d3 == 'S') {
                        count += 1;
                        std.debug.print("up->right\n", .{});
                    }
                }

                // up->left
                if (signedY - 3 >= 0 and signedX - 3 >= 0) {
                    const d1 = reasonable[index - pitch - 1];
                    const d2 = reasonable[index - 2 * pitch - 2];
                    const d3 = reasonable[index - 3 * pitch - 3];
                    std.debug.print("X{c}{c}{c}\n", .{ d1, d2, d3 });
                    if (d1 == 'M' and d2 == 'A' and d3 == 'S') {
                        count += 1;
                        std.debug.print("up->left\n", .{});
                    }
                }

                // down->left
                if (signedY + 4 <= rows and signedX - 3 >= 0) {
                    const d1 = reasonable[index + pitch - 1];
                    const d2 = reasonable[index + 2 * pitch - 2];
                    const d3 = reasonable[index + 3 * pitch - 3];
                    std.debug.print("X{c}{c}{c}\n", .{ d1, d2, d3 });
                    if (d1 == 'M' and d2 == 'A' and d3 == 'S') {
                        count += 1;
                        std.debug.print("down->left\n", .{});
                    }
                }

                // down->right
                if (signedY + 4 <= rows and signedX + 3 <= pitch) {
                    const d1 = reasonable[index + pitch + 1];
                    const d2 = reasonable[index + 2 * pitch + 2];
                    const d3 = reasonable[index + 3 * pitch + 3];
                    std.debug.print("X{c}{c}{c}\n", .{ d1, d2, d3 });
                    if (d1 == 'M' and d2 == 'A' and d3 == 'S') {
                        count += 1;
                        std.debug.print("down->right\n", .{});
                    }
                }

                std.debug.print("\n", .{});
            }

            if (char == 'A') {
                if (signedX - 1 >= 0 and signedX + 1 < pitch and signedY + 1 < rows and signedY - 1 >= 0) {
                    const upLeft = reasonable[index - pitch - 1];
                    const upRight = reasonable[index - pitch + 1];
                    const downLeft = reasonable[index + pitch - 1];
                    const downRight = reasonable[index + pitch + 1];
                    if (upLeft == 'M' and downRight == 'S' and upRight == 'M' and downLeft == 'S') {
                        count2 += 1;
                    }
                    if (upLeft == 'M' and downRight == 'S' and upRight == 'S' and downLeft == 'M') {
                        count2 += 1;
                    }
                    if (upLeft == 'S' and downRight == 'M' and upRight == 'S' and downLeft == 'M') {
                        count2 += 1;
                    }
                    if (upLeft == 'S' and downRight == 'M' and upRight == 'M' and downLeft == 'S') {
                        count2 += 1;
                    }
                }
            }
        }
    }
    std.debug.print("{d}\n", .{count});
    std.debug.print("{d}\n", .{count2});
}
