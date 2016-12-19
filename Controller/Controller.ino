#include <OneWire.h>

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
    {"togPump", togglePump},
    {"readThm", readThermometer},
    {"readWLV", readWaterLevel},
    {"togFeed", toggleFeeder}
};
const int ACTION_COUNT = sizeof(ACTIONS) / sizeof(CommandAction); 

void setup() {
    Serial.begin(54600);
}


void loop() {
    String cmd;
    // while the serial is available append the current byte
    while(Serial.available()) {
        // perform a chomp operation
        if(Serial.peek() == '\n'){
            Serial.read();
            break;
        }
        cmd += Serial.read(); 
    }
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

void readThermometer() {
    Serial.println(0);
}

void readWaterLevel() {
    Serial.println(0);
}

void toggleFeeder() {
    Serial.println(0);
}
