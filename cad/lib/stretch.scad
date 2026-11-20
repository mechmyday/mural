// Mesh "stretch" helpers for remixing imported STLs.
// Cut the children at a plane, move everything past the plane by d, and fill the gap
// with the plane's cross-section extruded over d. Features away from the plane are untouched.

BIG = 1000;
EPS = 0.01;

// Insert d mm at plane x = c (everything with x > c moves +d).
module stretch_x(c, d) {
    if (d == 0) children();
    else union() {
        intersection() { children(); translate([c - BIG, -BIG/2, -BIG/2]) cube(BIG); }
        translate([d, 0, 0]) intersection() { children(); translate([c, -BIG/2, -BIG/2]) cube(BIG); }
        translate([c + d + EPS, 0, 0]) rotate([0, -90, 0])
            linear_extrude(d + 2*EPS)
                projection(cut = true) rotate([0, 90, 0]) translate([-c, 0, 0]) children();
    }
}

// Insert d mm at plane z = c (everything with z > c moves +d).
module stretch_z(c, d) {
    if (d == 0) children();
    else union() {
        intersection() { children(); translate([-BIG/2, -BIG/2, c - BIG]) cube(BIG); }
        translate([0, 0, d]) intersection() { children(); translate([-BIG/2, -BIG/2, c]) cube(BIG); }
        translate([0, 0, c - EPS])
            linear_extrude(d + 2*EPS)
                projection(cut = true) translate([0, 0, -c]) children();
    }
}

// Symmetric x stretch: insert d at x = +c and at x = -c.
module stretch_x_sym(c, d) {
    mirror([1, 0, 0]) stretch_x(c, d) mirror([1, 0, 0]) stretch_x(c, d) children();
}

// Insert d mm at plane y = c (everything with y > c moves +d).
module stretch_y(c, d) {
    if (d == 0) children();
    else union() {
        intersection() { children(); translate([-BIG/2, c - BIG, -BIG/2]) cube(BIG); }
        translate([0, d, 0]) intersection() { children(); translate([-BIG/2, c, -BIG/2]) cube(BIG); }
        translate([0, c - EPS, 0]) rotate([-90, 0, 0])
            linear_extrude(d + 2*EPS)
                projection(cut = true) rotate([90, 0, 0]) translate([0, -c, 0]) children();
    }
}

// Apply stretch_y only inside box [lo, hi]; outside the box the part is unchanged.
module stretch_y_local(c, d, lo, hi) {
    difference() { children(); translate(lo) cube(hi - lo); }
    stretch_y(c, d) intersection() { children(); translate(lo) cube(hi - lo); }
}
