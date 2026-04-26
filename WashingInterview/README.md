# Washing Interview Dataset - Data Engineering Project

## Project Overview

This project is part of the **Lux Data Engineering Cohort 7** curriculum. It demonstrates data import, schema design, and SQL querying using a real-world manufacturing dataset from a washing facility. The dataset contains employee performance metrics including wages, days worked, and production output (perfected bottles) across three months.

## Dataset Description

The **Washing Interview Dataset** captures operational metrics for employees working in different departments:

### Key Metrics:
- **Employee Name** - Individual worker identifier
- **Department** - Washing Night or Washing Day shift
- **Net Wage** - Monthly compensation (in local currency)
- **Days Worked** - Number of working days per month
- **Perfected Bottles** - Production output (quality bottles completed)

### Data Coverage:
- **Time Period:** January 2026 - March 2026
- **Records:** 18 employees
- **Departments:** Washing Night, Washing Day

## Project Files

| File | Description |
|------|-------------|
| `Washing_Interview_Dataset_Basic.csv` | Raw dataset with double header rows (month names + column names) |
| `washing_interview.sql` | SQL setup and import script for PostgreSQL |
| `README.md` | Project documentation |

## Getting Started

### Prerequisites:
- PostgreSQL database server (v10 or higher)
- SQL client (pgAdmin, psql, or DBeaver)
- The CSV dataset file

### Setup Instructions:

1. **Download the Dataset**
   - Save `Washing_Interview_Dataset_Basic.csv` to your local machine
   - Note the file path (e.g., `D:\Lux-cohort7\WashingInterview\`)

2. **Update File Path in SQL Script**
   - Open `washing_interview.sql`
   - Locate the `COPY staging` statement (around line 48)
   - Update the file path to match your local directory:
   ```sql
   COPY staging
   FROM 'C:\path\to\Washing_Interview_Dataset_Basic.csv'
   DELIMITER ','
   CSV HEADER;
   ```

3. **Execute the SQL Script**
   - Connect to your PostgreSQL database
   - Run the entire `washing_interview.sql` script
   - This will:
     - Create the `washing_interview` schema
     - Create the main table
     - Import and clean the data
     - Convert text columns to appropriate data types

4. **Verify Data Import**
   - Query the table to confirm successful import:
   ```sql
   SELECT * FROM washing_interview.washing_interview_dataset_basic LIMIT 5;
   ```

## Data Quality Handling

The SQL script includes special handling for the CSV structure:

- **Double Header Rows:** The CSV contains both month labels (Jan-26, Feb-26, Mar-26) and column names. The script uses a staging table to skip the first header and removes the duplicate header row that appears in the data.
- **Type Conversion:** Data is imported as text in the staging table, then converted to appropriate types (INTEGER, NUMERIC) for analysis.
- **Data Validation:** The script includes a WHERE clause to filter out non-numeric serial numbers.

## Use Cases

This dataset is ideal for practicing:
- ✅ CSV data import and ETL workflows
- ✅ Schema design and table creation
- ✅ Data type conversion and cleaning
- ✅ Exploratory data analysis (EDA)
- ✅ Wage analysis by department
- ✅ Production efficiency metrics
- ✅ Performance trend analysis over time

## Sample Queries

After importing, try these queries:

```sql
-- Average wage by department
SELECT department, AVG(jan_net_wage) as avg_jan_wage 
FROM washing_interview.washing_interview_dataset_basic 
GROUP BY department;

-- Top performers by bottle count
SELECT employee_name, department, jan_perf_bottles, feb_perf_bottles, mar_perf_bottles
FROM washing_interview.washing_interview_dataset_basic
ORDER BY jan_perf_bottles DESC
LIMIT 5;

-- Attendance trends
SELECT department, 
       AVG(jan_days_worked) as avg_jan_days,
       AVG(feb_days_worked) as avg_feb_days,
       AVG(mar_days_worked) as avg_mar_days
FROM washing_interview.washing_interview_dataset_basic
GROUP BY department;
```

## Learning Outcomes

Through this project, learners gain experience with:
- PostgreSQL data import and schema management
- Handling messy real-world data (double headers, mixed data types)
- Data cleaning and validation techniques
- SQL aggregation and analysis queries
- Performance metrics and business intelligence

## Troubleshooting

**Issue: "COPY failed" error**
- Ensure the file path in the COPY statement matches your actual CSV location
- Check that the CSV file is accessible and not locked by another application

**Issue: "Column count mismatch"**
- Verify the CSV has 12 data columns (after the double header)
- Check that no columns are missing in your CSV file

**Issue: Data type conversion errors**
- Ensure the staging table successfully imported the data
- Run `SELECT * FROM staging LIMIT 5;` to inspect raw values

---

## Contact & Availability

**Navas Herbert**
- 📧 **Email:** navasherbert01@gmail.com
- 📱 **Phone:** +254715623803

### Open to Opportunities
I'm actively looking for **Data Engineering & Data Analytics roles**. I'm passionate about building efficient data pipelines, optimizing data workflows, and leveraging data for business insights. If you have an opportunity that aligns with my experience, feel free to reach out!

---

*Project: Lux Data Engineering Cohort 7*
