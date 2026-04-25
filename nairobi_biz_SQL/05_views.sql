/*
==============================================================================
NAIROBI BIZ SQL - VIEWS QUESTIONS & SOLUTIONS
==============================================================================
This file contains 8 View exercises covering:
- Creating simple views with filters
- Creating views with JOINs
- Creating views with aggregations
- Using CREATE OR REPLACE to update views
- Creating views with window functions
- Creating views with CASE WHEN logic
- DROP VIEW IF EXISTS
- Creating views on top of other views

IMPORTANT: Before running these queries:
1. First ensure the nairobi_biz schema is set
2. Run each view creation command (the CREATE VIEW statements)
3. Then run the subsequent queries that use those views

Each question is clearly commented with the requirement.
The PostgreSQL solution query appears directly below each question.
==============================================================================
*/

SET search_path TO nairobi_biz;


/*
Q1. Create a simple view
Create a view called v_active_shops that shows only active shops (is_active = TRUE) 
with columns: shop_name, category, location, monthly_rent. 
Then query the view to show only Food category shops.
*/

-- ===== CREATE VIEW =====
CREATE OR REPLACE VIEW v_active_shops AS
SELECT 
    shop_name,
    category,
    location,
    monthly_rent
FROM shops
WHERE is_active = TRUE;

-- ===== QUERY THE VIEW =====
SELECT *
FROM v_active_shops
WHERE category = 'Food'
ORDER BY shop_name;


/*
Q2. Create a view with JOIN
Create a view called v_employee_directory that shows each employee's:
• full name (first + last concatenated as 'full_name')
• job_title
• shop_name
• category (shop category)
• salary
• manager_name (use COALESCE to show 'No Manager' for managers)
Then query the view to show only Pharmacists.
*/

-- ===== CREATE VIEW =====
CREATE OR REPLACE VIEW v_employee_directory AS
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.job_title,
    sh.shop_name,
    sh.category,
    e.salary,
    COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'No Manager') AS manager_name
FROM employees e
LEFT JOIN shops sh ON e.shop_id = sh.shop_id
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- ===== QUERY THE VIEW =====
SELECT *
FROM v_employee_directory
WHERE job_title = 'Pharmacist'
ORDER BY full_name;


/*
Q3. Create a view with aggregation
Create a view called v_shop_revenue with: shop_name, category, total_sales (count), 
total_revenue (sum), avg_sale_value (round to 2dp). 
Then query it to show shops ordered by total_revenue descending.
*/

-- ===== CREATE VIEW =====
CREATE OR REPLACE VIEW v_shop_revenue AS
SELECT 
    sh.shop_name,
    sh.category,
    COUNT(s.sale_id) AS total_sales,
    COALESCE(SUM(s.total_amount), 0) AS total_revenue,
    ROUND(COALESCE(AVG(s.total_amount), 0)::NUMERIC, 2) AS avg_sale_value
FROM shops sh
LEFT JOIN sales s ON sh.shop_id = s.shop_id
GROUP BY sh.shop_id, sh.shop_name, sh.category;

-- ===== QUERY THE VIEW =====
SELECT *
FROM v_shop_revenue
ORDER BY total_revenue DESC;


/*
Q4. CREATE OR REPLACE - update a view
Replace your v_shop_revenue view to add two new columns: monthly_rent and 
rent_coverage_ratio = total_revenue / monthly_rent (ROUND to 2dp). 
The ratio shows how many times over the shop's revenue covers its rent. 
Query the updated view.
*/

-- ===== CREATE OR REPLACE VIEW (updated version) =====
CREATE OR REPLACE VIEW v_shop_revenue AS
SELECT 
    sh.shop_name,
    sh.category,
    COUNT(s.sale_id) AS total_sales,
    COALESCE(SUM(s.total_amount), 0) AS total_revenue,
    ROUND(COALESCE(AVG(s.total_amount), 0)::NUMERIC, 2) AS avg_sale_value,
    sh.monthly_rent,
    CASE 
        WHEN sh.monthly_rent > 0 
        THEN ROUND((COALESCE(SUM(s.total_amount), 0) / sh.monthly_rent)::NUMERIC, 2)
        ELSE 0
    END AS rent_coverage_ratio
FROM shops sh
LEFT JOIN sales s ON sh.shop_id = s.shop_id
GROUP BY sh.shop_id, sh.shop_name, sh.category, sh.monthly_rent;

-- ===== QUERY THE UPDATED VIEW =====
SELECT *
FROM v_shop_revenue
WHERE total_sales > 0
ORDER BY total_revenue DESC;


/*
Q5. Create a view with window function
Create a view called v_employee_salary_rank that shows each employee's full name, 
shop_name, salary, overall salary rank (across all employees), and their rank 
within their own shop. Query the view to find employees who are rank 1 in their 
shop but NOT rank 1 overall.
*/

-- ===== CREATE VIEW =====
CREATE OR REPLACE VIEW v_employee_salary_rank AS
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    sh.shop_name,
    e.salary,
    RANK() OVER (ORDER BY e.salary DESC) AS overall_rank,
    RANK() OVER (PARTITION BY e.shop_id ORDER BY e.salary DESC) AS shop_rank
FROM employees e
LEFT JOIN shops sh ON e.shop_id = sh.shop_id;

-- ===== QUERY THE VIEW =====
SELECT *
FROM v_employee_salary_rank
WHERE shop_rank = 1 AND overall_rank > 1
ORDER BY overall_rank;


/*
Q6. Create a customer summary view
Create a view called v_customer_summary that shows for each customer: full_name, 
city, loyalty_tier, total_purchases, total_spent, and a column 'customer_status' 
that labels them:
• 'VIP' if total_spent > 100,000
• 'Regular' if total_spent between 10,000 and 100,000
• 'Occasional' if total_spent < 10,000 or has made no purchases
Then query the view to count how many customers fall into each status.
*/

-- ===== CREATE VIEW =====
CREATE OR REPLACE VIEW v_customer_summary AS
SELECT 
    c.full_name,
    c.city,
    c.loyalty_tier,
    COUNT(s.sale_id) AS total_purchases,
    COALESCE(SUM(s.total_amount), 0) AS total_spent,
    CASE 
        WHEN COALESCE(SUM(s.total_amount), 0) > 100000 THEN 'VIP'
        WHEN COALESCE(SUM(s.total_amount), 0) BETWEEN 10000 AND 100000 THEN 'Regular'
        ELSE 'Occasional'
    END AS customer_status
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.full_name, c.city, c.loyalty_tier;

-- ===== QUERY THE VIEW =====
SELECT 
    customer_status,
    COUNT(*) AS num_customers,
    ROUND(AVG(total_spent)::NUMERIC, 2) AS avg_spent
FROM v_customer_summary
GROUP BY customer_status
ORDER BY 
    CASE 
        WHEN customer_status = 'VIP' THEN 1
        WHEN customer_status = 'Regular' THEN 2
        ELSE 3
    END;


/*
Q7. DROP and recreate
Drop the v_active_shops view. Then recreate it as v_shops_full that includes 
all shops (active and inactive), adding a column 'status' = 'Active' or 'Closed' 
based on is_active. This tests DROP VIEW IF EXISTS and CREATE OR REPLACE VIEW.
*/

-- ===== DROP VIEW =====
DROP VIEW IF EXISTS v_active_shops CASCADE;

-- ===== CREATE NEW VIEW =====
CREATE OR REPLACE VIEW v_shops_full AS
SELECT 
    shop_name,
    category,
    location,
    monthly_rent,
    CASE 
        WHEN is_active = TRUE THEN 'Active'
        ELSE 'Closed'
    END AS status
FROM shops;

-- ===== QUERY THE NEW VIEW =====
SELECT *
FROM v_shops_full
ORDER BY status, shop_name;


/*
Q8. View on top of a view
Create a view called v_top_shops that queries your existing v_shop_revenue view 
and shows only shops where total_revenue > 100,000. This demonstrates that views 
can build on other views.
*/

-- ===== CREATE VIEW ON TOP OF ANOTHER VIEW =====
CREATE OR REPLACE VIEW v_top_shops AS
SELECT 
    shop_name,
    category,
    total_sales,
    total_revenue,
    avg_sale_value,
    monthly_rent,
    rent_coverage_ratio
FROM v_shop_revenue
WHERE total_revenue > 100000;

-- ===== QUERY THE VIEW =====
SELECT *
FROM v_top_shops
ORDER BY total_revenue DESC;
