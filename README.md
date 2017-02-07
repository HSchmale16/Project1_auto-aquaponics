# Project 1 - Automated Aquaponics
A fully automated aquaponics system monitoring temperature and other
parameters. This is my project 1 for Harrisburg University.

# Monitored Parameters
* Air Temperature
    * DHT11
* Water Temperature in Reservoir
    * DST18B20 Temperature Probe
* Relative Humidity
    * DHT 11
* Count of Fish in Reservoir
    * OpenCV Compatible Webcam

# Controlled Functions
* Water Pump
* Lights

# Project Hardware Layout
This section describes the layout of hardware in the project

              ------- Arduino ----- DHT11
             /                |
    NUC -----                 \---- DST18B20
            |                 |
            |                 \--- Relay Board --- Water Pump
            |                                  \
            |                                   --- Lights
            |                                   \
             \                                    --- Air Pump
              -------- WebCam


