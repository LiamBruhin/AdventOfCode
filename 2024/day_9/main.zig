const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("test.txt", .{});

    const reader = file.reader();

    const slice = try reader.readAllAlloc(std.heap.page_allocator, 100000);

    var string = std.ArrayList(?i64).init(std.heap.page_allocator);
    defer string.deinit();

    var isFile: bool = true;
    var i: i64 = 0;
    for (slice[0 .. slice.len - 1]) |char| {
        const fileID = i;

        const len = try std.fmt.parseInt(usize, &[_]u8{char}, 10);
        for (0..len) |_| {
            if (isFile) {
                try string.append(fileID);
            } else {
                try string.append(-fileID);
            }
        }
        if (isFile) i += 1;
        isFile = !isFile;
    }

    for (string.items) |num| {
        std.debug.print(" {?d} ", .{num});
    }
    std.debug.print("\n\n", .{});

    var checkedIds = std.ArrayList(?i64).init(std.heap.page_allocator);
    defer checkedIds.deinit();
    try checkedIds.append(null);

    while (std.mem.lastIndexOfNone(?i64, string.items, checkedIds.items)) |index| {
        const id = string.items[index];
        const len = getSequenceLenBack(string.items, index);
        std.debug.print("{?d} at {d} of len: {d} \n", .{ id, index, len });
        try checkedIds.append(id);

        // var uncheckedSlice = string.items;
        // while (std.mem.indexOf(?i64, uncheckedSlice, &[_]?i64{null})) |nullIndex| {
        //     const nullLen = getSequenceLenForward(uncheckedSlice, nullIndex);
        //     uncheckedSlice = uncheckedSlice[(nullIndex + nullLen)..];
        //
        //     for (uncheckedSlice) |num| {
        //         std.debug.print(" {?d} ", .{num});
        //     }
        //
        //     std.debug.print("\n", .{});
        //
        //     std.debug.print("null at {d} of len: {d}\n", .{ nullIndex, nullLen });
        // }
    }
    std.debug.print("\n\n", .{});

    for (string.items) |num| {
        std.debug.print(" {?d} ", .{num});
    }
    std.debug.print("\n\n", .{});
    // var count: i64 = 0;
    // for (string.items, 0..) |number, j| {
    //     if (number) |num| {
    //         count += @as(i64, @intCast(j)) * num;
    //     }
    // }
    //
    // std.debug.print("{d}\n", .{count});
}

pub fn getSequenceLenForward(list: []?i64, startIdx: usize) usize {
    var len: usize = 0;
    var item = list[startIdx];

    while (item == null and startIdx + len < list.len) {
        len += 1;
        item = list[startIdx + len];
    }

    return len;
}

pub fn getSequenceLenBack(list: []?i64, startIdx: usize) usize {
    var len: usize = 0;
    const firstItem = list[startIdx];
    var item = list[startIdx];

    while (item == firstItem and len < startIdx) {
        len += 1;
        item = list[startIdx - len];
    }

    return len;
}
