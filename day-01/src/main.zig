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

    var totalDistance: i64 = 0;

    var list1 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(allocator);
    defer list2.deinit();

    while (try file.reader().readUntilDelimiterOrEof(buffer, '\n')) |line| {
        totalDistance += 1;

        var distances = std.mem.splitSequence(u8, line, "   ");
        var n: u8 = 0;
        while (distances.next()) |value| {
            const int = try std.fmt.parseInt(i32, value, 10);

            if (n == 0) {
                try list1.append(int);
            } else if (n == 1) {
                try list2.append(int);
            }
            n += 1;
        }
    }

    std.mem.sort(i32, list1.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, list2.items, {}, std.sort.asc(i32));

    var totalDiff: u32 = 0;

    if (list1.items.len == list2.items.len) {
        for (list1.items, list2.items) |list1Value, list2Value| {
            const diff = @abs(list1Value - list2Value);
            totalDiff += diff;
        }
    }

    print("-------------------------\nTotal Difference: {}\n", .{totalDiff});

    var similarityScore: i32 = 0;
    for (list1.items) |value| {
        var occurences: i32 = 0;
        for (list2.items) |occurence| {
            if (value == occurence) {
                occurences += 1;
            }
        }
        similarityScore += occurences * value;
    }
    print("Similarity Score: {}\n", .{similarityScore});
}
