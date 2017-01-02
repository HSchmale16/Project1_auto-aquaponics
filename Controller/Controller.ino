#include <OneWire.h>
#include <DallasTemperature.h>
#include <SimpleDHT.h>

/**
 * AutoAquaponics Sensor Controller
 * Henry J Schmale
 * December 21, 2016
 *
 * Handles the reading and controlling of the sensors and relays
 * attached to the arduino. The NUC controls the arduino via
 * a serial port. 
 */

/**
 * Defines an action that the machine can take.
 */
struct CommandAction {
    // The code used to look it up
    String code;
    // use a function pointer to determine the action to take
    void (*action)();
};

// All possible actions that the machine can take.
const CommandAction ACTIONS[] = {
    {"tCiPump", togglePump},
    {"rWatThm", readWaterThermometer},
    {"rdWaLvl", readWaterLevel},
    {"tFeeder", toggleFeeder},
    {"rdHumid", readHumidity},
    {"rdAirTm", readAirThermometer}
};
// Total Number of Possible Actions
const int ACTION_COUNT = sizeof(ACTIONS) / sizeof(CommandAction); 

// Define the pins used
const int pinDHT11 = 2;
const int ONE_WIRE_BUS = 5;
const int pinTrigger = 12;
const int pinEcho = 11;
const int RELAY_BOARD_LOWER = 14;
const int RELAY_BOARD_UPPER = 22;
const int PIN_PUMP = RELAY_BOARD_LOWER + 1;
const int PIN_FEEDER = RELAY_BOARD_LOWER + 2;

 /* Temperature and Humidity Sensor
 */
SimpleDHT11 dht11;

/* Setup water temperature sensor
 */
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

void setup() {
    Serial.begin(9600);
    // setup the various sensors on the OneWire bus
    sensors.begin();
    // setup the pins for the echo sensor.
    pinMode(pinTrigger, OUTPUT);
    pinMode(pinEcho, INPUT);
    
    // setup relay pins
    for(int rp = RELAY_BOARD_LOWER; rp <= RELAY_BOARD_UPPER;  rp++){
        pinMode(rp, OUTPUT);
        digitalWrite(rp, HIGH);
    }
}   
    
 void loop() {
    if(!Serial.available()){
        return;
    }
    delay(50);
    String cmd;
    // while the serial is available append the current byte
    while(Serial.available()) {
        // perform a chomp operation
        if(Serial.peek() == '\n'){
            Serial.read();
            break;
        }
        cmd += (char)Serial.read(); 
    }
    Serial.println(cmd);
    // Search through possible actions and execute that action on find
    for(byte i = 0; i < ACTION_COUNT; i++){
        if(cmd.equals(ACTIONS[i].code)) {
            ACTIONS[i].action();
            break;
        }
    }
}

/* Read the water temperature by using a DST18B20 Temperature Sensor
 */
void readWaterThermometer() {
    sensors.requestTemperatures();
    Serial.println(sensors.getTempCByIndex(0));
}

/* Read the air temperature using a DHT11 Sensor
 */
void readAirThermometer() {
    byte temp = 0, humidity = 0;
    if(dht11.read(pinDHT11, &temp, &humidity, NULL)) {
        Serial.println(0);
        return;
    }
    Serial.println((int) temp);
}

/* Read the humidity using a DHT11 Sensor
 */
void readHumidity() {
    byte temp = 0, humidity = 0;
    if(dht11.read(pinDHT11, &temp, &humidity, NULL)) {
        Serial.println(0);
        return;
    }
    Serial.println((int) humidity);
}

void readWaterLevel() {
    Serial.println(0);
}

void toggleFeeder() {
    // invert digitalRead to flip-flop
    digitalWrite(PIN_FEEDER, !digitalRead(PIN_FEEDER));
    // invert to show the correct state
    Serial.println(!digitalRead(PIN_FEEDER));
}

// toggles the pump, and prints the current state of the pump after
// toggling it.
void togglePump() {
    // flip-flop the current state of pin pump
    digitalWrite(PIN_PUMP, !digitalRead(PIN_PUMP));
    // the digitalRead needs to be inverted to be in standard notion
    // because of the pull down on the pins.
    Serial.println(!digitalRead(PIN_PUMP));
}


