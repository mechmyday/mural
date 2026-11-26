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
TONGUE_LOW = true;    // true: keep the screw tongue at stock height (clears the motor carriers)
TONGUE_Z = -16.5;     // tongue/raised-lid step; motor carriers reach z -17.5
TONGUE_STEP_T = 2;
module cover_raised() {
    band_lo = [-RAISE_HALF_W + RAISE_WALL, -50, -100];
    band_hi = [ RAISE_HALF_W - RAISE_WALL,  50,  200];
    union() {
        // outer bands unchanged
        difference() { cover_stretched(); translate(band_lo) cube(band_hi - band_lo); }
        // middle band: everything above y = 5 moves out by RAISE_LID (end walls get taller).
        // With TONGUE_LOW the screw tongue below TONGUE_Z stays at stock height and a step joins it
        // to the raised lid.
        stretch_y(5, RAISE_LID) intersection() {
            cover_stretched();
            translate(TONGUE_LOW ? [band_lo[0], band_lo[1], TONGUE_Z] : band_lo)
                cube(band_hi - (TONGUE_LOW ? [band_lo[0], band_lo[1], TONGUE_Z] : band_lo));
        }
        if (TONGUE_LOW) {
            intersection() { cover_stretched(); translate(band_lo) cube([band_hi[0] - band_lo[0], band_hi[1] - band_lo[1], TONGUE_Z - band_lo[2]]); }
            intersection() {
                translate([0, LID_IN, 0]) rotate([90, 0, 0]) mirror([0, 0, 1])
                    linear_extrude(LID_OUT + RAISE_LID - LID_IN) lid_footprint();
                translate([band_lo[0], -50, TONGUE_Z]) cube([band_hi[0] - band_lo[0], 100, TONGUE_STEP_T]);
            }
        }
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

// Step 4: move the OLED window and its holder screw holes up by OLED_DZ, toward the PD-trigger
// pocket, so the OLED's pin header clears the driver heatsinks. The lid is flat in the band, so the
// old spot is filled with plain lid and the window (with its chamfer) and the under-lid ribs and
// bosses are moved as one block.
OLED_DZ = 21;                                  // stock window z 2.5..14; PD pocket starts at z 44.5
OLED_LO = [-25, 18, -4.5];                     // block around window, ribs and screw bosses
OLED_HI = [ 25, 30, 22.5];
LID_LO_R = LID_IN + RAISE_LID;                 // raised lid underside / top
LID_HI_R = LID_OUT + RAISE_LID;
module oled_box() translate(OLED_LO) cube(OLED_HI - OLED_LO);
module oled_lid() intersection() { oled_box(); translate([-100, LID_LO_R, -100]) cube([200, LID_HI_R - LID_LO_R, 300]); }
module cover_oled_moved() {
    difference() {
        union() {
            difference() { cover_raised(); oled_box(); }
            oled_lid();                                               // old spot: plain lid
            translate([0, 0, OLED_DZ]) difference() {                 // ribs and bosses under the lid
                intersection() { cover_raised(); oled_box(); }
                oled_lid();
            }
        }
        translate([0, 0, OLED_DZ]) difference() { oled_lid(); cover_raised(); }   // window + screw holes
    }
}

// Step 5: connector notches in the top wall (open at the plate side, prints fine lid-down).
// x positions follow the board placement in dlc32max_board.scad (x_m = x_d - 50).
// Left to right seen from outside with the PD-trigger end down: DC jack, USB, SD, RJ11 (no notch).
TOP_WALL_Z = 72.9 + STRETCH_Z;
NOTCHES = [
    // [x0, x1, y_top]
    [-36.0,  -8.0,  1.5],  // DC jack + USB, one opening (no thin wall between them)
    [  3.5,  20.5, -6.5],  // SD card
];

// Step 6: motor-cable notches in the lid edge at the motor end. Stock: x 35.8..41.8, 1.5 mm deep
// (lid edge z -17.3, notch top z -15.75). Moved 5 mm inward, 4 mm wider and 2.5 mm deeper.
LID_EDGE_Z = -17.3;
CABLE_NOTCH = [28.8, 38.8, -13.25];            // [x0, x1, z_top], mirrored to -x
STOCK_CABLE_NOTCH = [35.8, 41.8, -15.75];

module cover_dlc32max() {
    difference() {
        union() {
            cover_oled_moved();
            // fill the stock cable notches (lid slab, and the step wall above it)
            for (sx = [-1, 1]) mirror([sx < 0 ? 1 : 0, 0, 0]) {
                translate([STOCK_CABLE_NOTCH[0] - 0.1, LID_IN, LID_EDGE_Z])
                    cube([STOCK_CABLE_NOTCH[1] - STOCK_CABLE_NOTCH[0] + 0.2, LID_OUT - LID_IN, STOCK_CABLE_NOTCH[2] - LID_EDGE_Z + 0.1]);
                translate([STOCK_CABLE_NOTCH[0] - 0.1, LID_IN, TONGUE_Z])
                    cube([STOCK_CABLE_NOTCH[1] - STOCK_CABLE_NOTCH[0] + 0.2, LID_HI_R - LID_IN, STOCK_CABLE_NOTCH[2] - TONGUE_Z + 0.1]);
            }
        }
        for (n = NOTCHES)
            translate([n[0], PLATE_TOP - 1, TOP_WALL_Z - 8]) cube([n[1] - n[0], n[2] - PLATE_TOP + 1, 12]);
        for (sx = [-1, 1]) mirror([sx < 0 ? 1 : 0, 0, 0])
            translate([CABLE_NOTCH[0], LID_IN - 0.5, LID_EDGE_Z - 1])
                cube([CABLE_NOTCH[1] - CABLE_NOTCH[0], LID_HI_R - LID_IN + 1.5, CABLE_NOTCH[2] - LID_EDGE_Z + 1]);
    }
}

cover_dlc32max();
