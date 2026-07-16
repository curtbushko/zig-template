const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // --- Hexagonal architecture modules (dependencies flow INWARD) ---

    // Domain: innermost layer. NO imports from other layers.
    const domain_mod = b.addModule("domain", .{
        .root_source_file = b.path("src/domain/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Ports: depends only on domain.
    const ports_mod = b.addModule("ports", .{
        .root_source_file = b.path("src/ports/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    ports_mod.addImport("domain", domain_mod);

    // App: depends on domain + ports.
    const app_mod = b.addModule("app", .{
        .root_source_file = b.path("src/app/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    app_mod.addImport("domain", domain_mod);
    app_mod.addImport("ports", ports_mod);

    // Adapters: depends on domain + ports. NOT on app.
    const adapters_mod = b.addModule("adapters", .{
        .root_source_file = b.path("src/adapters/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    adapters_mod.addImport("domain", domain_mod);
    adapters_mod.addImport("ports", ports_mod);

    // --- Executable: composition root, can see everything ---

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("domain", domain_mod);
    exe_mod.addImport("ports", ports_mod);
    exe_mod.addImport("app", app_mod);
    exe_mod.addImport("adapters", adapters_mod);

    const exe = b.addExecutable(.{
        .name = "zig-template",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // --- Tests mirror architectural boundaries ---

    // Domain tests: only domain
    const domain_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/domain_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    domain_tests.root_module.addImport("domain", domain_mod);

    // App tests: domain + ports + app (mock adapters in test file)
    const app_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/app_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    app_tests.root_module.addImport("domain", domain_mod);
    app_tests.root_module.addImport("ports", ports_mod);
    app_tests.root_module.addImport("app", app_mod);

    // Integration tests: all layers
    const integration_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/integration_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    integration_tests.root_module.addImport("domain", domain_mod);
    integration_tests.root_module.addImport("ports", ports_mod);
    integration_tests.root_module.addImport("app", app_mod);
    integration_tests.root_module.addImport("adapters", adapters_mod);

    // Test step runs all test suites
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&b.addRunArtifact(domain_tests).step);
    test_step.dependOn(&b.addRunArtifact(app_tests).step);
    test_step.dependOn(&b.addRunArtifact(integration_tests).step);

    // Check step for fast compile-only verification
    const check_exe = b.addExecutable(.{
        .name = "zig-template-check",
        .root_module = exe_mod,
    });
    const check_step = b.step("check", "Check if code compiles");
    check_step.dependOn(&check_exe.step);
}
