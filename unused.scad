    module arrow3d() {
        translate([0, 0, l_pen_tip])
        cylinder(h=l_pen_tip, r=r_pen, center=false, $fn=20);

        // tip
        cylinder(h=l_pen_tip, r1=0, r2=r_pen*2, center=false, $fn=20);

    }