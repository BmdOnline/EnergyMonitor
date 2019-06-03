/**
 *
 * SensorEnergy
 *
 */

/* SCT013-030 - Current Sensor
   Connections
   ===========
    A0 and so on...
*/

/* nRF24L01 - 2.4GHz Transmitter
   Connections
   ===========
     VCC  to 3.3V DC
     GND  to GND
     CE   to digital pin 9
     CS   to digital pin 10
     MOSI to MOSI (digital pin 11)
     MISO to MISO (digital pin 12)
     SCK  to SCK  (digital pin 13)
     IRQ  to none
*/


    // Calibration, see SCT-013-030 datasheet
    //   built-in burden : 62 Ohms
    //   turn ratio      : 1800
    // Calibration = Ratio/BurdenR
    //   1800/62 = 29
    // See also :
    //   https://learn.openenergymonitor.org/electricity-monitoring/ctac/ct-and-ac-power-adaptor-installation-and-calibration-theory

//    sensors.current[0].Vrms = 230;
//    sensors.current[0].ICal = 29.40;
//    sensors.current[0].IZero = 0.01;

//    sensors.current[1].Vrms = 230;
//    sensors.current[1].ICal = 32.30;
//    sensors.current[1].IZero = 0.06;

// F0:5;F1:60
// E0:1;E1:1;E2:0;E3:0;E4:0;E5:0
// E0:1;V0:230;C0:29.40;O0:0.01
// E1:1;V1:230;C1:32:30;O1:0.05
// M3;S0;T0


/*--------------------------------------------------------------------------------------
  Main Defines
--------------------------------------------------------------------------------------*/
#define USE_MYSENSORS
#define USE_SERIAL
//#define USE_OLED
//#define USE_LCD
//#define DEBUG


#ifdef USE_MYSENSORS
// Enable and select radio type attached
#define MY_RADIO_NRF24
// wait until transport is ready
#define MY_TRANSPORT_WAIT_READY_MS 5000 // 5 seconds
// Enable debug prints to serial monitor
#define MY_DEBUG
//#define MY_RF24_CE_PIN 9   // Radio specific settings for RF24
//#define MY_RF24_CS_PIN 10  // Radio specific settings for RF24 (you'll find similar config for RFM69)
#endif

/*--------------------------------------------------------------------------------------
  Includes
--------------------------------------------------------------------------------------*/
#include "EmonLib.h"
#include <Wire.h>
#include <EEPROM.h>

#ifdef USE_MYSENSORS
// MySensors
#include <MySensors.h>
#endif

#ifdef USE_LCD
// https://bitbucket.org/fmalpartida/new-liquidcrystal/wiki/Home
#include <LiquidCrystal_I2C.h>
#endif

#ifdef USE_OLED
// https://github.com/olikraus/u8g2
#include <U8g2lib.h>
#endif

/*--------------------------------------------------------------------------------------
  Additional Defines
--------------------------------------------------------------------------------------*/
#define NB_SENSORS 6             // Number of sensors
#define SENSOR_PIN_n A0 // First sensor PIN, then increment

#ifdef USE_MYSENSORS
// MySensor
unsigned long SLEEP_TIME = 5000; // Sleep time between reads (in milliseconds)
#define CHILD_ID_POWER_n 0 // First child ID, then increment

// Wait times
#define LONG_WAIT 500
#define SHORT_WAIT 50
#endif


/*--------------------------------------------------------------------------------------
  Objects
--------------------------------------------------------------------------------------*/
#ifdef USE_MYSENSORS
// MySensor
//MySensor gw;
// Register all sensors to gw (they will be created as child devices)
// Look at MyMessage.h
//  S_MULTIMETER   //!< Multimeter device, V_VOLTAGE, V_CURRENT, V_IMPEDANCE
//    V_CURRENT    //!< S_MULTIMETER
//    V_VOLTAGE    //!< S_MULTIMETER
//    V_IMPEDANCE  //!< S_MULTIMETER, S_WEIGHT. Impedance value
//
//  S_POWER           //!< Power meter, V_WATT, V_KWH, V_VAR, V_VA, V_POWER_FACTOR
//    V_WATT          //!< S_POWER, S_BINARY, S_DIMMER, S_RGB_LIGHT, S_RGBW_LIGHT. Watt value for power meters
//    V_KWH           //!< S_POWER. Accumulated number of KWH for a power meter
//    V_VAR           //!< S_POWER, Reactive power: volt-ampere reactive (var)
//    V_VA            //!< S_POWER, Apparent power: volt-ampere (VA)
//    V_POWER_FACTOR  //!< S_POWER, Ratio of real power to apparent power: floating point value in the range [-1,..,1]
//
//  S_INFO            //!< LCD text device / Simple information device on controller, V_TEXT
//    V_TEXT          //!< S_INFO. Text message to display on LCD or controller device

MyMessage msg(0, 0);
/*MyMessage msgEnergy1(CHILD_ID_POWER_1, V_WATT);
MyMessage msgEnergy1(CHILD_ID_POWER_1, V_KWH);
MyMessage msgEnergy1(CHILD_ID_POWER_1, V_VAR1);*/
#endif

#ifdef USE_LCD
// Set the pins on the I2C chip used for LCD connections:
//                    addr, en,rw,rs,d4,d5,d6,d7,bl,blpol
LiquidCrystal_I2C lcd(0x27, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);  // Set the LCD I2C address
#endif

#ifdef USE_OLED
U8G2_SSD1306_128X32_UNIVISION_F_HW_I2C u8g2(U8G2_R0);
#endif

// Include Emon Library
EnergyMonitor emon[NB_SENSORS];

/*--------------------------------------------------------------------------------------
  Variables
--------------------------------------------------------------------------------------*/

// Sensor
boolean metric = true;

// Instructions set, may use these separators
#define CMD_SEPARATOR ";" // Semicolon separates different instructions
#define ARG_SEPARATOR ":" // Coma separates different arguments from an instruction

#define NUM_CHARS 64      // May be 32, but decrease for memory consumption
#define END_CHAR '\0'

char receivedChars[NUM_CHARS] = {0}; // an array to store the received data
static byte ndx = 0;
boolean newData = false;

// ID of the settings block
#define CONFIG_VERSION "ct1"

// Tell it where to store your config data in EEPROM
#define CONFIG_START 32

struct config_t {
    // This is for mere detection if they are your settings
    char version[4];

    int sampleFrequency;
    int sendFrequency;
    byte sensorMode;

    byte enableTransmission;
    byte enableSerial;

    bool enabled[NB_SENSORS];
    int Vrms[NB_SENSORS];
    float ICal[NB_SENSORS];
    float IOffset[NB_SENSORS];
};

static config_t config = {
    .version = CONFIG_VERSION,

    .sampleFrequency = 5, // 5 sec betwen sample
    .sendFrequency = 60,  // 60 sec between send
    .sensorMode = 3,      // 1 : power, 2 : current, 3 : power+current

    .enableTransmission = false,
    .enableSerial = false,

    .enabled = {},
    .Vrms = {},
    .ICal = {},
    .IOffset = {}
};
bool configLoaded = false;

struct current_t {
    float Irms = 0;
    int power = 0;
    double wh = 0;
    boolean received = false;
};

struct sensors_t {
    // Vrms for apparent power readings (when no AC-AC voltage sample is present)
    current_t current[NB_SENSORS];
};

static sensors_t sensors;

const int no_of_samples = 1480;
int nb_samples = 0;

unsigned long lastSend = millis();
unsigned long lastSample = millis();
unsigned long currentMillis;

#ifdef USE_OLED
char StringFloat[6];
#endif

#if defined(USE_LCD) || defined(USE_OLED)
char StringOut[17]; //16 digits plus the null char
#endif

bool readSensors(unsigned long sampleDelay);

#ifdef USE_MYSENSORS
void sendMySensors (bool force);
#endif

/*--------------------------------------------------------------------------------------
  Main program
--------------------------------------------------------------------------------------*/
#ifdef USE_MYSENSORS
void presentSensor(int num) {
    String childName;
    char childChar[20];

    if ((config.enableTransmission) && (configLoaded)) {
        childName = "EnergyMonitor"+String(num+1);
        childName.toCharArray(childChar, 50);
        // 1 : power, 2 : current, 3 : power+current
        if ((config.sensorMode == 1) || (config.sensorMode == 3)) {
            #ifdef DEBUG
            Serial.print(F("DEBUG:Presenting POWER: ")); Serial.println(childName);
            #endif
            present(CHILD_ID_POWER_n+num, S_POWER, childChar);
        }
        if ((config.sensorMode == 2)) { // Only for current mode
            #ifdef DEBUG
            Serial.print(F("DEBUG:Presenting MULTIMETER: ")); Serial.println(childName);
            #endif
            present(CHILD_ID_POWER_n+num, S_MULTIMETER, childChar);
        }
        wait(SHORT_WAIT);
    }
}

void presentSensors() {
    if ((config.enableTransmission) && (configLoaded)) {
        // Register all sensors to gateway (they will be created as child devices)
        for (int i=0; i<NB_SENSORS; i++) {
            if (config.enabled[i]) {
                presentSensor(i);
            }
        }
    }
}

void presentation()
{
    // Load config from eeprom
    loadConfig();

    if (config.enableTransmission) {
        // Send the sketch version information to the gateway and Controller
        sendSketchInfo("Energy Sensor SCT013", "1.0");

        if (configLoaded) {
            presentSensors();
        }
    }
}

void receive(const MyMessage &message) {
    #ifdef DEBUG
    Serial.print(F("DEBUG:Message received: ")); Serial.print(message.sensor);
    Serial.print(F(", Type: ")); Serial.print(message.type);
    Serial.print(F(", Message: ")); Serial.print(message.getString());
    Serial.print(F(" (int)")); Serial.print(message.getInt());
    Serial.print(F(" (float)")); Serial.println(message.getFloat());
    #endif

    if (message.type==V_VAR1) {
        if ((message.sensor >=0) && (message.sensor < NB_SENSORS)) {
            sensors.current[message.sensor].wh = message.getFloat() * 1000 * 3600;
            sensors.current[message.sensor].received = true;
        } else {
            Serial.println(F(" unknown sensor received"));
        }
    } else {
        Serial.println(F(" unknown message received"));
    }
}

// This is called when a new time value was received
void receiveTime(unsigned long controllerTime) {
    Serial.print(F("Time value received: "));
    Serial.println(controllerTime);
    //#include <Time.h>                  //http://playground.arduino.cc/Code/Time
    //setTime(controllerTime);           // time from controller
    //timeReceived = true;
}
#endif

void loadConfig() {
    // To make sure there are settings, and they are YOURS!
    // If nothing is found it will use the default settings.
    /*if (EEPROM.read(CONFIG_START + 0) == CONFIG_VERSION[0] &&
        EEPROM.read(CONFIG_START + 1) == CONFIG_VERSION[1] &&
        EEPROM.read(CONFIG_START + 2) == CONFIG_VERSION[2])
    for (unsigned int t=0; t<sizeof(config); t++)
        *((char*)&config + t) = EEPROM.read(CONFIG_START + t);*/

    if (loadState(CONFIG_START + 0) == CONFIG_VERSION[0] &&
        loadState(CONFIG_START + 1) == CONFIG_VERSION[1] &&
        loadState(CONFIG_START + 2) == CONFIG_VERSION[2])
    for (unsigned int t=0; t<sizeof(config); t++)
        *((char*)&config + t) = loadState(CONFIG_START + t);

    configLoaded = true;
}

void saveConfig() {
    for (unsigned int t=0; t<sizeof(config); t++)
        //EEPROM.write(CONFIG_START + t, *((char*)&config + t));
        saveState(CONFIG_START + t, *((char*)&config + t));
}

/**
 * Initial configuration
 */
void setup()
{
    Serial.begin(115200);
    Serial.println(F("Energy Sensor has powered up"));

    #ifdef USE_MYSENSORS
    metric = getControllerConfig().isMetric;
    // true (=metric) Report sensor data in Celsius, meter, cm, gram, km/h, m/s etc..
    // false (=imperial) - Fahrenheit, feet, gallon, mph etc...
    // https://www.mysensors.org/download/sensor_api_20#controller-configuration

    // get the time from controller (handled by receiveTime)
    //requestTime(receiveTime);
    #endif

    // Set default values
    for (int i=0; i<NB_SENSORS; i++) {
        if (i==0) {
            config.enabled[i] = true;
        } else {
            config.enabled[i] = false;
        }
        config.Vrms[i] = 230;
        config.ICal[i] = 30;
        config.IOffset[i] = 0;
    }
    // Then try to load config from eeprom
    loadConfig();

    // Initialize sensors data
    for (int i=0; i<NB_SENSORS; i++) {
        sensors.current[i].Irms = 0;
        sensors.current[i].power = 0;
        sensors.current[i].wh = 0;
        sensors.current[i].received = false;

        if (config.enabled[i]) {
            #ifdef USE_MYSENSORS
            if (config.enableTransmission) {
                // present sensors again (now config is loaded)
                //presentSensor(i);

                // request value from controller
                request(CHILD_ID_POWER_n+i, V_VAR1);
            }
            #endif

            emon[i].current(SENSOR_PIN_n+i, config.ICal[i]); // Current: input pin, calibration.

            // initial boot to charge up capacitor (no reading is taken) - testing
            emon[i].calcIrms(no_of_samples);
        }
    }

    //double Irms;
    #ifdef USE_LCD
        lcd.begin(16, 2);
        for(int i = 0; i< 3; i++) {
            lcd.backlight();
            delay(250);
            lcd.noBacklight();
            delay(250);
        }
        lcd.backlight(); // finish with backlight on  lcd.setBacklight(HIGH); // NOTE: You can turn the backlight off by setting it to LOW instead of HIGH
        lcd.clear();

        lcd.setCursor(0,0);
        lcd.print("1:");
        lcd.setCursor(0,1);
        lcd.print("2:");
    #endif

    #ifdef USE_OLED
        // U8G
        // Font list :https://github.com/olikraus/u8g2/wiki/fntlistall
        // Try also u8g2_font_prospero_bold_nbp_tf
        u8g2.begin();
        u8g2.clearBuffer();
        //u8g2.setFont(u8g2_font_smart_patrol_nbp_tf); // 9px height
        u8g2.setFont(u8g2_font_open_iconic_embedded_2x_t); // 8px height
        u8g2.setCursor(0,15);
        u8g2.print("C");
        u8g2.setCursor(0,31);
        u8g2.print("F");
        u8g2.sendBuffer();
        //u8g2.setFont(u8g2_font_cursor_tf);
        //u8g2.setCursor(8,10);
    #endif

    showHelp();
}

void loop()
{
    // millis rolls over naturally every 49+ days, micros every 71+ minutes
    currentMillis = millis();

    // Read instructions from the Serial Monitor
    readSerial(Serial);
    // Send instruction
    if (newData) {
        parseData(receivedChars);
    }

    if (currentMillis - lastSample > (unsigned long)(config.sampleFrequency)*1000) {
        #ifdef DEBUG
        Serial.println(F("DEBUG:Time to read from Sensor"));
        #endif

        if (readSensors(currentMillis - lastSample)) {
            if (currentMillis - lastSend > (unsigned long)(config.sendFrequency)*1000) {
                #ifdef DEBUG
                Serial.println(F("DEBUG:Time to send to MySensor"));
                #endif
                #ifdef USE_MYSENSORS
                sendMySensors(false);
                #endif

                nb_samples = 0;
                lastSend = currentMillis;
            }

            #ifdef USE_OLED
            // Refresh OLED
            showOLED();
            #endif

            #ifdef USE_LCD
            // Refresh LCD
            showLCD();
            #endif

            #ifdef USE_SERIAL
            showSerial();
            #endif
        };

        lastSample = currentMillis;
    }
}

// Check if data received, and read it
void readSerial(Stream &refSer) {
    char rc = END_CHAR;

    while ((refSer.available()) && (!newData)) {
        rc = refSer.read();
        switch (rc) {
            case '\r':
                // Discard it
                break;
            case '\n':
                receivedChars[ndx] = END_CHAR; // terminate the string
                if (ndx>0) newData = true;
                ndx = 0;
                #ifdef DEBUG
                refSer.print(F("received command "));
                refSer.println(receivedChars);
                #endif
                break;
            default:
                receivedChars[ndx] = rc;
                if (ndx < NUM_CHARS-1) {
                    ndx++;
                }
                break;
        }
    }
}

void showHelp() {
    Serial.print(F("Energy Sensor (can use up to ")); Serial.print(NB_SENSORS); Serial.println(F(" sensors)"));
    Serial.println(F("F0:<val> : Sample frequency in seconds (F0:5)"));
    Serial.println(F("F1:<val> : Send frequency in seconds (F0:60)"));
    Serial.println(F("E#:[0|1] : Enable Sensor # (E0:1[;E1:1])"));
    Serial.println(F("V<#:val> : Set Vrms (V0:230[;V1:230])"));
    Serial.println(F("C<#:val> : Set ICal (I0:29.95[;I1:29.98])"));
    Serial.println(F("O<#:val> : Set intensity offset (O0:0.05[;I1:0.07])"));
    Serial.println(F("S[0|1]   : Toggle Serial output"));
    #ifdef USE_MYSENSORS
    Serial.println(F("T[0|1]   : Enable MySensors transmission"));
    #endif
    Serial.println(F("M<#>     : Sensor mode (1: power, 2: current, 3: power+current)"));
    Serial.println(F("all commands are case insentitive"));
    Serial.println();
    Serial.print(F("F0")); Serial.print(F(ARG_SEPARATOR)); Serial.print(config.sampleFrequency);
    Serial.print(F(CMD_SEPARATOR));
    Serial.print(F("F1")); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.sendFrequency);
    for (int i=0; i<NB_SENSORS; i++) {
        if (config.enabled[i]) {
            Serial.print(F("E")); Serial.print(i); Serial.print(F(ARG_SEPARATOR)); Serial.print(config.enabled[i]); Serial.print(F(ARG_SEPARATOR));
            Serial.print(F("V")); Serial.print(i); Serial.print(F(ARG_SEPARATOR)); Serial.print(config.Vrms[i]); Serial.print(F(ARG_SEPARATOR));
            Serial.print(F("C")); Serial.print(i); Serial.print(F(ARG_SEPARATOR)); Serial.print(config.ICal[i]); Serial.print(F(ARG_SEPARATOR));
            Serial.print(F("O")); Serial.print(i); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.IOffset[i]);
        }
    }
    Serial.print(F("S")); Serial.print(config.enableSerial);
    #ifdef USE_MYSENSORS
    Serial.print(F(CMD_SEPARATOR));
    Serial.print(F("T")); Serial.print(config.enableTransmission);
    #endif
    Serial.println();
    Serial.print(F("M")); Serial.println(config.sensorMode);
}

void parseData(char* receivedData) {
    char *tok, *saved;
    if (strlen(receivedData) > 0) {
        for (tok = strtok_r(receivedData, CMD_SEPARATOR, &saved); tok; tok = strtok_r(NULL, CMD_SEPARATOR, &saved)) {
            parseCommand(tok);
        }
    } else {
        // Nothing to parse, may not happens
        newData = false;
    }
}

void parseCommand(char* receivedCommand) {
    char *tok, *saved;
    int num;
    int ivalue;
    float fvalue;

    bool change;
    char* receivedValue;

    switch (toupper(receivedCommand[0])) {
        case 'F': // F = Set sample/send frequency (example F0:5 / F1:60)
            tok = strtok_r(&receivedCommand[1], ARG_SEPARATOR, &saved);
            num = atoi(tok);

            tok = strtok_r(NULL, ARG_SEPARATOR, &saved);
            ivalue = atoi(tok);

            if (num == 0) { // sample frequency
                change = (config.sampleFrequency != ivalue);
                if (change) {
                    config.sampleFrequency = ivalue;
                    saveConfig();
                }
                Serial.print(F("OK : F")); Serial.print(num); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.sampleFrequency);
            } else if (num == 1) { // send frenquency
                change = (config.sendFrequency != ivalue);
                if (change) {
                    config.sendFrequency = ivalue;
                    saveConfig();
                }
                Serial.print(F("OK : F")); Serial.print(num); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.sendFrequency);
            } else {
                Serial.println(F("Invalid command"));
            }
            break;
        case 'E': // E = Enable Sensor # (example E0:1 E1:1)
            tok = strtok_r(&receivedCommand[1], ARG_SEPARATOR, &saved);
            num = atoi(tok);

            tok = strtok_r(NULL, ARG_SEPARATOR, &saved);
            ivalue = atoi(tok);

            if ((num >=0) && (num < NB_SENSORS)) {
                change = (config.enabled[num] != ivalue);
                if (change) {
                    config.enabled[num] = ivalue;
                    saveConfig();

                    if (config.enabled[num]) {
                        presentSensor(num);
                        if (!sensors.current[num].received) {
                            request(CHILD_ID_POWER_n+num, V_VAR1);  // request value from controller
                        }
                    }
                }
                Serial.print(F("OK : E")); Serial.print(num); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.enabled[num]);
                //Serial.println(F("Restart is required for sensor activation"));
            } else {
                Serial.println(F("Invalid command"));
            }
            break;
        case 'V': // V = Set Vrms (example V0:230)
            tok = strtok_r(&receivedCommand[1], ARG_SEPARATOR, &saved);
            num = atoi(tok);

            tok = strtok_r(NULL, ARG_SEPARATOR, &saved);
            ivalue = atoi(tok);

            if ((num >=0) && (num < NB_SENSORS)) {
                change = (config.Vrms[num] != ivalue);
                if (change) {
                    config.Vrms[num] = ivalue;
                    saveConfig();

                    nb_samples = 0;
                    lastSend = currentMillis;
                }
                Serial.print(F("OK : V")); Serial.print(num); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.Vrms[num]);
            } else {
                Serial.println(F("Invalid sensor number"));
            }
            break;
        case 'C': // C = Set calibration (example : C0:29.95)
            tok = strtok_r(&receivedCommand[1], ARG_SEPARATOR, &saved);
            num = atoi(tok);

            tok = strtok_r(NULL, ARG_SEPARATOR, &saved);
            fvalue = atof(tok);

            if ((num >=0) && (num < NB_SENSORS)) {
                change = (config.ICal[num] != fvalue);
                if (change) {
                    config.ICal[num] = fvalue;
                    saveConfig();

                    if (config.enabled[num]) {
                        // Calibration changed, reconfigure emon
                        emon[num].current(SENSOR_PIN_n+num, config.ICal[num]); // Current: input pin, calibration.
                    }

                    nb_samples = 0;
                    lastSend = currentMillis;
                }
                Serial.print(F("OK : C")); Serial.print(num); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.ICal[num]);
            } else {
                Serial.println(F("Invalid sensor number"));
            }
            break;
        case 'O': // O = Set intensity offset (example : O0:0.05)
            tok = strtok_r(&receivedCommand[1], ARG_SEPARATOR, &saved);
            num = atoi(tok);

            tok = strtok_r(NULL, ARG_SEPARATOR, &saved);
            fvalue = atof(tok);

            if ((num >=0) && (num < NB_SENSORS)) {
                change = (config.IOffset[num] != fvalue);
                if (change) {
                    config.IOffset[num] = fvalue;
                    saveConfig();

                    nb_samples = 0;
                    lastSend = currentMillis;
                }
                Serial.print(F("OK : O")); Serial.print(num); Serial.print(F(ARG_SEPARATOR)); Serial.println(config.IOffset[num]);
            } else {
                Serial.println(F("Invalid sensor number"));
            }
            break;
        case 'S': // S = toggle enableSerial
            change = (strlen(receivedCommand)==1) || (config.enableSerial != (receivedCommand[1]=='1'));
            if (change) {
                config.enableSerial = !config.enableSerial;
                saveConfig();
            }
            Serial.print(F("OK : S")); Serial.println(config.enableSerial);
            break;
        #ifdef USE_MYSENSORS
        case 'T': // T = toggle enableTransmission
            change = (strlen(receivedCommand)==1) || (config.enableTransmission != (receivedCommand[1]=='1'));
            if (change) {
                config.enableTransmission = !config.enableTransmission;
                saveConfig();

                if (config.enableTransmission) {
                    presentation();
                }

            }
            Serial.print(F("OK : T")); Serial.println(config.enableTransmission);
            Serial.println(F("Restart is recommended due to MySensors presentation"));
            break;
        #endif
        case 'M': // M = sensor mode : 1 : power, 2 : current, 3 : power+current
            tok = strtok_r(&receivedCommand[1], ARG_SEPARATOR, &saved);
            ivalue = atoi(tok);

            change = (strlen(receivedCommand)==2) && (config.sensorMode != (byte)ivalue);
            if (change) {
                config.sensorMode = (byte)ivalue;
                saveConfig();
            }
            Serial.print(F("OK : M")); Serial.println(config.sensorMode);
            break;
        case '?' : // ? = print help
            showHelp();
            break;
        default:
            Serial.println(F("I don't understand"));
            break;
    }
    newData = false;
}

#ifdef USE_SERIAL
/* Display sensors data to serial output */
void showSerial()
{
    if (config.enableSerial) {
        for (int i=0; i<NB_SENSORS; i++) {
            if (config.enabled[i]) {
                // 1 : power, 2 : current, 3 : power+current
                if ((config.sensorMode == 1) || (config.sensorMode == 3)) {
                    Serial.print(F("P")); Serial.print(i); Serial.print(F(":"));
                    Serial.print(sensors.current[i].power);       // Apparent power
                    Serial.print(F(";E")); Serial.print(i); Serial.print(F(":"));
                    Serial.print(sensors.current[i].wh/3600/1000, 5);      // Energy
                    Serial.print(F(";"));
                }
                if ((config.sensorMode == 2) || (config.sensorMode == 3)) {
                    Serial.print(F("I")); Serial.print(i); Serial.print(F(":"));
                    Serial.print(sensors.current[i].Irms);        // Irms
                    Serial.print(F(";"));
                }
            }
        }
        Serial.println("");
    }
}
#endif

#ifdef USE_OLED
void showOLED()
{
    // Font list :https://github.com/olikraus/u8g2/wiki/fntlistall
    // Try also u8g2_font_prospero_bold_nbp_tf
    // u8g2_font_prospero_nbp_tf
    // u8g2_font_smart_patrol_nbp_tf
    u8g2.clearBuffer();

    u8g2.setFont(u8g2_font_open_iconic_embedded_2x_t); // 8px height

    u8g2.setCursor(0,18);
    u8g2.print("C");
    u8g2.setCursor(0,34);
    u8g2.print("F");

    u8g2.setFont(u8g2_font_prospero_nbp_tf); // 9px height

    u8g2.setCursor(24,14);
    dtostrf(sensors.current[0].Irms, 4, 1, StringFloat);
    sprintf (StringOut, "%sA   %04dW", StringFloat, sensors.current[0].power);
    u8g2.print(StringOut);

    u8g2.setCursor(24,30);
    dtostrf(sensors.current[1].Irms, 4, 1, StringFloat);
    sprintf (StringOut, "%sA   %04dW", StringFloat, sensors.current[1].power);
    u8g2.print(StringOut);

    u8g2.sendBuffer();
}
#endif

#ifdef USE_LCD
void showLCD()
{
    for (int i=0; i<NB_SENSORS; i++) {
        if (config.enabled[i]) {
            lcd.setCursor(3,i);
            lcd.print(sensors.current[i].Irms);
            lcd.setCursor(7,i);
            lcd.print("A");
            lcd.setCursor(10,i);
            sprintf (StringOut, "%04d", sensors.current[i].power);
            lcd.print(StringOut);
            lcd.setCursor(14,i);
            lcd.print("W");
        }
    }
}
#endif

bool readSensors(unsigned long sampleDelay)
{
    bool result = true;

    float curIrms;
    for (int i=0; i<NB_SENSORS; i++) {
        if (config.enabled[i]) {
            curIrms = max(0, emon[i].calcIrms(no_of_samples) - config.IOffset[i]);
            //if (curIrms < 0.3) curIrms = 0;

             // Calculate average
            sensors.current[i].Irms = (nb_samples * sensors.current[i].Irms + curIrms) / (nb_samples + 1);

            sensors.current[i].power = sensors.current[i].Irms * config.Vrms[i];
            //sensors.current[i].energy += (sensors.current[i].power * SEND_FREQUENCY / 1000) / 3.6E6;
            //sensors.current[i].wh += (((float)sensors.current[i].power * (float)(sampleDelay/1000)) / 3600); // sampleFrequency in seconds
            sensors.current[i].wh += ((float)sensors.current[i].power * (float)(sampleDelay/1000)); // sampleDelay in milliseconds. Don not divide by 3600 now (for precision)

            #ifdef DEBUG
            Serial.print(F("DEBUG:Read Sensor ")); Serial.print(i);
            Serial.print(F(" I:")); Serial.print(sensors.current[i].Irms);
            Serial.print(F(" W:")); Serial.print(sensors.current[i].power);
            Serial.print(F(" kWh:")); Serial.println(sensors.current[i].wh/3600/1000, 5);
            #endif
        }
    }

    nb_samples++;
    return result;
}

#ifdef USE_MYSENSORS
void sendMySensors (bool force)
{
    if (config.enableTransmission) {
        /*MyMessage msgEnergy1(CHILD_ID_POWER_1, V_WATT);
        MyMessage msgEnergy1(CHILD_ID_POWER_1, V_KWH);
        MyMessage msgEnergy1(CHILD_ID_POWER_1, V_VAR1);*/
        for (int i=0; i<NB_SENSORS; i++) {
            if (config.enabled[i]) {
                if (sensors.current[i].received) {
                    // 1 : power, 2 : current, 3 : power+current
                    if ((config.sensorMode == 1) || (config.sensorMode == 3)) {
                        msg.setSensor(CHILD_ID_POWER_n+i);
                        msg.setType(V_WATT);
                        send(msg.set(sensors.current[i].power, 1));

                        msg.setSensor(CHILD_ID_POWER_n+i);
                        msg.setType(V_KWH);
                        send(msg.set(sensors.current[i].wh/3600/1000, 5));

                        msg.setSensor(CHILD_ID_POWER_n+i);
                        msg.setType(V_VAR1);
                        send(msg.set(sensors.current[i].wh/3600/1000, 5));
                    }
                    if ((config.sensorMode == 2) || (config.sensorMode == 3)) {
                        msg.setSensor(CHILD_ID_POWER_n+i);
                        msg.setType(V_CURRENT);
                        send(msg.set(sensors.current[i].Irms, 5));
                    }

                    #ifdef DEBUG
                    Serial.print(F("DEBUG:Send MySensors ")); Serial.print(i);
                    Serial.print(F(" I:")); Serial.print(sensors.current[i].Irms);
                    Serial.print(F(" W:")); Serial.print(sensors.current[i].power);
                    Serial.print(F(" kWh:")); Serial.println(sensors.current[i].wh/3600/1000, 5);
                    #endif
                } else {
                    request(CHILD_ID_POWER_n+i, V_VAR1);  // request value from controller

                    #ifdef DEBUG
                    Serial.println(F("DEBUG:History not received yet. Nothing to send"));
                    #endif
                }
            }
        }
    }
}
#endif