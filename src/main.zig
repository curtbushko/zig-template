const std = @import("std");
const app = @import("app");
const adapters = @import("adapters");

pub fn main() !void {
    var da: std.heap.DebugAllocator(.{}) = .init;
    defer _ = da.deinit();
    const allocator = da.allocator();

    var repo = try adapters.MemoryItemRepository.init(allocator);
    defer repo.deinit();

    const ItemService = app.ItemService(adapters.MemoryItemRepository);
    var service = ItemService.init(&repo);

    const item = try service.addItem("example");
    std.log.info("Added item: {s}", .{item.name});

    std.log.info("zig-template is working!", .{});
}
