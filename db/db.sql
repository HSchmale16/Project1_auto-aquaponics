-- The database of the automatic aquaponics system


CREATE TABLE IF NOT EXISTS Sensors (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24),
    description     TEXT,
    units           VARCHAR(12)
);

INSERT INTO Sensors (name, description, units) VALUES 
    ('thermometer', 'reads the water temperature', 'Celsius'),
    ('water level', 'reads the current waterlevel using an ultrasonic sensor', 'centimeters')
    ;

CREATE TABLE IF NOT EXISTS Readings (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reading         NUMBER,
    sensorId        INTEGER REFERENCES Sensors(id)
);


CREATE TABLE IF NOT EXISTS Actions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24),
    description     TEXT
);

CREATE TABLE IF NOT EXISTS ActionLog (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    actionId        INTEGER REFERENCES Actions(id),
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




