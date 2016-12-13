
module clamp() {


    module lever(l_lever) {
        translate([-h_laserwood/2, 0, 0])
        rotate([90, 0, 90])
        linear_extrude(height=h_laserwood)
        polygon(points=[[0,0], // left bottom
                        [l_lever,0], // right bottom
                        [l_lever,h_lm8uu-5], // right top
                        [0,h_lm8uu]]); // left top

    }


    for(i = [-1, 1]) {
        rotate([90, 0, 0])
        translate([i*g_rod_centers/2, 0, 0])
        union() {
            bearing_with_mount(c_clamp, a_clamp);
            //spring(height=g_clamp_topbar);
        }
    }

    l_lever = sqrt((g_bearing_mount_egg_y)*(g_bearing_mount_egg_y)
                   + g_rods_inner/2*g_rods_inner/2);


    color(c_clamp, a_clamp)
    translate([0, d_bearing_mount,0])
    union() {

        // connection peace between the two bearings
        w_connection_piece = (g_rods_inner - ro_lm8uu);
        translate([-g_bearing_mounts/2, -h_laserwood, 0])
        cube(size=[g_bearing_mounts, h_laserwood, l_bearing_mount], center=false);


        // egg top bearing holder
        translate([0, g_bearing_mount_egg_y, 0])
        union() {
            // z position of the bearing within the cylinder
            h_bearing_pos = (h_lm8uu-5)/2  - h_608zz/2;
            difference() {
                union() {
                    // cylinder that contains the 608zz
                    cylinder(h=h_lm8uu-5, r=14, center=false, $fn=20);

                    // the lever arms
                    for(i = [-1, 1]) {
                        translate([0, -g_bearing_mount_egg_y, 0])
                        translate([i*(g_rod_centers/2-15), -3, 0])
                        rotate([0, 0, i*10])
                        lever(l_lever);
                    }

                }

                // hole to insert 608zz bearing
                translate([0, 0, h_bearing_pos])
                k608zz_long();

                // hole to access 608zz bearing from top and bottom
                translate([0, 0, -h_lm8uu])
                cylinder(r=ri_608zz+2, h=2*h_lm8uu);
            }
            translate([0, 0, h_bearing_pos])
            k608zz();
        }
    }

    // linear moving tooth
    translate([0, d_bearing_mount,0])
    union() {


        color(c_gears, a_gears)
        translate([g_bearing_mounts/2+w_bearing_mount-w_linearmoovingtooth, 0, -h_linearmoovingtooth+l_bearing_mount])
        cube(size=[w_linearmoovingtooth, d_gear, h_linearmoovingtooth], center=false);
    }

}

