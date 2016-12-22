#include <Wire.h>


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
    Serial.println(0);
}

void readHumidity() {
    Serial.println(0);
}

void readWaterLevel() {
    Serial.println(0);
}

void toggleFeeder() {
    Serial.println(0);
}
