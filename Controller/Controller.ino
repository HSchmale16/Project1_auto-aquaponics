#include <SimpleDHT.h>
#include <Wire.h>

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
const int ACTION_COUNT = sizeof(ACTIONS) / sizeof(CommandAction); 
const int pinDHT11 = 2;
SimpleDHT11 dht11;


void setup() {
    Serial.begin(9600);
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
    //Serial.println(cmd);
    // Search through possible actions and execute that action on find
    for(byte i = 0; i < ACTION_COUNT; i++){
        if(cmd.equals(ACTIONS[i].code)) {
            ACTIONS[i].action();
            break;
        }
    }
}

void togglePump() {
    Serial.println(0);    
}

void readWaterThermometer() {
    Serial.println(0);
}

void readAirThermometer() {
    byte temp = 0, humidity = 0;
    if(dht11.read(pinDHT11, &temp, &humidity, NULL)) {
        Serial.println(0);
        return;
    }
    Serial.println((int) temp);
}

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
    Serial.println(0);
}
