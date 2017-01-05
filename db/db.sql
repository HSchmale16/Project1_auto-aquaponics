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


CREATE TABLE IF NOT EXISTS Actions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(24) UNIQUE,
    description     TEXT
);

INSERT INTO Actions(name, description) VALUES
    ('toggle circulation pump', 'toggling of the primary circulation pump');

CREATE TABLE IF NOT EXISTS ActionLog (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    actionId        INTEGER REFERENCES Actions(id),
    ts              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE VIEW IF NOT EXISTS NewestReadings AS
SELECT
	r.id,
	r.ts,
	r.sensorId,
	r.reading,
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

