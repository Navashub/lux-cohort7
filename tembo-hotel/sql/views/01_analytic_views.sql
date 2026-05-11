-- Analytic Views for Hotel Data Analysis
-- These views provide cleaned data with additional calculated fields for reporting

-- Clean bookings view with calculated fields
CREATE OR REPLACE VIEW v_clean_bookings AS
SELECT *,
    DATE_TRUNC('month', check_in_date) AS booking_month,
    TO_CHAR(check_in_date, 'YYYY-MM') AS month_label,
    TO_CHAR(check_in_date, 'Month') AS month_name,
    EXTRACT(YEAR FROM check_in_date) AS booking_year,
    EXTRACT(DOW FROM check_in_date) AS day_of_week_num,
    TO_CHAR(check_in_date, 'Day') AS day_name,
    (nights_stayed * room_rate_per_night) AS room_revenue,
    COALESCE(service_price, 0) AS service_revenue,
    CASE
        WHEN guest_rating BETWEEN 4 AND 5 THEN 'Happy'
        WHEN guest_rating = 3 THEN 'Neutral'
        WHEN guest_rating BETWEEN 1 AND 2 THEN 'Unhappy'
        ELSE 'No Rating'
    END AS sentiment
FROM bookings
WHERE booking_status = 'Checked Out';

COMMENT ON VIEW v_clean_bookings IS 'Clean bookings view with calculated fields for revenue analysis and guest sentiment. Only includes completed bookings.';

-- Monthly revenue view
CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT
    TO_CHAR(check_in_date, 'YYYY-MM') AS month,
    TO_CHAR(check_in_date, 'Month YYYY') AS month_label,
    COUNT(*) AS total_bookings,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_booking_value,
    SUM(nights_stayed) AS total_nights
FROM v_clean_bookings
GROUP BY TO_CHAR(check_in_date, 'YYYY-MM'), TO_CHAR(check_in_date, 'Month YYYY')
ORDER BY month;

COMMENT ON VIEW v_monthly_revenue IS 'Monthly revenue aggregation with booking counts and averages.';

-- Room performance view
CREATE OR REPLACE VIEW v_room_performance AS
SELECT
    room_type,
    COUNT(*) AS total_bookings,
    SUM(nights_stayed) AS total_nights,
    ROUND(AVG(nights_stayed), 2) AS avg_nights,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_revenue,
    ROUND(AVG(guest_rating), 2) AS avg_rating,
    ROUND(SUM(total_amount) / NULLIF(SUM(nights_stayed), 0), 2) AS revenue_per_night
FROM v_clean_bookings
GROUP BY room_type
ORDER BY total_revenue DESC;

COMMENT ON VIEW v_room_performance IS 'Room type performance metrics including revenue, occupancy, and guest satisfaction.';

-- Staff performance view
CREATE OR REPLACE VIEW v_staff_performance AS
SELECT
    staff_name,
    staff_department,
    COUNT(*) AS bookings_handled,
    SUM(total_amount) AS revenue_generated,
    ROUND(AVG(total_amount), 2) AS avg_booking_value,
    ROUND(AVG(guest_rating), 2) AS avg_guest_rating,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM v_clean_bookings
GROUP BY staff_name, staff_department
ORDER BY revenue_generated DESC;

COMMENT ON VIEW v_staff_performance IS 'Staff performance metrics with revenue rankings and guest satisfaction scores.';

-- Guest insights view
CREATE OR REPLACE VIEW v_guest_insights AS
SELECT
    guest_city,
    COUNT(*) AS total_bookings,
    COUNT(DISTINCT guest_name) AS unique_guests,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_spend,
    ROUND(AVG(guest_rating), 2) AS avg_rating,
    ROUND(AVG(nights_stayed), 2) AS avg_nights
FROM v_clean_bookings
GROUP BY guest_city
ORDER BY total_revenue DESC;

COMMENT ON VIEW v_guest_insights IS 'Guest behavior analysis by city including spending patterns and satisfaction.';

-- Cancellation analysis view
CREATE OR REPLACE VIEW v_cancellation_analysis AS
SELECT
    room_type,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status = 'Checked Out' THEN 1 ELSE 0 END) AS checked_out,
    SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN booking_status = 'No Show' THEN 1 ELSE 0 END) AS no_show,
    ROUND(SUM(CASE WHEN booking_status IN ('Cancelled', 'No Show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS cancellation_rate_pct
FROM bookings
GROUP BY room_type
ORDER BY cancellation_rate_pct DESC;

COMMENT ON VIEW v_cancellation_analysis IS 'Cancellation and no-show analysis by room type with percentage calculations.';