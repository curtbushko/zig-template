pub const DomainError = error{EmptyName};

pub const Item = struct {
    name: []const u8,

    pub fn validate(self: Item) DomainError!void {
        if (self.name.len == 0) return error.EmptyName;
    }
};
