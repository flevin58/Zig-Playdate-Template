/// entry.zig
/// This is the entry point to the playdate application
/// DO NOT MODIFY unless you know what you are doing!
/// Functions here will initialize hw / simulator and will
/// automagically instantiate your Game struct in 'game.zig'
/// Note: the playdate will call game.update() at each frame
const std = @import("std");
const playdate = @import("playdate");
const Game = @import("game");

comptime {
    if (!std.meta.hasMethod(Game, "init") or !std.meta.hasMethod(Game, "update")) {
        @compileError(
            \\
            \\ ==================================================================================================
            \\ "Game" must implement at least the following two methods:
            \\    1) init(playdate: *pdapi.PlaydateAPI) Self ---> it will be called once by the playdate api.
            \\    2) update() bool ---> that be called at every frame and should return true if redraw is needed.
            \\ ==================================================================================================
            \\
        );
    }
}

pub export fn eventHandler(pdapi_arg: *playdate.PlaydateAPI, event: playdate.PDSystemEvent, arg: u32) callconv(.C) c_int {
    _ = arg;
    switch (event) {
        .EventInit => {
            //NOTE: Initalizing the panic handler should be the first thing that is done.
            //      If a panic happens before calling this, the simulator or hardware will
            //      just crash with no message.
            // panic_handler.init(playdate);
            const game: *Game = @ptrCast(
                @alignCast(
                    pdapi_arg.system.realloc(
                        null,
                        @sizeOf(Game),
                    ),
                ),
            );
            game.* = Game.init(pdapi_arg);
            pdapi_arg.system.setUpdateCallback(update_and_render, game);
        },
        else => {},
    }
    return 1;
}

/// This is the update callback that is called by the playdate at every frame
/// Note: we set it up in the .Init event of the eventHandler and it actually
/// calls game.update() which is user defined in the game.zig file.
fn update_and_render(data: ?*anyopaque) callconv(.C) c_int {
    var game: *Game = @ptrCast(@alignCast(data));
    return if (game.update() == true) 1 else 0;
}
