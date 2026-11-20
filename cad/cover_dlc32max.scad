// Mural v2 cover, remixed for the MKS DLC32 MAX.
// - Stretched STRETCH_X per side and STRETCH_Z in height so the 100 x 70 board fits
//   between the screw posts.
// - Middle of the lid (|x| < RAISE_HALF_W) raised RAISE_LID for the driver modules. The outer
//   bands stay at stock height so the belts can't rub.
// - Old board's side block removed and its wall opening closed.
// - Notches in the top wall for the DC jack, SD card and USB.
// All lid features (OLED window, screen-holder bosses, PD-trigger pocket, slot) are kept.

include <params.scad>
use <lib/stretch.scad>

$fn = 48;

module stock_cover() translate(COVER_FRAME) import("src/cover.stl");

// Step 1: remove the block on the inside of the left wall (x -47..-35.3, z ~0..30) and close
// the wall there.
module cover_cleaned() {
    union() {
        difference() {
            stock_cover();
            translate([-44, PLATE_TOP - 1, -2]) cube([10, LID_IN + 1 - PLATE_TOP, 34]);
        }
        translate([-47, PLATE_TOP, -2]) cube([3, LID_IN - PLATE_TOP + 0.5, 34]);
    }
}

// Step 2: stretch in height, then widen everything above STRETCH_SPLIT_Z.
module cover_z() stretch_z(STRETCH_Z_AT, STRETCH_Z) cover_cleaned();

module section_z(z) projection(cut = true) translate([0, 0, -z]) children();

BRIDGE_T = 1.5;
module cover_stretched() {
    zs = STRETCH_SPLIT_Z;
    union() {
        stretch_x_sym(STRETCH_X_AT, STRETCH_X)
            intersection() { cover_z(); translate([-200, -200, zs]) cube(400); }
        intersection() { cover_z(); translate([-200, -200, zs - 400]) cube(400); }
        // ledge joining the stock-width lower walls to the widened upper walls
        for (sx = [-1, 1]) translate([0, 0, zs - BRIDGE_T]) linear_extrude(BRIDGE_T + 0.01) hull() {
            intersection() {
                section_z(zs - 0.5) cover_z();
                translate([sx > 0 ? 40 : -48, -100]) square([8, 200]);
            }
            intersection() {
                section_z(zs + 0.5) stretch_x_sym(STRETCH_X_AT, STRETCH_X) cover_z();
                translate([sx > 0 ? 40 : -60, -100]) square([20, 200]);
            }
        }
    }
}

// Lid footprint (x-z) after stretching, used to build the side walls of the raised band.
module lid_footprint() {
    projection() rotate([-90, 0, 0])
        intersection() { cover_stretched(); translate([-200, LID_IN + 0.5, -200]) cube([400, 10, 400]); }
}

// Step 3: raise the middle band of the lid.
RAISE_WALL = 2;
module cover_raised() {
    band_lo = [-RAISE_HALF_W + RAISE_WALL, -50, -100];
    band_hi = [ RAISE_HALF_W - RAISE_WALL,  50,  200];
    union() {
        // outer bands unchanged
        difference() { cover_stretched(); translate(band_lo) cube(band_hi - band_lo); }
        // middle band: everything above y = 5 moves out by RAISE_LID (end walls get taller)
        stretch_y(5, RAISE_LID) intersection() { cover_stretched(); translate(band_lo) cube(band_hi - band_lo); }
        // side walls of the raised band, standing on the outer lid
        for (sx = [-1, 1])
            intersection() {
                translate([0, LID_IN, 0]) rotate([90, 0, 0]) mirror([0, 0, 1])
                    linear_extrude(LID_OUT + RAISE_LID - LID_IN) lid_footprint();
                translate([sx > 0 ? RAISE_HALF_W - RAISE_WALL : -RAISE_HALF_W, -50, -100])
                    cube([RAISE_WALL, 100, 300]);
            }
    }
}

// Step 4: connector notches in the top wall (open at the plate side, prints fine lid-down).
// x positions follow the board placement in dlc32max_board.scad (x_m = x_d - 50).
TOP_WALL_Z = 72.9 + STRETCH_Z;
NOTCHES = [
    // [x0, x1, y_top]
    [-36.0, -23.5,  1.5],  // DC jack + plug
    [  3.5,  20.5, -6.5],  // SD card
    [ 29.0,  41.0,  1.5],  // USB (J19)
];

module cover_dlc32max() {
    difference() {
        cover_raised();
        for (n = NOTCHES)
            translate([n[0], PLATE_TOP - 1, TOP_WALL_Z - 8]) cube([n[1] - n[0], n[2] - PLATE_TOP + 1, 12]);
    }
}

cover_dlc32max();
