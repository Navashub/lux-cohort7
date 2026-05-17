# Safari Connect — Instructor Verification Baseline

**CONFIDENTIAL — instructor use only.**  
Neon project: `lux_training_db` · schema: `safari_connect`  
Generated from instructor reference pipeline run.

## Quick verification (Part G)

| Check | Expected | Reference DB |
|-------|----------|--------------|
| Staging after CSV load | 290 rows | 290 |
| Staging after cleaning | 288 rows | 288 |
| `bookings` count | 280–287 | **283** |
| `v_clean_trips` count | Completed only | **248** |
| `seats_booked < 1` | 0 | 0 |
| Views in schema | ≥ 4 | **5** |
| Indexes in schema | ≥ 8 | **9** |

### Distinct values (must match exactly)

| Column | Values |
|--------|--------|
| `booking_status` | Cancelled, Completed, No Show |
| `seat_class` | Business, Economy |
| `passenger_gender` | Female, Male |
| `vehicle_type` | Bus, Matatu, Minibus |

## Revenue sanity

| Metric | Value |
|--------|-------|
| `SUM(total_fare)` from `v_clean_trips` | **KES 223,970** |
| Completed trip count | **248** |

## Booking status breakdown (Q5A)

| Status | Count | % |
|--------|-------|---|
| Completed | 248 | 87.6% |
| Cancelled | 21 | 7.4% |
| No Show | 14 | 4.9% |

## Lost revenue (Q5C)

| Status | Bookings | Revenue lost |
|--------|----------|--------------|
| Cancelled | 21 | KES 24,805 |
| No Show | 14 | KES 7,345 |
| **Total lost** | **35** | **KES 32,150** |

## Route insights (Q1)

**Highest revenue (completed trips):**

| Route | Bookings | Revenue |
|-------|----------|---------|
| RT001 Nairobi → Mombasa | 26 | KES 51,600 |
| RT004 Nairobi → Eldoret | 26 | KES 42,400 |
| RT002 Nairobi → Kisumu | 25 | KES 38,250 |

**Most bookings (volume vs value):**

| Route | Bookings |
|-------|----------|
| RT005 Nairobi → Thika | **30** (highest volume) |
| RT007 Nairobi → Nyeri | 28 |

Key teaching point: RT005 has the most bookings but RT001 earns far more per trip — volume vs value.

## Driver performance (Q2)

Top 5 by revenue (`v_driver_performance`):

| Rank | Driver | Vehicle | Revenue |
|------|--------|---------|---------|
| 1 | Isaac Korir | Matatu | KES 32,505 |
| 2 | Kelvin Omondi | Bus | KES 30,855 |
| 3 | Brian Kamau | Bus | KES 28,290 |
| 4 | Samuel Gitonga | Minibus | KES 27,755 |
| 5 | Hassan Abdi | Minibus | KES 27,575 |

Isaac Korir has the lowest platform rating (3.8) in the dataset — useful contrast for promotion discussions.

## Cancellations by route

| Route | Cancel rate % |
|-------|---------------|
| RT006 Mombasa → Malindi | 20.0% |
| RT009 Nairobi → Machakos | 17.4% |
| RT008 Kisumu → Kakamega | 14.3% |

## Monthly revenue peaks

| Month | Revenue |
|-------|---------|
| 2024-10 | KES 23,140 |
| 2024-07 | KES 22,855 |
| 2024-11 | KES 20,270 |

## Rows removed during cleaning

- Duplicate `BK0005` (exact duplicate)
- `BK9002` (negative `seats_booked`)

## Reset reference database

```sql
DROP SCHEMA IF EXISTS safari_connect CASCADE;
```

Then re-run pipeline from [README.md](../README.md).
