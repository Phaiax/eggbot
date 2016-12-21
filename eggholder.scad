
r_eggholder_ring = 4;
ri_eggholder_gummi = 2;

ri_eggholder_cyl = r_eggholder_ring - ri_eggholder_gummi;
ro_eggholder_cyl = r_eggholder_ring + ri_eggholder_gummi;
h_eggholder_cyl = 20;
h_eggholder_insideplate = 4;
mz_eggholder_insideplate = 2;
mz_eggholder_nemashaft_top = mz_eggholder_insideplate +h_eggholder_insideplate;

r_eggholder_shield=20;
h_eggholder_shield=4;

c_eggholder = "PeachPuff";

module eggholder_moveup(debug=true) {
    translate([0, 0, +mz_eggholder_nemashaft_top +h_nema_shaft])
    eggholder(debug);
}

module eggholder(debug=true) {

    color(c_eggholder)
    difference() {
        union() {

            // cylinder under gummi ring
            translate([0, 0, -h_eggholder_cyl])
            cylinder_with_hole(ri=ri_eggholder_cyl, ro=ro_eggholder_cyl,
                                h=h_eggholder_cyl, $fn=20);

            // protector agains brogen eggs
            color(c_eggholder)
            translate([0,0,-h_eggholder_cyl])
            cylinder(r=r_eggholder_shield, h=h_eggholder_shield);
        }

        // cut out torus for gummi
        torus(ri_eggholder_gummi, r_eggholder_ring);
        // smooth top of cylinder
        cube([2*ro_eggholder_cyl, 2*ro_eggholder_cyl, 2], center=true);

        // hole for nema shaft
        translate([0, 0, -mz_eggholder_nemashaft_top - h_nema_shaft ])
        nema17shaft();
    }


    // intermediate plate as max for motor shaft
    color(c_eggholder)
    translate([0, 0, -mz_eggholder_insideplate-h_eggholder_insideplate])
    cylinder(r=(ro_eggholder_cyl+ri_eggholder_cyl)/2,
             h=h_eggholder_insideplate);

    //// visible gummi ring
    //color(c_eggholder, 0.7)
    //torus(ri_eggholder_gummi, r_eggholder_ring);

    // visible nema shaft
    //color(c_eggholder, 0.7)
    //translate([0, 0, -mz_eggholder_nemashaft_top - h_nema_shaft ])
    //nema17shaft();
}

h_topeggholder_cyl1 = 5;
h_topeggholder_cyl2 = 10;
ro_topeggholder_cyl2 = 11.5/2;
ri_topeggholder_cyl2 = 4;

module topeggholder(debug=true) {
    color(c_eggholder)
    difference() {
        // cylinder under gummi ring
        translate([0, 0, 0])
        cylinder_with_hole(ri=ri_eggholder_cyl, ro=ro_eggholder_cyl,
                            h=h_topeggholder_cyl1, $fn=20);

        // cut out torus for gummi
        torus(ri_eggholder_gummi, r_eggholder_ring);
        // smooth top of cylinder
        cube([2*ro_eggholder_cyl, 2*ro_eggholder_cyl, 2], center=true);

    }

    // intermediate plate as max for shaft
    //translate([0, 0, mz_eggholder_insideplate])
    //cylinder(r=(ro_eggholder_cyl+ri_eggholder_cyl)/2,
    //         h=h_eggholder_insideplate);

    // visible gummi ring
    // color(c_eggholder, 0.7)
    // torus(ri_eggholder_gummi, r_eggholder_ring);

    // cylinder that touches to bearing
    color(c_eggholder)
    translate([0, 0, h_topeggholder_cyl1-0.1])
    difference() {
        cylinder(h=h_topeggholder_cyl2, r2=ro_topeggholder_cyl2,
                 r1 = ro_eggholder_cyl);
        translate([0, 0, -1])
        cylinder(h=h_topeggholder_cyl2+2, r=ri_topeggholder_cyl2);
    }

    if (debug) {
        cylinder_with_hole(ri=ri_topeggholder_cyl2, ro=ro_topeggholder_cyl2,
                            h=h_topeggholder_cyl2, $fn=20);
    }
}