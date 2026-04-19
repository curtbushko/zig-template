const std = @import("std");

/// Example function that adds two numbers
pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

/// Example function that demonstrates error handling
pub fn divide(a: i32, b: i32) !i32 {
    if (b == 0) {
        return error.DivisionByZero;
    }
    return @divTrunc(a, b);
}

/// Example struct with memory management
pub const Calculator = struct {
    allocator: std.mem.Allocator,
    history: std.ArrayList(i32),

    pub fn init(allocator: std.mem.Allocator) !Calculator {
        return .{
            .allocator = allocator,
            .history = try .initCapacity(allocator, 8),
        };
    }

    pub fn deinit(self: *Calculator) void {
        self.history.deinit(self.allocator);
    }

    pub fn addToHistory(self: *Calculator, value: i32) !void {
        try self.history.append(self.allocator, value);
    }

    pub fn getHistory(self: *const Calculator) []const i32 {
        return self.history.items;
    }
};

// ============================================================================
// Tests
// ============================================================================

test "add function" {
    const result = add(2, 3);
    try std.testing.expectEqual(5, result);
}

test "add with negative numbers" {
    const result = add(-5, 3);
    try std.testing.expectEqual(-2, result);
}

test "divide function" {
    const result = try divide(10, 2);
    try std.testing.expectEqual(5, result);
}

test "divide by zero returns error" {
    const result = divide(10, 0);
    try std.testing.expectError(error.DivisionByZero, result);
}

test "Calculator init and deinit" {
    var calc = try Calculator.init(std.testing.allocator);
    defer calc.deinit();

    try std.testing.expectEqual(0, calc.history.items.len);
}

test "Calculator add to history" {
    var calc = try Calculator.init(std.testing.allocator);
    defer calc.deinit();

    try calc.addToHistory(42);
    try calc.addToHistory(100);

    const history = calc.getHistory();
    try std.testing.expectEqual(2, history.len);
    try std.testing.expectEqual(42, history[0]);
    try std.testing.expectEqual(100, history[1]);
}
