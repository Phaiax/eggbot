

module arm_elevator_gear() {

    ri_screwheads_gap = r_gear * 0.57;
    ro_screwheads_gap = r_gear * 0.82;
    w_screwhead_gap_bridge = 10;

    difference() {
        // main
        cylinder(r=r_gear, h=d_gear);
        translate([0, 0, -1])
        cylinder(r=ro_screwheads_gap, h=d_gear + 2);
    }

    cylinder(r=ri_screwheads_gap, h=d_gear);


    for(i = [0, 1]) {
        rotate([0, 0, i*90])
        translate([-ro_screwheads_gap, -w_screwhead_gap_bridge/2, 0])
        cube(size=[ro_screwheads_gap*2, w_screwhead_gap_bridge, d_gear], center=false);
    }
}

module arm_elevator() {

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
            cylinder(r=r_nema_big_cylinder, h=d_arm_elevator_plate+10);

        }
        // gear
        translate([0,w_nema/2,-d_gear])
        rotate([0,0,0])
        // color(c_gears, a_gears)
        arm_elevator_gear();
    }

}


// | Motor Front
// | | 2mm Motor Front Cylinder Big
//   | | 4mm first holding plate
//     |   | 8mm gear ( 3mm depth, 2*0.5mm spacing)
//         |    | 13mm Housing outsite (5mm wood)
// |                   | 20mm End of shaft
//         |<  12mm   >| Shaft holding space
//         |<5 >|        Radius resticted holding space
//               |<5 >|  Lever body
//              || g_housingfront_lever
//               0

g_housingfront_lever = 1;
w_housingfront_slot = 14;
g_housingfront_arm = 1; // gap from lever arm to housing front

l_arm_second_extra_for_screw = 20;
h_nut = 4.7; // M5
w_nut = 8; // M5
ro_m5_screw = 4.2/2;

d_shaftholder_neg = g_gear + h_laserwood+g_housingfront_lever;
g_arm_hinge = 15;
d_arm_hinge_outer = d_arm_elevator_plate + 2;
w_arm_hinge_outer = 10;
h_arm_hinge_center = 12; // from housing front
r_arm_hinge_center_hole = ro_m5_screw;

ro_arm2_hinge = h_arm_hinge_center - g_housingfront_lever - h_arm_levers - 1;

w_arm2_wall = 2;

x_arm_servo = 20;

module arm() {


    // pen nema
    translate([0, 0, -g_armmotor_housingfront - h_nema])
    nema17();


    union() {

        // first part of arm
        arm1();

        // second part of arm
        translate([l_arm_rotating, 0, 0])
        rotate([90, 0, -90])
        arm2();


    }

}


module arm1() {
        // the arm body
        translate([-w_arm_levers/2, -w_arm_levers/2, g_housingfront_lever])
        cube(size=[l_arm_rotating + w_arm_levers/2 + w_arm_hinge_outer/2,
                   w_arm_levers,
                   h_arm_levers],
                   center=false);



        // The reinforcement that connects the nema shaft to the arm
        translate([0, 0, -h_laserwood-g_gear])
        cylinder(h=d_shaftholder_neg + h_arm_levers,
                 r=w_housingfront_slot/2 - g_housingfront_arm);

        % translate([0, 0, -h_laserwood-d_gear-g_gear-d_arm_elevator_plate])
        rotate([0, 0, 180])
        nema17shaft();

        // hinge
        translate([l_arm_rotating, 0, 0])
        for ( i = [-1, 1]) {
            translate([-w_arm_hinge_outer/2,
                      - d_arm_hinge_outer/2
                      + i*(g_arm_hinge/2 + d_arm_hinge_outer/2),
                      g_housingfront_arm])
            difference() {
                // hinge half cyl + stand
                union() {
                    cube(size=[w_arm_hinge_outer, d_arm_hinge_outer, 10], center=false);
                    rotate([-90, 0, 0])
                    translate([w_arm_hinge_outer/2, -h_arm_hinge_center + g_housingfront_arm, 0])
                        cylinder(h=d_arm_hinge_outer,
                            r=w_arm_hinge_outer/2, center=false, $fn=20);

                }
                // hinge screw hole
                rotate([-90, 0, 0])
                translate([w_arm_hinge_outer/2, -h_arm_hinge_center + g_housingfront_arm, -1])
                cylinder(h=d_arm_hinge_outer + 2,
                    r=r_arm_hinge_center_hole, center=false, $fn=20);
            }
        }

        // servo
        translate([x_arm_servo, -w_arm_levers/2 + h_servo_mount, 0])
        rotate([0,0, -90])
        translate([0, 0, h_arm_levers + g_housingfront_lever])
        servo_mount(1);
}


module arm2() {



    difference() {
        union() {
            // body
            translate([-g_arm_hinge/2, h_arm_hinge_center, -ro_arm2_hinge])
            cube(size=[g_arm_hinge,
                       l_arm_second + l_arm_second_extra_for_screw - h_arm_hinge_center,
                       ro_arm2_hinge*2],
                       center=false);

            // hinge cylinder
            translate([0, h_arm_hinge_center, 0])
            rotate([0, 90, 0])
            cylinder(h=g_arm_hinge, r=ro_arm2_hinge, center=true, $fn=20);

        }

        union() {

            // hinge hole
            translate([0, h_arm_hinge_center, 0])
            rotate([0, 90, 0])
            cylinder(h=g_arm_hinge + 1, r=r_arm_hinge_center_hole, center=true, $fn=20);

            rotate([0,180,0])
            translate([0, l_arm_second, -l_pen_standout])
            pen_ext();

            // hole for M5 nut
            translate([0, l_arm_second + 14, 0])
            cube([w_nut, h_nut, ro_arm2_hinge*2+1], center=true);

            // hole for m5 screw
            translate([0, l_arm_second + 20, 0])
            rotate([90, 0, 0])
            cylinder(h=20, r=ro_m5_screw, center=true, $fn=20);

            // material saving hole
            translate([0,
                       h_arm_hinge_center + ro_arm2_hinge
                       + (l_arm_second-25)/2,
                       w_arm2_wall])
            cube(size=[g_arm_hinge - 2*w_arm2_wall, l_arm_second-25, ro_arm2_hinge*2], center=true);

        }

    }


    // example pen
    rotate([0,180,0])
    % translate([0, l_arm_second, -l_pen_standout])
    pen();

}