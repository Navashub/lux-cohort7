-- Master ETL Pipeline Script
-- This script orchestrates the complete data pipeline from raw CSV to analytic views

-- Step 1: Set up schema and tables
\i sql/ddl/01_schema_and_staging.sql
\i sql/ddl/02_production_table.sql

-- Step 2: Load raw data into staging (this would be done via pgAdmin or psql \copy)
-- Note: CSV loading must be done separately as it requires file system access

-- Step 3: Clean the data using stored procedure
CALL clean_booking_data();

-- Step 4: Load cleaned data to production
CALL load_production_data();

-- Step 5: Create analytic views
\i sql/views/01_analytic_views.sql

-- Step 6: Create performance indexes
\i sql/ddl/03_indexes.sql

-- Verification queries
SELECT 'Staging count' as metric, COUNT(*) as value FROM bookings_staging
UNION ALL
SELECT 'Production count', COUNT(*) FROM bookings
UNION ALL
SELECT 'Clean bookings count', COUNT(*) FROM v_clean_bookings
UNION ALL
SELECT 'Distinct room types', COUNT(DISTINCT room_type) FROM bookings
UNION ALL
SELECT 'Distinct payment methods', COUNT(DISTINCT payment_method) FROM bookings;