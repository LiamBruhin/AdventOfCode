const std = @import("std");

const arr = struct {
    pitch: usize,
    pub fn getIndex(self: *arr, ax: usize, ay: usize) usize {
        return ay * self.pitch + ax;
    }
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});

    const reader = file.reader();

    var buf: [100000]u8 = undefined;
    const size = try reader.readAll(&buf);

    var slice = buf[0..size];

    std.debug.print("{s}", .{slice});
    std.debug.print("{d}\n", .{size});

    var splits = std.mem.split(u8, slice, "\n");
    const ogSlice: []u8 = try std.heap.page_allocator.alloc(u8, size);
    std.mem.copyForwards(u8, ogSlice, slice);

    const next = splits.next().?;

    const rows = std.mem.count(u8, slice, "\n");
    const pitch = rows + 1;
    const cols = next.len;

    var count: i32 = 0;
    var loops: i32 = 0;

    const symbols: [4]u8 = .{ '>', 'v', '<', '^' };
    var pos: usize = 0;

    var tools = arr{
        .pitch = pitch,
    };
    const index = std.mem.indexOf(u8, slice, "^").?;
    var x = index % pitch;
    var y = index / pitch;
    const initX = x;
    const initY = y;

    var toVisit = std.ArrayList(usize).init(std.heap.page_allocator);

    {
        var currentDir: u8 = '^';
        while (true) {
            if (slice[tools.getIndex(x, y)] == '^') {
                if (y == 0) {
                    break;
                }
                if (slice[tools.getIndex(x, y - 1)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    try toVisit.append(tools.getIndex(x, y));

                    y -= 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = '^';
                }
            } else if (slice[tools.getIndex(x, y)] == 'v') {
                if (y + 1 > rows - 1) {
                    break;
                }
                if (slice[tools.getIndex(x, y + 1)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    try toVisit.append(tools.getIndex(x, y));

                    y += 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = 'v';
                }
            } else if (slice[tools.getIndex(x, y)] == '>') {
                if (x + 1 > cols) {
                    break;
                }
                if (slice[tools.getIndex(x + 1, y)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    try toVisit.append(tools.getIndex(x, y));

                    x += 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = '>';
                }
            } else if (slice[tools.getIndex(x, y)] == '<') {
                if (x == 0) {
                    break;
                }
                if (slice[tools.getIndex(x - 1, y)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    try toVisit.append(tools.getIndex(x, y));

                    x -= 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = '<';
                }
            }
            if (x > cols or y > rows) {
                break;
            }
        }
    }

    for (toVisit.items) |toVisitIndex| {
        if (toVisitIndex == index) {
            continue;
        }
        std.mem.copyForwards(u8, slice, ogSlice);
        slice[toVisitIndex] = '#';
        x = initX;
        y = initY;
        pos = 0;

        var visited = std.AutoHashMap(usize, []u8).init(std.heap.page_allocator);
        defer visited.deinit();
        var currentDir: u8 = '^';

        var firstLoop: bool = true;
        while (true) {
            //std.debug.print("testing...\n", .{});
            if (visited.contains(tools.getIndex(x, y))) {
                const visitedDirs = visited.get(tools.getIndex(x, y)).?;
                var currentDirslice: [1]u8 = .{currentDir};
                if (std.mem.containsAtLeast(u8, visitedDirs, 1, &currentDirslice)) {
                    loops += 1;
                    std.debug.print("inf\n", .{});
                    break;
                }
            }
            firstLoop = false;
            if (slice[tools.getIndex(x, y)] == '^') {
                if (y == 0) {
                    break;
                }
                if (slice[tools.getIndex(x, y - 1)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    // set as visited
                    if (!visited.contains(tools.getIndex(x, y))) {
                        var ls: [1]u8 = .{'^'};
                        try visited.put(tools.getIndex(x, y), &ls);
                    } else {
                        const blah = visited.get(tools.getIndex(x, y)).?;
                        var alst = std.ArrayList(u8).init(std.heap.page_allocator);
                        try alst.insertSlice(0, blah);
                        try alst.append('^');
                        const ownedslice = try alst.toOwnedSlice();
                        try visited.put(tools.getIndex(x, y), ownedslice);
                    }

                    y -= 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = '^';
                }
            } else if (slice[tools.getIndex(x, y)] == 'v') {
                if (y + 1 > rows - 1) {
                    break;
                }
                if (slice[tools.getIndex(x, y + 1)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    // set as visited
                    if (!visited.contains(tools.getIndex(x, y))) {
                        var ls: [1]u8 = .{'v'};
                        try visited.put(tools.getIndex(x, y), &ls);
                    } else {
                        const blah = visited.get(tools.getIndex(x, y)).?;
                        var alst = std.ArrayList(u8).init(std.heap.page_allocator);
                        try alst.insertSlice(0, blah);
                        try alst.append('v');
                        const ownedslice = try alst.toOwnedSlice();
                        try visited.put(tools.getIndex(x, y), ownedslice);
                    }

                    y += 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = 'v';
                }
            } else if (slice[tools.getIndex(x, y)] == '>') {
                if (x + 1 > cols) {
                    break;
                }
                if (slice[tools.getIndex(x + 1, y)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    // set as visited
                    if (!visited.contains(tools.getIndex(x, y))) {
                        var ls: [1]u8 = .{'>'};
                        try visited.put(tools.getIndex(x, y), &ls);
                    } else {
                        const blah = visited.get(tools.getIndex(x, y)).?;
                        var alst = std.ArrayList(u8).init(std.heap.page_allocator);
                        try alst.insertSlice(0, blah);
                        try alst.append('>');
                        const ownedslice = try alst.toOwnedSlice();
                        try visited.put(tools.getIndex(x, y), ownedslice);
                    }

                    x += 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = '>';
                }
            } else if (slice[tools.getIndex(x, y)] == '<') {
                if (x == 0) {
                    break;
                }
                if (slice[tools.getIndex(x - 1, y)] == '#') {
                    slice[tools.getIndex(x, y)] = symbols[pos];
                    currentDir = symbols[pos];
                    pos += 1;
                    if (pos > 3) {
                        pos = 0;
                    }
                } else {
                    slice[tools.getIndex(x, y)] = 'X';

                    // set as visited
                    if (!visited.contains(tools.getIndex(x, y))) {
                        var ls: [1]u8 = .{'<'};
                        try visited.put(tools.getIndex(x, y), &ls);
                    } else {
                        const blah = visited.get(tools.getIndex(x, y)).?;
                        var alst = std.ArrayList(u8).init(std.heap.page_allocator);
                        try alst.insertSlice(0, blah);
                        try alst.append('<');
                        const ownedslice = try alst.toOwnedSlice();
                        try visited.put(tools.getIndex(x, y), ownedslice);
                    }

                    x -= 1;
                    if (slice[tools.getIndex(x, y)] != 'X')
                        count += 1;
                    slice[tools.getIndex(x, y)] = '<';
                }
            }
            if (x > cols or y > rows) {
                break;
            }
        }
        std.debug.print("{s}\n", .{slice});
    }
    std.debug.print("num: {d}\n", .{count});
    std.debug.print("Loops: {d}\n", .{loops});
}
