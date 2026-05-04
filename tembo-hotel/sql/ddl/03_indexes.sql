-- Performance Indexes for Hotel Database
-- These indexes optimize query performance for common analytic queries

-- Date-based indexes for time series analysis
CREATE INDEX IF NOT EXISTS idx_bookings_checkin ON bookings (check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_checkout ON bookings (check_out_date);

-- Categorical indexes for filtering and grouping
CREATE INDEX IF NOT EXISTS idx_bookings_roomtype ON bookings (room_type);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings (booking_status);
CREATE INDEX IF NOT EXISTS idx_bookings_staff ON bookings (staff_name);
CREATE INDEX IF NOT EXISTS idx_bookings_payment ON bookings (payment_method);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_bookings_room_date ON bookings (room_type, check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_staff_date ON bookings (staff_name, check_in_date);

-- Partial indexes for active bookings
CREATE INDEX IF NOT EXISTS idx_bookings_active ON bookings (check_in_date, check_out_date)
WHERE booking_status = 'Checked Out';

COMMENT ON INDEX idx_bookings_checkin IS 'Optimizes date range queries and monthly aggregations';
COMMENT ON INDEX idx_bookings_roomtype IS 'Speeds up room type filtering and grouping operations';
COMMENT ON INDEX idx_bookings_staff IS 'Accelerates staff performance queries';
COMMENT ON INDEX idx_bookings_room_date IS 'Composite index for room performance over time queries';
COMMENT ON INDEX idx_bookings_active IS 'Partial index for completed bookings analysis';