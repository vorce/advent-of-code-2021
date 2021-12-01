const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const io = std.io;

pub fn countIncreases(depths: []u32) u32 {
    var increaseCounter: u32 = 0;
    var previousDepth: u32 = 9999999;

    for (depths) |currentDepth| {
        if (currentDepth > previousDepth) {
            increaseCounter += 1;
        }
        previousDepth = currentDepth;
    }

    return increaseCounter;
}

test "countIncreases" {
    var depthValues = [_]u32{ 199, 200, 208, 210, 200, 207, 240, 269, 260, 263 };
    const expected_result: u32 = 7;

    const result: u32 = countIncreases(&depthValues);

    try testing.expectEqual(expected_result, result);
}

pub fn part1() anyerror!void {
    var file = try std.fs.cwd().openFile("inputs/day1_1.txt", .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var depths = std.ArrayList(u32).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var depth: u32 = try std.fmt.parseUnsigned(u32, line, 0);
        try depths.append(depth);
    }
    const depthIncreases = countIncreases(depths.items);

    std.debug.print("part1, number of increases: {d}\n", .{depthIncreases});
}

pub fn main() anyerror!void {
    try part1();
}
