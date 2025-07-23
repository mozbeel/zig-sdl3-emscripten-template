const std = @import("std");
const entry = @import("entry.zig");

const zemscripten = @import("zemscripten");
pub const panic = zemscripten.panic;

pub const std_options = std.Options{
    .logFn = zemscripten.log,
};

fn tick() callconv(.c) void {
    if (!entry.running) {
        zemscripten.cancelMainLoop();
    }

    entry.event();
    entry.iterate();
}

export fn main(argc: c_int, argv: [*c]const [*c]const u8) callconv(.c) u8 {
    _ = argc;
    _ = argv;
    entry.init() catch return 1;
    defer entry.destroy();

    zemscripten.setMainLoop(tick, 0, true);

    return 0;
}
