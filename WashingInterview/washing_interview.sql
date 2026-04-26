-- ============================================================
--  WASHING INTERVIEW PRACTICE SCRIPT
--  Lux Data Engineering Cohort 7
-- ============================================================
--  BEFORE YOU START:
--  Download the CSV file from the link below and save it
--  somewhere easy to find on your computer e.g. D:\lux\
--
--  Dataset link: Is in the questions pdf
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: CREATE THE SCHEMA
-- ------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS washing_interview;


-- ------------------------------------------------------------
-- STEP 2: CREATE THE TABLE
-- ------------------------------------------------------------
DROP TABLE IF EXISTS washing_interview.washing_interview_dataset_basic;

CREATE TABLE washing_interview.washing_interview_dataset_basic (
    sno           INTEGER,
    employee_name VARCHAR(100),
    department    VARCHAR(50),
    jan_net_wage      NUMERIC(10,2),
    jan_days_worked   INTEGER,
    jan_perf_bottles  INTEGER,
    feb_net_wage      NUMERIC(10,2),
    feb_days_worked   INTEGER,
    feb_perf_bottles  INTEGER,
    mar_net_wage      NUMERIC(10,2),
    mar_days_worked   INTEGER,
    mar_perf_bottles  INTEGER
);


-- ------------------------------------------------------------
-- STEP 3: IMPORT THE CSV DATA
-- ------------------------------------------------------------
-- NOTE: The CSV has TWO header rows (month names + column names)
-- We use a staging table to handle this cleanly.

-- 3a. Create a temporary staging table (all text columns)
CREATE TEMP TABLE staging (
    sno           TEXT,
    employee_name TEXT,
    department    TEXT,
    jan_net_wage      TEXT,
    jan_days_worked   TEXT,
    jan_perf_bottles  TEXT,
    feb_net_wage      TEXT,
    feb_days_worked   TEXT,
    feb_perf_bottles  TEXT,
    mar_net_wage      TEXT,
    mar_days_worked   TEXT,
    mar_perf_bottles  TEXT
);

-- 3b. Load the CSV into staging
--     HEADER skips the first row (month names row)
--     Update the file path below to match where you saved the CSV!
COPY staging
FROM 'D:\Lux-cohort7\WashingInterview\Washing_Interview_Dataset_Basic.csv'
DELIMITER ','
CSV HEADER;

-- 3c. Remove the second header row that snuck in as data
DELETE FROM staging WHERE sno = 'S/no';

-- 3d. Insert clean data into the real table with proper types
INSERT INTO washing_interview.washing_interview_dataset_basic
SELECT
    sno::INTEGER,
    employee_name,
    department,
    jan_net_wage::NUMERIC,
    jan_days_worked::INTEGER,
    jan_perf_bottles::INTEGER,
    feb_net_wage::NUMERIC,
    feb_days_worked::INTEGER,
    feb_perf_bottles::INTEGER,
    mar_net_wage::NUMERIC,
    mar_days_worked::INTEGER,
    mar_perf_bottles::INTEGER
FROM staging
WHERE sno ~ '^[0-9]+$'; 

-- 3e. Verify the import
SELECT * FROM washing_interview.washing_interview_dataset_basic LIMIT 5;


-- ============================================================
--  NOW ANSWER THE INTERVIEW QUESTIONS IN SQL
-- ============================================================


-- ------------------------------------------------------------
-- QUESTION 1: Average Earning
-- Calculate the average net wage of Jan, Feb and Mar per employee
-- (This is the Excel "Average Earning" column done in SQL)
-- ------------------------------------------------------------
SELECT
    sno,
    employee_name,
    department,
    jan_net_wage,
    feb_net_wage,
    mar_net_wage,
    ROUND((jan_net_wage + feb_net_wage + mar_net_wage) / 3, 2) AS average_earning
FROM washing_interview.washing_interview_dataset_basic
ORDER BY average_earning DESC;


-- ------------------------------------------------------------
-- QUESTION 2: Earning Category
-- Classify each employee based on their average earning:
--   <= 10,000          → Below Average
--   10,001 - 15,000    → Average
--   > 15,000           → Above Average
-- (This is the Excel nested IF done with CASE WHEN in SQL)
-- ------------------------------------------------------------
SELECT
    sno,
    employee_name,
    department,
    ROUND((jan_net_wage + feb_net_wage + mar_net_wage) / 3, 2) AS average_earning,
    CASE
        WHEN (jan_net_wage + feb_net_wage + mar_net_wage) / 3 <= 10000
             THEN 'Below Average'
        WHEN (jan_net_wage + feb_net_wage + mar_net_wage) / 3 <= 15000
             THEN 'Average'
        ELSE 'Above Average'
    END AS earning_category
FROM washing_interview.washing_interview_dataset_basic
ORDER BY average_earning DESC;


-- BONUS: Use a CTE to avoid repeating the average calculation
-- (cleaner version of Question 2 -- good practice!)
WITH earnings AS (
    SELECT
        sno,
        employee_name,
        department,
        ROUND((jan_net_wage + feb_net_wage + mar_net_wage) / 3, 2) AS average_earning
    FROM washing_interview.washing_interview_dataset_basic
)
SELECT
    sno,
    employee_name,
    department,
    average_earning,
    CASE
        WHEN average_earning <= 10000 THEN 'Below Average'
        WHEN average_earning <= 15000 THEN 'Average'
        ELSE 'Above Average'
    END AS earning_category
FROM earnings
ORDER BY average_earning DESC;


-- ------------------------------------------------------------
-- QUESTION 3: Work Shift Distribution
-- Count how many employees work Washing Day vs Washing Night
-- (This is the Excel COUNTIF done with GROUP BY in SQL)
-- ------------------------------------------------------------
SELECT
    department,
    COUNT(*)                                                        AS employee_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1)             AS percentage
FROM washing_interview.washing_interview_dataset_basic
GROUP BY department
ORDER BY employee_count DESC;


-- ============================================================
--  CHALLENGE: Can you combine all 3 answers in one query?
-- ============================================================
WITH earnings AS (
    SELECT
        sno,
        employee_name,
        department,
        ROUND((jan_net_wage + feb_net_wage + mar_net_wage) / 3, 2) AS average_earning
    FROM washing_interview.washing_interview_dataset_basic
)
SELECT
    department,
    CASE
        WHEN average_earning <= 10000 THEN 'Below Average'
        WHEN average_earning <= 15000 THEN 'Average'
        ELSE 'Above Average'
    END                  AS earning_category,
    COUNT(*)             AS count
FROM earnings
GROUP BY department, earning_category
ORDER BY department, earning_category;
-- ============================================================
--  END OF SCRIPT
-- ============================================================