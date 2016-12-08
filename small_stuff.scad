
module pen() {
    translate([0, 0, l_pen_tip])
    cylinder(h=l_pen, r=r_pen, center=false, $fn=20);

    cylinder(h=l_pen_tip, r1=0, r2=r_pen, center=false, $fn=20);
}

module egg() {

    translate([0, 0, r_egg])
    hull() {
        sphere(r_egg);

        translate([0,0,r_egg*0.7])
        sphere(r_egg*0.7);
    }

    echo(str("Eihöhe: ", h_egg, " mm"));
}

module k608zz() {
    color("red", 0.5)
    cylinder(r=ro_608zz, h=h_608zz);
}

module k608zz_long() {
    hull() {
        translate([0, -50, 0])
        k608zz();
        k608zz();
    }
}

module rods() {
    for(i=[-1,1]) {
        translate([i*x_rod, 0, 0])
        cylinder(h=h_rods, r=r_rods, center=false, $fn=20);
    }
}

module bearing(ri=ri_lm8uu, ro=ro_lm8uu, h=h_lm8uu) {
    cylinder_with_hole(ri, ro, h);
}

module cylinder_with_hole(ri=ri_lm8uu, ro=ro_lm8uu, h=h_lm8uu) {
    // LM8UU   8 mm    15 mm   24 mm
    difference() {
        cylinder(h=h, r=ro);
        translate([0, 0, -1])
        cylinder(h=h+2, r=ri);
    }
}

module spring(height=50, radius=8, rounds=8) {
    color("orange")
    linear_extrude(height = height,
                   center = false,
                   convexity = 10,
                   twist = 360*rounds)
    translate([radius, 0, 0])
    circle(r = 1);
}

module bearing_with_mount(c="red",a=1.0) {
    translate([0, h_lm8uu+3, 0])
    union() {
        rotate([90, 0, 0])
        bearing();

        color(c, a)
        translate([0, -h_lm8uu/2, -d_bearing_mount])
        rotate([0, 0, 90])
        bearingMount();
    }
}