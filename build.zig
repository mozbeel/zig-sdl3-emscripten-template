const std = @import("std");
const zemscripten = @import("zemscripten");
const android = @import("android");
const builtin = @import("builtin");
const root = @import("root");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const android_targets : []std.Build.ResolvedTarget = android.standardTargets(b, target);
   
    const os = target.result.os.tag;

    if (android_targets.len > 0) {
        try buildApk(b, android_targets, optimize);
    } else if (os == .windows or os == .linux or os == .macos or os == .ios) {
        try buildBin(b, target, optimize);
    } else if(os == .emscripten) {
        try buildWeb(b, target, optimize);
    }
}

fn buildBin(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "zig_sdl3_cross_template",
        .root_module = exe_mod,
    });

    const sdl3 = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });

    const sdl_lib = sdl3.artifact("SDL3");

    if (target.result.os.tag == .ios) {
        sdl_lib.addFrameworkPath(.{ .cwd_relative = b.pathJoin(&.{ b.sysroot.?, "System", "Library", "Frameworks" }) });
    }

    exe.linkLibrary(sdl_lib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    if (b.args) |args| { // If b.args is not null, unwrap it into the 'args' variable
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the App");
    run_step.dependOn(&run_cmd.step);
}

fn buildApk(
    b: *std.Build,
    android_targets: []std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode
    ) !void {
    if (android_targets.len == 0) return error.MustProvideAndroidTargets;
    const exe_name: []const u8 = "main";
    

    const android_apk: ?*android.Apk = blk: {
        if (android_targets.len == 0) break :blk null;

        const android_sdk = android.Sdk.create(b, .{});
        const apk = android_sdk.createApk(.{
            .api_level = .android15,
            .build_tools_version = "35.0.1",
            .ndk_version = "29.0.13599879",
        });
        const key_store_file = android_sdk.createKeyStore(.example);
        apk.setKeyStore(key_store_file);
        apk.setAndroidManifest(b.path("android/AndroidManifest.xml"));
        apk.addResourceDirectory(b.path("android/res"));

        // Add Java files
        // - If you have 'android:hasCode="false"' in your AndroidManifest.xml then no Java files are required
        //   see: https://developer.android.com/ndk/samples/sample_na
        //
        //   WARNING: If you do not provide Java files AND android:hasCode="false" isn't explicitly set, then you may get the following error on "adb install"
        //      Scanning Failed.: Package /data/app/base.apk code is missing]
        //
        // apk.addJavaSourceFile(.{ .file = b.path("android/src/X.java") });
        apk.addJavaSourceFile(.{ .file = b.path("android/src/ZigSDLActivity.java")});

        const sdl = b.dependency("sdl", .{
            .target = android_targets[0],
            .optimize = optimize,
        });

        const sdl_java_files = sdl.namedWriteFiles("sdljava");
        for (sdl_java_files.files.items) |file| {
            apk.addJavaSourceFile(.{.file = file.contents.copy});
        }

        break :blk apk;
    };
    for (android_targets) |t| {
            if (!t.result.abi.isAndroid()) {
            @panic("expected Android target");
        }
        const app_module = b.createModule(.{
            .target = t,
            .optimize = optimize,
            .root_source_file = b.path("src/main-android.zig"),
        });

        var exe: *std.Build.Step.Compile = if (t.result.abi.isAndroid()) b.addSharedLibrary(.{
            .name = exe_name,
            .root_module = app_module,
        }) else b.addExecutable(.{
            .name = exe_name,
            .root_module = app_module,
        });

        const sdl = b.dependency("sdl", .{
            .target = t,
            .optimize = optimize,
        });

        const sdl_lib = sdl.artifact("SDL3");

        exe.linkLibrary(sdl_lib);
        exe.linkLibC();

        // if building as library for Android, add this target
        // NOTE: Android has different CPU targets so you need to build a version of your
        //       code for x86, x86_64, arm, arm64 and more
        if (t.result.abi.isAndroid()) {
            const apk: *android.Apk = android_apk orelse @panic("Android APK should be initialized");
            const android_dep = b.dependency("android", .{
                .optimize = optimize,
                .target = t,
            });
            exe.root_module.addImport("android", android_dep.module("android"));

            apk.addArtifact(exe);
        } else {
            b.installArtifact(exe);

            // If only 1 target, add "run" step
            if (android_targets.len == 1) {
                const run_step = b.step("run", "Run the application");
                const run_cmd = b.addRunArtifact(exe);
                run_step.dependOn(&run_cmd.step);
            }
        }
    }
    if (android_apk) |apk| {
        const installed_apk = apk.addInstallApk();
        b.getInstallStep().dependOn(&installed_apk.step);

        const android_sdk = apk.sdk;
        const run_step = b.step("run", "Install and run the application on an Android device");
        const adb_install = android_sdk.addAdbInstall(installed_apk.source);
        const adb_start = android_sdk.addAdbStart("com.zig.minimal/com.zig.minimal.ZigSDLActivity");
        adb_start.step.dependOn(&adb_install.step);
        run_step.dependOn(&adb_start.step);
    }
}

fn buildWeb(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) !void {
    const activateEmsdk = zemscripten.activateEmsdkStep(b);
    b.default_step.dependOn(activateEmsdk);

    const wasm = b.addStaticLibrary(.{
        .name = "zig_sdl3_cross_template",
        .root_source_file = b.path("src/main-web.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const zemscripten_dep = b.dependency("zemscripten", .{});
    wasm.root_module.addImport("zemscripten", zemscripten_dep.module("root"));

    const sdl3 = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });

    const sdl_lib = sdl3.artifact("SDL3");
    wasm.linkLibrary(sdl_lib);

    const emsdk_dep = b.dependency("emsdk", .{});
    const emsdk_sysroot_include_path = emsdk_dep.path("upstream/emscripten/cache/sysroot/include");

    sdl3.artifact("SDL3").addSystemIncludePath(emsdk_sysroot_include_path);

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
    emcc_settings.put("USE_SDL", "3") catch unreachable;

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

    var run_emrun_step = b.step("emrun", "Run the WebAssembly app using emrun");

    const emrun_cmd = b.addSystemCommand(&.{
        "emrun",
        "--no_browser",
        "--port", "8080",
        wasm.name,
    });

    emrun_cmd.step.dependOn(b.getInstallStep());

    run_emrun_step.dependOn(&emrun_cmd.step);

    const run_step = b.step("run", "Run the app (via emrun)");
    run_step.dependOn(run_emrun_step);

    
    if (b.args) |args| {
        emrun_cmd.addArgs(args);
    }
}

