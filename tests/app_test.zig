const std = @import("std");
const domain = @import("domain");
const app = @import("app");
const testing = std.testing;

const MockItemRepo = struct {
    items: [32]domain.Item,
    count: usize = 0,

    pub fn save(self: *MockItemRepo, item: domain.Item) !void {
        if (self.count >= 32) return error.OutOfMemory;
        self.items[self.count] = item;
        self.count += 1;
    }

    pub fn findByName(self: *const MockItemRepo, name: []const u8) ?domain.Item {
        for (self.items[0..self.count]) |item| {
            if (std.mem.eql(u8, item.name, name)) return item;
        }
        return null;
    }
};

test "ItemService addItem succeeds with valid name" {
    var repo = MockItemRepo{ .items = undefined };
    const ItemService = app.ItemService(MockItemRepo);
    var service = ItemService.init(&repo);

    const item = try service.addItem("test-item");
    try testing.expectEqualStrings("test-item", item.name);
    try testing.expectEqual(@as(usize, 1), repo.count);
}

test "ItemService addItem rejects empty name" {
    var repo = MockItemRepo{ .items = undefined };
    const ItemService = app.ItemService(MockItemRepo);
    var service = ItemService.init(&repo);

    try testing.expectError(error.EmptyName, service.addItem(""));
}

test "ItemService addItem rejects duplicate name" {
    var repo = MockItemRepo{ .items = undefined };
    const ItemService = app.ItemService(MockItemRepo);
    var service = ItemService.init(&repo);

    _ = try service.addItem("test-item");
    try testing.expectError(error.DuplicateName, service.addItem("test-item"));
}
