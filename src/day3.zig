const std = @import("std");
const testing = std.testing;
const io = std.io;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

fn parseLine(line: []const u8) anyerror![12]u2 {
    var index: u32 = 0;
    var binary = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    while (index < (line.len)) : (index += 1) {
        if (line[index] == '1') {
            binary[index] = 1;
        } else if (line[index] == '0') {
            binary[index] = 0;
        }
    }

    return binary;
}

test "parseLine" {
    const line1 = "000000010110";
    var expected_result = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0 };

    var result = try parseLine(line1);

    try testing.expectEqual(true, std.mem.eql(u2, expected_result[0..], result[0..]));
}

fn calculateGammaRate(diagnostic_report: []const [12]u2) [12]u2 {
    var gamma_rate = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var column_zeros = [12]u32{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var column_ones = [12]u32{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    for (diagnostic_report) |code| {
        var index: u8 = 0;
        while (index < (code.len)) : (index += 1) {
            if (code[index] == 0) {
                column_zeros[index] += 1;
            } else {
                column_ones[index] += 1;
            }
        }
    }

    var index: u8 = 0;
    while (index < (gamma_rate.len)) : (index += 1) {
        if (column_zeros[index] > column_ones[index]) {
            gamma_rate[index] = 0;
        } else {
            gamma_rate[index] = 1;
        }
    }

    return gamma_rate;
}

fn calculateEpsilonRate(gamma_rate: [12]u2) [12]u2 {
    var epsilon_rate = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var index: u8 = 0;

    while (index < (gamma_rate.len)) : (index += 1) {
        epsilon_rate[index] = if (gamma_rate[index] == 0) 1 else 0;
    }

    return epsilon_rate;
}

test "calculateGammaRate" {
    const diagnostic_report: [13][12]u2 = [_][12]u2{ [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 }, [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 } };
    var expected_result = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0 };

    var result = calculateGammaRate(diagnostic_report[0..]);

    try testing.expectEqual(true, std.mem.eql(u2, expected_result[0..], result[0..]));
}

test "calculateEpsilonRate" {
    var gamma_rate = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0 };
    const expected_result = [12]u2{ 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1 };

    var result = calculateEpsilonRate(gamma_rate);

    // std.debug.print("result {d}{d}{d}{d}{d}{d}{d}{d}{d}{d}{d}{d}\n", .{ result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11] });
    try testing.expect(std.mem.eql(u2, expected_result[0..], result[0..]));
}

fn binaryToDecimal(binary: [12]u2) u32 {
    const decimal_mapping = [12]u32{ 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 };
    var index: u32 = 0;
    var decimal: u32 = 0;

    while (index < (binary.len)) : (index += 1) {
        decimal += if (binary[index] == 1) decimal_mapping[index] else 0;
    }

    return decimal;
}

test "binaryToDecimal" {
    const binary1 = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0 };
    var expected_result: u32 = 22;

    var result = binaryToDecimal(binary1);

    try testing.expectEqual(expected_result, result);

    const binary2 = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 };
    expected_result = 9;

    result = binaryToDecimal(binary2);

    try testing.expectEqual(expected_result, result);
}

fn findOxygeneGeneratorRating(diagnostic_report: []const [12]u2, bit_index: u8) anyerror![12]u2 {
    // std.debug.print("len: {d}, index: {d}\n", .{ diagnostic_report.len, bit_index });

    if (diagnostic_report.len == 1) {
        return diagnostic_report[0];
    }

    var zeros: u32 = 0;
    var ones: u32 = 0;
    for (diagnostic_report) |code| {
        if (code[bit_index] == 1) {
            ones += 1;
        } else {
            zeros += 1;
        }
    }
    const most_common_bit: u2 = if (ones >= zeros) 1 else 0;

    var filtered_report = std.ArrayList([12]u2).init(allocator);
    for (diagnostic_report) |code| {
        if (code[bit_index] == most_common_bit) {
            try filtered_report.append(code);
        }
    }
    const next_bit_index = bit_index + 1;
    return findOxygeneGeneratorRating(filtered_report.items, next_bit_index);
}

fn findCO2ScrubberRating(diagnostic_report: []const [12]u2, bit_index: u8) anyerror![12]u2 {
    // std.debug.print("len: {d}, index: {d}\n", .{ diagnostic_report.len, bit_index });

    if (diagnostic_report.len == 1) {
        return diagnostic_report[0];
    }

    var zeros: u32 = 0;
    var ones: u32 = 0;
    for (diagnostic_report) |code| {
        if (code[bit_index] == 1) {
            ones += 1;
        } else {
            zeros += 1;
        }
    }
    const least_common_bit: u2 = if (ones < zeros) 1 else 0;

    var filtered_report = std.ArrayList([12]u2).init(allocator);
    for (diagnostic_report) |code| {
        if (code[bit_index] == least_common_bit) {
            try filtered_report.append(code);
        }
    }
    const next_bit_index = bit_index + 1;
    return findCO2ScrubberRating(filtered_report.items, next_bit_index);
}

test "findOxygeneGeneratorRating" {
    const diagnostic_report: [12][12]u2 = [_][12]u2{
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }, // 00100
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0 }, // 11110
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0 }, // 10110
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1 }, // 10111
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1 }, // 10101
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 }, // 01111
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 }, // 00111
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0 }, // 11100
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }, // 10000
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1 }, // 11001
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 }, // 00010
        [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 }, // 01010
    };
    const expected_result = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1 };

    const result = try findOxygeneGeneratorRating(diagnostic_report[0..], 0);

    try testing.expect(std.mem.eql(u2, expected_result[0..], result[0..]));
}

// test "findCO2ScrubberRating" {
//     const diagnostic_report: [12][12]u2 = [_][12]u2{
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }, // 00100
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0 }, // 11110
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0 }, // 10110
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1 }, // 10111
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1 }, // 10101
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1 }, // 01111
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 }, // 00111
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0 }, // 11100
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0 }, // 10000
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1 }, // 11001
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 }, // 00010
//         [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 }, // 01010
//     };
//     const expected_result = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 };

//     const result = try findCO2ScrubberRating(diagnostic_report[0..], 0);

//     try testing.expect(std.mem.eql(u2, expected_result[0..], result[0..]));
// }

fn parseFile() anyerror![][12]u2 {
    var file = try std.fs.cwd().openFile("inputs/day3_1.txt", .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var diagnostic_report = std.ArrayList([12]u2).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var code = try parseLine(line);
        try diagnostic_report.append(code);
    }
    return diagnostic_report.items;
}

fn part1(diagnostic_report: []const [12]u2) void {
    const gamma_rate = calculateGammaRate(diagnostic_report);
    const epsilon_rate = calculateEpsilonRate(gamma_rate);
    const gamma_dec = binaryToDecimal(gamma_rate);
    const epsilon_dec = binaryToDecimal(epsilon_rate);

    std.debug.print("part1, gamma_rate: {d}, epsilon_rate: {d}, product: {d}", .{ gamma_dec, epsilon_dec, gamma_dec * epsilon_dec });
}

fn part2(diagnostic_report: []const [12]u2) anyerror!void {
    // multiply the oxygen generator rating by the CO2 scrubber rating
    const oxygene_generator_rating = try findOxygeneGeneratorRating(diagnostic_report, 0);
    const oxygene_generator_dec = binaryToDecimal(oxygene_generator_rating);
    const co2_scrubber_rating = try findCO2ScrubberRating(diagnostic_report, 0);
    const co2_scrubber_dec = binaryToDecimal(co2_scrubber_rating);
    // 3385170
    std.debug.print("part2, oxygene_generator_dec: {d}, co2_scrubber_dec: {d}, product: {d}", .{ oxygene_generator_dec, co2_scrubber_dec, oxygene_generator_dec * co2_scrubber_dec });
}

pub fn main() anyerror!void {
    const diagnostic_report = try parseFile();
    part1(diagnostic_report);
    try part2(diagnostic_report);
}
