-- Core analytic view: completed trips only with calculated fields

SET search_path TO safari_connect;

CREATE OR REPLACE VIEW v_clean_trips AS
SELECT
    *,
    TO_CHAR(departure_date, 'YYYY-MM') AS travel_month,
    TO_CHAR(departure_date, 'Month YYYY') AS month_label,
    TO_CHAR(departure_date, 'Day') AS day_name,
    EXTRACT(MONTH FROM departure_date) AS month_num,
    EXTRACT(DOW FROM departure_date) AS day_of_week,
    (fare_per_seat * seats_booked) AS calculated_fare,
    CASE
        WHEN trip_rating BETWEEN 4 AND 5 THEN 'Satisfied'
        WHEN trip_rating = 3 THEN 'Neutral'
        WHEN trip_rating BETWEEN 1 AND 2 THEN 'Unsatisfied'
        ELSE 'No Rating'
    END AS satisfaction
FROM bookings
WHERE booking_status = 'Completed';

COMMENT ON VIEW v_clean_trips IS 'Completed bookings with travel month, satisfaction, and calculated fare for Day 2 analysis.';
