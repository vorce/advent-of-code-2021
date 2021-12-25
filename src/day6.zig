const std = @import("std");
const testing = std.testing;
const allocator = std.heap.page_allocator;
var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = &gpa_impl.allocator;

pub fn tick(lanternfish: []const u8) ![]u8 {
    var newborn = std.ArrayList(u8).init(gpa);
    var oldies = std.ArrayList(u8).init(gpa);

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

pub fn main() !void {
    var start = [_]u8{ 3, 4, 3, 1, 2, 1, 5, 1, 1, 1, 1, 4, 1, 2, 1, 1, 2, 1, 1, 1, 3, 4, 4, 4, 1, 3, 2, 1, 3, 4, 1, 1, 3, 4, 2, 5, 5, 3, 3, 3, 5, 1, 4, 1, 2, 3, 1, 1, 1, 4, 1, 4, 1, 5, 3, 3, 1, 4, 1, 5, 1, 2, 2, 1, 1, 5, 5, 2, 5, 1, 1, 1, 1, 3, 1, 4, 1, 1, 1, 4, 1, 1, 1, 5, 2, 3, 5, 3, 4, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 5, 5, 1, 3, 3, 1, 2, 1, 3, 1, 5, 1, 1, 4, 1, 1, 2, 4, 1, 5, 1, 1, 3, 3, 3, 4, 2, 4, 1, 1, 5, 1, 1, 1, 1, 4, 4, 1, 1, 1, 3, 1, 1, 2, 1, 3, 1, 1, 1, 1, 5, 3, 3, 2, 2, 1, 4, 3, 3, 2, 1, 3, 3, 1, 2, 5, 1, 3, 5, 2, 2, 1, 1, 1, 1, 5, 1, 2, 1, 1, 3, 5, 4, 2, 3, 1, 1, 1, 4, 1, 3, 2, 1, 5, 4, 5, 1, 4, 5, 1, 3, 3, 5, 1, 2, 1, 1, 3, 3, 1, 5, 3, 1, 1, 1, 3, 2, 5, 5, 1, 1, 4, 2, 1, 2, 1, 1, 5, 5, 1, 4, 1, 1, 3, 1, 5, 2, 5, 3, 1, 5, 2, 2, 1, 1, 5, 1, 5, 1, 2, 1, 3, 1, 1, 1, 2, 3, 2, 1, 4, 1, 1, 1, 1, 5, 4, 1, 4, 5, 1, 4, 3, 4, 1, 1, 1, 1, 2, 5, 4, 1, 1, 3, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 4 };
    var day: i32 = 0;
    var result: []u8 = try tick(start[0..]);

    while (day < 79) : (day += 1) {
        result = try tick(result);
    }
    std.debug.print("Length after 80 days: {d}\n", .{result.len});
}
