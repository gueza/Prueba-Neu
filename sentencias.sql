-- Creamos la base de datos
--CREATE DATABASE Neu;

-- creamos tabla tariffs
--CREATE TABLE tariffs (
	id_market int,
    cdi int,
	voltage_leel int,
	G float, 
	T float,
	D float,
	R float,
	C float, 
	P float,
	CU float
);

-- creamos tabla services
--CREATE TABLE services (
    id_service int,
	id_market int,
    cdi int,
	voltage_leel int
);

--- creamos la tabla records
--CREATE TABLE records (
    id_record int,
	id_service int,
	record_timestamp TIMESTAMP
);

--- creamos la tabla xm_data_hourly_per_agent
--CREATE TABLE xm_data_hourly_per_agent (
    value float,
	record_timestamp TIMESTAMP
);

--- creamos la tabla consumption
--CREATE TABLE consumption (
    id_record int,
	value float
);

--- creamos la tabla injection
--CREATE TABLE injection (
    id_record int,
	value float
);


----- importamos la información de la tabla injection desde la consola
--\COPY injection(id_record, value)
FROM 'C:\Users\STEPHANIA ZAMBRANO G\Documents\Prueba\Test Neu Energy\injection.csv'
DELIMITER ','
CSV HEADER;

--select * from injection


----- importamos la información de la tabla consumption desde la consola
--\COPY consumption(id_record, value)
FROM 'C:\Users\STEPHANIA ZAMBRANO G\Documents\Prueba\Test Neu Energy\consumption.csv'
DELIMITER ','
CSV HEADER;

select * from consumption

----- importamos la información de la tabla records desde la consola
--\COPY records(id_record, id_service, record_timestamp)
FROM 'C:\Users\STEPHANIA ZAMBRANO G\Documents\Prueba\Test Neu Energy\records.csv'
DELIMITER ','
CSV HEADER;

select * from records

----- importamos la información de la tabla services desde la consola
--\COPY services(id_service, id_market, cdi, voltage_leel)
FROM 'C:\Users\STEPHANIA ZAMBRANO G\Documents\Prueba\Test Neu Energy\services.csv'
DELIMITER ','
CSV HEADER;

select * from services

----- importamos la información de la tabla tariffs desde la consola
--\COPY tariffs(id_market, voltage_leel, cdi, g, t, d, r, c, p, cu)
FROM 'C:\Users\STEPHANIA ZAMBRANO G\Documents\Prueba\Test Neu Energy\tariffs.csv'
DELIMITER ','
CSV HEADER;

select * from tariffs

----- importamos la información de la tabla xm_data_hourly_per_agent desde la consola
--\COPY xm_data_hourly_per_agent(record_timestamp, value)
FROM 'C:\Users\STEPHANIA ZAMBRANO G\Documents\Prueba\Test Neu Energy\xm_data_hourly_per_agent.csv'
DELIMITER ','
CSV HEADER;

select * from xm_data_hourly_per_agent




