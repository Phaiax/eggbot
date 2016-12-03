
use <Nema17.scad>
use <servosg90.scad>

// w width
// d depth
// h height
// l length
// r radius
// ri inner
// ro outer
// g gap
// s size (3array)
// c color
// all in mm

h_laserwood = 5;

w_groundplate = 300;
d_groundplate = 300;

w_nema = 42.3;
r_egg = 35/2;

l_pen = 130;
l_pen_tip = 10;
r_pen = 10/2;

h_arm_levers = 5;
w_arm_levers = 25;

l_arm_rotating = 45;
l_arm_second = 50;
l_pen_standout = 20;
g_pen_to_arm = h_laserwood + 5;

// LM8UU   8 mm    15 mm   24 mm
h_lm8uu = 24;
ri_lm8uu = 8/2;
ro_lm8uu = 15/2;

h_clamp_rods = 200;
g_clamp_rods = w_nema + 3;
r_clamp_rods = 4;

h_clamp_pos = 120;

w_tower = g_clamp_rods + 2*r_clamp_rods + 2*h_laserwood + 10;
d_tower = 80;
h_tower = 110;
s_tower = [w_tower, d_tower, h_tower];
s_tower_inner = [w_tower - 2*h_laserwood,
                 d_tower - 2*h_laserwood,
                 h_tower - h_laserwood];

r_rope = 2;
c_rope = "red";

g_clamp_topbar = h_clamp_rods-h_clamp_pos-h_lm8uu;


w_numpad_button = 10;
g_numpad_button = 3;
c_numpad_button = "WhiteSmoke";
w_numpad = 3*w_numpad_button+4*g_numpad_button;
d_numpad = 4*w_numpad_button+5*g_numpad_button;
c_numpad = "Silver";

eggbot();
translate([100, 0, 0])
numpad();
// pen();
// groundplate();

module groundplate() {
    translate([0,0,-5])
    cube([w_groundplate, w_groundplate, 10], center=true);
}


module eggbot() {
    translate([0, l_arm_second, 60])
    egg();
    translate([0, l_arm_second, 0])
    nema17();
    translate([0, 0, 80])
    rotate([90, 0, 180])
    arm();

    clamp();


    housing();

}

module housing() {
    color("LightBlue", 0.4) {
        translate([-w_tower/2, -d_tower-1, 0])
        difference() {
            cube(size=s_tower, center=false);

            translate([h_laserwood, h_laserwood, 0])
            cube(size=s_tower_inner, center=false);
        }
    }
}

module numpad() {
    translate([g_numpad_button, g_numpad_button, 0])
    color(c_numpad_button)
    for( x = [0 : 2] ) {
        for (y = [0 : 3]) {
            translate([x*(w_numpad_button + g_numpad_button),
                       y*(w_numpad_button + g_numpad_button),
                       0])
            cube(size=[w_numpad_button,
                       w_numpad_button,
                       4], center=false);
        }
    }
    color(c_numpad)
    cube(size=[w_numpad, d_numpad, 2]);
}

module clamp() {

    module spring(height=50, radius=8, rounds=8) {
        color("orange")
        linear_extrude(height = height,
                       center = false,
                       convexity = 10,
                       twist = 360*rounds)
        translate([radius, 0, 0])
        circle(r = 1);
    }


    module bearing() {
        // LM8UU   8 mm    15 mm   24 mm
        difference() {
            cylinder(h=h_lm8uu, r=ro_lm8uu);
            translate([0, 0, -1])
            cylinder(h=h_lm8uu+2, r=ri_lm8uu);
        }
    }
    module rod() {
        cylinder(h=h_clamp_rods, r=r_clamp_rods, center=false, $fn=20);
        translate([0, 0, h_clamp_pos])
        union() {
            bearing();
            rotate([0, 0, 15])
            lever(l_lever);
            translate([0, 0, h_lm8uu])
            spring(height=g_clamp_topbar);
        }
    }
    module lever(l_lever) {
        ro = ro_lm8uu+3;
        color("Green")
        difference() {
            union() {
                translate([-ro, 0, 0])
                rotate([90, 0, 90])
                linear_extrude(height=h_laserwood)
                polygon(points=[[0,0], // left bottom
                                [l_lever,0], // right bottom
                                [l_lever,h_lm8uu-5], // right top
                                [0,h_lm8uu]]); // left top

                cylinder(h=h_lm8uu, r=ro, center=false, $fn=20);

            }
            translate([0, 0, -1])
            cylinder(h=h_lm8uu+2, r=ro_lm8uu, center=false, $fn=20);
        }
    }

    module arrow3d() {
        translate([0, 0, l_pen_tip])
        cylinder(h=l_pen_tip, r=r_pen, center=false, $fn=20);

        // tip
        cylinder(h=l_pen_tip, r1=0, r2=r_pen*2, center=false, $fn=20);

    }



    d_rods_pos = h_laserwood + r_clamp_rods + 10;
    w_rods_pos = r_clamp_rods + g_clamp_rods/2;
    l_lever = sqrt((l_arm_second+d_rods_pos)*(l_arm_second+d_rods_pos)
                   + g_clamp_rods/2*g_clamp_rods/2);

    // lever(l_lever);

    translate([0, -d_rods_pos, 0])
    union() {
        translate([w_rods_pos, 0, 0])
        rod();

        translate([-w_rods_pos, 0, 0])
        mirror([1, 0, 0])
        rod();

        // connection peace between the two bearings
        w_connection_piece = (g_clamp_rods - ro_lm8uu);
        translate([-w_connection_piece/2, 0, h_clamp_pos])
        color("green")
        cube(size=[w_connection_piece, h_laserwood, h_lm8uu], center=false);

        // topbar
        d_topbar = 2*(r_clamp_rods+5);
        w_topbar = (g_clamp_rods + 30);
        w_topbar_extension = 20;
        translate([-w_topbar/2, -d_topbar/2, h_clamp_rods])
        cube(size=[w_topbar + w_topbar_extension,
                   d_topbar,
                   h_laserwood*2],
                   center=false);

        // egg_top_holder
        translate([0, l_arm_second+d_rods_pos, h_clamp_pos])
        cylinder(h=h_lm8uu-5, r=10, center=false, $fn=20);

        // rope
        translate([0, 0, h_clamp_pos + h_lm8uu -10])
        color(c_rope)
        cylinder(h=g_clamp_topbar+10, r=r_rope, center=false, $fn=20);

        translate([w_topbar/2+w_topbar_extension - 10,
                   0,
                   h_clamp_rods])

        union() {
            l_rope_left = h_clamp_rods*0.5;

            rotate([180, 0, 0])
            color(c_rope)
            cylinder(h=l_rope_left, r=r_rope, center=false, $fn=20);

            translate([0, 0, -l_rope_left-20])
            arrow3d();
        }

    }

}

module arm() {

    union() {
        translate([0, 0, -37-g_pen_to_arm])
        nema17();

        translate([-w_arm_levers/2, -w_arm_levers/2, 0])
        cube(size=[l_arm_rotating + w_arm_levers/2,
                   w_arm_levers,
                   h_arm_levers],
                   center=false);
    }

    translate([l_arm_rotating, 0, 0])
    rotate([0, 0, 0])
    union() {
        rotate([0, -90, 0])
        translate([0, -w_arm_levers/2, 0])
        cube(size=[l_arm_second + w_arm_levers/2,
                   w_arm_levers,
                   h_arm_levers],
                   center=false);

        translate([0, 0, l_arm_second])
        rotate([0, 90, 0])
        translate([0, 0, -l_pen_standout])
        pen();
    }

    translate([l_arm_rotating-15, -21, h_arm_levers])
    rotate([90, 0, 180])
    servoSG90();

}



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
}
