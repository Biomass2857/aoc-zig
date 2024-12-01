const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file_path = "input.txt";

    const file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });

    const content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    defer allocator.free(content);

    var lines = std.mem.splitSequence(u8, content, "\n");

    var list1 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();
    var list2 = std.ArrayList(i32).init(allocator);
    defer list2.deinit();

    while (true) {
        if (lines.next()) |line| {
            var values = std.mem.splitSequence(u8, line, "   ");
            const val1_str = std.mem.trim(u8, values.next().?, "\t\n ");
            const val2_str = std.mem.trim(u8, values.next().?, "\t\n ");

            const val1 = try std.fmt.parseInt(i32, val1_str, 10);
            const val2 = try std.fmt.parseInt(i32, val2_str, 10);

            try list1.append(val1);
            try list2.append(val2);
        } else {
            break;
        }
    }

    std.mem.sort(i32, list1.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, list2.items, {}, std.sort.asc(i32));

    std.debug.assert(list1.items.len == list2.items.len);

    var diff: u32 = 0;
    for (0..list1.items.len) |index| {
        const v1 = list1.items[index];
        const v2 = list2.items[index];

        diff += @abs(v2 - v1);
    }

    std.debug.print("diff = {}\n", .{diff});
}
