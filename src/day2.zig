const std = @import("std");
const testing = std.testing;
const io = std.io;

const Part = enum { one, two };
const Direction = enum { forward, down, up };

const Command = struct {
    dir: Direction = undefined,
    steps: i32 = undefined,

    pub fn init(dir: Direction, steps: i32) Command {
        return Command{
            .dir = dir,
            .steps = steps,
        };
    }
};

const Position = struct {
    depth: i32 = 0,
    horizontal: i32 = 0,
    aim: i32 = 0,

    pub fn init(depth: i32, horizontal: i32, aim: i32) Position {
        return Position{ .depth = depth, .horizontal = horizontal, .aim = aim };
    }

    fn movePart1(self: Position, command: Command) Position {
        const new_position: Position = switch (command.dir) {
            Direction.forward => Position.init(self.depth, self.horizontal + command.steps, self.aim),
            Direction.down => Position.init(self.depth + command.steps, self.horizontal, self.aim),
            Direction.up => Position.init(self.depth - command.steps, self.horizontal, self.aim),
        };

        return new_position;
    }

    fn movePart2(self: Position, command: Command) Position {
        const new_position: Position = switch (command.dir) {
            Direction.forward => Position.init(self.depth + (self.aim * command.steps), self.horizontal + command.steps, self.aim),
            Direction.down => Position.init(self.depth, self.horizontal, self.aim + command.steps),
            Direction.up => Position.init(self.depth, self.horizontal, self.aim - command.steps),
        };

        return new_position;
    }

    pub fn move(self: Position, command: Command, part: Part) Position {
        switch (part) {
            Part.one => return self.movePart1(command),
            Part.two => return self.movePart2(command),
        }
    }

    pub fn product(self: Position) i32 {
        return self.depth * self.horizontal;
    }
};

fn findCommandDelimiterPosition(line: []const u8) u32 {
    var index: u32 = 0;
    var delimiter_pos: u32 = 0;

    while (index < (line.len)) : (index += 1) {
        if (line[index] == ' ') {
            delimiter_pos = index;
        }
    }

    return delimiter_pos;
}

fn parseLine(line: []const u8) anyerror!Command {
    const delimiter_pos: u32 = findCommandDelimiterPosition(line);

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
    }

    return Command.init(direction, step);
}

fn calculatePosition(part: Part) anyerror!Position {
    var file = try std.fs.cwd().openFile("inputs/day2_1.txt", .{});
    defer file.close();
    var buf_reader = io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var position: Position = Position.init(0, 0, 0);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var command: Command = try parseLine(line);
        position = position.move(command, part);
    }
    return position;
}

fn part1() anyerror!void {
    const finalPosition: Position = try calculatePosition(Part.one);
    std.debug.print("part1, final position: (depth: {d}, horizontal: {d}), product: {d}\n", .{ finalPosition.depth, finalPosition.horizontal, finalPosition.product() });
}

fn part2() anyerror!void {
    const finalPosition: Position = try calculatePosition(Part.two);
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
