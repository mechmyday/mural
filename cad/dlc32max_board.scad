// MKS DLC32 MAX keep-out model, for fit checks only (not printed).
// Positions from "MKS DLC32 MAX Manual.pdf" (Installation Dimensions) and the V1.0_002 PIN.pdf.
// Board-local frame: x_d right, y_d up as in the MKS drawing (component side up), origin at the
// bottom-left corner, z = height above the top of the PCB. Component heights are estimates:
// measure your board (driver + heatsink especially) and adjust DRIVER_H if needed.

include <params.scad>

DRIVER_H = 21;   // socket (8.5) + StepStick PCB (1.6) + heatsink (~10) + margin

// [x0, y0, x1, y1, height, name]
PARTS = [
    // TMC2209 modules in the X and Y sockets (Z and A sockets stay empty; A holds the servo dupont)
    [ 8.5, 40.4, 21.3, 62.0, DRIVER_H, "X driver"],
    [24.6, 40.4, 37.4, 62.0, DRIVER_H, "Y driver"],
    // Empty Z / A sockets with dupont plugs for the OLED and servo
    [40.7, 40.4, 53.5, 62.0, 8.5 + 14, "Z socket + dupont"],
    [56.9, 40.4, 69.6, 62.0, 8.5 + 14, "A socket + dupont"],
    // Motor connectors along the top edge (XH 2.54), plugs in X and Y1
    [ 8.0, 62.6, 34.0, 70.0, 7 + 6, "X/Y1 motor plugs"],
    [34.0, 62.6, 73.0, 70.0, 7, "Y2/Z/A motor headers"],
    [73.0, 62.6, 92.0, 70.0, 8, "AIR/BEEPER"],
    // Bottom edge, left to right: DC jack, USB, SD, RJ11 (checked on the real board; the USB and
    // RJ11 positions are approximate). SD and USB stick out ~2 mm.
    [15.2,  0.0, 25.3, 14.0, 11, "DC jack"],
    [30.5, -2.0, 40.7, 12.0, 11, "USB (J19)"],
    [54.6, -2.0, 69.4, 14.0, 2.5, "SD slot"],
    [78.5, -0.5, 91.2, 15.0, 16, "RJ11 display"],
    // Big parts in the middle
    [80.4, 14.8, 99.2, 34.3, 3.5, "ESP32-S3 module"],
    [11.5, 27.0, 18.5, 34.5, 11, "C5"],
    [30.5, 27.5, 37.5, 34.5, 11, "C13"],
    [22.5, 21.5, 29.5, 28.5, 11, "C21"],
    [11.5, 18.0, 20.0, 26.0, 6, "regulator / inductor"],
    // Left edge terminals, right edge endstop / aux headers
    [ 0.0,  8.0,  9.5, 62.0, 9, "left terminals"],
    [86.0, 37.0, 100.0, 62.0, 9, "endstop headers"],
];

module board_local(show_parts = true) {
    color("green") difference() {
        translate([0, 0, -PCB_T]) cube([BOARD_W, BOARD_H, PCB_T]);
        for (x = [4, 96], y = [4, 66]) translate([x, y, -5]) cylinder(d = 3.2, h = 10, $fn = 24);
    }
    if (show_parts)
        for (p = PARTS) color("dimgray") translate([p[0], p[1], 0]) cube([p[2] - p[0], p[3] - p[1], p[4]]);
}

// Board-local -> bot frame. Rotated 180 degrees in the wall plane: the motor-connector edge
// (drawing top) faces down toward the motors, the USB/SD/DC edge faces the cover's top wall.
module place_board() {
    multmatrix([[1, 0, 0, -BOARD_W / 2],
                [0, 0, 1, PCB_BOTTOM + PCB_T],
                [0, -1, 0, BOARD_ZC + BOARD_H / 2],
                [0, 0, 0, 1]]) children();
}

module dlc32max_placed(show_parts = true) place_board() board_local(show_parts);

dlc32max_placed();
