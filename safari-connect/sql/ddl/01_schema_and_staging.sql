-- DDL: Safari Connect schema and staging table
-- All columns TEXT so dirty CSV imports without type errors

CREATE SCHEMA IF NOT EXISTS safari_connect;

SET search_path TO safari_connect;

CREATE TABLE IF NOT EXISTS bookings_staging (
    booking_id       TEXT,
    passenger_name   TEXT,
    passenger_phone  TEXT,
    passenger_gender TEXT,
    passenger_city   TEXT,
    route_code       TEXT,
    route_from       TEXT,
    route_to         TEXT,
    vehicle_plate    TEXT,
    vehicle_type     TEXT,
    driver_name      TEXT,
    driver_rating    TEXT,
    departure_date   TEXT,
    departure_time   TEXT,
    seat_class       TEXT,
    seats_booked     TEXT,
    fare_per_seat    TEXT,
    total_fare       TEXT,
    payment_method   TEXT,
    booking_status   TEXT,
    trip_rating      TEXT
);

COMMENT ON TABLE bookings_staging IS 'Staging table for raw bus booking CSV. All TEXT columns accept dirty data before cleaning.';
COMMENT ON SCHEMA safari_connect IS 'Safari Connect bus/matatu booking data pipeline.';
