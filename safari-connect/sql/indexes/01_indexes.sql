-- Performance indexes on bookings

SET search_path TO safari_connect;

CREATE INDEX IF NOT EXISTS idx_bookings_depdate ON bookings (departure_date);
CREATE INDEX IF NOT EXISTS idx_bookings_route ON bookings (route_code);
CREATE INDEX IF NOT EXISTS idx_bookings_driver ON bookings (driver_name);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings (booking_status);
CREATE INDEX IF NOT EXISTS idx_bookings_payment ON bookings (payment_method);
CREATE INDEX IF NOT EXISTS idx_bookings_vehicle ON bookings (vehicle_type);
CREATE INDEX IF NOT EXISTS idx_bookings_passcity ON bookings (passenger_city);
CREATE INDEX IF NOT EXISTS idx_bookings_seatclass ON bookings (seat_class);
