const std = @import("std");
const domain = @import("domain");
const testing = std.testing;

test "Item validate accepts non-empty name" {
    const item = domain.Item{ .name = "test" };
    try item.validate();
}

test "Item validate rejects empty name" {
    const item = domain.Item{ .name = "" };
    try testing.expectError(error.EmptyName, item.validate());
}
