#include <OneWire.h>
#include <DallasTemperature.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>

#define DHTTYPE DHT11

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
// sensor readings are more common than toggling actions
const CommandAction ACTIONS[] = {
    {"rWatThm", readWaterThermometer},
    {"rdWaLvl", readWaterLevel},
    {"rdHumid", readHumidity},
    {"rdAirTm", readAirThermometer},
    // negate the current actions
    {"nLights", noLights},
    {"nAirPmp", noAirPump},
    {"nCiPump", noCircPump},
    // activates the actions
    {"yLights", yesLights},
    {"yAirPmp", yesAirPump},
    {"yCiPump", yesCircPump},
};

// Total Number of Possible Actions
const int ACTION_COUNT = sizeof(ACTIONS) / sizeof(CommandAction); 

// Define the pins used
const int PIN_DHT11 = 6;
const int ONE_WIRE_BUS = 5;
const int pinTrigger = 12;
const int pinEcho = 11;
const int RELAY_BOARD_LOWER = 14;
const int RELAY_BOARD_UPPER = 22;
const int PIN_PUMP = RELAY_BOARD_LOWER + 1;
const int PIN_LIGHTS = RELAY_BOARD_LOWER + 2;
const int PIN_AIR_PUMP =  RELAY_BOARD_LOWER + 3;

 /* Temperature and Humidity Sensor
 */
DHT dht(PIN_DHT11, DHTTYPE);


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
   
    dht.begin();
 
    // setup relay pins
    for(int rp = RELAY_BOARD_LOWER; rp <= RELAY_BOARD_UPPER;  rp++){
        pinMode(rp, OUTPUT);
        digitalWrite(rp, HIGH);
    }
    digitalWrite(RELAY_BOARD_UPPER, LOW);

}   
    
 void loop() {
    if(!Serial.available()){
        return;
    }
    // wait for bytes to arrive
    delay(50);
    String cmd = "";
    // while the serial is available append the current byte
    while(Serial.available()) {
        // perform a chomp operation
        if(Serial.peek() == '\n'){
            Serial.read();
            break;
        }
        cmd += (char)Serial.read(); 
    }
    // Search through possible actions and execute that action on find
    for(byte i = 0; i < ACTION_COUNT; i++){
        if(cmd.equals(ACTIONS[i].code)) {
            Serial.print(cmd);
            Serial.print(' ');
            ACTIONS[i].action();
            break;
        }
    }
}

/* Read the water temperature by using a DST18B20 Temperature Sensor
 */
void readWaterThermometer() {
    sensors.requestTemperatures();
    float tempC = sensors.getTempCByIndex(0);
    Serial.println(DallasTemperature::toFahrenheit(tempC));
}

/* Read the air temperature using a DHT11 Sensor
 */
void readAirThermometer() {
    // read as fahrenheit
    Serial.println(dht.readTemperature(true));
}

/* Read the humidity using a DHT11 Sensor
 */
void readHumidity() {
    Serial.println(dht.readHumidity());
}

void readWaterLevel() {
    int startTime = millis();
    // delay for a clean pulse
    digitalWrite(pinTrigger, LOW);
    delayMicroseconds(5);
    digitalWrite(pinTrigger, HIGH);
    delayMicroseconds(10);
    digitalWrite(pinTrigger, LOW);
    
    int duration = pulseIn(pinEcho, HIGH);

    Serial.println((duration / 2) / 29.1);

    delay(100);
}

// toggles the pump, and prints the current state of the pump after
// toggling it.
void yesCircPump() {
    digitalWrite(PIN_PUMP, 1);
    // the digitalRead needs to be inverted to be in standard notion
    // because of the pull down on the pins.
    Serial.println(!digitalRead(PIN_PUMP));
}

void yesLights() {
    digitalWrite(PIN_LIGHTS, 1);
    Serial.println(!digitalRead(PIN_LIGHTS));
}

void yesAirPump() {
    digitalWrite(PIN_AIR_PUMP, 1);
    // because of the pull down on the pins.
    Serial.println(!digitalRead(PIN_AIR_PUMP));
}

void noLights() {
    digitalWrite(PIN_LIGHTS, 0);
    Serial.println(!digitalRead(PIN_LIGHTS));
}

void noAirPump() {
    digitalWrite(PIN_AIR_PUMP, 0);
    Serial.println(!digitalRead(PIN_LIGHTS));
}

void noCircPump() {
    digitalWrite(PIN_PUMP, 0);
    Serial.println(!digitalRead(PIN_PUMP));
}
