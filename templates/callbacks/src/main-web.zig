const std = @import("std");
const start = @import("start.zig");

const zemscripten = @import("zemscripten");
pub const panic = zemscripten.panic;

pub const std_options = std.Options{
    .logFn = zemscripten.log,
};

export fn main() c_int {
    return start.start();
}
