-- The database of the automatic aquaponics system


CREATE TABLE IF NOT EXISTS Sensors (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24) UNIQUE,
    lookUpCode      VARCHAR(7) UNIQUE,
    description     TEXT,
    units           VARCHAR(12)
);

INSERT INTO Sensors (name, description, units, lookUpCode) VALUES 
    ('water thermometer', 'reads the water temperature', 'Celsius', 'rWatThm'),
    ('water level', 'reads the current waterlevel using an ultrasonic sensor', 'centimeters', 'rdWatLvl'),
    ('humidity', 'reads the relative humidity of the air', 'Percent', 'rdHumid'),
    ('air temperature', 'reads the current air temperature', 'Celsius', 'rdAirTm')
    ;

CREATE TABLE IF NOT EXISTS Readings (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reading         NUMBER,
    sensorId        INTEGER REFERENCES Sensors(id)
);


CREATE TABLE IF NOT EXISTS Actions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24) UNIQUE,
    description     TEXT
);

INSERT INTO Actions(name, description) VALUES
    ('toggle circulation pump', 'toggling of the primary circulation pump'),    ('toggle feeder', 'toggles the feeder on or off');

CREATE TABLE IF NOT EXISTS ActionLog (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    actionId        INTEGER REFERENCES Actions(id),
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




