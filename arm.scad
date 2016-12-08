
module arm_elevator() {
    d_arm_elevator_plate = 4;

    for(i = [-1, 1]) {
        translate([i*g_rod_centers/2, 0, 0])
        union() {

            bearing_with_mount();
        }
    }


    // plate to hold nema
    translate([0, 0, -d_bearing_mount])
    union() {
        difference() {
            translate([-g_bearing_mounts/2,0,0])
            cube([g_bearing_mounts, w_nema, d_arm_elevator_plate]);

            // hole for nema shaft
            translate([0, w_nema/2, -1])
            cylinder(r=10, h=d_arm_elevator_plate+10);

        }
        // gear
        translate([0,w_nema/2,-d_gear])
        rotate([0,0,0])
        color(c_gears, a_gears)
        cylinder(r=r_gear, h=d_gear);
    }

}

module arm() {


    // pen nema
    translate([0, 0, -37-g_armmotor_arm])
    nema17();


    union() {

        // first part of arm
        translate([-w_arm_levers/2, -w_arm_levers/2, 0])
        cube(size=[l_arm_rotating + w_arm_levers/2,
                   w_arm_levers,
                   h_arm_levers],
                   center=false);

        // second part of arm
        translate([l_arm_rotating, 0, 0])
        rotate([0, 1, 0])
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

        // servo
        translate([l_arm_rotating-15, -21, h_arm_levers])
        rotate([90, 0, 180])
        servoSG90();

    }

}



