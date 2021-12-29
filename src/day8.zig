const std = @import("std");
const testing = std.testing;
const allocator = std.heap.page_allocator;
var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = &gpa_impl.allocator;
const ArrayList = std.ArrayList;

const Input = struct {
    signal_patterns: [10][]const u8,

    pub fn parse(line: []const u8) Input {
        var signal_patterns: [10][]const u8 = undefined;
        var iter = std.mem.tokenize(u8, line, " ");
        var pos: usize = 0;
        while (iter.next()) |input| {
            signal_patterns[pos] = input;
            pos += 1;
        }
        return Input{ .signal_patterns = signal_patterns };
    }

    pub fn findMappings(input: Input) ![10]Number {
        var mappings = [_]Number{ Number{}, Number{}, Number{}, Number{}, Number{}, Number{}, Number{}, Number{}, Number{}, Number{} };
        var val_pos: usize = 0;
        var one: Number = undefined;
        var four: Number = undefined;
        var seven: Number = undefined;

        // map the easy ones
        while (val_pos < input.signal_patterns.len) : (val_pos += 1) {
            switch (input.signal_patterns[val_pos].len) {
                2 => {
                    one = try Number.initWithSort(input.signal_patterns[val_pos], 1);
                    mappings[val_pos] = one;
                },
                3 => {
                    seven = try Number.initWithSort(input.signal_patterns[val_pos], 7);
                    mappings[val_pos] = seven;
                },
                4 => {
                    four = try Number.initWithSort(input.signal_patterns[val_pos], 4);
                    mappings[val_pos] = four;
                },
                7 => {
                    mappings[val_pos] = try Number.initWithSort(input.signal_patterns[val_pos], 8);
                },
                else => {},
            }
        }

        // now we go for the trickier ones
        val_pos = 0;
        while (val_pos < input.signal_patterns.len) : (val_pos += 1) {
            switch (input.signal_patterns[val_pos].len) {
                5 => {
                    const sorted = try Number.sortedString(input.signal_patterns[val_pos]);
                    const diffs_vs_one = countDiffs(sorted, one.string);
                    const diffs_vs_four = countDiffs(sorted, four.string);
                    // 2, 3, or 5,
                    if (diffs_vs_one == 0) {
                        mappings[val_pos] = Number.init(sorted, 3);
                    } else {
                        if (diffs_vs_four == 2) {
                            mappings[val_pos] = Number.init(sorted, 2);
                        } else {
                            mappings[val_pos] = Number.init(sorted, 5);
                        }
                    }
                },
                6 => {
                    const sorted = try Number.sortedString(input.signal_patterns[val_pos]);
                    const diffs_vs_one = countDiffs(sorted, one.string);
                    const diffs_vs_four = countDiffs(sorted, four.string);

                    if (diffs_vs_one != 0) {
                        mappings[val_pos] = Number.init(sorted, 6);
                    } else if (diffs_vs_four != 0) {
                        mappings[val_pos] = Number.init(sorted, 0);
                    } else {
                        mappings[val_pos] = Number.init(sorted, 9);
                    }
                },
                else => {},
            }
        }
        return mappings;
    }
};

test "Input.parse" {
    const line = "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb";

    const result: Input = Input.parse(line);

    try testing.expectEqual(result.signal_patterns.len, 10);
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[0], "be"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[1], "cfbegad"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[2], "cbdgef"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[3], "fgaecd"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[4], "cgeb"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[5], "fdcge"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[6], "agebfd"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[7], "fecdb"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[8], "fabcd"));
    try testing.expectEqual(true, std.mem.eql(u8, result.signal_patterns[9], "edb"));
}

test "Input.findMappings" {
    const input = Input.parse("be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb");

    const mapping = try input.findMappings();

    try testing.expectEqual(@as(u8, 1), mapping[0].value);
    try testing.expectEqual(@as(u8, 8), mapping[1].value);
    try testing.expectEqual(@as(u8, 9), mapping[2].value);
    try testing.expectEqual(@as(u8, 6), mapping[3].value);
    try testing.expectEqual(@as(u8, 4), mapping[4].value);
    try testing.expectEqual(@as(u8, 5), mapping[5].value);
    try testing.expectEqual(@as(u8, 0), mapping[6].value);
    try testing.expectEqual(@as(u8, 3), mapping[7].value);
    try testing.expectEqual(@as(u8, 2), mapping[8].value);
    try testing.expectEqual(@as(u8, 7), mapping[9].value);
}

const Output = struct {
    values: [4][]const u8,

    pub fn parse(line: []const u8) Output {
        var values: [4][]const u8 = undefined;
        var iter = std.mem.tokenize(u8, line, " ");
        var pos: usize = 0;
        while (iter.next()) |input| {
            values[pos] = input;
            pos += 1;
        }
        return Output{ .values = values };
    }

    pub fn countEasy(self: Output) i32 {
        var count: i32 = 0;
        var val_pos: usize = 0;
        while (val_pos < self.values.len) : (val_pos += 1) {
            if (self.easyValue(val_pos)) {
                count += 1;
            }
        }
        return count;
    }

    fn easyValue(self: Output, value_pos: usize) bool {
        const easy_lengths = [_]u8{ 2, 3, 4, 7 };
        return self.values[value_pos].len == easy_lengths[0] or self.values[value_pos].len == easy_lengths[1] or self.values[value_pos].len == easy_lengths[2] or self.values[value_pos].len == easy_lengths[3];
    }

    pub fn decode(output: Output, mappings: [10]Number) !u32 {
        var factors = [4]u32{ 1000, 100, 10, 1 };
        var decoded: u32 = 0;
        var out_index: usize = 0;

        while (out_index < output.values.len) : (out_index += 1) {
            const sorted = try Number.sortedString(output.values[out_index]);
            for (mappings) |nr| {
                if (std.mem.eql(u8, sorted, nr.string)) {
                    decoded += nr.value * factors[out_index];
                }
            }
        }
        return decoded;
    }
};

test "Output.parse" {
    const line = "fdgacbe cefdb cefbgd gcbe";

    const result: Output = Output.parse(line);

    try testing.expectEqual(result.values.len, 4);
    try testing.expectEqual(true, std.mem.eql(u8, result.values[0], "fdgacbe"));
    try testing.expectEqual(true, std.mem.eql(u8, result.values[1], "cefdb"));
    try testing.expectEqual(true, std.mem.eql(u8, result.values[2], "cefbgd"));
    try testing.expectEqual(true, std.mem.eql(u8, result.values[3], "gcbe"));
}

test "Output.countEasy" {
    const line = "fdgacbe cefdb cefbgd gcbe";
    const expected_result: i32 = 2;

    const result: i32 = Output.parse(line).countEasy();

    try testing.expectEqual(expected_result, result);
}

test "Output.decode" {
    const raw_line = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf";
    const line: Line = Line.parse(raw_line);
    const mapping = try line.input.findMappings();

    const result = try line.output.decode(mapping);

    try testing.expectEqual(@as(u32, 5353), result);
}

const Line = struct {
    input: Input,
    output: Output,

    pub fn parse(line: []const u8) Line {
        var delim_iter = std.mem.split(u8, line, " | ");
        var input_raw = delim_iter.next().?;
        var input = Input.parse(input_raw);
        input_raw = delim_iter.next().?;
        var output = Output.parse(input_raw);

        return Line{ .input = input, .output = output };
    }
};

test "Line.parse" {
    const line = "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe";

    const result: Line = Line.parse(line);

    try testing.expectEqual(result.input.signal_patterns.len, 10);
    try testing.expectEqual(result.output.values.len, 4);
}

pub fn part1(text: []const u8) i32 {
    var line_iter = std.mem.split(u8, text, "\n");
    var total_easy: i32 = 0;
    while (line_iter.next()) |line_str| {
        if (std.mem.eql(u8, line_str, "")) continue;
        var line: Line = Line.parse(line_str);
        total_easy += line.output.countEasy();
    }
    return total_easy;
}

const Number = struct {
    string: []const u8 = undefined,
    value: u8 = undefined,

    pub fn init(sorted_string: []const u8, value: u8) Number {
        return Number{ .string = sorted_string, .value = value };
    }

    pub fn initWithSort(unsorted: []const u8, value: u8) !Number {
        return Number{ .string = try sortedString(unsorted), .value = value };
    }

    pub fn sortedString(input: []const u8) ![]const u8 {
        var buf = try allocator.alloc(u8, input.len);
        std.mem.copy(u8, buf, input[0..]);
        std.sort.sort(u8, buf, {}, comptime std.sort.asc(u8));
        return buf;
    }
};

fn order_u8(context: void, lhs: u8, rhs: u8) std.math.Order {
    _ = context;
    return std.math.order(lhs, rhs);
}

pub fn countDiffs(haystack: []const u8, needles: []const u8) u8 {
    var diffs: u8 = 0;
    for (needles) |needle| {
        if (std.sort.binarySearch(u8, needle, haystack, {}, order_u8) == null) {
            diffs += 1;
        }
    }
    return diffs;
}

test "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe" {
    const raw_line = "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe";
    const line: Line = Line.parse(raw_line);
    const mapping = try line.input.findMappings();

    const result = try line.output.decode(mapping);

    try testing.expectEqual(@as(u32, 8394), result);
}

test "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc" {
    const raw_line = "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc";
    const line: Line = Line.parse(raw_line);
    const mapping = try line.input.findMappings();

    const result = try line.output.decode(mapping);

    try testing.expectEqual(@as(u32, 9781), result);
}

pub fn part2(text: []const u8) !u32 {
    var line_iter = std.mem.split(u8, text, "\n");
    var total: u32 = 0;
    while (line_iter.next()) |line_str| {
        if (std.mem.eql(u8, line_str, "")) continue;
        const line: Line = Line.parse(line_str);
        const mapping = try line.input.findMappings();
        const decoded_output = try line.output.decode(mapping);
        total += decoded_output;
    }
    return total;
}

pub fn main() !void {
    const text = @embedFile("../inputs/day8_1.txt");
    var part1_result = part1(text);
    std.debug.print("Part 1: {d}\n", .{part1_result}); // 310

    var part2_result = try part2(text);
    std.debug.print("Part 2: {d}\n", .{part2_result}); // 915941
}
