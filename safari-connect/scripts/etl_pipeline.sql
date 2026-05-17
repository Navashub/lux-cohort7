-- Master ETL pipeline for Safari Connect
-- Run from project root: psql "$DATABASE_URL" -f scripts/etl_pipeline.sql
-- Load CSV first: python scripts/load_csv.py

\i sql/ddl/01_schema_and_staging.sql
-- CSV load: python scripts/load_csv.py (requires DATABASE_URL)
\i sql/cleaning/01_clean_staging.sql
\i sql/ddl/02_production_table.sql
\i sql/views/01_v_clean_trips.sql
\i sql/views/02_analytic_views.sql
\i sql/indexes/01_indexes.sql

SET search_path TO safari_connect;

SELECT 'Staging count' AS metric, COUNT(*)::TEXT AS value FROM bookings_staging
UNION ALL
SELECT 'Production count', COUNT(*)::TEXT FROM bookings
UNION ALL
SELECT 'Clean trips count', COUNT(*)::TEXT FROM v_clean_trips
UNION ALL
SELECT 'Distinct booking_status', COUNT(DISTINCT booking_status)::TEXT FROM bookings
UNION ALL
SELECT 'Views in schema', COUNT(*)::TEXT
FROM information_schema.views
WHERE table_schema = 'safari_connect';
