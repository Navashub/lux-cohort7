# Safari Connect — Bus & Matatu Booking Platform

PostgreSQL data pipeline for a SQL group capstone. Students clean dirty booking CSV data, load a production table, build analytic views, and present findings in Power BI.

## Project structure

```
safari-connect/
├── dataset/
│   └── safari_connect_dirty.csv
├── sql/
│   ├── ddl/
│   ├── cleaning/
│   ├── views/
│   └── indexes/
├── scripts/
│   ├── load_csv.py
│   └── etl_pipeline.sql
└── docs/
    └── instructor_verification.md   (instructor baseline numbers)
```

Student guides and the instructor answer key are provided separately as Word documents.

## Quick start (Neon PostgreSQL)

### Prerequisites

- Python 3.8+
- `pandas`, `psycopg2`
- Neon connection string

### Setup

```bash
cd safari-connect
export DATABASE_URL="postgresql://user:pass@host/neondb?sslmode=require"
```

### Run pipeline

```bash
# 1. Schema + staging table
psql "$DATABASE_URL" -f sql/ddl/01_schema_and_staging.sql

# 2. Load CSV into staging
python scripts/load_csv.py

# 3. Clean, load production, views, indexes
psql "$DATABASE_URL" -f sql/cleaning/01_clean_staging.sql
psql "$DATABASE_URL" -f sql/ddl/02_production_table.sql
psql "$DATABASE_URL" -f sql/views/01_v_clean_trips.sql
psql "$DATABASE_URL" -f sql/views/02_analytic_views.sql
psql "$DATABASE_URL" -f sql/indexes/01_indexes.sql
```

Or reset and run everything (after CSV load):

```sql
DROP SCHEMA IF EXISTS safari_connect CASCADE;
```

Then repeat the steps above.

### Expected results

| Check | Expected |
|-------|----------|
| `bookings_staging` count | 291 (before cleaning) |
| `bookings` count | ~280–287 |
| `booking_status` values | Completed, Cancelled, No Show |
| `v_clean_trips` | Completed bookings only |

## Key views

| View | Purpose |
|------|---------|
| `v_clean_trips` | Completed trips + satisfaction, travel month |
| `v_route_performance` | Revenue and bookings by route |
| `v_driver_performance` | Driver rankings by revenue |
| `v_monthly_revenue` | Monthly revenue trend |
| `v_cancellation_analysis` | Cancellation rate by route |

## Data pipeline

```
CSV → bookings_staging (TEXT) → cleaning → bookings (typed) → v_clean_trips → analytic views
```

Cancellation analysis uses `bookings` directly (not `v_clean_trips`), because completed-only view excludes Cancelled and No Show rows.
