const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const io = std.io;

pub const Direction = enum { forward, down, up };

pub const Command = struct {
    dir: Direction = undefined,
    steps: i32 = undefined,

    pub fn init(dir: Direction, steps: i32) Command {
        return Command{
            .dir = dir,
            .steps = steps,
        };
    }
};

pub const Position = struct {
    depth: i32 = 0,
    horizontal: i32 = 0,
    aim: i32 = 0,

    pub fn init(depth: i32, horizontal: i32, aim: i32) Position {
        return Position{ .depth = depth, .horizontal = horizontal, .aim = aim };
    }

    pub fn movePart1(self: Position, command: Command) Position {
        const new_position: Position = switch (command.dir) {
            Direction.forward => Position.init(self.depth, self.horizontal + command.steps, self.aim),
            Direction.down => Position.init(self.depth + command.steps, self.horizontal, self.aim),
            Direction.up => Position.init(self.depth - command.steps, self.horizontal, self.aim),
        };

        return new_position;
    }

    pub fn movePart2(self: Position, command: Command) Position {
        const new_position: Position = switch (command.dir) {
            Direction.forward => Position.init(self.depth + (self.aim * command.steps), self.horizontal + command.steps, self.aim),
            Direction.down => Position.init(self.depth, self.horizontal, self.aim + command.steps),
            Direction.up => Position.init(self.depth, self.horizontal, self.aim - command.steps),
        };

        return new_position;
    }

    pub fn product(self: Position) i32 {
        return self.depth * self.horizontal;
    }
};

pub fn parseLine(line: []const u8) anyerror!Command {
    var index: u32 = 0;
    var delimiter_pos: u32 = 0;

    while (index < (line.len)) : (index += 1) {
        if (line[index] == ' ') {
            delimiter_pos = index;
        }
    }

    var direction_string = line[0..delimiter_pos];
    var step_string = line[(delimiter_pos + 1)..line.len];

    const step: i32 = try std.fmt.parseInt(i32, step_string, 0);
    var direction: Direction = undefined;

    if (std.mem.eql(u8, direction_string, "forward")) {
        direction = Direction.forward;
    } else if (std.mem.eql(u8, direction_string, "up")) {
        direction = Direction.up;
    } else if (std.mem.eql(u8, direction_string, "down")) {
        direction = Direction.down;
    } else {
        std.debug.print("Direction [{s}]: is unknown!!", .{direction_string});
        unreachable;
        // direction = Direction.up;
    }

    return Command.init(direction, step);
}

pub fn calculatePositionPart1() anyerror!Position {
    var file = try std.fs.cwd().openFile("inputs/day2_1.txt", .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var position: Position = Position.init(0, 0, 0);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var command: Command = try parseLine(line);
        position = position.movePart1(command);
    }
    return position;
}

pub fn calculatePositionPart2() anyerror!Position {
    var file = try std.fs.cwd().openFile("inputs/day2_1.txt", .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var position: Position = Position.init(0, 0, 0);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var command: Command = try parseLine(line);
        position = position.movePart2(command);
    }
    return position;
}

pub fn part1() anyerror!void {
    const finalPosition: Position = try calculatePositionPart1();
    std.debug.print("part1, final position: (depth: {d}, horizontal: {d}), product: {d}\n", .{ finalPosition.depth, finalPosition.horizontal, finalPosition.product() });
}

pub fn part2() anyerror!void {
    const finalPosition: Position = try calculatePositionPart2();
    std.debug.print("part2, final position: (depth: {d}, horizontal: {d}), product: {d}\n", .{ finalPosition.depth, finalPosition.horizontal, finalPosition.product() });
}

pub fn main() anyerror!void {
    try part1();
    try part2();
}

test "parseLine" {
    const line1 = "forward 10";
    var expected_result: Command = Command.init(Direction.forward, 10);

    var result: Command = try parseLine(line1);

    try testing.expectEqual(expected_result.dir, result.dir);
    try testing.expectEqual(expected_result.steps, result.steps);

    const line2 = "down 213";
    expected_result = Command.init(Direction.down, 213);

    result = try parseLine(line2);

    try testing.expectEqual(expected_result.dir, result.dir);
    try testing.expectEqual(expected_result.steps, result.steps);

    const line3 = "up 9";
    expected_result = Command.init(Direction.up, 9);

    result = try parseLine(line3);

    try testing.expectEqual(expected_result.dir, result.dir);
    try testing.expectEqual(expected_result.steps, result.steps);
}

// forward 5
// down 5
// forward 8
// up 3
// down 8
// forward 2
