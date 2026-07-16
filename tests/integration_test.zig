const std = @import("std");
const domain = @import("domain");
const app = @import("app");
const adapters = @import("adapters");
const testing = std.testing;

test "MemoryItemRepository save and findByName roundtrip" {
    var repo = try adapters.MemoryItemRepository.init(testing.allocator);
    defer repo.deinit();

    const item = domain.Item{ .name = "test-item" };
    try repo.save(item);

    const found = repo.findByName("test-item");
    try testing.expect(found != null);
    try testing.expectEqualStrings("test-item", found.?.name);
}

test "MemoryItemRepository findByName returns null for missing" {
    var repo = try adapters.MemoryItemRepository.init(testing.allocator);
    defer repo.deinit();

    const found = repo.findByName("nonexistent");
    try testing.expect(found == null);
}

test "ItemService with MemoryItemRepository integration" {
    var repo = try adapters.MemoryItemRepository.init(testing.allocator);
    defer repo.deinit();

    const ItemService = app.ItemService(adapters.MemoryItemRepository);
    var service = ItemService.init(&repo);

    const item = try service.addItem("integration-test");
    try testing.expectEqualStrings("integration-test", item.name);

    const found = repo.findByName("integration-test");
    try testing.expect(found != null);
}
