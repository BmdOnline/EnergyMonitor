# EnergyMonitor
Arduino energy monitor, using SCT-013-030 current sensors

Project Links :
* [Software part, on GitHub](https://github.com/BmdOnline/EnergyMonitor)
* [Hardware part, on Thingiverse](https://www.thingiverse.com/thing:3670139)

This is a full energy monitor project :
* You can manage 1 to 6 sensors.
* You can configure it through USB (see below).
* It can communicate through USB, with any homemade software.
* It can communicate with any Home Automation System supporting MySensors (I'm using Domoticz).
* Full source is provided, you can customize it.

Needed parts :
* For each sensor :
  * 1x SCT-013-030 current sensor ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=SCT+013+030)).
      * It also works with SCT-013-000 ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=SCT+013+000)) (see below).
  * 1x 3.5mm Audio jack socket ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=3.5mm+Audio+jack+socket)).
  * 2x 100k Resistor ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=100k+Resistor)).
  * 1x 10µF Capacitor ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=10uF+Capacitor)).
* 1x NRF24L01 wireless module ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=NRF24L01)).
  * 1x 10µF Capacitor ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=10uF+Capacitor)) (see below).
* 1x Arduino Nano ([AliExpress](https://www.aliexpress.com/wholesale?SearchText=Arduino+Nano)).

Instructions :
* Before to print case, you can specify how many sensors you have.
  * You can define the exact number of sensors, or plan more. Each socket will be pre-cut for future use.
* Follow joined scheme for assembly.
  * Each sensor have to be connected to A0, A1 and so on...
* Upload sketch to the Arduino Nano.
* Connect it to any computer for configuration (see below).
* Let's play...

Configuration parameters :
  * Number of sensors,
  * Sensor calibration (Vrms, ICal, IOffset),
  * Sample frequency,
  * Transmission frequency,
  * Toggle MySensors on/off,
  * Toggle serial output on/off.

Configuration will be saved to eeprom.

Using serial console, you can communicate with the sensor.
For example, using minicom (? for show help) :
<pre><code>$ minicom -b 115200 -D /dev/ttyUSB0

 __  __       ____
|  \/  |_   _/ ___|  ___ _ __  ___  ___  _ __ ___
| |\/| | | | \___ \ / _ \ `_ \/ __|/ _ \| `__/ __|
| |  | | |_| |___| |  __/ | | \__ \  _  | |  \__ \
|_|  |_|\__, |____/ \___|_| |_|___/\___/|_|  |___/
        |___/                      2.3.1

Energy Sensor has powered up

Energy Sensor (can use up to 6 sensors)
F0:<val> : Sample frequency in seconds (F0:5)
F1:<val> : Send frequency in seconds (F0:60)
E#:[0|1] : Enable Sensor # (E0:1[;E1:1])
V<#:val> : Set Vrms (V0:230[;V1:230])
C<#:val> : Set ICal (I0:29.95[;I1:29.98])
O<#:val> : Set intensity offset (O0:0.05[;I1:0.07])
S[0|1]   : Toggle Serial output
T[0|1]   : Enable MySensors transmission
M<#>     : Sensor mode (1: power, 2: current, 3: power+current)
all commands are case insentitive

F0:2;F1:60
E0:1:V0:230:C0:29.40:O0:0.01
E1:1:V1:230:C1:32.00:O1:0.05
S0;T1
M3
</code></pre>

Latest lines show current configuration.

Warning :
If you are using SCT-013-000 instead of SCT-013-030, you have to add burden resistor.
NRF24L01 may have connection issues. You have to add 10µF capacitor between PWR and GND.

You'll be handling dangerous voltages.
I decline any responsibility in case of any incident or accident.
