const std = @import("std");
const testing = std.testing;
const io = std.io;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

fn parseLine(line: []const u8) anyerror![12]u2 {
    var index: u32 = 0;
    var binary = [12]u2{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    // var binary = std.ArrayList(u2).init(allocator);

    while (index < (line.len)) : (index += 1) {
        if (line[index] == '1') {
            // try binary.append(1); // [index] = 1;
            binary[index] = 1;
        } else if (line[index] == '0') {
            // try binary.append(0); // binary[index] = 0;
            binary[index] = 0;
        }
    }

    return binary; //.items;
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

pub fn main() anyerror!void {
    const diagnostic_report = try parseFile();
    part1(diagnostic_report);
    // part2(commands);
}
