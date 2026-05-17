-- Cleaning script: run after CSV load into bookings_staging
-- Order matters — run top to bottom

SET search_path TO safari_connect;

-- 1. Names: trim + fix casing
UPDATE bookings_staging
SET passenger_name = INITCAP(TRIM(passenger_name))
WHERE passenger_name != INITCAP(TRIM(passenger_name));

-- 2. Phones: remove dashes
UPDATE bookings_staging
SET passenger_phone = REGEXP_REPLACE(passenger_phone, '[^0-9]', '', 'g')
WHERE passenger_phone LIKE '%-%';

-- 3. Phones: fix +254 -> 07XXXXXXXX
UPDATE bookings_staging
SET passenger_phone = '0' || SUBSTRING(REGEXP_REPLACE(passenger_phone, '[^0-9]', '', 'g'), 4)
WHERE passenger_phone LIKE '+254%';

-- 4. Phones: set empty to NULL
UPDATE bookings_staging
SET passenger_phone = NULL
WHERE TRIM(passenger_phone) = '';

-- 5. Gender: standardise all variants
UPDATE bookings_staging
SET passenger_gender = CASE
    WHEN UPPER(TRIM(passenger_gender)) IN ('MALE', 'M') THEN 'Male'
    WHEN UPPER(TRIM(passenger_gender)) IN ('FEMALE', 'F') THEN 'Female'
    ELSE passenger_gender
END;

-- 6. City: fix casing and empty
UPDATE bookings_staging
SET passenger_city = INITCAP(TRIM(passenger_city))
WHERE passenger_city != INITCAP(TRIM(passenger_city));

UPDATE bookings_staging
SET passenger_city = 'Unknown'
WHERE TRIM(passenger_city) = '';

-- 7. Dates: fix DD/MM/YYYY
UPDATE bookings_staging
SET departure_date = TO_DATE(departure_date, 'DD/MM/YYYY')::TEXT
WHERE departure_date LIKE '%/%';

-- 8. Dates: fix DD-MM-YY (length 8)
UPDATE bookings_staging
SET departure_date = TO_DATE(departure_date, 'DD-MM-YY')::TEXT
WHERE departure_date LIKE '%-%' AND LENGTH(departure_date) = 8;

-- 9. Dates: fix MM-DD-YYYY (length 10, day part > 12)
UPDATE bookings_staging
SET departure_date = TO_DATE(departure_date, 'MM-DD-YYYY')::TEXT
WHERE departure_date LIKE '%-%'
  AND LENGTH(departure_date) = 10
  AND SPLIT_PART(departure_date, '-', 2)::INTEGER > 12;

-- 10. seat_class: fix abbreviations and casing
UPDATE bookings_staging
SET seat_class = CASE
    WHEN UPPER(TRIM(seat_class)) IN ('ECONOMY', 'ECO', 'ECONOMY CLASS') THEN 'Economy'
    WHEN UPPER(TRIM(seat_class)) IN ('BUSINESS', 'BUS', 'BUSINESS CLASS') THEN 'Business'
    ELSE seat_class
END;

-- 11. payment_method and booking_status
UPDATE bookings_staging
SET payment_method = CASE
    WHEN UPPER(TRIM(payment_method)) IN ('MPESA', 'M-PESA', 'M PESA') THEN 'M-Pesa'
    WHEN UPPER(TRIM(payment_method)) = 'CASH' THEN 'Cash'
    WHEN UPPER(TRIM(payment_method)) = 'CARD' THEN 'Card'
    ELSE payment_method
END;

UPDATE bookings_staging
SET booking_status = CASE
    WHEN UPPER(TRIM(booking_status)) = 'COMPLETED' THEN 'Completed'
    WHEN UPPER(TRIM(booking_status)) = 'CANCELLED' THEN 'Cancelled'
    WHEN UPPER(TRIM(booking_status)) = 'NO SHOW' THEN 'No Show'
    ELSE booking_status
END;

-- 12. Fare columns: strip KES text
UPDATE bookings_staging
SET total_fare = REGEXP_REPLACE(total_fare, '[^0-9.]', '', 'g')
WHERE total_fare SIMILAR TO '%[^0-9.]%';

UPDATE bookings_staging
SET fare_per_seat = REGEXP_REPLACE(fare_per_seat, '[^0-9.]', '', 'g')
WHERE fare_per_seat SIMILAR TO '%[^0-9.]%';

-- 13. Driver and vehicle type casing
UPDATE bookings_staging
SET driver_name = INITCAP(TRIM(driver_name))
WHERE driver_name != INITCAP(TRIM(driver_name));

UPDATE bookings_staging
SET vehicle_type = INITCAP(TRIM(vehicle_type))
WHERE vehicle_type != INITCAP(TRIM(vehicle_type));

-- 14. Trip rating: invalid values to NULL
UPDATE bookings_staging
SET trip_rating = NULL
WHERE TRIM(trip_rating) NOT IN ('1', '2', '3', '4', '5', '');

-- 15. Remove negative seats_booked rows
DELETE FROM bookings_staging
WHERE NULLIF(REGEXP_REPLACE(seats_booked, '[^0-9-]', '', 'g'), '')::INTEGER < 1;

-- 16. Remove exact duplicates
DELETE FROM bookings_staging
WHERE ctid NOT IN (
    SELECT MIN(ctid) FROM bookings_staging GROUP BY booking_id
);
