# API Reference

## Stored Procedures

### `clean_booking_data()`
Comprehensive data cleaning procedure that standardizes all dirty data in the staging table.

**Parameters**: None

**Operations Performed**:
- Guest name trimming and title casing
- Phone number format standardization
- City name corrections and defaults
- Date format normalization (3 formats supported)
- Room type categorization
- Payment method standardization
- Booking status casing
- Numeric field cleaning (amounts, salaries)
- Rating validation
- Duplicate removal
- Nationality casing

**Logging**: Provides progress notifications for each major operation

### `load_production_data()`
Loads cleaned data from staging into production table with proper type casting.

**Parameters**: None

**Operations Performed**:
- Type-safe data insertion
- NULL handling for missing values
- Date validation and casting
- Numeric validation and casting
- Constraint enforcement
- Record count reporting

## Views

### `v_clean_bookings`
Core analytic view with calculated fields for business intelligence.

**Columns**:
- All production table columns
- `booking_month`: Month truncated date
- `month_label`: YYYY-MM format
- `month_name`: Full month name
- `booking_year`: Extracted year
- `day_of_week_num`: Day of week (0-6)
- `day_name`: Full day name
- `room_revenue`: `nights_stayed * room_rate_per_night`
- `service_revenue`: `COALESCE(service_price, 0)`
- `sentiment`: Happy/Neutral/Unhappy/No Rating based on rating

**Filter**: Only `booking_status = 'Checked Out'`

### `v_monthly_revenue`
Monthly revenue aggregation for time-series analysis.

**Columns**:
- `month`: YYYY-MM format
- `month_label`: "Month YYYY" format
- `total_bookings`: COUNT(*)
- `total_revenue`: SUM(total_amount)
- `avg_booking_value`: ROUND(AVG(total_amount), 2)
- `total_nights`: SUM(nights_stayed)

**Grouping**: By month

### `v_room_performance`
Room type profitability and performance metrics.

**Columns**:
- `room_type`
- `total_bookings`: COUNT(*)
- `total_nights`: SUM(nights_stayed)
- `avg_nights`: ROUND(AVG(nights_stayed), 2)
- `total_revenue`: SUM(total_amount)
- `avg_revenue`: ROUND(AVG(total_amount), 2)
- `avg_rating`: ROUND(AVG(guest_rating), 2)
- `revenue_per_night`: total_revenue / total_nights

**Ordering**: By total_revenue DESC

### `v_staff_performance`
Employee performance metrics with rankings.

**Columns**:
- `staff_name`, `staff_department`
- `bookings_handled`: COUNT(*)
- `revenue_generated`: SUM(total_amount)
- `avg_booking_value`: ROUND(AVG(total_amount), 2)
- `avg_guest_rating`: ROUND(AVG(guest_rating), 2)
- `revenue_rank`: RANK() OVER revenue DESC

**Ordering**: By revenue_generated DESC

### `v_guest_insights`
Guest behavior analysis by city.

**Columns**:
- `guest_city`
- `total_bookings`: COUNT(*)
- `unique_guests`: COUNT(DISTINCT guest_name)
- `total_revenue`: SUM(total_amount)
- `avg_spend`: ROUND(AVG(total_amount), 2)
- `avg_rating`: ROUND(AVG(guest_rating), 2)
- `avg_nights`: ROUND(AVG(nights_stayed), 2)

**Ordering**: By total_revenue DESC

### `v_cancellation_analysis`
Booking cancellation patterns by room type.

**Columns**:
- `room_type`
- `total_bookings`: COUNT(*)
- `checked_out`, `cancelled`, `no_show`: Status counts
- `cancellation_rate_pct`: ROUND((cancelled + no_show) / total * 100, 1)

**Ordering**: By cancellation_rate_pct DESC

## Tables

### `bookings_staging`
Raw data staging table - all columns TEXT type.

**Purpose**: Handle dirty data during ingestion without type conversion errors.

### `bookings` (Production)
Clean, validated booking data with proper constraints.

**Constraints**:
- `booking_id` PRIMARY KEY
- `guest_rating` CHECK (1-5)
- `nights_stayed` CHECK (> 0)
- `check_out_date >= check_in_date`

**Indexes**:
- `idx_bookings_checkin`: check_in_date
- `idx_bookings_checkout`: check_out_date
- `idx_bookings_roomtype`: room_type
- `idx_bookings_status`: booking_status
- `idx_bookings_staff`: staff_name
- `idx_bookings_payment`: payment_method
- `idx_bookings_room_date`: (room_type, check_in_date)
- `idx_bookings_staff_date`: (staff_name, check_in_date)
- `idx_bookings_active`: (check_in_date, check_out_date) WHERE status = 'Checked Out'

## Usage Examples

### Data Cleaning Pipeline
```sql
-- 1. Load raw data (via script)
-- 2. Clean data
CALL clean_booking_data();
-- 3. Load to production
CALL load_production_data();
```

### Revenue Analysis
```sql
SELECT month, total_revenue, avg_booking_value
FROM v_monthly_revenue
WHERE month >= '2024-01'
ORDER BY total_revenue DESC;
```

### Room Performance
```sql
SELECT room_type,
       total_revenue,
       avg_rating,
       revenue_per_night
FROM v_room_performance
ORDER BY revenue_per_night DESC;
```

### Staff Rankings
```sql
SELECT staff_name,
       department,
       revenue_generated,
       revenue_rank
FROM v_staff_performance
WHERE revenue_rank <= 10;
```

### Cancellation Rates
```sql
SELECT room_type,
       total_bookings,
       cancellation_rate_pct
FROM v_cancellation_analysis
ORDER BY cancellation_rate_pct DESC;
```

## Performance Considerations

### Query Optimization
- Use indexed columns in WHERE clauses
- Leverage composite indexes for multi-column filters
- Consider partial indexes for status-based queries

### View Refresh
- Views are automatically updated when base tables change
- No manual refresh required
- Consider materialized views for complex aggregations if performance becomes an issue

### Bulk Operations
- Stored procedures use efficient bulk operations
- Minimize individual row operations
- Use appropriate transaction boundaries