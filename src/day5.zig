const std = @import("std");
const testing = std.testing;
const allocator = std.heap.page_allocator;
var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = &gpa_impl.allocator;

const Part = enum { one, two };

const Point = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn init(x: i32, y: i32) Point {
        return Point{ .x = x, .y = y };
    }

    pub fn parse(text: []const u8) !Point {
        var point_iter = std.mem.split(u8, text, ",");
        var x: i32 = 0;
        var y: i32 = 0;

        if (point_iter.next()) |nr_str| {
            x = try std.fmt.parseInt(i32, nr_str, 10);
        }

        if (point_iter.next()) |nr_str| {
            y = try std.fmt.parseInt(i32, nr_str, 10);
        }

        return Point.init(x, y);
    }

    pub fn expectEqual(expected: Point, actual: Point) anyerror!void {
        try testing.expectEqual(expected.x, actual.x);
        try testing.expectEqual(expected.y, actual.y);
    }
};

const Line = struct {
    start: Point,
    end: Point,

    pub fn init(start: Point, end: Point) Line {
        return Line{ .start = start, .end = end };
    }

    pub fn isHorizontal(self: Line) bool {
        return self.start.y == self.end.y;
    }

    pub fn isVertical(self: Line) bool {
        return self.start.x == self.end.x;
    }

    pub fn isDiagonal(self: Line) !bool {
        // |𝑥1−𝑥2|=|𝑦1−𝑦2|
        const abs_x = try std.math.absInt(self.start.x - self.end.x);
        const abs_y = try std.math.absInt(self.start.y - self.end.y);
        return abs_x == abs_y;
    }

    pub fn parse(raw_line: []const u8) !Line {
        var start: Point = undefined;
        var end: Point = undefined;
        var point_iterator = std.mem.tokenize(u8, raw_line, " -> ");

        if (point_iterator.next()) |point_str| {
            start = try Point.parse(point_str);
        }

        if (point_iterator.next()) |point_str| {
            end = try Point.parse(point_str);
        }

        return Line.init(start, end);
    }

    pub fn points(self: Line, part: Part) ![]Point {
        var point_list = std.ArrayList(Point).init(gpa);
        var x: i32 = @minimum(self.start.x, self.end.x);
        var y: i32 = @minimum(self.start.y, self.end.y);

        if (self.isVertical()) {
            // std.debug.print("Line is vertical: {d},{d} -> {d},{d}\n", .{ self.start.x, self.start.y, self.end.x, self.end.y });
            while (y <= @maximum(self.start.y, self.end.y)) : (y += 1) {
                try point_list.append(Point.init(x, y));
            }
        } else if (self.isHorizontal()) {
            // std.debug.print("Line is horizontal: {d},{d} -> {d},{d}\n", .{ self.start.x, self.start.y, self.end.x, self.end.y });
            while (x <= @maximum(self.start.x, self.end.x)) : (x += 1) {
                try point_list.append(Point.init(x, y));
            }
        } else if (part == Part.two and try self.isDiagonal()) {
            // std.debug.print("Line is diagonal: {d},{d} -> {d},{d}\n", .{ self.start.x, self.start.y, self.end.x, self.end.y });
            const add_x: i32 = if (self.start.x < self.end.x) 1 else -1;
            const add_y: i32 = if (self.start.y < self.end.y) 1 else -1;
            y = self.start.y;
            x = self.start.x;

            while (y != (self.end.y + add_y) and x != (self.end.x + add_x)) : ({
                y += add_y;
                x += add_x;
            }) {
                try point_list.append(Point.init(x, y));
            }
        }

        return point_list.items;
    }

    pub fn expectEqual(expected: Line, actual: Line) anyerror!void {
        try expected.start.expectEqual(actual.start);
        try expected.end.expectEqual(actual.end);
    }
};

test "Point.parse" {
    const point_text = "0,9";
    const expected_result = Point.init(0, 9);

    var result: Point = try Point.parse(point_text);

    try expected_result.expectEqual(result);
}

test "Line.parse" {
    const line_text = "0,9 -> 5,9";
    const expected_result = Line.init(Point.init(0, 9), Point.init(5, 9));

    var result: Line = try Line.parse(line_text);

    try expected_result.expectEqual(result);
}

test "Line.points" {
    const line = Line.init(Point.init(0, 9), Point.init(5, 9));
    const expected_result = [_]Point{ Point.init(0, 9), Point.init(1, 9), Point.init(2, 9), Point.init(3, 9), Point.init(4, 9), Point.init(5, 9) };

    var result: []Point = try line.points();

    try testing.expectEqual(expected_result.len, result.len);
    var index: usize = 0;
    while (index < result.len) : (index += 1) {
        try expected_result[index].expectEqual(result[index]);
    }
}

test "Line.points 256,172 -> 810,172" {
    const line = Line.init(Point.init(256, 172), Point.init(810, 172));
    const expected_result_len: usize = @intCast(usize, line.end.x - line.start.x) + 1;
    var result: []Point = try line.points();

    try testing.expectEqual(expected_result_len, result.len);
}

test "Line.points 220, 930 -> 220, 507" {
    const line = Line.init(Point.init(220, 930), Point.init(220, 507));
    const expected_result_len: usize = @intCast(usize, line.start.y - line.end.y) + 1;

    var result: []Point = try line.points();

    try testing.expectEqual(expected_result_len, result.len);
}

test "Line.points 9,7 -> 7,9" {
    const line = Line.init(Point.init(9, 7), Point.init(7, 9));
    const expected_result = [_]Point{ Point.init(9, 7), Point.init(8, 8), Point.init(7, 9) };

    var result: []Point = try line.points();

    try testing.expectEqual(expected_result.len, result.len);
    var index: usize = 0;
    while (index < result.len) : (index += 1) {
        try expected_result[index].expectEqual(result[index]);
    }
}

pub fn count(text: []const u8, part: Part) !void {
    var line_iter = std.mem.split(u8, text, "\n");
    var point_coverage = std.AutoHashMap(Point, i32).init(std.heap.page_allocator);
    defer point_coverage.deinit();
    while (line_iter.next()) |line_str| {
        if (std.mem.eql(u8, line_str, "")) continue;
        // std.debug.print("Handling line: [{s}]\n", .{line_str});
        var line: Line = try Line.parse(line_str);
        var points = try line.points(part);
        for (points) |point| {
            if (point_coverage.get(point)) |coverage| {
                try point_coverage.put(point, coverage + 1);
            } else {
                try point_coverage.put(point, 1);
            }
        }
    }

    var point_coverage_iter = point_coverage.iterator();
    var more_than_2_coverage: i32 = 0;
    while (point_coverage_iter.next()) |entry| {
        if (entry.value_ptr.* >= 2) {
            more_than_2_coverage += 1;
        }
    }
    std.debug.print("Number of points with two or more: {d}\n", .{more_than_2_coverage});
}

pub fn main() anyerror!void {
    const text = @embedFile("../inputs/day5_1.txt");
    try count(text, Part.one);
    try count(text, Part.two);
}
