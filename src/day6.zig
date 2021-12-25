const std = @import("std");
const testing = std.testing;
const allocator = std.heap.page_allocator;
var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = &gpa_impl.allocator;

pub fn tick(lanternfish: []const u8) ![]u8 {
    var newborn = std.ArrayList(u8).init(gpa);
    defer newborn.deinit();
    var oldies = std.ArrayList(u8).init(gpa);
    defer oldies.deinit();

    for (lanternfish) |fish| {
        if (fish <= 0) {
            try oldies.append(6);
            try newborn.append(8);
        } else {
            try oldies.append(fish - 1);
        }
    }
    const result = try std.mem.concat(gpa, u8, &[_][]const u8{ oldies.items, newborn.items });
    return result;
}

test "tick no newbords" {
    const fish = [_]u8{ 3, 4, 3, 1, 2 };
    const expected_result = [_]u8{ 2, 3, 2, 0, 1 };

    var result: []u8 = try tick(fish[0..]);

    try std.testing.expectEqual(expected_result.len, result.len);
    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        try std.testing.expectEqual(expected_result[i], result[i]);
    }
}

test "tick with newborns" {
    const fish = [_]u8{ 2, 3, 2, 0, 1 };
    const expected_result = [_]u8{ 1, 2, 1, 6, 0, 8 };

    var result: []u8 = try tick(fish[0..]);

    try std.testing.expectEqual(expected_result.len, result.len);
    var i: usize = 0;
    while (i < result.len) : (i += 1) {
        try std.testing.expectEqual(expected_result[i], result[i]);
    }
}

pub fn part1() !void {
    var start = [_]u8{ 3, 4, 3, 1, 2, 1, 5, 1, 1, 1, 1, 4, 1, 2, 1, 1, 2, 1, 1, 1, 3, 4, 4, 4, 1, 3, 2, 1, 3, 4, 1, 1, 3, 4, 2, 5, 5, 3, 3, 3, 5, 1, 4, 1, 2, 3, 1, 1, 1, 4, 1, 4, 1, 5, 3, 3, 1, 4, 1, 5, 1, 2, 2, 1, 1, 5, 5, 2, 5, 1, 1, 1, 1, 3, 1, 4, 1, 1, 1, 4, 1, 1, 1, 5, 2, 3, 5, 3, 4, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 5, 5, 1, 3, 3, 1, 2, 1, 3, 1, 5, 1, 1, 4, 1, 1, 2, 4, 1, 5, 1, 1, 3, 3, 3, 4, 2, 4, 1, 1, 5, 1, 1, 1, 1, 4, 4, 1, 1, 1, 3, 1, 1, 2, 1, 3, 1, 1, 1, 1, 5, 3, 3, 2, 2, 1, 4, 3, 3, 2, 1, 3, 3, 1, 2, 5, 1, 3, 5, 2, 2, 1, 1, 1, 1, 5, 1, 2, 1, 1, 3, 5, 4, 2, 3, 1, 1, 1, 4, 1, 3, 2, 1, 5, 4, 5, 1, 4, 5, 1, 3, 3, 5, 1, 2, 1, 1, 3, 3, 1, 5, 3, 1, 1, 1, 3, 2, 5, 5, 1, 1, 4, 2, 1, 2, 1, 1, 5, 5, 1, 4, 1, 1, 3, 1, 5, 2, 5, 3, 1, 5, 2, 2, 1, 1, 5, 1, 5, 1, 2, 1, 3, 1, 1, 1, 2, 3, 2, 1, 4, 1, 1, 1, 1, 5, 4, 1, 4, 5, 1, 4, 3, 4, 1, 1, 1, 1, 2, 5, 4, 1, 1, 3, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 4 };
    var day: i32 = 0;
    var result: []u8 = try tick(start[0..]);

    while (day < 79) : (day += 1) {
        result = try tick(result);
    }
    std.debug.print("Length after 80 days: {d}\n", .{result.len});
}

pub fn calculate(start: u8, days: u16) u64 {
    if (days <= 0) {
        return 1;
    }

    var days_left: u16 = days;
    var current: u8 = start;
    var total_count: u64 = 1;

    while (days_left > 0) : (days_left -= 1) {
        if (current <= 0) {
            current = 6;
            total_count += calculate(9, days_left);
        } else {
            current -= 1;
        }
    }
    return total_count;
}

pub fn part2(start: []const u8, days: u16) !u64 {
    var fish_distribution = std.AutoHashMap(u8, u64).init(std.heap.page_allocator);
    defer fish_distribution.deinit();
    var i: usize = 0;
    var total: u64 = 0;
    while (i < start.len) : (i += 1) {
        if (fish_distribution.get(start[i])) |nr| {
            try fish_distribution.put(start[i], nr + 1);
        } else {
            try fish_distribution.put(start[i], 1);
        }
    }

    var distribution_iter = fish_distribution.iterator();
    while (distribution_iter.next()) |entry| {
        std.debug.print("Handling {d} (count: {d}) ...\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        total += (calculate(entry.key_ptr.*, days) * entry.value_ptr.*);
    }
    return total;
}

test "part2 for 80 days" {
    var start = [_]u8{ 3, 4, 3, 1, 2, 1, 5, 1, 1, 1, 1, 4, 1, 2, 1, 1, 2, 1, 1, 1, 3, 4, 4, 4, 1, 3, 2, 1, 3, 4, 1, 1, 3, 4, 2, 5, 5, 3, 3, 3, 5, 1, 4, 1, 2, 3, 1, 1, 1, 4, 1, 4, 1, 5, 3, 3, 1, 4, 1, 5, 1, 2, 2, 1, 1, 5, 5, 2, 5, 1, 1, 1, 1, 3, 1, 4, 1, 1, 1, 4, 1, 1, 1, 5, 2, 3, 5, 3, 4, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 5, 5, 1, 3, 3, 1, 2, 1, 3, 1, 5, 1, 1, 4, 1, 1, 2, 4, 1, 5, 1, 1, 3, 3, 3, 4, 2, 4, 1, 1, 5, 1, 1, 1, 1, 4, 4, 1, 1, 1, 3, 1, 1, 2, 1, 3, 1, 1, 1, 1, 5, 3, 3, 2, 2, 1, 4, 3, 3, 2, 1, 3, 3, 1, 2, 5, 1, 3, 5, 2, 2, 1, 1, 1, 1, 5, 1, 2, 1, 1, 3, 5, 4, 2, 3, 1, 1, 1, 4, 1, 3, 2, 1, 5, 4, 5, 1, 4, 5, 1, 3, 3, 5, 1, 2, 1, 1, 3, 3, 1, 5, 3, 1, 1, 1, 3, 2, 5, 5, 1, 1, 4, 2, 1, 2, 1, 1, 5, 5, 1, 4, 1, 1, 3, 1, 5, 2, 5, 3, 1, 5, 2, 2, 1, 1, 5, 1, 5, 1, 2, 1, 3, 1, 1, 1, 2, 3, 2, 1, 4, 1, 1, 1, 1, 5, 4, 1, 4, 5, 1, 4, 3, 4, 1, 1, 1, 1, 2, 5, 4, 1, 1, 3, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 4 };
    const expected_result: u64 = 371379;

    var result: u64 = try part2(start[0..], 80);

    try std.testing.expectEqual(expected_result, result);
}

pub fn main() !void {
    // try part1();
    var start = [_]u8{ 3, 4, 3, 1, 2, 1, 5, 1, 1, 1, 1, 4, 1, 2, 1, 1, 2, 1, 1, 1, 3, 4, 4, 4, 1, 3, 2, 1, 3, 4, 1, 1, 3, 4, 2, 5, 5, 3, 3, 3, 5, 1, 4, 1, 2, 3, 1, 1, 1, 4, 1, 4, 1, 5, 3, 3, 1, 4, 1, 5, 1, 2, 2, 1, 1, 5, 5, 2, 5, 1, 1, 1, 1, 3, 1, 4, 1, 1, 1, 4, 1, 1, 1, 5, 2, 3, 5, 3, 4, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 5, 5, 1, 3, 3, 1, 2, 1, 3, 1, 5, 1, 1, 4, 1, 1, 2, 4, 1, 5, 1, 1, 3, 3, 3, 4, 2, 4, 1, 1, 5, 1, 1, 1, 1, 4, 4, 1, 1, 1, 3, 1, 1, 2, 1, 3, 1, 1, 1, 1, 5, 3, 3, 2, 2, 1, 4, 3, 3, 2, 1, 3, 3, 1, 2, 5, 1, 3, 5, 2, 2, 1, 1, 1, 1, 5, 1, 2, 1, 1, 3, 5, 4, 2, 3, 1, 1, 1, 4, 1, 3, 2, 1, 5, 4, 5, 1, 4, 5, 1, 3, 3, 5, 1, 2, 1, 1, 3, 3, 1, 5, 3, 1, 1, 1, 3, 2, 5, 5, 1, 1, 4, 2, 1, 2, 1, 1, 5, 5, 1, 4, 1, 1, 3, 1, 5, 2, 5, 3, 1, 5, 2, 2, 1, 1, 5, 1, 5, 1, 2, 1, 3, 1, 1, 1, 2, 3, 2, 1, 4, 1, 1, 1, 1, 5, 4, 1, 4, 5, 1, 4, 3, 4, 1, 1, 1, 1, 2, 5, 4, 1, 1, 3, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 4 };
    var result = try part2(start[0..], 256);
    std.debug.print("Length after 256 days: {d}\n", .{result});
}
