const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

// this code is genuinely atrrocious

fn checkLine(levelsArray: std.ArrayList(i32)) !bool {
    const levels = try levelsArray.clone();
    defer levels.deinit();

    var decreasing = false;
    var increasing = false;
    var maxDiff: u32 = 0;
    var prevLevel: i32 = 0;
    var firstValue = true;
    var duplicate = false;

    for (levels.items) |level| {

        // I dont understand optional types so flags it is...
        if (firstValue) {
            prevLevel = level;
            firstValue = false;
            continue;
        }

        if (level < prevLevel) {
            decreasing = true;
        } else if (level > prevLevel) {
            increasing = true;
        } else if (level == prevLevel) {
            duplicate = true;
        }

        if (@abs(prevLevel - level) > maxDiff) {
            maxDiff = @abs(prevLevel - level);
        }

        prevLevel = level;
    }

    return (((increasing and !decreasing) or (decreasing and !increasing)) and maxDiff <= 3 and !duplicate);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try std.fs.cwd().openFile("./data/input.txt", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size + 1);
    defer allocator.free(buffer);

    var totalSafe: u32 = 0;
    var totalDampenedSafe: u32 = 0;
    while (try file.reader().readUntilDelimiterOrEof(buffer, '\n')) |line| {
        var levelsString = std.mem.splitSequence(u8, line, " ");
        var levels = std.ArrayList(i32).init(allocator);
        defer levels.deinit();
        while (levelsString.next()) |levelValue| {
            try levels.append(try std.fmt.parseInt(i32, levelValue, 10));
        }

        if (try checkLine(levels)) {
            totalSafe += 1;
            totalDampenedSafe += 1;
        } else {
            var pass = false;
            for (0..levels.items.len) |index| {
                var elementRemovedList = try levels.clone();
                defer elementRemovedList.deinit();

                _ = elementRemovedList.orderedRemove(index);

                if (try checkLine(elementRemovedList)) {
                    pass = true;
                }
            }
            if (pass) {
                totalDampenedSafe += 1;
            }
        }
    }

    print("\nTotal Safe Levels: {}\nTotal Dampened Safe Levels: {}", .{ totalSafe, totalDampenedSafe });
}
