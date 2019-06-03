$fn = 100;

include <modules.scad>

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

*translate ([ArduinoNano_support_offset_x, ArduinoNano_support_offset_y, ArduinoNano_support_offset_z]) {
%ArduinoNano_board(upsideDown=true);
ArduinoNano_support();
%ArduinoNano_window(offset_y=3, negative=true, upsideDown=true);
}