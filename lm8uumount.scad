
module bearingMount() {
	mountLength=29;
	mountWidth=22;
	mountHeight=15.5;
	cableTieWidth=5;
	bearingLength=23;
	bearingDiameter=16;
	rodClearance=12;

	difference() {
		// mount cube
		translate([0,0,mountHeight/2]) cube([mountLength,mountWidth,mountHeight],center=true);
		union() {
			//clearance hole
			translate([0,0,11.5]) rotate([0,90,0]) cylinder(mountLength+1,rodClearance/2,rodClearance/2,center=true);
			translate([0,0,16.5]) rotate([0,90,0]) cube([rodClearance,rodClearance,mountLength+1],center=true);

			// bearing hole
			translate([0,0,11.5]) rotate([0,90,0]) cylinder(bearingLength,bearingDiameter/2,bearingDiameter/2,center=true);
			translate([0,0,16.5]) rotate([0,90,0]) cube([bearingDiameter-1,bearingDiameter-1,bearingLength],center=true);
			// cable clip hole
			translate([0,0,15]) rotate([0,90,0]) cube([14,mountWidth+1,cableTieWidth],center=true);
			translate([0,0,0]) rotate([0,90,0]) cube([7,mountWidth+1,cableTieWidth],center=true);
			translate([0,0,0]) rotate([0,90,0]) cube([12,12,cableTieWidth],center=true);
		}
	}
}
