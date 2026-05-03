-- Production table DDL
-- This table stores cleaned and validated booking data

CREATE TABLE IF NOT EXISTS bookings (
    booking_id VARCHAR(10) PRIMARY KEY,
    guest_name VARCHAR(100),
    guest_phone VARCHAR(15),
    guest_city VARCHAR(60),
    guest_nationality VARCHAR(60),
    room_no VARCHAR(5),
    room_type VARCHAR(20),
    room_rate_per_night NUMERIC(10,2),
    check_in_date DATE,
    check_out_date DATE,
    nights_stayed INTEGER,
    staff_name VARCHAR(100),
    staff_department VARCHAR(50),
    staff_salary NUMERIC(10,2),
    payment_method VARCHAR(20),
    booking_status VARCHAR(20),
    total_amount NUMERIC(12,2),
    service_used VARCHAR(60),
    service_price NUMERIC(10,2),
    guest_rating INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add constraints and indexes
ALTER TABLE bookings ADD CONSTRAINT chk_guest_rating CHECK (guest_rating BETWEEN 1 AND 5);
ALTER TABLE bookings ADD CONSTRAINT chk_nights_stayed CHECK (nights_stayed > 0);
ALTER TABLE bookings ADD CONSTRAINT chk_dates CHECK (check_out_date >= check_in_date);

-- Add comments
COMMENT ON TABLE bookings IS 'Production table for cleaned and validated hotel booking data.';
COMMENT ON COLUMN bookings.booking_id IS 'Unique booking identifier (e.g., BK0001)';
COMMENT ON COLUMN bookings.guest_rating IS 'Guest satisfaction rating (1-5 scale)';
COMMENT ON COLUMN bookings.total_amount IS 'Total booking amount including room and services';