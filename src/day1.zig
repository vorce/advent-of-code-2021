const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const io = std.io;

pub fn countIncreases(depths: []u32) u32 {
    var increase_counter: u32 = 0;
    var previous_depth: u32 = 9999999;

    for (depths) |current_depth| {
        if (current_depth > previous_depth) {
            increase_counter += 1;
        }
        previous_depth = current_depth;
    }

    return increase_counter;
}

test "countIncreases" {
    var depth_values = [_]u32{ 199, 200, 208, 210, 200, 207, 240, 269, 260, 263 };
    const expected_result: u32 = 7;

    const result: u32 = countIncreases(&depth_values);

    try testing.expectEqual(expected_result, result);
}

pub fn parseInputFile() anyerror![]u32 {
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
    return depths.items;
}

pub fn part1() anyerror!void {
    const depths = try parseInputFile();
    const depth_increases = countIncreases(depths);

    std.debug.print("part1, number of increases: {d}\n", .{depth_increases});
}

pub fn count3MeasurementSlidingWindows(depths: []u32) u32 {
    var increase_counter: u32 = 0;
    var first_window_1: u32 = 0;
    var first_window_2: u32 = 0;
    var first_window_3: u32 = 0;
    var second_window_1: u32 = 0;
    var second_window_2: u32 = 0;
    var second_window_3: u32 = 0;
    var first_window_sum: u32 = 0;
    var second_window_sum: u32 = 0;

    var index: u32 = 2;
    while (index < (depths.len - 1)) : (index += 1) {
        first_window_1 = depths[index - 2];
        first_window_2 = depths[index - 1];
        first_window_3 = depths[index];
        first_window_sum = first_window_1 + first_window_2 + first_window_3;

        second_window_1 = first_window_2;
        second_window_2 = first_window_3;
        second_window_3 = depths[index + 1];
        second_window_sum = second_window_1 + second_window_2 + second_window_3;

        if (second_window_sum > first_window_sum) {
            increase_counter += 1;
        }
    }

    return increase_counter;
}

test "count3MeasurementSlidingWindows" {
    var depth_values = [_]u32{ 199, 200, 208, 210, 200, 207, 240, 269, 260, 263 };
    const expected_result: u32 = 5;

    const result: u32 = count3MeasurementSlidingWindows(&depth_values);

    try testing.expectEqual(expected_result, result);
}

pub fn part2() anyerror!void {
    const depths = try parseInputFile();
    const depth_increases = count3MeasurementSlidingWindows(depths);

    std.debug.print("part2, number of increases: {d}\n", .{depth_increases});
}

pub fn main() anyerror!void {
    try part1();
    try part2();
}
