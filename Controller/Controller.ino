#include <OneWire.h>

struct CommandAction {
    String code;
    void (*action)();
};

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
    while(Serial.available()) {
        if(Serial.peek() == '\n'){
            Serial.read();
            break;
        }
        cmd += Serial.read(); 
    }
    for(byte i = 0; i < ACTION_COUNT; i++){
        if(cmd.equals(ACTIONS[i].code)) {
            ACTIONS[i].action();
            break;
        }
    }
}

void togglePump() {
    
}

void readThermometer() {

}

void readWaterLevel() {

}

void toggleFeeder() {

}
