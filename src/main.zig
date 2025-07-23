const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub fn main() !void {
    defer c.SDL_Quit();
    
    if (c.SDL_Init(c.SDL_INIT_VIDEO) == false) {
        std.log.err("Failed to initialize SDL", .{});
        return;
    }

    var window : ?*c.SDL_Window = undefined;
    var renderer: ?*c.SDL_Renderer = undefined;

    if(!c.SDL_CreateWindowAndRenderer("Basic SDL3", 1280, 720, 0, &window, &renderer)) {
        std.log.err("Failed to initialize SDL Window or Renderer: {s}", .{ c.SDL_GetError() }); 
        return;
    }
    defer c.SDL_DestroyWindow(window.?);
    defer c.SDL_DestroyRenderer(renderer.?);

    var running : bool = true;

    while (running) {
        var event : c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_QUIT, c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => running = false,
                else => continue,
            }
        }
        _ = c.SDL_SetRenderDrawColor(renderer.?, 128, 30, 255, 255);

        _ = c.SDL_RenderClear(renderer.?);

        _ = c.SDL_RenderPresent(renderer.?);
    }
}

