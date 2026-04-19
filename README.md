# Zig Template

A comprehensive template for starting Zig projects with modern tooling and best practices.

## Features

This template provides:

- **Dual-purpose build**: Creates both a library (`libzig-template.a`) and an executable (`zig-template`)
- **Nix flakes**: Reproducible development environment with pinned Zig 0.15.2
- **Task runner**: Task-based workflow with `Taskfile.yml` (run `task` to see commands)
- **Example code**: Demonstrates Zig best practices including error handling, memory management, and testing
- **CI/CD ready**: GitHub Actions workflow for automated testing
- **Dependency management**: Configured with `build.zig.zon` and Renovate

## Quick Start

### Prerequisites

- **Nix with flakes enabled** (recommended) - If on macOS, use the [Determinate Systems installer](https://determinate.systems/nix-installer/)
- **direnv** (optional but recommended) - Automatically loads the Nix environment

### Using Nix (Recommended)

1. Clone this template:
   ```bash
   git clone <your-repo-url>
   cd zig-template
   ```

2. If using direnv, allow the environment:
   ```bash
   direnv allow
   ```

   Otherwise, enter the Nix shell manually:
   ```bash
   nix develop
   ```

3. See available commands:
   ```bash
   task
   ```

4. Build and run:
   ```bash
   task build
   task run
   ```

### Without Nix

If you have Zig 0.15.2+ installed locally:

1. Install [go-task](https://taskfile.dev/) (or use `zig build` commands directly)
2. Run `task build` or `zig build`

## Project Structure

```
zig-template/
├── build.zig          # Build configuration
├── build.zig.zon      # Package dependencies
├── flake.nix          # Nix development environment
├── Taskfile.yml       # Task definitions
├── src/
│   ├── main.zig       # Executable entry point
│   └── root.zig       # Library entry point with tests
├── .envrc             # direnv configuration
├── .gitignore         # Zig-specific ignores
└── README.md          # This file
```

## Available Tasks

Run `task` to see all available commands. Common ones:

- `task build` - Build the project
- `task run` - Build and run the executable
- `task test` - Run all tests
- `task fmt` - Format all source files
- `task check` - Check if code compiles (fast)
- `task clean` - Clean build artifacts
- `task ci` - Run all CI checks (format, build, test)

## Development

### Building

```bash
# Debug build (default)
task build

# Release builds (optimized)
task build:release  # Balanced safety and speed
task build:fast     # Maximum speed
task build:small    # Minimum size
```

### Testing

```bash
# Run all tests
task test

# Verbose output
task test:verbose
```

### Formatting

```bash
# Format all files
task fmt

# Check formatting (CI)
task fmt:check
```

## Using as a Library

Other Zig projects can use this as a dependency in `build.zig.zon`:

```zig
.dependencies = .{
    .@"zig-template" = .{
        .url = "https://github.com/your-username/zig-template/archive/<commit-hash>.tar.gz",
        .hash = "...", // Use 'zig fetch' to get the hash
    },
},
```

Then in your `build.zig`:

```zig
const zig_template = b.dependency("zig-template", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zig-template", zig_template.module("zig-template"));
```

## CI/CD

The included GitHub Actions workflow (`.github/workflows/ci.yml`) automatically:

- Checks code formatting
- Builds the project
- Runs all tests
- Tests on multiple platforms (Linux, macOS, Windows)

## Adding Dependencies

1. Add to `build.zig.zon`:
   ```zig
   .dependencies = .{
       .somelib = .{
           .url = "https://github.com/user/repo/archive/commit.tar.gz",
           .hash = "...", // Use 'zig fetch' to get this
       },
   },
   ```

2. Fetch and verify:
   ```bash
   zig fetch
   ```

3. Use in `build.zig`:
   ```zig
   const somelib = b.dependency("somelib", .{
       .target = target,
       .optimize = optimize,
   });
   exe.root_module.addImport("somelib", somelib.module("somelib"));
   ```

## Customization

### Rename the Project

1. Update `build.zig.zon` - Change `.name`
2. Update `build.zig` - Change artifact names
3. Update this README
4. Update GitHub Actions workflow if needed

### Change Zig Version

Edit `flake.nix` and change the Zig version:

```nix
zigPkg = zig-overlay.packages.${system}."0.15.2";  # Change version here
```

Then update the lock file:

```bash
nix flake update
```

## Zig Best Practices

This template demonstrates:

- **Error handling**: Using error unions (`!T`) and `try`/`catch`
- **Memory management**: Explicit allocator passing and `defer` for cleanup
- **Testing**: Tests alongside implementation code
- **Module structure**: Public API at top, implementation below, tests at bottom
- **Documentation**: Doc comments with `///`

## Resources

- [Zig Documentation](https://ziglang.org/documentation/master/)
- [Zig Language Reference](https://ziglang.org/documentation/master/#Zig-Language-Reference)
- [Zig Build System](https://ziglang.org/documentation/master/#Zig-Build-System)
- [Task Documentation](https://taskfile.dev/)

## License

MIT - See LICENSE file for details

## Contributing

This is a template repository. Fork it and customize it for your own projects!

## Warranty

There is no warranty for this template. Use at your own risk. There be dragons.
