const std = @import("std");
const zemscripten = @import("zemscripten");
pub const panic = zemscripten.panic;

pub const std_options = std.Options{
    .logFn = zemscripten.log,
};

const sdl3 = @import("sdl3");

const SCREEN_WIDTH = 1280;
const SCREEN_HEIGHT = 720;

var should_quit: bool = false;

fn tick() callconv(.c) void {
    if (should_quit) {
        zemscripten.cancelMainLoop();
    }

    while (sdl3.events.available()) {
        switch (sdl3.events.waitAndPop() catch {
            should_quit = true;
            return;
        }) {
            .quit => {
                std.log.info("Quit event received.", .{});
                should_quit = true;
                break; // Exit the while loop after a quit event
            },
            .terminating => {
                std.log.info("Terminating event received.", .{});
                should_quit = true;
                break; // Exit the while loop after a terminating event
            },
            else => {
                // Handle other events here if needed (mouse, keyboard, etc.)
                // std.log.info("Unhandled event: {any}", .{event});
            },
        }
    }
}

export fn main() c_int {
    std.log.info("Hello World", .{});

    const init_flags = sdl3.InitFlags{ .video = true };
    sdl3.init(init_flags) catch return 1;
    defer sdl3.quit(init_flags);

    const window = sdl3.video.Window.init("Hello SDL3", SCREEN_WIDTH, SCREEN_HEIGHT, .{}) catch return 1;
    defer window.deinit();

    const surface = window.getSurface() catch return 1;
    surface.fillRect(null, surface.mapRgb(128, 30, 255)) catch return 1;
    window.updateSurface() catch return 1;

    zemscripten.setMainLoop(tick, 0, true);

    return 0;
}
