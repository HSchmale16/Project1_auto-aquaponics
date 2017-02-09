-- The database of the automatic aquaponics system


CREATE TABLE IF NOT EXISTS Sensors (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24) UNIQUE,
    description     TEXT,
    units           VARCHAR(12)
);

INSERT INTO Sensors (name, description, units) VALUES
    ('water thermometer', 'reads the water temperature', 'Celsius'),
    ('water level', 'reads the current waterlevel using an ultrasonic sensor', 'centimeters'),
    ('humidity', 'reads the relative humidity of the air', 'Percent'),
    ('air temperature', 'reads the current air temperature', 'Celsius')
    ;

CREATE TABLE IF NOT EXISTS Readings (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reading         NUMBER,
    sensorId        INTEGER REFERENCES Sensors(id)
);
CREATE UNIQUE INDEX ux_SensorTs ON Readings(ts, sensorId);

CREATE TABLE IF NOT EXISTS Actions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24) UNIQUE,
    description     TEXT
);

INSERT INTO Actions(name, description) VALUES
    ('toggle circulation pump', 'toggling of the primary circulation pump'),
    ('toggle air pump', 'toggling of the airation pump'),
    ('toggle lights', 'toggling of the tank lights')
    ;

CREATE TABLE IF NOT EXISTS ActionLog (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    actionId        INTEGER REFERENCES Actions(id),
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

-- Generates a sequence between 1 and 24
CREATE VIEW __hoursInDay AS
WITH RECURSIVE
	cnt(x) as (
	SELECT 1
	UNION ALL SELECT x + 1 from cnt
	LIMIT 24
)
SELECT x FROM cnt;

-- Describes the schedule statew
CREATE VIEW vScheduleState AS
SELECT
	X1 as Action,
	GROUP_CONCAT(X2, ' ') as hours,
	1 as state
FROM Schedule
GROUP By X1
UNION
SELECT
	X1 as Action,
	(SELECT GROUP_CONCAT(x, ' ') FROM __hoursInDay WHERE x NOT IN (SELECT X2 FROM Schedule WHERE X1 = s2.X1)),
	0 as state
FROM Schedule s2
GROUP BY X1;







