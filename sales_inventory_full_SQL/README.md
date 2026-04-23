# Sales & Inventory SQL Assignment - Complete Solution Guide

## Overview
This project contains a complete PostgreSQL SQL assignment with 139 questions organized into 7 focused scripts. The assignment covers a Sales & Inventory database with 4 tables: Customers, Products, Sales, and Inventory.

---

## Database Schema

### Tables Structure

#### **assignment.customers** (50 records)
- `customer_id` (INT, PRIMARY KEY)
- `first_name` (VARCHAR)
- `last_name` (VARCHAR)
- `email` (VARCHAR)
- `phone_number` (VARCHAR)
- `registration_date` (DATE)
- `membership_status` (VARCHAR) - Bronze, Silver, Gold

#### **assignment.products** (15 records)
- `product_id` (INT, PRIMARY KEY)
- `product_name` (VARCHAR)
- `category` (VARCHAR) - Electronics, Appliances, Accessories
- `price` (DECIMAL)
- `supplier` (VARCHAR)
- `stock_quantity` (INT)

#### **assignment.sales** (15 records)
- `sale_id` (INT, PRIMARY KEY)
- `customer_id` (INT, FOREIGN KEY)
- `product_id` (INT, FOREIGN KEY)
- `quantity_sold` (INT)
- `sale_date` (DATE)
- `total_amount` (DECIMAL)

#### **assignment.inventory** (15 records)
- `product_id` (INT, PRIMARY KEY, FOREIGN KEY)
- `stock_quantity` (INT)

---

## Script Organization

### **01_DDL_CreateSchema_Tables.sql**
**Purpose:** Create the database schema and table structure
- Creates the `assignment` schema
- Creates 4 tables with proper constraints and relationships
- Sets up PRIMARY KEYS and FOREIGN KEYS
- Approximately 40 lines

### **02_DML_InsertData.sql**
**Purpose:** Populate the database with sample data
- Inserts 50 customer records
- Inserts 15 product records
- Inserts 15 sales transactions
- Inserts 15 inventory records
- Includes 12 basic SELECT queries (Q1-Q12) for data verification
- Approximately 250 lines

### **03_Joins_Queries.sql**
**Purpose:** Master JOIN operations (Questions 13-50)
- **Q13:** INNER JOIN - Customers with high-value products
- **Q14-Q42:** Various INNER, LEFT, and self-JOIN scenarios
- **Q43-Q44:** Multi-table JOINs with GROUP BY
- **Q45-Q50:** Complex filtering with JOINs and aggregation
- **Key Topics:** INNER JOIN, LEFT JOIN, self-JOIN, multiple table joins, filtering, aggregation
- Approximately 300 lines

### **04_Subqueries.sql**
**Purpose:** Subquery techniques (Questions 51-60)
- **Q51:** Customers spending above average
- **Q52:** Products priced above average
- **Q53-Q54:** Finding non-existent relationships (NOT IN)
- **Q55:** Most expensive purchase
- **Q56-Q60:** Complex comparisons using scalar subqueries
- **Key Topics:** Scalar subqueries, IN/NOT IN operators, comparison operators, correlation
- Approximately 130 lines

### **05_CTEs_CommonTableExpressions.sql**
**Purpose:** Common Table Expressions (Questions 61-70)
- **Q61:** Top 5 spenders (WITH clause)
- **Q62:** Most sold products
- **Q63:** Highest revenue category
- **Q64:** Purchase frequency analysis
- **Q65-Q70:** Advanced CTE patterns with multiple CTEs and cross joins
- **Key Topics:** Single CTE, multiple CTEs, recursive references, complex aggregations
- Approximately 220 lines

### **06_WindowFunctions.sql**
**Purpose:** Window functions and analytical queries (Questions 71-80)
- **Q71-Q74:** RANK(), DENSE_RANK() for ranking
- **Q75:** PARTITION BY with window functions
- **Q76:** Multiple ranking functions
- **Q77:** SUM() OVER for running totals and cumulative sums
- **Q78-Q79:** LAG(), LEAD() for row comparisons
- **Q80:** NTILE() for quartile distribution
- **Key Topics:** RANK, DENSE_RANK, LAG, LEAD, SUM OVER, NTILE, PARTITION BY
- Approximately 200 lines

### **07_AdvancedAnalytical.sql**
**Purpose:** Advanced queries, functions, and SQL features (Questions 81-139)

#### Advanced Analytical (Q81-Q100)
- **Q81-Q90:** Complex multi-table analysis, percentiles, cumulative revenue
- **Q91-Q100:** Advanced window functions, consecutive analysis, contribution percentages

#### CASE WHEN & Date Functions (Q101-Q110)
- **Q101-Q103:** CASE WHEN for data categorization
- **Q104-Q110:** Date extraction and formatting

#### NULL Handling & Data Quality (Q111-Q115)
- **Q111-Q115:** COALESCE, NULL checking, data validation

#### Functions & Stored Procedures (Q116-Q119)
- **Q116:** Function with DECIMAL return type
- **Q117:** Scalar function for customer spending
- **Q118:** Table-valued function for date ranges
- **Q119:** Stored procedure for data insertion

#### Indexes (Q120-Q121)
- **Q120:** Index on sales.product_id
- **Q121:** Index on customers.registration_date

#### Transactions (Q122-Q123)
- **Q122:** Multi-statement transaction with conditional logic
- **Q123:** Transaction with rollback example

#### Views (Q124-Q125)
- **Q124:** View for product revenue analysis
- **Q125:** View for customer spending summary

#### Set Operations (Q126-Q129)
- **Q126:** UNION to combine results
- **Q127:** INTERSECT for common values
- **Q128:** Anti-join pattern
- **Q129:** NOT EXISTS alternative

#### Type Casting & Formatting (Q130-Q139)
- **Q130-Q131:** Casting and format conversions
- **Q132-Q134:** Query error identification and fixes
- **Q135-Q139:** Data cleaning and NULL handling patterns

- Approximately 1000+ lines

---

## How to Use These Scripts

### Step 1: Create Schema & Tables
```sql
-- Run script 01_DDL_CreateSchema_Tables.sql
-- Creates empty database structure
```

### Step 2: Populate with Data
```sql
-- Run script 02_DML_InsertData.sql
-- Adds all test data
```

### Step 3: Learn by Topic
Run each script in order based on learning progression:
1. **Basic Queries** (already in DML script)
2. **Joins** (03_Joins_Queries.sql)
3. **Subqueries** (04_Subqueries.sql)
4. **CTEs** (05_CTEs_CommonTableExpressions.sql)
5. **Window Functions** (06_WindowFunctions.sql)
6. **Advanced Topics** (07_AdvancedAnalytical.sql)

---

## Key SQL Concepts Covered

### Basic SQL
- SELECT, WHERE, ORDER BY
- COUNT, SUM, AVG, MIN, MAX
- GROUP BY, HAVING
- DISTINCT, LIMIT

### JOINs
- INNER JOIN
- LEFT JOIN
- Self-JOIN
- Multiple table JOINs

### Subqueries
- Scalar subqueries
- IN / NOT IN
- Correlated subqueries
- EXISTS / NOT EXISTS

### Advanced Features
- **CTEs (WITH clause):** Multiple CTEs, recursive references
- **Window Functions:** RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD, SUM OVER, NTILE
- **Functions:** CREATE FUNCTION with parameters and return types
- **Procedures:** CREATE PROCEDURE with parameters
- **Transactions:** BEGIN/COMMIT/ROLLBACK
- **Views:** CREATE VIEW
- **Indexes:** CREATE INDEX
- **Set Operations:** UNION, INTERSECT
- **Case Expressions:** CASE WHEN for conditional logic
- **Date Functions:** EXTRACT, TO_CHAR, DATE arithmetic
- **Type Casting:** CAST, :: operator
- **NULL Handling:** COALESCE, NULLIF
- **String Functions:** UPPER, LOWER, TRIM, LIKE

---

## Suggested Learning Path for Students

### Week 1-2: Fundamentals
- Run 01_DDL_CreateSchema_Tables.sql
- Run 02_DML_InsertData.sql
- Practice basic SELECT queries from DML script

### Week 3-4: Joins & Relationships
- Study and practice 03_Joins_Queries.sql
- Focus on INNER vs LEFT JOIN patterns
- Understand multi-table relationships

### Week 5: Subqueries
- Study 04_Subqueries.sql
- Compare subquery vs JOIN approaches
- Practice correlated subqueries

### Week 6: Advanced Features
- Study 05_CTEs_CommonTableExpressions.sql
- Learn CTE advantages over subqueries
- Practice multiple CTE patterns

### Week 7: Analytical Queries
- Study 06_WindowFunctions.sql
- Master ranking and analytical functions
- Practice running totals and comparisons

### Week 8: Expert Topics
- Study 07_AdvancedAnalytical.sql
- Implement functions and procedures
- Learn performance optimization with indexes

---

## Key Insights & Teaching Points

### Q14 vs Q15: JOIN Type Selection
- Q14: LEFT JOIN shows all products (even unsold)
- Q15: LEFT JOIN shows all customers (even non-buyers)
- Compare these to understand importance of join direction

### Q51 vs Q52: Subquery Patterns
- Scalar subquery vs aggregation
- Using subqueries in WHERE vs FROM clause

### Q61 vs Q51: CTE vs Subquery
- Same business logic, different approach
- CTEs are more readable for complex queries
- Subqueries work in more contexts

### Q71 vs Q61: Window Functions vs GROUP BY
- Window functions preserve detail rows
- GROUP BY reduces to aggregate level
- Choose based on whether you need detail or summary

### Performance (Q120-Q121)
- Indexes on frequently searched/joined columns
- JOIN columns should be indexed
- Filter columns should be indexed

### Data Quality (Q111-Q115, Q132-Q139)
- Always handle NULL values
- Use COALESCE for defaults
- Validate data during loading
- Use CASE WHEN for categorization

---

## Testing Queries

To verify the scripts work correctly, after running all scripts:

```sql
-- Check row counts
SELECT 'Customers' as table_name, COUNT(*) as row_count FROM assignment.customers
UNION ALL
SELECT 'Products', COUNT(*) FROM assignment.products
UNION ALL
SELECT 'Sales', COUNT(*) FROM assignment.sales
UNION ALL
SELECT 'Inventory', COUNT(*) FROM assignment.inventory;

-- Check views exist
SELECT * FROM information_schema.views WHERE table_schema = 'assignment';

-- Check functions exist
SELECT * FROM information_schema.routines 
WHERE routine_schema = 'assignment' AND routine_type = 'FUNCTION';
```

---

## Notes for Trainer

1. **Difficulty Progression:** Questions follow logical progression from basic to advanced
2. **Error Examples:** Q132-Q134 include intentional errors for debugging practice
3. **Real-World Scenarios:** All questions based on typical business requirements
4. **PostgreSQL Specific:** Uses PostgreSQL functions (EXTRACT, TO_CHAR, etc.)
5. **Best Practices:** Solutions demonstrate proper indexing, transactions, and error handling
6. **Performance:** Window functions are more efficient than self-joins or complex subqueries

---

## Additional Resources

### PostgreSQL Functions Used
- String: CONCAT, UPPER, LOWER, TRIM, LENGTH, LIKE
- Date: EXTRACT, TO_CHAR, CURRENT_DATE, DATE arithmetic
- Aggregate: COUNT, SUM, AVG, MIN, MAX
- Window: RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD, NTILE
- Type: CAST, COALESCE, NULLIF

### Advanced Concepts Demonstrated
- **Correlated Subqueries:** Q51, Q58, Q59
- **Recursive CTEs:** Not used in this set (could be added)
- **Partitioning:** Q75, Q76, Q80
- **Set Operations:** Q39, Q127, Q128, Q129
- **Error Handling:** Q122-Q123
- **Dynamic SQL:** Not included (could be advanced extension)

---

## Version Information
- **Database:** PostgreSQL 12+
- **Syntax:** Standard SQL with PostgreSQL extensions
- **Last Updated:** 2024
- **Total Lines of SQL:** 1,700+
- **Total Questions:** 139

---

## Support

For each script, students can:
1. Read the query comment explaining what it does
2. Execute the query
3. Analyze the results
4. Modify the query to test variations
5. Write equivalent solutions using different approaches (e.g., JOIN vs subquery)

---

These scripts provide comprehensive coverage of SQL from basics to advanced analytics. 🎓
