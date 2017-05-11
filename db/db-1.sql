-- Database Migration 1
-- Fix the views for date ranges
-- Also add some new views
-- Henry J Schmale
-- May 9, 2017

DROP VIEW IF EXISTS vSensorReadings;
CREATE VIEW IF NOT EXISTS vSensorReadings AS
SELECT
    r.id,
    datetime(ts, 'localtime') as ts,
    CAST(reading as REAL) as reading,
    name,
    description,
    units,
    sensorId
FROM Readings r
JOIN Sensors s ON s.id = r.sensorId;


-- displays last 30 days of sensor readings
-- we need to cast the output from strftime to int to do greater than
    -- comparisons.
DROP VIEW IF EXISTS vLast30DaysReadings;
CREATE VIEW vLast30DaysReadings AS
SELECT *
FROM
	vSensorReadings as r
WHERE
	CAST(STRFTIME('%s', r.ts) AS INT) > 
		(CAST(STRFTIME('%s', CURRENT_TIMESTAMP) AS INT) - 2592000);

-- Displays the last 7 days of sensor readings
DROP VIEW IF EXISTS vLast7DaysReadings;
CREATE VIEW vLast7DaysReadings AS
SELECT *
FROM
	vSensorReadings as r
WHERE
	CAST(STRFTIME('%s', r.ts) AS INT) > 
		(CAST(STRFTIME('%s', CURRENT_TIMESTAMP) AS INT) - 604800);

DROP VIEW IF EXISTS vLast14DaysReadings;
CREATE VIEW vLast14DaysReadings AS
SELECT *
FROM
	vSensorReadings as r
WHERE
	CAST(STRFTIME('%s', r.ts) AS INT) > 
		(CAST(STRFTIME('%s', CURRENT_TIMESTAMP) AS INT) - 1209600);

DROP VIEW IF EXISTS vLast24Hours;
CREATE VIEW vLast24Hours AS
SELECT *
FROM
	vSensorReadings as r
WHERE
	CAST(STRFTIME('%s', r.ts) AS INT) > 
		(CAST(STRFTIME('%s', CURRENT_TIMESTAMP) AS INT) - 86400);

DROP VIEW IF EXISTS vLast48Hours;
CREATE VIEW vLast48Hours AS
SELECT *
FROM
	vSensorReadings as r
WHERE
	CAST(STRFTIME('%s', r.ts) AS INT) > 
		(CAST(STRFTIME('%s', CURRENT_TIMESTAMP) AS INT) - 172800);

DROP VIEW IF EXISTS vTodaysReadings;
CREATE VIEW vTodaysReadings AS
SELECT *
FROM
    vSensorReadings as r
WHERE
    DATE(r.ts) = DATE('now');

