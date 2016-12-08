
use <Nema17.scad>
use <servosg90.scad>
//use <gears_spur.scad>
use <lm8uumount.scad>

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
// a alpha
// x pos x
// y pos y
// z pos z
// mx, my, mz minus pos x,y,z
// all in mm

h_laserwood = 5;

w_groundplate = 300;
d_groundplate = 300;

h_pos_egg_center = 85;

w_nema = 42.3;
h_nema = 34;
h_nema_shaft = 20;
r_egg = 45/2;
z_egg_pos = 60;
h_egg = r_egg+2*0.7*r_egg;

w_bearing_mount = 22;
d_bearing_mount = 11.5; // from bearing center to mount front
l_bearing_mount = 29;

l_pen = 130;
l_pen_tip = 10;
r_pen = 10/2;

y_egg_center = 50;

h_arm_levers = 5;
w_arm_levers = 25;

l_arm_rotating = 45;
l_arm_second = y_egg_center;
l_pen_standout = 20;
g_armmotor_arm = h_laserwood + 5;

// LM8UU   8 mm    15 mm   24 mm
h_lm8uu = 24;
ri_lm8uu = 8/2;
ro_lm8uu = 15/2;

ro_608zz = 22/2;
ri_608zz = 8/2;
h_608zz = 7;

h_rods = 200;
g_rods_inner = w_nema + w_bearing_mount;
r_rods = 4;
g_rod_centers = g_rods_inner + r_rods;
my_rod = h_laserwood + r_rods + 10;
x_rod = g_rod_centers/2;


// distance between two bearing mounts that slide the rods
g_bearing_mounts = g_rod_centers - w_bearing_mount;

// dostance from bearing mount front to egg center
g_bearing_mount_egg_y = y_egg_center + my_rod - d_bearing_mount;

h_clamp_pos = 130;
c_clamp = "Olive";
a_clamp = 0.8;


h_linearmoovingtooth = 130;
// then they meet in front of the rod
w_linearmoovingtooth = w_bearing_mount/2;

r_gear = g_rod_centers/2;
d_gear = 3;
c_gears = "DarkOrchid";
a_gears = 0.9;

// block1 is the lower block and holds the rods.
w_block1 = 90; // raspberry pi mount width
d_block1 = h_nema + 10;
h_block1 = 50;

// block2 is a mounting plate at the back of block 1
w_block2 = w_block1;
d_block2 = h_laserwood;
h_block2 = 160;
d_block2_back_position = -d_block2-my_rod+d_bearing_mount - d_block1;

w_tower = g_rods_inner + 2*r_rods + 2*h_laserwood + 25;
d_tower = 80;
h_tower = 110;
s_tower = [w_tower, d_tower, h_tower];
s_tower_inner = [w_tower - 2*h_laserwood,
                 d_tower - 2*h_laserwood,
                 h_tower - h_laserwood];


r_rope = 2;
c_rope = "red";

g_clamp_topbar = h_rods-h_clamp_pos-h_lm8uu;


w_numpad_button = 10;
g_numpad_button = 3;
c_numpad_button = "WhiteSmoke";
w_numpad = 3*w_numpad_button+4*g_numpad_button;
d_numpad = 4*w_numpad_button+5*g_numpad_button;
c_numpad = "Silver";


include <small_stuff.scad>
include <arm.scad>
include <clamp.scad>
include <eggholder.scad>


translate([-200, 0, 0])
assembly();

lay_out();

translate([0, 0, -10])
eggholder();

translate([0, 0, 0])
topeggholder();

module lay_out() {
   clamp();

   translate([100, 0, 0])
   numpad();

   translate([80, 80, 0])
   arm_elevator();

   translate([160, 80, 0])
   arm();

   translate([40, 160, 0])
   bearingMount();
}

module assembly() {

    eggbot();

    // rotate([0, 0, 180])
    //translate([0, d_block2_back_position, 30])
    //pi();

}

module pi() {
    translate([-41.5, 0, 0])
    rotate([90, 0, 0])
    union() {
        //translate([4, 103, 24.5])
        //rotate([180, 0, 0])
        //import("pi_top.stl");

        import("pi_bottom.stl");
    }
}

module groundplate() {
    translate([0,0,-5])
    cube([w_groundplate, w_groundplate, 10], center=true);
}


module eggbot() {
    translate([0, l_arm_second, z_egg_pos])
    egg();
    translate([0, l_arm_second, 0])
    union() {
        nema17();
        translate([0, 0, 34])
        eggholder_moveup();
    }

    translate([0, 0, h_pos_egg_center])
    rotate([90, 0, 180])
    arm();

    translate([0, -my_rod, h_pos_egg_center-w_nema/2])
    rotate([90, 0, 0])
    arm_elevator();

    translate([0, -my_rod, 0])
    rods();


    translate([0, -my_rod, h_clamp_pos])
    clamp();

    translate([0, y_egg_center, z_egg_pos+h_egg])
    topeggholder();

    block1();
    block2();

}


module block1() {
    color("LightBlue", 0.4) {
        translate([-w_block1/2, -d_block1-my_rod+d_bearing_mount, 0])
        cube(size=[w_block1, d_block1, h_block1], center=false);
    }
    color(c_gears, a_gears) {
        translate([-w_block1/2, -my_rod+d_bearing_mount, 0])
        cube(size=[w_linearmoovingtooth, d_gear, h_linearmoovingtooth], center=false);
    }
}

module block2() {
    color("LightBlue", 0.4) {
        translate([-w_block2/2, d_block2_back_position, 0])
        cube(size=[w_block2, d_block2, h_block2], center=false);
    }
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


module torus(ri=2, ro=7) {
    rotate_extrude(convexity = 10, $fn = 20)
    translate([ro, 0, 0])
    circle(r = ri, $fn = 20);
}


