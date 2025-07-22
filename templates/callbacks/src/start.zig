const sdl3 = @import("sdl3");
const std = @import("std");

const allocator = std.heap.c_allocator;

const SCREEN_WIDTH = 1280;
const SCREEN_HEIGHT = 720;

const AppState = struct {
    window: sdl3.video.Window,
};

fn init(
    app_state: *?*AppState,
    args: [][*:0]u8,
) !sdl3.AppResult {
    const window = try sdl3.video.Window.init(std.mem.span(args[0]), SCREEN_WIDTH, SCREEN_HEIGHT, .{});
    errdefer window.deinit();

    std.log.info("Checkpoint 1", .{});
    
    const state = try allocator.create(AppState);
    std.log.info("Checkpoint 2", .{});
    state.* = .{
        .window = window,
    };
    app_state.* = state;
    return .run;
}

fn iterate(
    app_state: ?*AppState,
) !sdl3.AppResult {
    const state = app_state orelse return .failure;

    const surface = try state.window.getSurface();
    try surface.fillRect(null, surface.mapRgb(128, 30, 255));
    try state.window.updateSurface();
    return .run;
}

fn event(
    app_state: ?*AppState,
    curr_event: sdl3.events.Event,
) !sdl3.AppResult {
    _ = app_state;

    return switch (curr_event) {
        .quit => .success,
        .terminating => .success,
        else => .run,
    };
}

fn quit(
    app_state: ?*AppState,
    result: sdl3.AppResult,
) void {
    _ = result;
    if (app_state) |state| {
        state.window.deinit();
        allocator.destroy(state);
    }
}

pub fn start() c_int {
    sdl3.main_funcs.setMainReady();
    std.log.info("Checkpoint 4", .{});
    var args = [_:null]?[*:0]u8{
        @constCast("Hello SDL3"),
    };
    std.log.info("Checkpoint 3", .{});
    return sdl3.main_funcs.enterAppMainCallbacks(&args, AppState, init, iterate, event, quit);
}

