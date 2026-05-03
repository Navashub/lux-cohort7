-- DDL for Tembo Hotel Data Pipeline
-- This file creates the schema and staging table for raw data ingestion

-- Create schema
CREATE SCHEMA IF NOT EXISTS tembo_hotel;

-- Set search path to the schema
SET search_path TO tembo_hotel;

-- Create staging table with all columns as TEXT to handle dirty data
CREATE TABLE IF NOT EXISTS bookings_staging (
    booking_id TEXT,
    guest_name TEXT,
    guest_phone TEXT,
    guest_city TEXT,
    guest_nationality TEXT,
    room_no TEXT,
    room_type TEXT,
    room_rate_per_night TEXT,
    check_in_date TEXT,
    check_out_date TEXT,
    nights_stayed TEXT,
    staff_name TEXT,
    staff_department TEXT,
    staff_salary TEXT,
    payment_method TEXT,
    booking_status TEXT,
    total_amount TEXT,
    service_used TEXT,
    service_price TEXT,
    guest_rating TEXT
);

-- Add comment for documentation
COMMENT ON TABLE bookings_staging IS 'Staging table for raw hotel booking data. All columns are TEXT to handle dirty data during ingestion.';
COMMENT ON SCHEMA tembo_hotel IS 'Schema for Tembo Hotel data pipeline including staging, production tables, and analytic views.';