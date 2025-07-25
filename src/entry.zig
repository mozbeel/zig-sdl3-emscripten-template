const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});
const builtin = @import("builtin");

var window : ?*c.SDL_Window = undefined;
var renderer: ?*c.SDL_Renderer = undefined;
pub var running : bool = true;

pub fn init() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) == false) {
        std.log.err("Failed to initialize SDL", .{});
        return error.InitSDLFailed;
    }
    
    var window_width : u16 = 1280;
    var window_height : u16 = 720;

    if (builtin.abi.isAndroid() or builtin.target.os.tag == .ios) {
        const display_mode = c.SDL_GetCurrentDisplayMode(c.SDL_GetPrimaryDisplay());

        if (display_mode.?) |d| {
            window_width = @intCast(d.*.w);
            window_height = @intCast(d.*.h);
        } else {
            std.log.err("Couldn't get screen size", .{});
            return error.InitSDLWindowSizeFailed;
        }
    }

    if(!c.SDL_CreateWindowAndRenderer("Basic SDL3", window_width, window_height, 0, &window, &renderer)) {
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
