// Print orientation: lid on the bed (raised middle band down).
include <params.scad>
use <cover_dlc32max.scad>
translate([0, 0, LID_OUT + RAISE_LID]) rotate([-90, 0, 0]) cover_dlc32max();
