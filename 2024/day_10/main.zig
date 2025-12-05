const std = @import("std");

const Array2D = struct {
    content: []u8,
    pitch: usize,
    pub fn getIndex(self: Array2D, x: usize, y: usize) usize {
        return y * self.pitch + x;
    }

    pub fn getAt(self: Array2D, x: usize, y: usize) u8 {
        const index = y * self.pitch + x;
        return self.content[index];
    }

    fn getAsInt(self: Array2D, x: usize, y: usize) i64 {
        const index = y * self.pitch + x;
        const num = std.fmt.parseInt(i64, &[_]u8{self.content[index]}, 10) catch @panic("Not a number");
        return num;
    }
};

const node = struct {
    value: i64,
    index: usize,
    visited: bool,
};

pub fn addEdge(graph: *std.AutoHashMap(*node, *std.ArrayList(node)), from: **node, to: **node) void {
    const list = graph.get(from.*).?;
    list.append(to.*.*) catch @panic("Could Not Add edge");
    graph.put(from.*, list) catch @panic("could not add to graph");
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    //const stdout = std.io.getStdOut().writer();
    const file = try std.fs.cwd().openFile("test.txt", .{});

    const reader = file.reader();

    const slice = try reader.readAllAlloc(allocator, 100000);

    var Graph = std.AutoHashMap(*node, *std.ArrayList(node)).init(allocator);
    defer Graph.deinit();

    var indexToNode = std.AutoHashMap(usize, *node).init(allocator);
    defer indexToNode.deinit();

    var trailHeads = std.ArrayList(node).init(allocator);
    defer trailHeads.deinit();

    const cols = std.mem.indexOf(u8, slice, &[_]u8{'\n'}).?;
    const pitch = cols + 1;
    const rows = std.mem.count(u8, slice, &[_]u8{'\n'});
    std.debug.print("pitch: {d}\n", .{pitch});
    std.debug.print("rows: {d}\n", .{rows});

    const blah = Array2D{
        .content = slice,
        .pitch = pitch,
    };

    for (0..rows) |row| {
        for (0..cols) |col| {
            std.debug.print("{d}", .{blah.getAsInt(col, row)});
            var newNode = try allocator.alloc(node, 1);
            newNode[0] = node{
                .value = blah.getAsInt(col, row),
                .index = blah.getIndex(col, row),
                .visited = false,
            };
            var neighbs = std.ArrayList(node).init(std.heap.page_allocator);
            try Graph.put(&newNode[0], &neighbs);
            try indexToNode.put(newNode[0].index, &newNode[0]);
            if (newNode[0].value == 0) {
                try trailHeads.append(newNode[0]);
            }
        }
        std.debug.print("\n", .{});
    }

    for (0..rows) |row| {
        for (0..cols) |col| {
            // left
            if (col > 0) {
                if (blah.getAsInt(col - 1, row) == blah.getAsInt(col, row) + 1) {
                    const currentIndex = blah.getIndex(col, row);
                    const otherIndex = blah.getIndex(col - 1, row);
                    var currentNode = indexToNode.get(currentIndex).?;
                    var otherNode = indexToNode.get(otherIndex).?;
                    addEdge(&Graph, &currentNode, &otherNode);
                }
            }
            // right
            if (col + 1 < cols) {
                if (blah.getAsInt(col + 1, row) == blah.getAsInt(col, row) + 1) {
                    const currentIndex = blah.getIndex(col, row);
                    const otherIndex = blah.getIndex(col + 1, row);
                    var currentNode = indexToNode.get(currentIndex).?;
                    var otherNode = indexToNode.get(otherIndex).?;
                    addEdge(&Graph, &currentNode, &otherNode);
                }
            }
            //down
            if (row + 1 < rows) {
                if (blah.getAsInt(col, row + 1) == blah.getAsInt(col, row) + 1) {
                    const currentIndex = blah.getIndex(col, row);
                    const otherIndex = blah.getIndex(col, row + 1);
                    var currentNode = indexToNode.get(currentIndex).?;
                    var otherNode = indexToNode.get(otherIndex).?;
                    addEdge(&Graph, &currentNode, &otherNode);
                }
            }
            // up
            if (row > 0) {
                if (blah.getAsInt(col, row - 1) == blah.getAsInt(col, row) + 1) {
                    const currentIndex = blah.getIndex(col, row);
                    const otherIndex = blah.getIndex(col, row - 1);
                    var currentNode = indexToNode.get(currentIndex).?;
                    var otherNode = indexToNode.get(otherIndex).?;
                    addEdge(&Graph, &currentNode, &otherNode);
                }
            }
        }
    }

    var count: i32 = 0;
    for (trailHeads.items) |trailHead| {
        count += bfsFor9s(trailHead, Graph);
    }
    std.debug.print("count: {d}\n", .{count});
}

pub fn bfsFor9s(start: node, graph: std.AutoHashMap(*node, *std.ArrayList(node))) i32 {
    const L = std.DoublyLinkedList(node);
    var frontier = L{};
    var startNode = L.Node{ .data = start };
    frontier.append(&startNode);
    var count: i32 = 0;

    while (frontier.len > 0) {
        std.debug.print(".", .{});
        const location = frontier.pop();
        var locationNode = location.?.data;
        if (locationNode.value == 9) count += 1;
        locationNode.visited = true;
        const neighbs = graph.get(&locationNode).?.items;
        for (neighbs) |neighb| {
            if (neighb.visited == false) {
                var newNode = L.Node{ .data = neighb };
                frontier.append(&newNode);
            }
        }
    }

    return count;
}
