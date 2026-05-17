-- Day 3 analytic views for Power BI and reporting

SET search_path TO safari_connect;

CREATE OR REPLACE VIEW v_route_performance AS
SELECT
    route_code,
    route_from || ' → ' || route_to AS route,
    COUNT(*) AS total_bookings,
    SUM(seats_booked) AS total_seats,
    SUM(total_fare) AS total_revenue,
    ROUND(AVG(fare_per_seat), 2) AS avg_fare,
    ROUND(AVG(trip_rating), 2) AS avg_rating,
    ROUND(SUM(total_fare) / NULLIF(SUM(seats_booked), 0), 2) AS revenue_per_seat
FROM v_clean_trips
GROUP BY route_code, route_from, route_to
ORDER BY total_revenue DESC;

CREATE OR REPLACE VIEW v_driver_performance AS
SELECT
    driver_name,
    vehicle_type,
    COUNT(*) AS total_trips,
    SUM(seats_booked) AS passengers_carried,
    SUM(total_fare) AS total_revenue,
    ROUND(AVG(trip_rating), 2) AS avg_passenger_rating,
    MAX(driver_rating) AS driver_platform_rating,
    RANK() OVER (ORDER BY SUM(total_fare) DESC) AS revenue_rank
FROM v_clean_trips
GROUP BY driver_name, vehicle_type
ORDER BY revenue_rank;

CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT
    TO_CHAR(departure_date, 'YYYY-MM') AS month,
    TO_CHAR(departure_date, 'Month YYYY') AS month_label,
    COUNT(*) AS bookings,
    SUM(total_fare) AS revenue
FROM v_clean_trips
GROUP BY TO_CHAR(departure_date, 'YYYY-MM'), TO_CHAR(departure_date, 'Month YYYY')
ORDER BY month;

CREATE OR REPLACE VIEW v_cancellation_analysis AS
SELECT
    route_code,
    route_from || ' → ' || route_to AS route,
    COUNT(*) AS total,
    SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(
        SUM(CASE WHEN booking_status IN ('Cancelled', 'No Show') THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        1
    ) AS cancel_rate_pct
FROM bookings
GROUP BY route_code, route_from, route_to
ORDER BY cancel_rate_pct DESC;
