/// game.zig
/// User-implemented Game struct
/// Here you have to define ALL fields that will be used by the game
/// Those fields MUST then be initialized in the init() function.
/// The playdev will then call the render() function at every frame to
/// determine if the screen needs update (true) or no drawing is necessary (false).
/// No other function is needed to implement a game.
const std = @import("std");
const pdapi = @import("playdate_api_definitions.zig");
const panic_handler = @import("panic_handler.zig");

const Self = @This();

playdate: *pdapi.PlaydateAPI,
zig_image: *pdapi.LCDBitmap,
font: *pdapi.LCDFont,
image_width: c_int,
image_height: c_int,

/// Initializes the Game struct.
/// It is called by the eventHandler function in entry.zig
pub fn init(playdate: *pdapi.PlaydateAPI) Self {
    var self = Self{
        .playdate = playdate,
        .zig_image = playdate.graphics.loadBitmap("assets/images/zig-playdate", null).?,
        .font = undefined,
        .image_width = 0,
        .image_height = 0,
    };
    playdate.graphics.getBitmapData(
        self.zig_image,
        &self.image_width,
        &self.image_height,
        null,
        null,
        null,
    );
    self.font = playdate.graphics.loadFont("/System/Fonts/Roobert-20-Medium.pft", null).?;
    playdate.graphics.setFont(self.font);
    return self;
}

/// The game loop called at every frame by the playdev.
/// Return true if the frame shoud be rendered (due to changes) or false if not.
/// You may define other functions and structs with functions (like sprites) but
/// at the end of the day everything is called from this function.
pub fn render(self: Self) bool {

    // ---------------------------------
    // READ EVENTS AND UPDATE GAME STATE
    // ---------------------------------
    var draw_mode: pdapi.LCDBitmapDrawMode = .DrawModeCopy;
    var clear_color: pdapi.LCDSolidColor = .ColorWhite;
    var buttons: pdapi.PDButtons = 0;
    self.playdate.system.getButtonState(&buttons, null, null);
    if (buttons & pdapi.BUTTON_A != 0) {
        draw_mode = .DrawModeInverted;
        clear_color = .ColorBlack;
    }

    // --------------------
    // RENDER TO THE SCREEN
    // --------------------
    const gfx = self.playdate.graphics;
    gfx.setDrawMode(draw_mode);
    gfx.clear(@intCast(@intFromEnum(clear_color)));
    const to_draw = "Hold Ⓐ";
    const text_width =
        gfx.getTextWidth(
            self.font,
            to_draw,
            to_draw.len,
            .UTF8Encoding,
            0,
        );

    gfx.drawBitmap(self.zig_image, 0, 0, .BitmapUnflipped);
    const pixel_width = gfx.drawText(
        to_draw,
        to_draw.len,
        .UTF8Encoding,
        @divTrunc(pdapi.LCD_COLUMNS - text_width, 2),
        pdapi.LCD_ROWS - gfx.getFontHeight(self.font) - 20,
    );
    _ = pixel_width;

    return true;
}

/// Our own simplified panic() function, with just a message.
pub fn panic(self: Self, msg: []const u8) noreturn {
    panic_handler.panic(self.playdate, msg, null, null);
}
