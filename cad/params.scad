// Shared numbers for the DLC32 MAX remix.
// Frame: the stock bottom.stl frame (mm). x = across the bot, z = up the wall,
// y = out from the wall (back plate at y = -18.1, plate top surface at y = -15.2).
// The stock cover sits at translate(COVER_FRAME) in this frame (taken from Mural v2.step).

COVER_FRAME = [0, 1.5, 16.8];

PLATE_BACK = -18.1;
PLATE_TOP  = -15.2;

// Cover remix
STRETCH_X_AT = 30;   // cut planes at x = +/-30 (no features there)
STRETCH_X    = 8;    // added per side: inner width 88 -> 104
STRETCH_Z_AT = 26.8; // cut plane between the OLED holder and the PD-trigger pocket
STRETCH_Z    = 6;    // moves the upper screw posts clear of the board
RAISE_LID    = 8;    // extra depth over the middle of the lid
RAISE_HALF_W = 46;   // raised band is |x| < 46: keeps clear of the belts (they leave the pulleys at |x| ~ 50)
LID_IN  = 15.2;      // stock lid underside
LID_OUT = 18.15;     // stock lid top

STRETCH_SPLIT_Z = -5.5; // only the cover above this is stretched in x; the lower corners
                        // (feet, lower posts) stay stock so they keep fitting the tray

// Cover screw posts [x, z] after the stretch (stock: x +/-40.4, z -10.1 / 66.3)
POSTS = [[40.4, -10.1], [40.4 + STRETCH_X, 66.3 + STRETCH_Z]];
POST_Z = [POSTS[0][1], POSTS[1][1]];

// Board placement: landscape, motor-connector edge facing down (toward the motors),
// USB / SD / DC-jack edge facing the top wall of the cover.
BOARD_W = 100;
BOARD_H = 70;
BOARD_HOLE_DX = 92;
BOARD_HOLE_DZ = 62;
BOARD_ZC = (POST_Z[0] + POST_Z[1]) / 2;   // centered between the screw posts
STANDOFF = 3;                              // board boss height above the plate
PCB_T = 1.6;
PCB_BOTTOM = PLATE_TOP + STANDOFF;

// Plate outline after the remix (cover walls sit on it)
PLATE_HALF_W = 47 + STRETCH_X;
PLATE_TOP_Z  = 72.9 + STRETCH_Z;

// Heat-set inserts (M3x4x5, same as stock)
INSERT_D = 4.2;
