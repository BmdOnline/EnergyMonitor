/* [Export] */
// Select part to generate (case,cover,all)
Part_to_export = 1; // [1:case,2:cover,0:all]

/* [Sensors] */
// Number of jack connectors
Number_of_sensors = 4;    // [1:6]

/* [Case Size] */
// Case Width (x)
Case_width = 70;
// Case Height (z)
Case_height = 30;
// Case Depth (y)
Case_depth = 50;

/* [Case Advanced] */
// Case Border thickness
Case_bt = 3.4;
// Case Front thickness
Case_ft = 3.4;
// Cover thickness
Case_ct = 2;
// Case Cover margin
Case_cm = 2;
// Cover Opening key
Case_opening = 10;     // Case opening key

/* [Hidden] */
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

ArduinoNano_width = 17.78;
ArduinoNano_length = 43.18;
ArduinoNano_height = 7.25;
ArduinoNano_pcb_height = 2; //1.5;

ArduinoNano_usb_offset_y = 2.0; // 1.3;
ArduinoNano_usb_length = 10.0; // 9.25;
ArduinoNano_usb_width = 8.0; // 7.6;
ArduinoNano_usb_height = 4.0; // 3.75;

ArduinoNano_support_thickness = 2;
ArduinoNano_support_width = ArduinoNano_width+ArduinoNano_support_thickness*2;
ArduinoNano_support_length = ArduinoNano_length+ArduinoNano_support_thickness;
ArduinoNano_support_height = ArduinoNano_usb_height+0.5;

ArduinoNano_support_offset_x = ArduinoNano_support_thickness;
ArduinoNano_support_offset_y = 1.15;
ArduinoNano_support_offset_z = 4.5;

module ArduinoNano_board(upsideDown=true) {
    yangle = upsideDown?180:0;
    xoffset = upsideDown?ArduinoNano_width:0;
    zoffset = upsideDown?ArduinoNano_pcb_height:0;

    *translate([0, 0, 0]) cube([ArduinoNano_width, ArduinoNano_length, ArduinoNano_pcb_height]);
    rotate([0, yangle, 0]) translate ([40.1-xoffset, 87.1, ArduinoNano_pcb_height-zoffset]) rotate([0, 0, 180]) import("imports/2078_Nano.stl");
    *translate ([ArduinoNano_width/2+0.1, ArduinoNano_length/2-0.1, 0]) rotate([0, 0, 90]) import("imports/Nano.stl");
}

module trianglerect(width_a=10, width_b=10, height=2, center=false) {
    linear_extrude(height = height, center = center)
    polygon(points=[[0, 0], [0, width_a], [width_b, 0]]);
}

module ArduinoNano_support(height=ArduinoNano_usb_offset_y, support_offset_y=ArduinoNano_usb_offset_y, cover_end=false){
    *%translate([0, 0, 0]) cube([ArduinoNano_width, ArduinoNano_length, ArduinoNano_pcb_height]);
    difference() {
        union() {
            // rear
            // rear left stop
            *translate([-ArduinoNano_support_thickness, ArduinoNano_length-ArduinoNano_support_thickness, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness*2, ArduinoNano_support_thickness*2, ArduinoNano_support_height+ArduinoNano_pcb_height]);
            translate([-ArduinoNano_support_thickness, ArduinoNano_length+ArduinoNano_support_thickness, -ArduinoNano_support_height]) rotate([0, 0, -90]) trianglerect(width_a=ArduinoNano_support_thickness*2, width_b=ArduinoNano_support_thickness*2, height=ArduinoNano_support_height+ArduinoNano_pcb_height);
            **translate([ArduinoNano_support_thickness, ArduinoNano_length+ArduinoNano_support_thickness, -ArduinoNano_support_height]) rotate([0, 0, -90]) trianglerect(width_a=ArduinoNano_support_thickness*2, width_b=ArduinoNano_support_thickness*2, height=ArduinoNano_support_height);

            *translate([0, ArduinoNano_length+ArduinoNano_support_thickness-ArduinoNano_support_thickness*1.25, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness, ArduinoNano_support_thickness*1.25, ArduinoNano_support_height+ArduinoNano_pcb_height+ArduinoNano_support_thickness]);

            // rear right stop
            **translate([ArduinoNano_width-ArduinoNano_support_thickness, ArduinoNano_length-ArduinoNano_support_thickness, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness*2, ArduinoNano_support_thickness*2, ArduinoNano_support_height+ArduinoNano_pcb_height]);
            translate([ArduinoNano_width+ArduinoNano_support_thickness, ArduinoNano_length+ArduinoNano_support_thickness, -ArduinoNano_support_height]) rotate([0, 0, 180]) trianglerect(width_a=ArduinoNano_support_thickness*2, width_b=ArduinoNano_support_thickness*2, height=ArduinoNano_support_height+ArduinoNano_pcb_height);
            **translate([ArduinoNano_width-ArduinoNano_support_thickness, ArduinoNano_length+ArduinoNano_support_thickness, -ArduinoNano_support_height]) rotate([0, 0, 180]) trianglerect(width_a=ArduinoNano_support_thickness*2, width_b=ArduinoNano_support_thickness*2, height=ArduinoNano_support_height);

            *translate([(ArduinoNano_width-ArduinoNano_support_thickness), ArduinoNano_length+ArduinoNano_support_thickness-ArduinoNano_support_thickness*1.25, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness, ArduinoNano_support_thickness*1.25, ArduinoNano_support_height+ArduinoNano_pcb_height+ArduinoNano_support_thickness]);

            // rear middle stop
            /*
            *translate([(ArduinoNano_width-ArduinoNano_support_thickness)/2, ArduinoNano_length-ArduinoNano_support_thickness, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness, ArduinoNano_support_thickness*2, ArduinoNano_support_height+ArduinoNano_pcb_height+ArduinoNano_support_thickness]);
            translate([(ArduinoNano_width-ArduinoNano_support_thickness)/2, ArduinoNano_length-ArduinoNano_support_thickness, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness, ArduinoNano_support_thickness*2, ArduinoNano_support_height+ArduinoNano_pcb_height*0]);
            *translate([(ArduinoNano_width-ArduinoNano_support_thickness)/2, ArduinoNano_length+ArduinoNano_support_thickness-ArduinoNano_support_thickness*1.25, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness, ArduinoNano_support_thickness*1.25, ArduinoNano_support_height+ArduinoNano_pcb_height+ArduinoNano_support_thickness]);
            */
            RearSize=0.85;
            translate([-ArduinoNano_support_thickness, ArduinoNano_length-ArduinoNano_support_thickness, -ArduinoNano_support_height]) cube([ArduinoNano_support_width, ArduinoNano_support_thickness*1, ArduinoNano_support_height+ArduinoNano_pcb_height*0]);
            translate([-ArduinoNano_support_thickness, ArduinoNano_length+ArduinoNano_support_thickness-ArduinoNano_support_thickness*RearSize, -ArduinoNano_support_height]) cube([ArduinoNano_support_width, ArduinoNano_support_thickness*RearSize, ArduinoNano_support_height+ArduinoNano_pcb_height+ArduinoNano_support_thickness/2]);

            // front
            // front left stop
            translate([-ArduinoNano_support_thickness, 0.5, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness*2, ArduinoNano_support_thickness, ArduinoNano_support_height+ArduinoNano_support_thickness+ArduinoNano_pcb_height]);
            translate([ArduinoNano_support_thickness, 0.5, -ArduinoNano_support_height]) trianglerect(width_a=ArduinoNano_support_thickness, width_b=ArduinoNano_support_thickness*1.25, height= ArduinoNano_support_height+ArduinoNano_support_thickness+ArduinoNano_pcb_height);
            // front right stop
            translate([ArduinoNano_width-ArduinoNano_support_thickness, 0.5, -ArduinoNano_support_height]) cube([ArduinoNano_support_thickness*2, ArduinoNano_support_thickness, ArduinoNano_support_height+ArduinoNano_support_thickness+ArduinoNano_pcb_height]);
            translate([ArduinoNano_width-ArduinoNano_support_thickness, 0.5, -ArduinoNano_support_height]) rotate([0, 0, 90]) trianglerect(width_a=ArduinoNano_support_thickness*1.25, width_b=ArduinoNano_support_thickness, height= ArduinoNano_support_height+ArduinoNano_support_thickness+ArduinoNano_pcb_height);
        }
        // notch
        translate([-0.2, -0.1, 0]) cube([ArduinoNano_width+0.4, ArduinoNano_length+0.4, ArduinoNano_pcb_height+0.1]);
    }

    // Arduino Nano cover end (usb)
    if (cover_end)
    translate([(ArduinoNano_width-ArduinoNano_usb_width)/2, -support_offset_y, -ArduinoNano_support_height-height]) cube([ArduinoNano_usb_width-0.2, support_offset_y, height]);

    // Arduino Nano cover end (support)
    //translate([0, -support_offset_y/2, -ArduinoNano_support_height-height]) cube([ArduinoNano_width, ArduinoNano_support_thickness+support_offset_y/2, height]);

}

module ArduinoNano_window(height=ArduinoNano_usb_height, offset_y=ArduinoNano_usb_offset_y, negative=false, upsideDown=false){
    yangle = upsideDown?180:0;
    xoffset = upsideDown?ArduinoNano_width:0;
    zoffset = upsideDown?ArduinoNano_pcb_height:0;

    if (negative) {
        rotate([0, yangle, 0]) translate([(ArduinoNano_width-ArduinoNano_usb_width)/2-xoffset-0.1, -offset_y, ArduinoNano_pcb_height-zoffset-0.1]) cube([ArduinoNano_usb_width+0.2, ArduinoNano_usb_length+offset_y+0.1, ArduinoNano_usb_height+height+0.2]);
        rotate([0, yangle, 0]) translate([-ArduinoNano_support_thickness-xoffset-0.1, -offset_y+ArduinoNano_usb_offset_y, -ArduinoNano_support_thickness-zoffset-0.5*0]) cube([ArduinoNano_width+ArduinoNano_support_thickness*2+0.2, ArduinoNano_usb_length-ArduinoNano_usb_offset_y+offset_y+0.1, ArduinoNano_pcb_height+ArduinoNano_support_thickness+ArduinoNano_support_height+0.5*0+0.1]);
    } else {
        difference() {
            %rotate([0, yangle, 0]) translate([-xoffset-ArduinoNano_support_thickness*2, -offset_y, -ArduinoNano_support_thickness*2-zoffset]) cube([ArduinoNano_width+ArduinoNano_support_thickness*4, offset_y, ArduinoNano_height+ArduinoNano_support_thickness*2]);
            rotate([0, yangle, 0]) translate([(ArduinoNano_width-ArduinoNano_usb_width)/2-xoffset-0.1, -offset_y-0.1, ArduinoNano_pcb_height-zoffset-0.1]) cube([ArduinoNano_usb_width+0.2, ArduinoNano_usb_length+offset_y+0.1, ArduinoNano_usb_height+height+0.2]);
            rotate([0, yangle, 0]) translate([-ArduinoNano_support_thickness-xoffset-0.1, -offset_y+ArduinoNano_usb_offset_y-0.1, -ArduinoNano_support_thickness-zoffset-0.5]) cube([ArduinoNano_width+ArduinoNano_support_thickness*2+0.2, ArduinoNano_usb_length-ArduinoNano_usb_offset_y+offset_y+0.1, ArduinoNano_pcb_height+ArduinoNano_support_thickness+ArduinoNano_support_height+0.5+0.1]);
        }
    }
}

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


// NRF24L01
//NRF24L01_offset_x = NRF24L01_support_length+(Case_width-NRF24L01_support_length)/2;
NRF24L01_offset_x = Case_bt*2;//Case_width-Case_bt*2;
//NRF24L01_offset_y = NRF24L01_support_width+(Case_depth-NRF24L01_support_width)/2;
NRF24L01_offset_y = Case_depth-NRF24L01_support_width;

// Arduino Nano
ArduinoNano_offset_x = Case_width; //-ArduinoNano_support_width-Case_bt;
ArduinoNano_offset_y = Case_depth;//ArduinoNano_support_width+Case_bt;

module Case_box() {
/*
Case_width        // Case Width (x)
Case_height       // Case Height (z)
Case_depth        // Case Depth (y)

Case_bt           // Case Border thickness
Case_ft           // Case Front thickness
Case_ct           // Case Cover thickness
Case_cm           // Case Cover margin

Case_opening      // Case opening key
*/
    // Front thickness adjustment
    Case_adj = Case_bt-Case_ft;
    // Cover margin according to front thickness

    Case_fm = min(Case_cm, Case_ft/2);
    difference() {
        // Box
        cube ([Case_width, Case_depth, Case_height]);
        // Borders
        translate ([Case_bt, Case_ft-0.1, -0.1]) cube ([Case_width-Case_bt*2, Case_depth+Case_adj-Case_bt*2, Case_height-Case_bt+0.2]);
        // Cover place - bottom
        translate ([Case_cm, Case_fm-0.1, -0.1]) cube ([Case_width-Case_cm*2, Case_depth-Case_cm-Case_fm+0.1, Case_ct+0.2]);
        // Opening key
        translate ([(Case_width-Case_opening)/5-0.1, Case_depth-Case_cm-0.1, -0.1]) cube ([Case_opening+0.1, Case_cm/2+0.1, Case_cm+0.2]);
    }
}

module Case_cover() {
/*
Case_width        // Case Width (x)
Case_depth        // Case Depth (y)

Case_ft           // Case Front thickness
Case_ct           // Case Cover thickness
Case_cm           // Case Cover margin
*/
    // Cover margin according to front thickness
    Case_fm = min(Case_cm, Case_ft/2);

    translate ([Case_cm, Case_fm-0.1, -0.1]) cube ([Case_width-Case_cm*2, Case_depth-Case_cm-Case_fm+0.2, Case_ct]);

}

module Case_base() {
/*
Case_width        // Case Width (x)
Case_depth        // Case Depth (y)
*/
    difference() {
        // Chassis
        /*translate([0, Case_height, 0])*/
            Case_box();

        // Arduino Nano
    translate([ArduinoNano_offset_x-ArduinoNano_support_offset_z-Case_bt, ArduinoNano_offset_y-ArduinoNano_support_offset_y, -ArduinoNano_support_offset_x+Case_height-Case_bt+0.1]) rotate([0, 90, 180])
                ArduinoNano_window(height=0.5, offset_y=2, negative=true, upsideDown=true);

        // Jack
        Jack_margin = ((Case_width-Case_bt*2)-(Number_of_sensors*Jack_width))/Number_of_sensors*0.5;
        //Jack_offset = Case_bt+Jack_width/2+Jack_margin/2;
        Jack_offset = Jack_width/2+(Case_width - (Number_of_sensors*Jack_width)-((Number_of_sensors-1)*Jack_margin))/2;
        for ( i= [0:1:Number_of_sensors-1]) {
            translate ([Jack_offset+(Jack_width+Jack_margin)*i, -0.2, Case_height/2]) Jack(negative=true);
        }

        *translate ([Jack_offset-Jack_width/2, 2-0.2, Case_height/2-Jack_width/2]) cube([Case_width-Jack_offset*2+Jack_width, Jack_filet_length, Jack_width]);
    }

    // NRF24L01
    translate([NRF24L01_offset_x-NRF24L01_support_offset_y, NRF24L01_offset_y-NRF24L01_support_offset_x, -NRF24L01_support_offset_z+Case_height-Case_bt+0.1]) rotate([0, 180, 270]) NRF24L01_support();

    // Arduino Nano
    translate([ArduinoNano_offset_x-ArduinoNano_support_offset_z-Case_bt, ArduinoNano_offset_y-ArduinoNano_support_offset_y, -ArduinoNano_support_offset_x+Case_height-Case_bt+0.1]) rotate([0, 90, 180])
    {
        ArduinoNano_support();
        *ArduinoNano_board(upsideDown=true);
    }
}

module Case_base_cover() {
    Case_cover();
}

module Case_base_components() {
    // NRF24L01
    translate([NRF24L01_offset_x-NRF24L01_support_offset_y, NRF24L01_offset_y-NRF24L01_support_offset_x, -NRF24L01_support_offset_z+Case_height-Case_bt+0.1]) rotate([0, 180, 270]) NRF24L01_board(version=1);


    // Arduino Nano
    translate([ArduinoNano_offset_x-ArduinoNano_support_offset_z-Case_bt, ArduinoNano_offset_y-ArduinoNano_support_offset_y, -ArduinoNano_support_offset_x+Case_height-Case_bt+0.1]) rotate([0, 90, 180])
        ArduinoNano_board(upsideDown=true);
    
    // Jack
    Jack_margin = ((Case_width-Case_bt*2)-(Number_of_sensors*Jack_width))/Number_of_sensors*0.5;
    //Jack_offset = Case_bt+Jack_width/2+Jack_margin/2;
    Jack_offset = Jack_width/2+(Case_width - (Number_of_sensors*Jack_width)-((Number_of_sensors-1)*Jack_margin))/2;
    for ( i= [0:1:Number_of_sensors-1]) {
        translate ([Jack_offset+(Jack_width+Jack_margin)*i, 0, Case_height/2]) Jack();
        translate ([Jack_offset+(Jack_width+Jack_margin)*i-Jack_width/2*0, 2, Case_height/2-Jack_width/2*0]) Jack_nut();
    }
}

/************************************************
 * Construct everything
 ************************************************/
 //Separate action for each child
module SeparateChildren(space) {
    for ( i= [0:1:$children-1])   // step needed in case $children < 2
      translate([i*space,0,0]) {
        children(i);
        //text(str(i));
      }
}

module main() {
    SeparateChildren(80){
        // Base
        //translate([0, 1.5*0, 0])
        translate([Case_width, 0, Case_height]) rotate([0, 180, 0]) Case_base();
        Case_base_cover();
        %Case_base_components(); // Components (for design only)
    }
}

module export(part=0){
    if (part==0) {
        main();
    } else if (part==1) {
        translate([Case_width, 0, Case_height]) rotate([0, 180, 0]) {
            Case_base();
            %Case_base_components(); // Components (for design only)
        }
    } else if (part==2) {
        translate([-Case_cm, -Case_cm, 0]) rotate([0, 0, 0])
        Case_base_cover();
    }
}

export(Part_to_export);
