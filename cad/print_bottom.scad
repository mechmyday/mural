// Print orientation: back plate on the bed.
include <params.scad>
use <bottom_dlc32max.scad>
translate([0, 0, -PLATE_BACK]) rotate([90, 0, 0]) bottom_dlc32max();
