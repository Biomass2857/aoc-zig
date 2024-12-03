const std = @import("std");

fn array_to_string(comptime T: type, arr: []const T) [200]u8 {
    var buffer: [200]u8 = undefined;
    var len: usize = 0;

    len += try std.fmt.bufPrint(buffer[len..], "[", .{});

    for (arr, 0..) |num, index| {
        if (index > 0) {
            len += try std.fmt.bufPrint(buffer[len..], ", ", .{});
        }
        len += try std.fmt.bufPrint(buffer[len..], "{}", .{num});
    }

    len += try std.fmt.bufPrint(buffer[len..], "]", .{});
    return buffer;
}

const Report = struct {
    levels: []const i8,

    const Increase = enum { Increasing, Decreasing, Nothing };

    fn is_valid(self: *const Report) bool {
        var previous = self.levels[0];
        var previous_inc: ?Increase = null;
        for (1..self.levels.len) |index| {
            const next_level = self.levels[index];
            const diff = next_level - previous;
            var current_inc: Increase = undefined;
            if (diff > 0) {
                current_inc = .Increasing;
            } else if (diff < 0) {
                current_inc = .Decreasing;
            } else {
                current_inc = .Nothing;
            }

            if (current_inc == .Nothing) {
                std.debug.print("no increase\n", .{});
                self.print();
                return false;
            }

            if (previous_inc) |p_inc| {
                if (p_inc != current_inc) {
                    std.debug.print("wrong inrease\n", .{});
                    self.print();
                    return false;
                }
            }

            if (@abs(diff) == 0 or @abs(diff) > 3) {
                std.debug.print("too high diff\n", .{});
                self.print();
                return false;
            }

            previous = next_level;
            previous_inc = current_inc;
        }

        std.debug.print("safe\n", .{});
        self.print();

        return true;
    }

    fn print(self: *const Report) void {
        std.debug.print(".levels = {any}\n", .{self.levels});
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file = try std.fs.cwd().openFile("input02.txt", .{ .mode = .read_only });
    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    var lines = std.mem.splitSequence(u8, content, "\n");
    var reports = std.ArrayList(Report).init(allocator);
    defer reports.deinit();

    const allocator2 = std.heap.page_allocator;
    while (lines.next()) |line| {
        var levels = std.mem.splitSequence(u8, line, " ");
        var levels_integer = std.ArrayList(i8).init(allocator2); // deinit this later

        while (levels.next()) |level| {
            try levels_integer.append(try std.fmt.parseInt(i8, level, 10));
        }

        try reports.append(.{ .levels = levels_integer.items });
    }

    var sum: i32 = 0;
    for (reports.items) |report| {
        if (report.is_valid()) {
            sum += 1;
        }
    }

    std.debug.print("reports safe = {}", .{sum});
}
