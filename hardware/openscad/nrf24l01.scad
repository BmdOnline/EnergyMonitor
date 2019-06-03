$fn = 100;

include <modules.scad>

NRF24L01_width = 15;
NRF24L01_length = 29;
NRF24L01_pcb_height = 1.2;

NRF24L01_support_width = 19.5;
NRF24L01_support_length = 34;
NRF24L01_support_height = 10;

NRF24L01_support_offset_x = (NRF24L01_support_width-NRF24L01_width)/2;
NRF24L01_support_offset_y = (NRF24L01_support_length-NRF24L01_length)/2;
NRF24L01_support_offset_z = 7;

/************************************************
 * NRF24L01_board 2.4Ghz board
 ************************************************/
module NRF24L01_board(version=1) {
    //color("green") cube([NRF24L01_width, NRF24L01_length, NRF24L01_pcb_height]);
    // PCB
    translate([NRF24L01_width/2+0.4, NRF24L01_length+4.3, 11.2]) rotate([0, 180, 0]) import("imports/NRF24L01.stl");
    // Connectors
    %translate([0, NRF24L01_length-6.5, NRF24L01_pcb_height]) cube([15, 5, 18]);
    // Capacitor
    if (version==1) {
        translate([0, NRF24L01_length-1.5-5/2, -1.5-5/2]) rotate([0, 90, 0]) cylinder(h=NRF24L01_width, r=5/2);
    } else {
        translate([-5/2-0.2, NRF24L01_length-1.5-5/2, -2]) rotate([0, 0, 0]) cylinder(h=12, r=5/2);
    }
}

module NRF24L01_support_old() {
base_diff_y = 1.5;
base_diff_z = 7.1;

    *%cube([NRF24L01_width, NRF24L01_length, NRF24L01_pcb_height]);
    render(convexity = 2) difference() {
        translate([0, NRF24L01_length+0.5, 0]) rotate([0, 0, -90]) import("imports/NRF24L01_Holder.stl");
        translate([0, base_diff_y, -base_diff_z]) cube([15.5, 28, 2.2]);
    }
}

module NRF24L01_support() {
    support_spacing_x = 0.5;
    support_spacing_y = 0.5;
    support_holding = 2;
    holding_width = NRF24L01_width * 0.4;
    inclination = 40;

    support_width = NRF24L01_support_offset_x-support_spacing_x;
    support_length = NRF24L01_support_offset_y-support_spacing_y;

    
    *NRF24L01_support_old();

    %cube([NRF24L01_width, NRF24L01_length, NRF24L01_pcb_height]);

    /* Rear */
    union()
    {
        translate([0, NRF24L01_length+support_spacing_y, -NRF24L01_support_offset_z])
            cube ([NRF24L01_width, support_length, NRF24L01_support_height]);

        translate([(NRF24L01_width-holding_width)/2, NRF24L01_length+support_spacing_y-support_holding, -NRF24L01_support_offset_z])
            cube([holding_width, support_holding, NRF24L01_support_offset_z]);
    }

    /* Front */
    difference() {
    union()
    {
        translate([-NRF24L01_support_offset_x, -NRF24L01_support_offset_y, -NRF24L01_support_offset_z])
            cube ([NRF24L01_support_width, support_length, NRF24L01_support_height]);

        translate([-NRF24L01_support_offset_x, -support_spacing_y, -NRF24L01_support_offset_z])
            cube([holding_width, support_holding, NRF24L01_support_offset_z]);
        translate([-NRF24L01_support_offset_x, -support_spacing_y, -NRF24L01_support_offset_z])
            cube([support_width, support_holding*3, NRF24L01_support_height]);
        translate([-NRF24L01_support_offset_x+support_width-support_width*cos(inclination), -support_spacing_y, NRF24L01_pcb_height+support_width*sin(inclination)])
        rotate([0, inclination, 0])
            cube([support_width, support_holding*3, (NRF24L01_support_height-NRF24L01_support_offset_z-NRF24L01_pcb_height)]);

        translate([NRF24L01_width+NRF24L01_support_offset_x-holding_width, -support_spacing_y, -NRF24L01_support_offset_z])
            cube([holding_width, support_holding, NRF24L01_support_offset_z]);
        translate([NRF24L01_width+support_spacing_x, -support_spacing_y, -NRF24L01_support_offset_z])
            cube([support_width, support_holding*3, NRF24L01_support_height]);
        translate([NRF24L01_width+NRF24L01_support_offset_x-support_width, 0-support_spacing_y, NRF24L01_pcb_height])
        rotate([0, -inclination, 0])
            cube([support_width, support_holding*3, (NRF24L01_support_height-NRF24L01_support_offset_z-NRF24L01_pcb_height)]);
    }

        translate([-NRF24L01_support_offset_x, -support_length-support_spacing_y, NRF24L01_support_height-NRF24L01_support_offset_z])
            cube([NRF24L01_support_width, NRF24L01_support_length, 1]);
}

}

*NRF24L01_board(version=2);
*NRF24L01_support();
