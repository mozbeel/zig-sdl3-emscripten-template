const std = @import("std");
const sdl3 = @import("sdl3");

const SCREEN_WIDTH = 1280;
const SCREEN_HEIGHT = 720;

pub fn main() !void {
    defer sdl3.shutdown();

    const init_flags = sdl3.InitFlags{ .video = true };
    try sdl3.init(init_flags);
    defer sdl3.quit(init_flags);

    const window = try sdl3.video.Window.init("Hello SDL3", SCREEN_WIDTH, SCREEN_HEIGHT, .{});
    defer window.deinit();

    const surface = try window.getSurface();
    try surface.fillRect(null, surface.mapRgb(128, 30, 255));
    try window.updateSurface();

    while (true) {
        switch (try sdl3.events.waitAndPop()) {
            .quit => break,
            .terminating => break,
            else => {},
        }
    }
}
