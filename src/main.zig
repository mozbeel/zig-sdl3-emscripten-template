const std = @import("std");
const entry = @import("entry.zig");

pub fn main() !void {
    try entry.init();
    defer entry.destroy();

    while (entry.running) {
        entry.event();
        entry.iterate();
    }

}

