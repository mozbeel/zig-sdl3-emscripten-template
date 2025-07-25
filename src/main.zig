const builtin = @import("builtin");
const entry = @import("entry.zig");
const android = @import("android");

const c = @cImport({
    @cInclude("SDL3/SDL_main.h");
});

pub const std_options: std.Options = if (builtin.abi.isAndroid())
    .{
        .logFn = android.logFn,
    }
else
    .{};
const std = @import("std");

pub export fn SDL_main(argc : c_int, argv: [*c][*c]u8) callconv(.c) c_int {
    _ = argc;
    _ = argv;
    std.log.info("Hello World!", .{});
    entry.init() catch return 1;
    defer entry.destroy();

    while (entry.running) {
        entry.event();
        entry.iterate();
    }
    return 0;
}


