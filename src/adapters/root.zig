const std = @import("std");
const domain = @import("domain");

pub const MemoryItemRepository = struct {
    allocator: std.mem.Allocator,
    items: std.ArrayList(domain.Item),

    pub fn init(allocator: std.mem.Allocator) !MemoryItemRepository {
        return .{
            .allocator = allocator,
            .items = try .initCapacity(allocator, 8),
        };
    }

    pub fn deinit(self: *MemoryItemRepository) void {
        self.items.deinit(self.allocator);
    }

    pub fn save(self: *MemoryItemRepository, item: domain.Item) !void {
        try self.items.append(self.allocator, item);
    }

    pub fn findByName(self: *const MemoryItemRepository, name: []const u8) ?domain.Item {
        for (self.items.items) |item| {
            if (std.mem.eql(u8, item.name, name)) return item;
        }
        return null;
    }
};
