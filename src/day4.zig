const std = @import("std");
const testing = std.testing;
const allocator = std.heap.page_allocator;
var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = &gpa_impl.allocator;

const Position = struct {
    x: usize = 0,
    y: usize = 0,
    marked: bool = false,

    pub fn init(x: usize, y: usize, marked: bool) Position {
        return Position{ .x = x, .y = y, .marked = marked };
    }

    pub fn mark(self: Position) Position {
        return init(self.x, self.y, true);
    }
};

const BingoBoard = struct {
    number_position: std.AutoHashMap(i32, Position) = undefined,
    numbers: [5][5]i32 = undefined,

    pub fn markAllPositions(self: BingoBoard, marked: bool) !BingoBoard {
        var number_position = std.AutoHashMap(i32, Position).init(std.heap.page_allocator);
        var y: usize = 0;
        var x: usize = 0;
        while (y < (self.numbers.len)) : (y += 1) {
            while (x < (self.numbers[y].len)) : (x += 1) {
                try number_position.put(self.numbers[y][x], Position.init(x, y, marked));
            }
            x = 0;
        }

        return BingoBoard{
            .numbers = self.numbers,
            .number_position = number_position,
        };
    }

    pub fn setRow(self: *BingoBoard, row_nr: usize, row: []const u8) !void {
        var tokenized_row = std.mem.tokenize(u8, row, " ");
        var column: usize = 0;

        while (tokenized_row.next()) |nr_str| {
            const number = try std.fmt.parseInt(i32, nr_str, 10);
            self.numbers[row_nr][column] = number;
            column += 1;
        }
    }

    pub fn checkBingo(self: BingoBoard, pos: ?Position) bool {
        if (pos) |position| {
            var y: usize = 0;
            var x: usize = 0;
            var all_marked: bool = false;

            while (y < (self.numbers.len)) : (y += 1) {
                if (self.number_position.get(self.numbers[y][position.x])) |val| {
                    if (val.marked) {
                        all_marked = true;
                    } else {
                        all_marked = false;
                        break;
                    }
                }
            }

            if (all_marked) {
                return true;
            }

            while (x < (self.numbers[position.y].len)) : (x += 1) {
                if (self.number_position.get(self.numbers[position.y][x])) |val| {
                    if (val.marked) {
                        all_marked = true;
                    } else {
                        all_marked = false;
                        break;
                    }
                }
            }

            return all_marked;
        }
        return false;
    }

    pub fn markNumber(number_position: *std.AutoHashMap(i32, Position), number: i32) !?Position {
        if (number_position.get(number)) |position| {
            try number_position.put(number, position.mark());
            return position.mark();
        }
        return null;
    }

    fn score(self: BingoBoard) i32 {
        // The score of the winning board can now be calculated. Start by finding the sum of all unmarked numbers on that board; in this case, the sum is 188. Then, multiply that sum by the number that was just called when the board won
        var total_score: i32 = 0;
        var it = self.number_position.iterator();

        while (it.next()) |entry| {
            if (entry.value_ptr.marked == false) {
                total_score += entry.key_ptr.*;
            }
        }
        return total_score;
    }

    fn print(self: *const BingoBoard) void {
        var row: usize = 0;
        var column: usize = 0;
        while (row < (self.numbers.len)) : (row += 1) {
            while (column < (self.numbers[row].len)) : (column += 1) {
                std.debug.print("numbers[{d}][{d}] = {d};\n", .{ row, column, self.numbers[row][column] });
            }
            column = 0;
            std.debug.print("\n", .{});
        }
    }
};

fn part1() !void {
    const text = @embedFile("../inputs/day4_1.txt");
    var line_iter = std.mem.split(u8, text, "\n");

    var numbers = std.ArrayList(i32).init(gpa);
    defer numbers.deinit();

    {
        const line = line_iter.next().?;
        var num_iter = std.mem.tokenize(u8, line, ",");

        while (num_iter.next()) |num_str| {
            const num = try std.fmt.parseInt(i32, num_str, 10);
            try numbers.append(num);
        }
    }

    var bingo_boards = std.ArrayList(BingoBoard).init(gpa);
    defer bingo_boards.deinit();
    var bingo_board: BingoBoard = BingoBoard{};

    var row: usize = 0;
    while (line_iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            if (row == 5) {
                bingo_board = try bingo_board.markAllPositions(false);
                try bingo_boards.append(bingo_board);
                bingo_board = BingoBoard{};
            }
            row = 0;
            continue;
        }
        try bingo_board.setRow(row, line);
        row += 1;
    }

    for (numbers.items) |number| {
        std.debug.print("Checking nr: {d}\n", .{number});
        for (bingo_boards.items) |*board| {
            var position = try BingoBoard.markNumber(&board.number_position, number);

            if (board.checkBingo(position)) {
                const score = board.score();
                std.debug.print("BINGO! score: {d}, number: {d}, score * number: {d}\n", .{ score, number, score * number });
                return;
            }
        }
    }
}

pub fn main() anyerror!void {
    try part1();
}
