const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

var window : ?*c.SDL_Window = undefined;
var renderer: ?*c.SDL_Renderer = undefined;
pub var running : bool = true;

pub fn init() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) == false) {
        std.log.err("Failed to initialize SDL", .{});
        return error.InitSDLFailed;
    }

    if(!c.SDL_CreateWindowAndRenderer("Basic SDL3", 1280, 720, 0, &window, &renderer)) {
        std.log.err("Failed to initialize SDL Window or Renderer: {s}", .{ c.SDL_GetError() }); 
        return error.InitWindowOrRendererFailed;
    }
}

pub fn event() void {
    var sdl_event : c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&sdl_event)) {
        switch (sdl_event.type) {
            c.SDL_EVENT_QUIT, c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => running = false,
            else => continue,
        }
    }

}

pub fn iterate() void {
    _ = c.SDL_SetRenderDrawColor(renderer.?, 128, 30, 255, 255);

    _ = c.SDL_RenderClear(renderer.?);

    _ = c.SDL_RenderPresent(renderer.?);

}

pub fn destroy() void {
    c.SDL_Quit();
    c.SDL_DestroyWindow(window.?);
    c.SDL_DestroyRenderer(renderer.?);

}
