//$fa = 0.01; $fs = 0.01;
$fn = 100;
//$vpr = [60, 0, 345];//cnc view point

include <modules.scad>;
include <arduino.scad>;
include <nrf24l01.scad>;
include <jack.scad>;

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
        Case_base();
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
