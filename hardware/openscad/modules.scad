$fn = 100;

/************************************************
 * Generic modules
 ************************************************/
module drill(width=10, height=10, hole=5) {
    difference() {
        translate ([0, 0, 0]) rotate ([-90, 0, 0]) cylinder (h=height, r=width/2);
        translate ([0, -0.1, 0]) rotate ([-90, 0, 0]) cylinder (h=height+0.2, r=hole/2);
    }
}

module connector(step=2.54, nbPins=4, pin_h=10, depth=0, holder=true, margin=true, pin_w=0.6) {
    offset = (holder || margin)?(step-pin_w)/2:0;

    for(pin = [0 : nbPins-1]) {
        color("yellow") translate([offset+step*pin, 0-depth, offset]) cube([pin_w, pin_h, pin_w]);
    }
    if (holder) {
        color("black") translate([0, 0, 0]) cube([nbPins*step, step, step]);
    }
}

module linear_support(support_width=6, support_length=50, support_height=2, support_extent=0, drill_height=3, drill_diam=5, drill_screw=2.5) {
    difference() {
        union() {
            translate([0, 0, support_width/2-support_extent]) cube([support_width, support_height, support_length-support_width]);
            translate([support_width/2, 0, support_width/2]) rotate ([-90, 0, 0]) cylinder(r=support_width/2, h=support_height);
            if (support_extent > 0) {
                translate([0, 0, -support_extent]) cube([support_width, support_height, support_width/2]);
            } else {
                translate([support_width/2, 0, support_length-support_width/2]) rotate ([-90, 0, 0]) cylinder(r=support_width/2, h=support_height);
            }
            translate([support_width/2, 0, support_length-support_extent-support_width/2]) rotate ([-90, 0, 0]) cylinder(r=support_width/2, h=support_height);
        }
        translate([support_width/2, -0.1, support_width/2]) rotate([-90, 0, 0]) cylinder(r=drill_screw/2, h=support_height+0.2);
        translate([support_width/2, -0.1, support_length-support_extent-support_width/2]) rotate([-90, 0, 0]) cylinder(r=drill_screw/2, h=support_height+0.2);
    }
    // drill
    translate([support_width/2, -drill_height, support_width/2]) drill(drill_diam, drill_height, drill_screw);
    translate([support_width/2, -drill_height, support_length-support_extent-support_width/2]) drill(drill_diam, drill_height, drill_screw);

}

module nut_casing(nut_size=3, hex_size=5.5, case_size=10) {
    case_border = 1;
    nut_height = 2;
    case_diag = sqrt(pow(case_size, 2)*2);
    difference() {
        // Support
        cube([case_size, case_size, case_size]);
        // Extrude
        translate([case_border, case_border+nut_height, case_border]) cube([case_size-case_border*2, case_size-case_border+0.1, case_size-case_border+0.1]);
        // Cut angle
        translate([-0.1, case_size, 0]) rotate([45, 0 ,0]) cube([case_size+0.2, case_diag, case_diag]);
        // Cut half cube
        translate([-0.1, case_size/2, -0.1]) cube([case_size+0.2, case_size, case_size+0.2]);
        // Hex hole
        translate([case_size/2, case_border+nut_height+0.1, case_size/2]) rotate([90, 0, 0]) cylinder(h=nut_height+0.2,r=hex_size/2,$fn=6);
        // screw hole
        translate([case_size/2, case_border+0.1, case_size/2]) rotate([90, 0, 0]) cylinder(h=case_border+0.2,r=nut_size/2);
    }
}

module bolt_casing(nut_size=3, head_size=5.5, case_size=10) {
    case_border = 1;
    nut_height = 2;
    case_diag = sqrt(pow(case_size, 2)*2);
    difference() {
        // Support
        cube([case_size, case_size, case_size]);
        // Extrude
        translate([case_border, case_border+nut_height, case_border]) cube([case_size-case_border*2, case_size-case_border+0.1, case_size-case_border+0.1]);
        // Cut angle
        translate([-0.1, case_size, 0]) rotate([45, 0 ,0]) cube([case_size+0.2, case_diag, case_diag]);
        // Cut half cube
        translate([-0.1, case_size/2, -0.1]) cube([case_size+0.2, case_size, case_size+0.2]);
        // Hex hole
        translate([case_size/2, case_border+nut_height+0.1, case_size/2]) rotate([90, 0, 0]) cylinder(h=nut_height+0.2,r=head_size/2);
        // screw hole
        translate([case_size/2, case_border+0.1, case_size/2]) rotate([90, 0, 0]) cylinder(h=case_border+0.2,r=nut_size/2);
    }
}

*drill();
*connector();
*linear_support();
*nut_casing(3, 5.5, 8);
*bolt_casing(3, 5.5, 8);