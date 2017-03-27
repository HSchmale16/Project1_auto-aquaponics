-- The database of the automatic aquaponics system

-- List of all sensors available
CREATE TABLE IF NOT EXISTS Sensors (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24) UNIQUE,
    description     TEXT,
    units           VARCHAR(12)
);

-- the default sensors
INSERT INTO Sensors (name, description, units) VALUES
    ('water thermometer', 'reads the water temperature', 'Fahrenheit'),
    ('water level', 'reads the current waterlevel using an ultrasonic sensor', 'centimeters'),
    ('humidity', 'reads the relative humidity of the air', 'Percent'),
    ('air temperature', 'reads the current air temperature', 'Fahrenheit')
    ;

-- Readings from the various sensors
CREATE TABLE IF NOT EXISTS Readings (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reading         NUMBER,
    sensorId        INTEGER REFERENCES Sensors(id)
);
-- only one reading per sensor per timestamp as it only has second level
-- granualarity
CREATE UNIQUE INDEX ux_SensorTs ON Readings(ts, sensorId);

CREATE TABLE IF NOT EXISTS Actions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24) UNIQUE,
    description     TEXT
);

INSERT INTO Actions(name, description) VALUES
    ('CiPump', 'toggling of the primary circulation pump'),
    ('AirPmp', 'toggling of the airation pump'),
    ('Lights', 'toggling of the tank lights')
    ;

CREATE TABLE IF NOT EXISTS ActionLog (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    actionId        INTEGER REFERENCES Actions(id),
    value           INTEGER,
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- This table manages the scheduling of the various actions
CREATE TABLE Schedule (
    X1 INTEGER REFERENCES Actions(id),
    X2 INTEGER
);
CREATE UNIQUE INDEX ux_Schedule ON Schedule(X1, X2);
-- create an initial entry for the database.
INSERT INTO Schedule VALUES (1, 1);


-- Retrieves the Newest Readings for All Sensors that currently exists as a
-- sensor
CREATE VIEW IF NOT EXISTS vNewestReadings AS
SELECT
	r.id,
	datetime(r.ts, 'localtime') as ts,
	r.sensorId,
	r.reading || ' ' || s.units as reading,
	s.name as sensor,
	s.units
FROM Readings r
INNER JOIN (
	SELECT
		max(ts) as MaxDate,
		sensorId
	FROM
		Readings as r
	GROUP BY sensorId
) rm ON r.sensorId = rm.sensorId AND r.ts = rm.MaxDate
JOIN Sensors s on s.id = r.sensorId;

CREATE VIEW IF NOT EXISTS vSensorReadings AS
SELECT
    r.id,
    datetime(ts, 'localtime') as ts,
    reading,
    name,
    description,
    units,
    sensorId
FROM Readings r
JOIN Sensors s ON s.id = r.sensorId;

-- displays last 30 days of sensor readings
CREATE VIEW IF NOT EXISTS vLast30DaysReadings AS
SELECT *
FROM
	vSensorReadings as r
WHERE
	strftime('%s', r.ts) > strftime('%s', CURRENT_TIMESTAMP) - 2592000;

-- Displays the last 7 days of sensor readings
CREATE VIEW IF NOT EXISTS vLast7DaysReadings AS
SELECT *
FROM
	vSensorReadings as r
WHERE
	strftime('%s', r.ts) > strftime('%s', CURRENT_TIMESTAMP) - 604800;

-- selects the number of readings from each sensor with name
CREATE VIEW IF NOT EXISTS vReadingsCount AS
SELECT
    sensorId,
    name,
    COUNT(*) as totReadings
FROM vSensorReadings
GROUP BY sensorId;

-- Describes the schedule state
CREATE VIEW vScheduleState AS
SELECT a.name, action, hours, state
FROM
(SELECT
	X1 as action,
	X2 - 1 as hours,
	1 as state
FROM Schedule
UNION
SELECT
	a.id,
	x - 1 as hour,
	0 as state
FROM __hoursInDay, actions a
WHERE a.id || ' '  || x NOT IN (
	SELECT X1 || ' ' || X2 FROM Schedule))
JOIN Actions a ON a.id = action;
