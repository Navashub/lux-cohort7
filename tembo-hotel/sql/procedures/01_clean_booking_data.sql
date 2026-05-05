-- Stored Procedure for Data Cleaning
-- This procedure performs all data cleaning operations on the staging table

CREATE OR REPLACE PROCEDURE tembo_hotel.clean_booking_data()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Log start of cleaning
    RAISE NOTICE 'Starting data cleaning process...';

    -- Clean 1: guest_name - trim and fix casing
    UPDATE tembo_hotel.bookings_staging
    SET guest_name = INITCAP(TRIM(guest_name))
    WHERE guest_name != INITCAP(TRIM(guest_name));

    RAISE NOTICE 'Cleaned guest names';

    -- Clean 2: guest_phone - normalize all phone formats to digits
    UPDATE tembo_hotel.bookings_staging
    SET guest_phone = REGEXP_REPLACE(COALESCE(guest_phone, ''), '[^0-9]', '', 'g')
    WHERE guest_phone IS NOT NULL;

    UPDATE tembo_hotel.bookings_staging
    SET guest_phone = CASE
        WHEN guest_phone LIKE '254%' THEN '0' || SUBSTRING(guest_phone, 4)
        ELSE guest_phone
    END
    WHERE guest_phone LIKE '254%';

    -- Set empty phones to NULL
    UPDATE tembo_hotel.bookings_staging
    SET guest_phone = NULL
    WHERE TRIM(COALESCE(guest_phone, '')) = '';

    RAISE NOTICE 'Cleaned guest phones';

    -- Clean 3: guest_city - fix casing and typos
    UPDATE tembo_hotel.bookings_staging
    SET guest_city = INITCAP(TRIM(guest_city))
    WHERE guest_city != INITCAP(TRIM(guest_city));

    -- Fix specific typos
    UPDATE tembo_hotel.bookings_staging SET guest_city = 'Nairobi' WHERE guest_city LIKE 'Nairobii';
    UPDATE tembo_hotel.bookings_staging SET guest_city = 'Mombasa' WHERE guest_city LIKE 'Mombasaa';
    UPDATE tembo_hotel.bookings_staging SET guest_city = 'Kisumu' WHERE guest_city LIKE 'Kisumux';
    UPDATE tembo_hotel.bookings_staging SET guest_city = 'Unknown' WHERE guest_city LIKE 'nan';

    -- Set empty cities to Unknown
    UPDATE tembo_hotel.bookings_staging
    SET guest_city = 'Unknown'
    WHERE TRIM(COALESCE(guest_city, '')) = '' OR guest_city IS NULL;

    RAISE NOTICE 'Cleaned guest cities';

    -- Clean 4: Date formats
    -- Fix DD/MM/YYYY format
    UPDATE tembo_hotel.bookings_staging
    SET check_in_date = TO_DATE(check_in_date, 'DD/MM/YYYY')::TEXT,
        check_out_date = TO_DATE(check_out_date, 'DD/MM/YYYY')::TEXT
    WHERE check_in_date LIKE '%/%';

    -- Fix DD-MM-YY format (2-digit year)
    UPDATE tembo_hotel.bookings_staging
    SET check_in_date = TO_DATE(check_in_date, 'DD-MM-YY')::TEXT,
        check_out_date = TO_DATE(check_out_date, 'DD-MM-YY')::TEXT
    WHERE check_in_date LIKE '%-%' AND LENGTH(check_in_date) = 8;

    -- Fix MM-DD-YYYY format (identify by month <=12 and day >12)
    UPDATE tembo_hotel.bookings_staging
    SET check_in_date = TO_DATE(check_in_date, 'MM-DD-YYYY')::TEXT,
        check_out_date = TO_DATE(check_out_date, 'MM-DD-YYYY')::TEXT
    WHERE check_in_date LIKE '%-%' AND LENGTH(check_in_date) = 10
      AND SPLIT_PART(check_in_date, '-', 1)::INTEGER <= 12
      AND SPLIT_PART(check_in_date, '-', 2)::INTEGER > 12;

    RAISE NOTICE 'Cleaned date formats';

    -- Clean 5: room_type standardization
    UPDATE tembo_hotel.bookings_staging
    SET room_type = CASE
        WHEN UPPER(TRIM(room_type)) IN ('STANDARD', 'STD') THEN 'Standard'
        WHEN UPPER(TRIM(room_type)) IN ('DELUXE', 'DLX') THEN 'Deluxe'
        WHEN UPPER(TRIM(room_type)) IN ('SUITE', 'STE') THEN 'Suite'
        WHEN UPPER(TRIM(room_type)) = 'PENTHOUSE' THEN 'Penthouse'
        ELSE room_type
    END;

    RAISE NOTICE 'Standardized room types';

    -- Clean 6: payment_method and booking_status casing
    UPDATE tembo_hotel.bookings_staging
    SET payment_method = CASE
        WHEN UPPER(TRIM(payment_method)) IN ('MPESA', 'M-PESA', 'M PESA') THEN 'M-Pesa'
        WHEN UPPER(TRIM(payment_method)) = 'CASH' THEN 'Cash'
        WHEN UPPER(TRIM(payment_method)) = 'CARD' THEN 'Card'
        WHEN UPPER(TRIM(payment_method)) IN ('BANK TRANSFER', 'BANK') THEN 'Bank Transfer'
        ELSE payment_method
    END;

    UPDATE tembo_hotel.bookings_staging
    SET booking_status = CASE
        WHEN UPPER(TRIM(booking_status)) = 'CHECKED OUT' THEN 'Checked Out'
        WHEN UPPER(TRIM(booking_status)) = 'CANCELLED' THEN 'Cancelled'
        WHEN UPPER(TRIM(booking_status)) = 'NO SHOW' THEN 'No Show'
        ELSE booking_status
    END;

    RAISE NOTICE 'Standardized payment methods and booking statuses';

    -- Clean 7: total_amount and staff_salary - strip non-numeric
    UPDATE tembo_hotel.bookings_staging
    SET total_amount = REGEXP_REPLACE(total_amount, '[^0-9.]', '', 'g')
    WHERE total_amount SIMILAR TO '%[^0-9.]%';

    UPDATE tembo_hotel.bookings_staging
    SET staff_salary = REGEXP_REPLACE(staff_salary, '[^0-9.]', '', 'g')
    WHERE staff_salary SIMILAR TO '%[^0-9.]%';

    -- Set empty total_amount to NULL
    UPDATE tembo_hotel.bookings_staging
    SET total_amount = NULL
    WHERE TRIM(COALESCE(total_amount, '')) = '';

    RAISE NOTICE 'Cleaned amounts and salaries';

    -- Clean 8: guest_rating - invalid values to NULL
    UPDATE tembo_hotel.bookings_staging
    SET guest_rating = NULL
    WHERE guest_rating NOT IN ('1','2','3','4','5') OR TRIM(COALESCE(guest_rating, '')) = '';

    RAISE NOTICE 'Cleaned guest ratings';

    -- Clean 9: Remove impossible rows (negative nights)
    DELETE FROM tembo_hotel.bookings_staging
    WHERE NULLIF(REGEXP_REPLACE(nights_stayed, '[^0-9]', '', 'g'), '')::INTEGER < 1;

    RAISE NOTICE 'Removed invalid night stays';

    -- Clean 10: Remove exact duplicates
    DELETE FROM tembo_hotel.bookings_staging
    WHERE ctid NOT IN (
        SELECT MIN(ctid)
        FROM tembo_hotel.bookings_staging
        GROUP BY booking_id
    );

    RAISE NOTICE 'Removed duplicate bookings';

    -- Clean 11: guest_nationality casing
    UPDATE tembo_hotel.bookings_staging
    SET guest_nationality = INITCAP(TRIM(guest_nationality))
    WHERE guest_nationality != INITCAP(TRIM(guest_nationality));

    RAISE NOTICE 'Standardized nationalities';

    RAISE NOTICE 'Data cleaning completed successfully';
END;
$$;

COMMENT ON PROCEDURE clean_booking_data() IS 'Comprehensive stored procedure that performs all data cleaning operations on the staging table, including name casing, phone formatting, date standardization, and data validation.';
