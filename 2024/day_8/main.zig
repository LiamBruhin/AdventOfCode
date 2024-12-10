const std = @import("std");

const coords = struct {
    x: usize,
    y: usize,
};

const function = struct {
    m: f32,
    x: f32,
    y: f32,
    fn get(self: function, x: usize) f32 {
        return self.m * (@as(f32, @floatFromInt(x)) - self.x) + self.y;
    }
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});

    const reader = file.reader();

    const slice = try reader.readAllAlloc(std.heap.page_allocator, 1000000);
    try file.seekTo(0);
    const display = try reader.readAllAlloc(std.heap.page_allocator, 1000000);

    var splits = std.mem.split(u8, slice, "\n");
    const next = splits.next().?;
    const cols = next.len;
    const pitch = cols + 1;
    const rows = std.mem.count(u8, slice, "\n");
    std.debug.print("{d}, {d}\n", .{ rows, cols });
    std.debug.print("{s}", .{slice});

    var map = std.AutoHashMap(u8, []coords).init(std.heap.page_allocator);
    defer map.deinit();

    for (0..rows) |row| {
        for (0..cols) |col| {
            const index = row * pitch + col;
            const char: u8 = slice[index];
            if (char != '.') {
                const newCoord = coords{
                    .x = col,
                    .y = row,
                };
                if (!map.contains(char)) {
                    var newList = std.ArrayList(coords).init(std.heap.page_allocator);
                    try newList.append(newCoord);
                    const ownedSlice = try newList.toOwnedSlice();
                    try map.put(char, ownedSlice);
                } else {
                    const list = map.get(char).?;
                    var arrList = std.ArrayList(coords).init(std.heap.page_allocator);
                    try arrList.insertSlice(0, list);
                    try arrList.append(newCoord);
                    const ownedSlice = try arrList.toOwnedSlice();
                    try map.put(char, ownedSlice);
                }
            }
        }
    }

    var count: usize = 0;
    var keyIterator = map.keyIterator();
    while (keyIterator.next()) |key| {
        std.debug.print("{c}\n", .{key.*});
        const coordsList = map.get(key.*).?;
        std.debug.print("{d}\n", .{coordsList.len});
        for (0..(coordsList.len)) |antenaOne| {
            const posOne = coordsList[antenaOne];
            //const antenaOneIndex = posOne.y * pitch + posOne.x;
            for (antenaOne + 1..(coordsList.len)) |antenaTwo| {
                const posTwo = coordsList[antenaTwo];
                //const antenaTwoIndex = posTwo.y * pitch + posTwo.x;

                const signedXOne: i32 = @intCast(posOne.x);
                const signedYOne: i32 = @intCast(posOne.y);
                const signedXTwo: i32 = @intCast(posTwo.x);
                const signedYTwo: i32 = @intCast(posTwo.y);
                const xDist: i32 = @intCast(signedXTwo - signedXOne);
                const yDist: i32 = @intCast(signedYTwo - signedYOne);
                if (posOne.x == posTwo.x) {
                    for (0..rows) |row| {
                        const i = row * pitch + posOne.x;

                        if (slice[i] != '#') {
                            slice[i] = '#';
                            display[i] = key.*;
                            count += 1;
                            std.debug.print("{s}\n\n", .{display});
                            //std.time.sleep(0.01 * std.time.ns_per_s);
                        }
                    }
                } else {
                    const slope: f32 = @as(f32, @floatFromInt(yDist)) / @as(f32, @floatFromInt(xDist));
                    const func = function{
                        .x = @floatFromInt(posOne.x),
                        .y = @floatFromInt(posOne.y),
                        .m = slope,
                    };

                    for (0..cols) |col| {
                        const y: f32 = func.get(col);
                        if (y - @floor(y) < 0.001) {
                            if (y >= 0 and y < @as(f32, @floatFromInt(rows))) {
                                const ysize: usize = @intFromFloat(y);
                                const i = ysize * pitch + col;
                                if (slice[i] != '#') {
                                    slice[i] = '#';
                                    display[i] = key.*;
                                    count += 1;
                                    std.debug.print("{s}\n\n", .{display});
                                    //std.time.sleep(0.01 * std.time.ns_per_s);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    std.debug.print("{d}\n", .{count});
}
