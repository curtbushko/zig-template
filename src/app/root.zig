const domain = @import("domain");
const ports = @import("ports");

pub fn ItemService(comptime Repo: type) type {
    _ = ports.ItemRepository(Repo);

    return struct {
        repo: *Repo,
        const Self = @This();

        pub fn init(repo: *Repo) Self {
            return .{ .repo = repo };
        }

        pub fn addItem(self: *Self, name: []const u8) !domain.Item {
            const item = domain.Item{ .name = name };
            try item.validate();
            if (self.repo.findByName(name) != null) return error.DuplicateName;
            try self.repo.save(item);
            return item;
        }
    };
}
