const std = @import("std");

const coords = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("test.txt", .{});

    const reader = file.reader();

    const slice = try reader.readAllAlloc(std.heap.page_allocator, 1000000);

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
            const antenaOneIndex = posOne.y * pitch + posOne.x;
            for (antenaOne..(coordsList.len)) |antenaTwo| {
                const posTwo = coordsList[antenaTwo];
                const antenaTwoIndex = posTwo.y * pitch + posTwo.x;
                const signedXOne: i32 = @intCast(posOne.x);
                const signedYOne: i32 = @intCast(posOne.y);
                const signedXTwo: i32 = @intCast(posTwo.x);
                const signedYTwo: i32 = @intCast(posTwo.y);
                const xDist: i32 = @intCast(signedXTwo - signedXOne);
                const yDist: i32 = @intCast(signedYTwo - signedYOne);

                if (signedXTwo + xDist >= 0 and signedXTwo + xDist < cols) {
                    if (signedYTwo + yDist >= 0 and signedYTwo + yDist < rows) {
                        const antinodeOne = coords{
                            .x = @intCast(signedXTwo + xDist),
                            .y = @intCast(signedYTwo + yDist),
                        };
                        const a1Index = antinodeOne.y * pitch + antinodeOne.x;
                        if (slice[a1Index] != '#' and a1Index != antenaOneIndex and a1Index != antenaTwoIndex) {
                            slice[a1Index] = '#';
                            count += 1;
                        }
                    }
                }

                if (signedXOne - xDist >= 0 and signedXOne - xDist < cols) {
                    if (signedYOne - yDist >= 0 and signedYOne - yDist < rows) {
                        const antinodeTwo = coords{
                            .x = @intCast(signedXOne - xDist),
                            .y = @intCast(signedYOne - yDist),
                        };

                        const a2Index = antinodeTwo.y * pitch + antinodeTwo.x;
                        if (slice[a2Index] != '#' and a2Index != antenaOneIndex and a2Index != antenaTwoIndex) {
                            slice[a2Index] = '#';
                            count += 1;
                        }
                    }
                }

                std.debug.print("{s}\n\n", .{slice});
            }
        }
    }
    std.debug.print("{d}\n", .{count});
}
