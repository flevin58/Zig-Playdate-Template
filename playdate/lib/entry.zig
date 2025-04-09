/// entry.zig
/// This is the entry point to the playdate application
/// DO NOT MODIFY unless you know what you are doing!
/// Functions here will initialize hw / simulator and will
/// automagically instantiate your Game struct in 'game.zig'
/// Note: the playdate will call game.update() at each frame
const std = @import("std");
const pdapi = @import("playdate").pdapi;
const panic_handler = @import("playdate").panic_handler;
const Game = @import("game");

pub export fn eventHandler(playdate: *pdapi.PlaydateAPI, event: pdapi.PDSystemEvent, arg: u32) callconv(.C) c_int {
    _ = arg;
    switch (event) {
        .EventInit => {
            //NOTE: Initalizing the panic handler should be the first thing that is done.
            //      If a panic happens before calling this, the simulator or hardware will
            //      just crash with no message.
            // panic_handler.init(playdate);
            const game: *Game = @ptrCast(
                @alignCast(
                    playdate.system.realloc(
                        null,
                        @sizeOf(Game),
                    ),
                ),
            );
            game.* = Game.init(playdate);
            //            gamePtr = game;
            playdate.system.setUpdateCallback(update_and_render, game);
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
