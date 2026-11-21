// Mural v2 bottom, remixed for the MKS DLC32 MAX.
// - Board plate widened and lengthened to match the remixed cover.
// - Old board bosses, ribs and side block removed, old holes filled.
// - New heat-set boss pattern 92 x 62 mm for the DLC32 MAX.
// - Cover screw bosses moved to the stretched post positions.
// - Each board boss tied to its nearest cover boss with a low rib.
// - The block the cover tongue screws into is raised by RAISE_LID.

include <params.scad>
use <lib/stretch.scad>

$fn = 48;

CLEAR_Z0 = -12.3;          // features above the plate are removed from here up (tray walls top out at -12.4)...
CLEAR_Z1 = PLATE_TOP_Z + 5;
CORNER_R = 5;

module stock_bottom() import("src/bottom.stl");

// Solid plate covering the whole board area (fills the old through-holes).
module plate_slab() {
    hull() {
        translate([-PLATE_HALF_W, PLATE_BACK, -20]) cube([2 * PLATE_HALF_W, PLATE_TOP - PLATE_BACK, 1]);
        for (sx = [-1, 1])
            translate([sx * (PLATE_HALF_W - CORNER_R), PLATE_BACK, PLATE_TOP_Z - CORNER_R])
                rotate([-90, 0, 0]) cylinder(r = CORNER_R, h = PLATE_TOP - PLATE_BACK);
    }
}

module boss(x, z, d) {
    translate([x, PLATE_TOP - 0.01, z]) rotate([-90, 0, 0]) cylinder(d = d, h = STANDOFF + 0.01);
}

// Rib joining two bosses, lower than the standoff so it stays clear of solder joints under the PCB.
RIB_W = 5;
RIB_H = STANDOFF - 1;
module rib_dot(h) translate([h[0], PLATE_TOP - 0.01, h[1]]) rotate([-90, 0, 0]) cylinder(d = RIB_W, h = RIB_H + 0.01);
// path = list of [x, z] points; one straight rib per segment
module rib(path) for (i = [0 : len(path) - 2]) hull() { rib_dot(path[i]); rib_dot(path[i + 1]); }

module insert_hole(x, z) {
    translate([x, PLATE_BACK - 1, z]) rotate([-90, 0, 0]) cylinder(d = INSERT_D, h = 30);
}

board_holes = [for (sx = [-1, 1], sz = [-1, 1]) [sx * BOARD_HOLE_DX / 2, BOARD_ZC + sz * BOARD_HOLE_DZ / 2]];
post_holes  = [for (sx = [-1, 1], p = POSTS) [sx * p[0], p[1]]];

// Each board hole tied to its nearest cover post. The lower ribs detour inward through RIB_BENDS
// and meet the post from the side, staying clear of the cover's ledge, which reaches the plate
// at |x| > 41.4, z -7..-5.5.
RIB_BENDS = [[36, -2], [36, POSTS[0][1]]];
ribs = [for (sx = [-1, 1]) each [
    [[sx * BOARD_HOLE_DX / 2, BOARD_ZC - BOARD_HOLE_DZ / 2], each [for (b = RIB_BENDS) [sx * b[0], b[1]]], [sx * POSTS[0][0], POSTS[0][1]]],
    [[sx * BOARD_HOLE_DX / 2, BOARD_ZC + BOARD_HOLE_DZ / 2], [sx * POSTS[1][0], POSTS[1][1]]],
]];

// Box around the block under the cover tongue (insert at x 0, z -26.5, guide lip above y 15.2)
TONGUE_LO = [-21, 5, -40];
TONGUE_HI = [21, 30, -22];

module bottom_dlc32max() {
    difference() {
        union() {
            stretch_y_local(12, RAISE_LID, TONGUE_LO, TONGUE_HI)
                difference() {
                    union() { stock_bottom(); plate_slab(); }
                    // remove everything standing on the plate in the board area
                    translate([-PLATE_HALF_W - 1, PLATE_TOP, CLEAR_Z0])
                        cube([2 * PLATE_HALF_W + 2, 40, CLEAR_Z1 - CLEAR_Z0]);
                }
            for (h = board_holes) boss(h[0], h[1], 7);
            for (h = post_holes) boss(h[0], h[1], 7);
            for (r = ribs) rib(r);
        }
        for (h = concat(board_holes, post_holes)) insert_hole(h[0], h[1]);
    }
}

bottom_dlc32max();
