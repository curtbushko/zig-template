pub fn ItemRepository(comptime Repo: type) type {
    comptime {
        if (!@hasDecl(Repo, "save"))
            @compileError("ItemRepository requires a 'save' method");
        if (!@hasDecl(Repo, "findByName"))
            @compileError("ItemRepository requires a 'findByName' method");
    }
    return Repo;
}
