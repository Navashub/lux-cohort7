# Lux Cohort 7 Repository Guide

This repository contains practical projects, assignments, and class materials for Cohort 7.  
Use this guide to understand what each folder is for, what skills it builds, and how to approach it.

## What this repo is for
- Build hands-on SQL, Python, ETL, and analytics skills.
- Practice with realistic business datasets (retail, hotel, manufacturing, telecom, crypto).
- Move from beginner topics (data structures, joins) to advanced SQL analytics and pipeline work.

## Core tools you’ll need
- **PostgreSQL** + a SQL client (`psql`, pgAdmin, or DBeaver)
- **Python 3.8+**
- **Jupyter Notebook** (for notebook-based projects)
- Optional: cloud PostgreSQL service (Aiven/Neon) for some projects

## Project map (what each folder entails)

### `morning-class-5am`
**Focus:** Python foundations for beginners.  
**What’s inside:** scripts/notebooks on lists, dictionaries, tuples, sets, operators, and basic functions.  
**Outcome:** confidence with core Python syntax before moving into data engineering workflows.

### `Assignment2`
**Focus:** starter material for SQL joins.  
**What’s inside:** a short note file (`test.txt`) introducing join concepts.  
**Outcome:** quick warm-up/reference for join practice.

### `nairobi_biz_SQL`
**Focus:** structured SQL practice on a realistic retail schema.  
**What’s inside:**
- `nairobi_biz.sql` to create schema and seed data
- `01_joins.sql`, `02_subqueries.sql`, `03_ctes.sql`, `04_window_functions.sql`, `05_views.sql`
- `NairobiBizQuiz.pdf` with guided questions
**Outcome:** strong command of joins, subqueries, CTEs, window functions, and view design.

### `SQL-projects`
**Focus:** Nairobi Academy SQL fundamentals.  
**What’s inside:** DDL/DML setup, DQL queries, and operator exercises in separate folders.  
**Outcome:** clean progression through schema creation, data manipulation, filtering, and conditional logic.

### `sales_inventory_full_SQL`
**Focus:** comprehensive SQL assignment pack (beginner to advanced).  
**What’s inside:** 7 scripts covering schema setup through advanced analytics, functions, procedures, transactions, and indexes.  
**Outcome:** broad SQL mastery across reporting, optimization, and production-style query patterns.

### `WashingInterview`
**Focus:** SQL data import and cleaning from messy CSV data.  
**What’s inside:** dataset CSV, SQL import/cleaning script, and interview briefs.  
**Outcome:** practical ETL experience (staging, cleanup, type conversion, validation).

### `tembo-hotel`
**Focus:** PostgreSQL ETL pipeline design for hotel bookings.  
**What’s inside:** raw dataset, DDL scripts, stored procedures, views, and orchestration scripts.  
**Outcome:** end-to-end pipeline thinking: ingest → clean → load → analyze.

### `MoPhones`
**Focus:** analytics case study on credit portfolio performance.  
**What’s inside:** notebook workflow, data folders, reports, and Python requirements.  
**Outcome:** ability to derive business insights from portfolio trends, customer behavior, and data quality issues.

### `night-of-codes`
**Focus:** API-to-PostgreSQL ETL mini project (crypto market data).  
**What’s inside:** notebook pipeline that extracts CoinGecko data, transforms it, and loads to Postgres.  
**Outcome:** practical understanding of API extraction, transformation, and database loading in Python.

### `cohort7Groups`
**Focus:** cohort administration (not a coding project).  
**What’s inside:** form-response PDF for member contacts/grouping status.  
**Outcome:** operational reference for cohort coordination.

## Other root-level files
- `hello.py` — currently empty placeholder file.
- `test.sql` — currently empty placeholder SQL file.
- `Hotel_Project_Brief11.docx` — supporting brief document tied to hotel-related work.

## Suggested learning order
1. `morning-class-5am` (Python basics)
2. `Assignment2` (joins intro)
3. `SQL-projects` (foundational SQL workflow)
4. `nairobi_biz_SQL` (topic-by-topic SQL depth)
5. `sales_inventory_full_SQL` (full-spectrum SQL challenge)
6. `WashingInterview` (SQL ETL with messy data)
7. `tembo-hotel` (stored-procedure ETL pipeline)
8. `night-of-codes` and `MoPhones` (Python analytics + ETL case studies)

## How to work in this repo
- Open each folder and read its local `README.md` (if present) first.
- For SQL projects, run setup scripts before query/exercise scripts.
- For Python projects, create a virtual environment and install dependencies from `requirements.txt` when provided.
- Keep credentials out of version control.

## Notes
- Some folders contain personal/assignment artifacts and may not be fully standardized yet.
- `.venv` / `venv` directories are local environments and should not be treated as project content.
