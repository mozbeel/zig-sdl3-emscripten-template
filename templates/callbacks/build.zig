const std = @import("std");
const zemscripten = @import("zemscripten");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    if (target.query.os_tag == .emscripten) {
        try buildWeb(b, target, optimize);
    } else if(target.query.abi == .android or target.query.abi == .androideabi) {
        @panic("This isn't supported (yet)");
    } else {
        try buildBin(b, target, optimize);
    }
}

fn buildWeb(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const activateEmsdk = zemscripten.activateEmsdkStep(b);
    b.default_step.dependOn(activateEmsdk);

    const wasm = b.addStaticLibrary(.{
        .name = "MyGame",
        .root_source_file = b.path("src/main-web.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const zemscripten_dep = b.dependency("zemscripten", .{});
    wasm.root_module.addImport("zemscripten", zemscripten_dep.module("root"));

    const sdl3 = b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,
    });
    wasm.root_module.addImport("sdl3", sdl3.module("sdl3"));

    const emsdk_dep = b.dependency("emsdk", .{});
    const emsdk_sysroot_include_path = emsdk_dep.path("upstream/emscripten/cache/sysroot/include");

    sdl3.module("sdl3").addSystemIncludePath(emsdk_sysroot_include_path);

    const sysroot_include = b.pathJoin(&.{ b.sysroot.?, "include" });
    var dir = std.fs.openDirAbsolute(sysroot_include, std.fs.Dir.OpenDirOptions{ .access_sub_paths = true, .no_follow = true }) catch @panic("No emscripten cache. Generate it!");
    dir.close();
    wasm.addSystemIncludePath(.{ .cwd_relative = sysroot_include });

    const emcc_flags = zemscripten.emccDefaultFlags(b.allocator, .{
        .optimize = optimize,
        .fsanitize = true,
    });

    var emcc_settings = zemscripten.emccDefaultSettings(b.allocator, .{
        .optimize = optimize,
    });
    try emcc_settings.put("ALLOW_MEMORY_GROWTH", "1");
    try emcc_settings.put("INITIAL_MEMORY", "256MB");

    const emcc_step = zemscripten.emccStep(
        b,
        wasm,
        .{
            .optimize = optimize,
            .flags = emcc_flags, // Pass the modified flags
            .settings = emcc_settings,
            .use_preload_plugins = true,
            .embed_paths = &.{},
            .preload_paths = &.{},
            .install_dir = .{ .custom = "web" },
            .shell_file_path = "src/html/shell.html",
        },
    );

    b.getInstallStep().dependOn(emcc_step);
}

fn buildBin(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const exe = b.addExecutable(.{
        .name = "MyGame",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const sdl3 = b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("sdl3", sdl3.module("sdl3"));

    exe.linkLibC();

    b.installArtifact(exe);

    b.getInstallStep().dependOn(&exe.step);
}
