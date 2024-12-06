const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const reader = file.reader();

    var ruleMap = std.AutoHashMap(i32, []i32).init(std.heap.page_allocator);
    defer ruleMap.deinit();

    var updates = std.ArrayList(std.ArrayList(i32)).init(std.heap.page_allocator);
    defer updates.deinit();

    var doneRules: bool = false;

    var buf: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            doneRules = true;
            continue;
        }

        if (!doneRules) {
            std.debug.print("{s}\n", .{line});
            var splits = std.mem.split(u8, line, "|");
            const left = splits.next().?;
            const right = splits.next().?;

            const leftNum = try std.fmt.parseInt(i32, left, 10);
            const rightNum = try std.fmt.parseInt(i32, right, 10);

            if (!ruleMap.contains(leftNum)) {
                var newList: std.ArrayList(i32) = std.ArrayList(i32).init(std.heap.page_allocator);
                try newList.append(rightNum);
                const ownedSlice = try newList.toOwnedSlice();
                try ruleMap.put(leftNum, ownedSlice);
                std.debug.print("{}\n", .{&newList.items});
            } else {
                const list = ruleMap.get(leftNum).?;
                var arrayList = std.ArrayList(i32).init(std.heap.page_allocator);
                try arrayList.insertSlice(0, list);
                try arrayList.append(rightNum);
                const ownedSlice = try arrayList.toOwnedSlice();
                try ruleMap.put(leftNum, ownedSlice);
            }
        } else {
            var thisUpdate = std.ArrayList(i32).init(std.heap.page_allocator);

            var splits = std.mem.split(u8, line, ",");
            while (splits.next()) |split| {
                const num = try std.fmt.parseInt(i32, split, 10);
                try thisUpdate.append(num);
            }
            try updates.append(thisUpdate);
        }
    }

    var iterator = ruleMap.keyIterator();
    while (iterator.next()) |key| {
        const rules = ruleMap.get(key.*).?;
        std.debug.print("len: {d}\n", .{rules.len});
        for (rules) |r| {
            std.debug.print("{d} << {d}\n", .{ key.*, r });
        }
    }

    var count: i64 = 0;
    var otherCount: i64 = 0;
    std.debug.print("num updates: {d}\n", .{updates.items.len});
    for (updates.items, 0..) |update, j| {
        count += update.items[update.items.len / 2];

        main: for (update.items, 0..) |item, i| {
            if (ruleMap.contains(item)) {
                const rules = ruleMap.get(item).?;
                for (rules) |rule| {
                    const x: [1]i32 = .{rule};
                    if (std.mem.containsAtLeast(i32, update.items, 1, &x)) {
                        if (i > std.mem.indexOf(i32, update.items, &x).?) {
                            std.debug.print("{d} broke {d} in line {d}\n", .{ item, rule, j });
                            count -= update.items[update.items.len / 2];
                            otherCount += fixOrder(update.items, ruleMap);
                            break :main;
                        }
                    }
                }
            }
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("count: {d}\n", .{count});
    std.debug.print("count: {d}\n", .{otherCount});
}

const Context = struct {
    r: std.AutoHashMap(i32, []i32),
    fn inner(self: Context, a: i32, b: i32) bool {
        const needle: [1]i32 = .{b};
        return std.mem.containsAtLeast(i32, self.r.get(a).?, 1, &needle);
    }
};

pub fn fixOrder(list: []i32, rules: std.AutoHashMap(i32, []i32)) i32 {
    const context = Context{ .r = rules };

    std.mem.sort(i32, list, context, Context.inner);
    return list[list.len / 2];
}
