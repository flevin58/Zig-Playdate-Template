/// game.zig
/// User-implemented Game struct
/// Here you have to define ALL fields that will be used by the game
/// Those fields MUST then be initialized in the init() function.
/// The playdev will then call the update() function at every frame to
/// determine if the screen needs update (true) or if no drawing is necessary (false).
/// No other function is needed to implement a game.
const std = @import("std");
const playdate = @import("playdate");

const Self = @This();

playdate_api: *playdate.PlaydateAPI,
zig_image: *playdate.LCDBitmap,
font: *playdate.LCDFont,
image_width: c_int,
image_height: c_int,

/// Initializes the Game struct.
/// It is called by the eventHandler function in entry.zig
pub fn init(pdapi: *playdate.PlaydateAPI) Self {
    const gfx = pdapi.graphics;
    var self = Self{
        .playdate_api = pdapi,
        .zig_image = gfx.loadBitmap("assets/images/zig-playdate", null).?,
        .font = undefined,
        .image_width = 0,
        .image_height = 0,
    };
    gfx.getBitmapData(
        self.zig_image,
        &self.image_width,
        &self.image_height,
        null,
        null,
        null,
    );
    self.font = gfx.loadFont("/System/Fonts/Roobert-20-Medium.pft", null).?;
    gfx.setFont(self.font);
    return self;
}

/// Centers the given text at row y
fn centerText(self: Self, to_draw: *const anyopaque, len: usize, encoding: playdate.PDStringEncoding, y: ?usize) void {
    const gfx = self.playdate_api.graphics;
    const row = y orelse playdate.LCD_ROWS / 2;
    const text_width =
        gfx.getTextWidth(
            self.font,
            to_draw,
            len,
            encoding,
            0,
        );
    _ = gfx.drawText(
        to_draw,
        len,
        encoding,
        @divTrunc(playdate.LCD_COLUMNS - text_width, 2),
        @intCast(row - gfx.getFontHeight(self.font)),
    );
}

/// The game loop called at every frame by the playdev.
/// Return true if the frame shoud be rendered (due to changes) or false if not.
/// You may define other functions and structs with functions (like sprites) but
/// at the end of the day everything is called from this function.
pub fn update(self: Self) bool {
    const pdapi = self.playdate_api;
    const gfx = pdapi.graphics;

    // ---------------------------------
    // READ EVENTS AND UPDATE GAME STATE
    // ---------------------------------
    var draw_mode: playdate.LCDBitmapDrawMode = .DrawModeCopy;
    var clear_color: playdate.LCDSolidColor = .ColorWhite;
    var buttons: playdate.PDButtons = 0;
    pdapi.system.getButtonState(&buttons, null, null);
    if (buttons & playdate.BUTTON_A != 0) {
        draw_mode = .DrawModeInverted;
        clear_color = .ColorBlack;
    }

    // --------------------
    // RENDER TO THE SCREEN
    // --------------------
    gfx.setDrawMode(draw_mode);
    gfx.clear(@intCast(@intFromEnum(clear_color)));
    const to_draw = "Hold Ⓐ";
    gfx.drawBitmap(self.zig_image, 0, 0, .BitmapUnflipped);
    self.centerText(to_draw, to_draw.len, .UTF8Encoding, playdate.LCD_ROWS);

    return true;
}
