EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:custom-symbols
LIBS:Circuit-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Diode_Bridge D1
U 1 1 58EA794C
P 2550 1350
F 0 "D1" H 2300 1650 50  0000 C CNN
F 1 "Diode_Bridge" H 2900 1000 50  0000 C CNN
F 2 "" H 2550 1350 50  0000 C CNN
F 3 "" H 2550 1350 50  0000 C CNN
	1    2550 1350
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 P1
U 1 1 58EA7A78
P 900 1450
F 0 "P1" H 900 1600 50  0000 C CNN
F 1 "Power Input" V 1000 1450 50  0000 C CNN
F 2 "" H 900 1450 50  0000 C CNN
F 3 "" H 900 1450 50  0000 C CNN
	1    900  1450
	-1   0    0    1   
$EndComp
$Comp
L CP1 C1
U 1 1 58EA7B47
P 2550 2000
F 0 "C1" H 2575 2100 50  0000 L CNN
F 1 "CP1" H 2575 1900 50  0000 L CNN
F 2 "" H 2550 2000 50  0000 C CNN
F 3 "" H 2550 2000 50  0000 C CNN
	1    2550 2000
	0    1    1    0   
$EndComp
$Comp
L TRANSFO T1
U 1 1 58EA7DBB
P 1650 1450
F 0 "T1" H 1650 1700 50  0000 C CNN
F 1 "TRANSFO" H 1650 1150 50  0000 C CNN
F 2 "" H 1650 1450 50  0000 C CNN
F 3 "" H 1650 1450 50  0000 C CNN
	1    1650 1450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR01
U 1 1 58EA814E
P 2150 2100
F 0 "#PWR01" H 2150 1850 50  0001 C CNN
F 1 "GND" H 2150 1950 50  0000 C CNN
F 2 "" H 2150 2100 50  0000 C CNN
F 3 "" H 2150 2100 50  0000 C CNN
	1    2150 2100
	1    0    0    -1  
$EndComp
$Comp
L GNDA #PWR02
U 1 1 58EA84F8
P 1100 1650
F 0 "#PWR02" H 1100 1400 50  0001 C CNN
F 1 "GNDA" H 1100 1500 50  0000 C CNN
F 2 "" H 1100 1650 50  0000 C CNN
F 3 "" H 1100 1650 50  0000 C CNN
	1    1100 1650
	1    0    0    -1  
$EndComp
$Comp
L 120VAC #U03
U 1 1 58EA8594
P 1150 1050
F 0 "#U03" H 1050 1100 60  0000 C CNN
F 1 "120VAC" H 1150 1000 60  0000 C CNN
F 2 "" H 1150 1050 60  0000 C CNN
F 3 "" H 1150 1050 60  0000 C CNN
	1    1150 1050
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1100 1400 1100 1250
Wire Wire Line
	2050 1250 2050 950 
Wire Wire Line
	2050 950  2550 950 
Wire Wire Line
	2050 1650 2050 1750
Wire Wire Line
	2050 1750 2550 1750
Wire Wire Line
	2150 1350 2150 2100
Wire Wire Line
	2150 2000 2400 2000
Connection ~ 2150 2000
Wire Wire Line
	2950 1250 2950 2000
Wire Wire Line
	2950 2000 2700 2000
Wire Wire Line
	1250 1650 1100 1650
Wire Wire Line
	1100 1650 1100 1500
Wire Wire Line
	1100 1250 1250 1250
Connection ~ 1150 1250
$Comp
L +12V #PWR04
U 1 1 58EA8788
P 2950 1250
F 0 "#PWR04" H 2950 1100 50  0001 C CNN
F 1 "+12V" H 2950 1390 50  0000 C CNN
F 2 "" H 2950 1250 50  0000 C CNN
F 3 "" H 2950 1250 50  0000 C CNN
	1    2950 1250
	1    0    0    -1  
$EndComp
Connection ~ 2950 1350
$EndSCHEMATC
