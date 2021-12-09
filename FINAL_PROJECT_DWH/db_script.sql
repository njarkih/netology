-- Host - 84.201.153.170, ???????? - 19001, ???????? ???????????? - demo, ???????????????????????? - netology, ???????????? - NetoSQL2019

--CREATE DATABASE bookings_dwh;


DROP TABLE IF EXISTS dim_calendar;
CREATE TABLE dim_calendar 
AS
WITH dates AS (
	SELECT dd::date AS dt
	FROM generate_series (
		'2017-05-17'::timestamp
	  , '2017-09-15'::timestamp
	  , '1 day'::interval
	) dd
)
SELECT
	to_char(dt, 'YYYYMMDD')::int AS id
  , dt AS date 
  , to_char(dt, 'YYYY-MM-DD') AS str_date
  , date_part('isodow', dt)::int AS day
  , date_part('month', dt)::int AS month
  , date_part('isodow', dt)::int AS year
  , (date_part('isodow', dt)::smallint BETWEEN 1 AND 5)::int AS week_day
  , (to_char(dt, 'YYYYMMDD')::int IN (20170612))::int AS holyday
FROM dates 
ORDER BY dt;

ALTER TABLE dim_calendar ADD PRIMARY KEY (id);

DROP TABLE IF EXISTS dim_aircrafts cascade;
CREATE TABLE dim_aircrafts (
	id serial NOT NULL PRIMARY KEY
  , aircraft_code bpchar(3) NULL
  , model_ru varchar(800) NULL
  , model_en varchar(800) NULL
  , "range" int4 NULL
  , start_ts date NULL
  , end_ts date NULL
  , is_current bool NULL
  , "version" int4 NULL
);

DROP TABLE IF EXISTS dim_airports cascade;
CREATE TABLE dim_airports (
	id serial NOT NULL PRIMARY KEY
  , airport_code bpchar(3) NULL
  , airport_name_en varchar(800) NULL
  , airport_name_ru varchar(800) NULL
  , city_en varchar(800) NULL
  , city_ru varchar(800) NULL
  , coordinates_latitude float NULL
  , coordinates_longitude float NULL
  , timezone_region varchar(800) NULL
  , timezone_city varchar(800) NULL
  , start_ts date NULL
  , end_ts date NULL
  , is_current bool
  , "version" int4 NULL
);

DROP TABLE IF EXISTS dim_tariff cascade;
CREATE TABLE dim_tariff (
	id serial NOT NULL PRIMARY KEY
  , fare_conditions varchar(10) NULL
  , start_ts date NULL
  , end_ts date NULL
  , is_current bool
  , "version" int4 NULL
);

DROP TABLE IF EXISTS dim_passengers cascade;
CREATE TABLE dim_passengers (
	id serial NOT NULL PRIMARY KEY
  , passenger_id varchar(20) NULL
  , passenger_name text NULL
  , email varchar(800) NULL
  , phone varchar(30) NULL  
);

CREATE UNIQUE INDEX dim_passengers_idx ON dim_passengers (passenger_id, passenger_name, email, phone);


DROP TABLE IF EXISTS fact_flights;
CREATE TABLE fact_flights (
	id serial NOT NULL PRIMARY KEY
  , flight_id int4 NOT NULL
  , passenger_key int NOT NULL REFERENCES dim_passengers(id)
  , date_departure_key int NOT NULL REFERENCES dim_calendar(id)
  , date_departure timestamptz NULL
  , date_arrival_key int NOT NULL REFERENCES dim_calendar(id)
  , date_arrival timestamptz NULL
  , dalay_departure int NULL
  , dalay_arrival int NULL
  , aircraft_key int NOT NULL REFERENCES dim_aircrafts(id)
  , airport_departure_key int NOT NULL REFERENCES dim_airports(id)
  , airport_arrival_key int NOT NULL REFERENCES dim_airports(id)
  , tariff_key int NOT NULL REFERENCES dim_tariff(id)
  , amount float8 NULL
  , dt timestamptz NULL -- insert data
);

CREATE INDEX fact_flights_idx ON fact_flights (flight_id);

--------------------
-- REJECTED TABLES
--------------------

DROP TABLE IF EXISTS aircrafts_rejected;
CREATE TABLE aircrafts_rejected (
	aircraft_code bpchar(3) NULL
  , model jsonb NULL
  , "range" int4 NULL
  , err_date date NULL
  , err_text varchar(800) NULL
);


DROP TABLE IF EXISTS airports_rejected;
CREATE TABLE airports_rejected (
	airport_code bpchar(3) NULL
  , airport_name jsonb NULL
  , city jsonb NULL
  , coordinates point NULL
  , timezone text NULL
  , err_date date NULL
  , err_text varchar(800) NULL
);

DROP TABLE IF EXISTS tariff_rejected;
CREATE TABLE tariff_rejected (
	fare_conditions varchar(800) NULL
  , err_date date NULL
  , err_text varchar(800) NULL	
);

DROP TABLE IF EXISTS passengers_rejected;
CREATE TABLE passengers_rejected (
    passenger_id varchar(20) NULL
  , passenger_name text NULL
  , contact_data text NULL
  , err_date date NULL
  , err_text varchar(800) NULL	
);

DROP TABLE IF EXISTS fact_flights_rejected;
CREATE TABLE fact_flights_rejected (
    flight_id int4 NULL
  , flight_no bpchar(6) NULL
  , scheduled_departure timestamptz NULL
  , scheduled_arrival timestamptz NULL
  , departure_airport bpchar(3) NULL
  , arrival_airport bpchar(3) NULL
  , aircraft_code bpchar(3) NULL
  , actual_departure timestamptz NULL
  , actual_arrival timestamptz NULL
  , fare_conditions varchar(10) NULL
  , amount numeric(10,2) NULL
  , passenger_id varchar(20) NULL
  , passenger_name text NULL
  , contact_data text NULL
  , err_date date NULL
  , err_text varchar(800) NULL	
);

