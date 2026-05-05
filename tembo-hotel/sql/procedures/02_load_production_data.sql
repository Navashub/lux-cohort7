-- Stored Procedure for Loading Production Data
-- This procedure loads cleaned data from staging to production table

CREATE OR REPLACE PROCEDURE tembo_hotel.load_production_data()
LANGUAGE plpgsql
AS $$
DECLARE
    rows_inserted INTEGER;
BEGIN
    -- Log start
    RAISE NOTICE 'Starting production data load...';

    -- Insert cleaned data into production table
    INSERT INTO tembo_hotel.bookings (
        booking_id,
        guest_name,
        guest_phone,
        guest_city,
        guest_nationality,
        room_no,
        room_type,
        room_rate_per_night,
        check_in_date,
        check_out_date,
        nights_stayed,
        staff_name,
        staff_department,
        staff_salary,
        payment_method,
        booking_status,
        total_amount,
        service_used,
        service_price,
        guest_rating
    )
    SELECT
        booking_id,
        INITCAP(TRIM(guest_name)),
        NULLIF(
            CASE
                WHEN REGEXP_REPLACE(COALESCE(guest_phone, ''), '[^0-9]', '', 'g') LIKE '254%' THEN
                    '0' || SUBSTRING(REGEXP_REPLACE(COALESCE(guest_phone, ''), '[^0-9]', '', 'g'), 4)
                ELSE REGEXP_REPLACE(COALESCE(guest_phone, ''), '[^0-9]', '', 'g')
            END,
            ''
        ),
        COALESCE(
            NULLIF(
                CASE WHEN guest_city ILIKE 'nan' THEN 'Unknown' ELSE INITCAP(TRIM(guest_city)) END,
                ''
            ),
            'Unknown'
        ),
        INITCAP(TRIM(guest_nationality)),
        room_no,
        room_type,
        NULLIF(REGEXP_REPLACE(room_rate_per_night, '[^0-9.]', '', 'g'), '')::NUMERIC,
        check_in_date::DATE,
        check_out_date::DATE,
        NULLIF(REGEXP_REPLACE(nights_stayed, '[^0-9]', '', 'g'), '')::INTEGER,
        TRIM(staff_name),
        TRIM(staff_department),
        NULLIF(REGEXP_REPLACE(staff_salary, '[^0-9.]', '', 'g'), '')::NUMERIC,
        CASE
            WHEN UPPER(TRIM(payment_method)) IN ('MPESA', 'M-PESA', 'M PESA') THEN 'M-Pesa'
            WHEN UPPER(TRIM(payment_method)) = 'CASH' THEN 'Cash'
            WHEN UPPER(TRIM(payment_method)) = 'CARD' THEN 'Card'
            WHEN UPPER(TRIM(payment_method)) IN ('BANK TRANSFER', 'BANK') THEN 'Bank Transfer'
            ELSE payment_method
        END,
        CASE
            WHEN UPPER(TRIM(booking_status)) = 'CHECKED OUT' THEN 'Checked Out'
            WHEN UPPER(TRIM(booking_status)) = 'CANCELLED' THEN 'Cancelled'
            WHEN UPPER(TRIM(booking_status)) = 'NO SHOW' THEN 'No Show'
            ELSE INITCAP(TRIM(booking_status))
        END,
        NULLIF(REGEXP_REPLACE(total_amount, '[^0-9.]', '', 'g'), '')::NUMERIC,
        NULLIF(TRIM(service_used), ''),
        NULLIF(REGEXP_REPLACE(service_price, '[^0-9.]', '', 'g'), '')::NUMERIC,
        NULLIF(guest_rating, '')::INTEGER
    FROM tembo_hotel.bookings_staging
    WHERE check_in_date SIMILAR TO '[0-9]{4}-[0-9]{2}-[0-9]{2}'
      AND check_out_date SIMILAR TO '[0-9]{4}-[0-9]{2}-[0-9]{2}'
      AND NULLIF(REGEXP_REPLACE(nights_stayed, '[^0-9]', '', 'g'), '')::INTEGER > 0;

    GET DIAGNOSTICS rows_inserted = ROW_COUNT;
    RAISE NOTICE 'Inserted % rows into production table', rows_inserted;

    -- Update timestamp
    UPDATE tembo_hotel.bookings SET updated_at = CURRENT_TIMESTAMP WHERE updated_at = created_at;

    RAISE NOTICE 'Production data load completed successfully';
END;
$$;

COMMENT ON PROCEDURE load_production_data() IS 'Loads cleaned and validated data from staging table into the production bookings table with proper data type casting and null handling.';
