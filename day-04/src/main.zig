const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("./data/input.txt", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size + 1);
    defer allocator.free(buffer);

    var wordSearch = std.ArrayList([]const u8).init(allocator);
    defer wordSearch.deinit();

    while (try file.reader().readUntilDelimiterOrEof(buffer, '\n')) |line| {
        const line_copy = try allocator.dupe(u8, line);
        try wordSearch.append(line_copy);
    }

    const windowSize = 4;

    var xmas: i32 = 0;
    var masInAnX: i32 = 0;
    const wordSearchSize = wordSearch.items.len;

    for (0..wordSearchSize) |y| {
        for (0..wordSearchSize) |x| {
            // keep it simple, stupid.
            // if statements just to keep the sliding windows in bounds

            if (x <= wordSearch.items[y].len - windowSize) {
                const windowX: [4]u8 = .{ wordSearch.items[y][x], wordSearch.items[y][x + 1], wordSearch.items[y][x + 2], wordSearch.items[y][x + 3] };

                if (std.mem.eql(u8, &windowX, "XMAS") or std.mem.eql(u8, &windowX, "SAMX")) {
                    xmas += 1;
                }
            }

            if (x <= wordSearch.items[y].len - windowSize and y <= wordSearch.items.len - windowSize) {
                const windowDiagLeft = .{ wordSearch.items[y][x], wordSearch.items[y + 1][x + 1], wordSearch.items[y + 2][x + 2], wordSearch.items[y + 3][x + 3] };
                if (std.mem.eql(u8, &windowDiagLeft, "XMAS") or std.mem.eql(u8, &windowDiagLeft, "SAMX")) {
                    xmas += 1;
                }
            }

            if (x >= windowSize - 1 and y <= wordSearch.items.len - windowSize) {
                const windowDiagRight = .{ wordSearch.items[y][x], wordSearch.items[y + 1][x - 1], wordSearch.items[y + 2][x - 2], wordSearch.items[y + 3][x - 3] };
                if (std.mem.eql(u8, &windowDiagRight, "XMAS") or std.mem.eql(u8, &windowDiagRight, "SAMX")) {
                    xmas += 1;
                }
            }

            if (y <= wordSearch.items.len - windowSize) {
                const windowY = .{ wordSearch.items[y][x], wordSearch.items[y + 1][x], wordSearch.items[y + 2][x], wordSearch.items[y + 3][x] };

                if (std.mem.eql(u8, &windowY, "XMAS") or std.mem.eql(u8, &windowY, "SAMX")) {
                    xmas += 1;
                }
            }

            if (x <= wordSearch.items[y].len - 3 and y <= wordSearch.items.len - 3) {
                const windowDiagRight: [3]u8 = .{ wordSearch.items[y][x], wordSearch.items[y + 1][x + 1], wordSearch.items[y + 2][x + 2] };
                const windowDiagLeft: [3]u8 = .{ wordSearch.items[y][x + 2], wordSearch.items[y + 1][x + 1], wordSearch.items[y + 2][x] };

                if ((std.mem.eql(u8, &windowDiagRight, "MAS") or std.mem.eql(u8, &windowDiagRight, "SAM")) and (std.mem.eql(u8, &windowDiagLeft, "MAS") or std.mem.eql(u8, &windowDiagLeft, "SAM"))) {
                    masInAnX += 1;
                    if (x == 4 and y == 5) {
                        print("{s}, {s}\n", .{ windowDiagLeft, windowDiagRight });
                    }
                }
            }
        }
        allocator.free(wordSearch.items[y]);
    }
    print("{}\n{}", .{ xmas, masInAnX });
}
