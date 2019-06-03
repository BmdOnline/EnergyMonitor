$fn = 100;

include <modules.scad>

Jack_width = 10.25;
Jack_length = 20.7;

Jack_support_offset_x = Jack_width/2;
Jack_support_offset_y = 3.3; // Jack_face_length
Jack_support_offset_z = Jack_width/2;

/************************************************
 * Jack
 ************************************************/
Jack_face_diam = Jack_width;
Jack_face_length = 3.3;

Jack_ring_diam = 6.3;

Jack_filet_diam = 7.9;
Jack_filet_length = 4.3;
Jack_filet_min_len = 2.3; // Jack_nut_length or more (impact case depth)

Jack_tube_diam = 7.1;
Jack_tube_length = 12.6;

Jack_hole_diam = 3.5;
Jack_hole_length = 15.8;

Jack_pin_width = 2.1;
Jack_pin_height = 0.24;
Jack_pin_length1 = 3.1;
Jack_pin_length2 = 4.6;

Jack_nut_hex = 10;
Jack_nut_length = 2;

module Jack(negative=false) {
    if (negative) {
        // Outside hole
        color("DimGray") translate ([0, -0.1, 0]) rotate ([-90, 0, 0]) cylinder (h=0.5, r=Jack_filet_diam/2);
            
        // Outside pre cut
        difference() {
            color("DimGray") translate ([0, -0.1, 0]) rotate ([-90, 0, 0]) cylinder (h=0.9, r=Jack_filet_diam/2);
            color("DimGray") translate ([0, -0.2, 0]) rotate ([-90, 0, 0]) cylinder (h=0.9+0.2, r=(Jack_filet_diam/2)-0.8);
        }
            
        // Inside pre cut
        difference() {
            color("DimGray") translate ([0, -0.1+1.3, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_filet_length, r=Jack_filet_diam/2);
            color("DimGray") translate ([0, -0.2+1.3, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_filet_length+0.2, r=(Jack_filet_diam/2)-0.8);
        }

        // Inside hole
        color("DimGray") translate ([0, -0.1+1.7, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_filet_length, r=Jack_filet_diam/2);

        // Nut hole
        translate ([0, (Jack_filet_length-Jack_filet_min_len), 0]) rotate([-90, 0, 0]) cylinder(h=Jack_filet_length,r=Jack_nut_hex/2*1.2);
    }
    else {
    difference() {
        union() {
            color("DimGray") translate ([0, -Jack_face_length+0.1, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_face_length, r=Jack_face_diam/2);
            color("Goldenrod") translate ([0, -Jack_face_length, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_face_length, r=Jack_ring_diam/2);
            color("DimGray") translate ([0, -0.1, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_filet_length, r=Jack_filet_diam/2);
            color("DimGray") translate ([0, -0.1, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_tube_length, r=Jack_tube_diam/2);

            color("silver") translate ([-Jack_tube_diam/2*0.9, Jack_tube_length-0.2, -Jack_pin_width/2]) rotate ([0, 0, 0]) cube([Jack_pin_height, Jack_pin_length1, Jack_pin_width]);
            color("silver") translate ([Jack_tube_diam/2*0.9-Jack_pin_height, Jack_tube_length-0.2, -Jack_pin_width/2]) rotate ([0, 0, 0]) cube([Jack_pin_height, Jack_pin_length1, Jack_pin_width]);
            color("silver") translate ([-Jack_pin_width/2, Jack_tube_length-0.2, -Jack_tube_diam/2*0.9]) rotate ([0, 0, 0]) cube([Jack_pin_width, Jack_pin_length2, Jack_pin_height]);
        }

        // Jack connector hole
        translate ([0, -Jack_face_length-0.1, 0]) rotate ([-90, 0, 0]) cylinder (h=Jack_hole_length, r=Jack_hole_diam/2);
    }
    }
}

module Jack_nut() {
    color("silver") difference() {
        // Hex hole
        translate([0, Jack_nut_length, 0]) rotate([90, 0, 0]) cylinder(h=Jack_nut_length,r=Jack_nut_hex/2,$fn=6);
        // screw hole
        translate([0, Jack_nut_length+0.1, 0]) rotate([90, 0, 0]) cylinder(h=Jack_nut_length+0.2,r=Jack_filet_diam/2);
    }
}

*translate ([Jack_support_offset_x, Jack_support_offset_y, Jack_support_offset_z])
{
    difference() {
        translate ([-15, 0, -15]) cube([30, 4, 30]);
        Jack(negative=true);
    }
    *Jack_nut();
}