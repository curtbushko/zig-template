const std = @import("std");
const root = @import("root.zig");

pub fn main() !void {
    // Example: Using library functions
    const sum = root.add(5, 7);
    std.debug.print("5 + 7 = {d}\n", .{sum});

    const quotient = try root.divide(20, 4);
    std.debug.print("20 / 4 = {d}\n", .{quotient});

    // Example: Using Calculator struct
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var calc = try root.Calculator.init(allocator);
    defer calc.deinit();

    try calc.addToHistory(sum);
    try calc.addToHistory(quotient);

    std.debug.print("\nCalculation history:\n", .{});
    for (calc.getHistory(), 0..) |value, i| {
        std.debug.print("  [{d}] {d}\n", .{ i, value });
    }

    std.debug.print("\nzig-template is working!\n", .{});
}

// ============================================================================
// Tests
// ============================================================================

test "main imports root correctly" {
    const result = root.add(1, 1);
    try std.testing.expectEqual(2, result);
}
