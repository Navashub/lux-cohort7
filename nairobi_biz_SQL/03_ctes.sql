/*
==============================================================================
NAIROBI BIZ SQL - CTEs (COMMON TABLE EXPRESSIONS) QUESTIONS & SOLUTIONS
==============================================================================
This file contains 8 CTE exercises covering:
- Basic CTEs with simple queries
- CTEs with filters and joins
- CTEs with CASE WHEN expressions
- Multiple chained CTEs
- CTEs with aggregation and window functions

Each question is clearly commented with the requirement.
The PostgreSQL solution query appears directly below each question.
==============================================================================
*/

SET search_path TO nairobi_biz;


/*
Q1. Basic CTE
Write a CTE called shop_totals that calculates total revenue per shop. 
Then query it to show the top 5 shops by revenue.
*/

WITH shop_totals AS (
    SELECT 
        sh.shop_id,
        sh.shop_name,
        SUM(s.total_amount) AS total_revenue
    FROM shops sh
    LEFT JOIN sales s ON sh.shop_id = s.shop_id
    GROUP BY sh.shop_id, sh.shop_name
)
SELECT 
    shop_name,
    total_revenue
FROM shop_totals
ORDER BY total_revenue DESC NULLS LAST
LIMIT 5;


/*
Q2. CTE with filter
Write a CTE called high_earners that finds all employees earning above 60,000. 
Then join the CTE result to the shops table to show each high earner's shop name 
and category alongside their name and salary.
*/

WITH high_earners AS (
    SELECT 
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS full_name,
        e.salary,
        e.shop_id
    FROM employees e
    WHERE e.salary > 60000
)
SELECT 
    he.full_name,
    he.salary,
    sh.shop_name,
    sh.category
FROM high_earners he
INNER JOIN shops sh ON he.shop_id = sh.shop_id
ORDER BY he.salary DESC;


/*
Q3. CTE with CASE WHEN
Write a CTE that assigns each sale a tier label based on total_amount:
• 'High Value' — above 50,000
• 'Medium Value' — 5,000 to 50,000
• 'Low Value' — below 5,000
Then query the CTE to count how many sales fall into each tier.
*/

WITH sale_tiers AS (
    SELECT 
        s.sale_id,
        s.total_amount,
        CASE 
            WHEN s.total_amount > 50000 THEN 'High Value'
            WHEN s.total_amount >= 5000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS sale_tier
    FROM sales s
)
SELECT 
    sale_tier,
    COUNT(*) AS num_sales,
    ROUND(AVG(total_amount)::NUMERIC, 2) AS avg_amount
FROM sale_tiers
GROUP BY sale_tier
ORDER BY 
    CASE 
        WHEN sale_tier = 'High Value' THEN 1
        WHEN sale_tier = 'Medium Value' THEN 2
        ELSE 3
    END;


/*
Q4. Two CTEs chained
Write two CTEs:
• gold_customers — all Gold-tier customers
• gold_spending — total amount spent per Gold customer (join to sales)
Then query to show each Gold customer's name and their total spending, 
ordered highest to lowest.
*/

WITH gold_customers AS (
    SELECT 
        c.customer_id,
        c.full_name,
        c.city
    FROM customers c
    WHERE c.loyalty_tier = 'Gold'
),
gold_spending AS (
    SELECT 
        gc.customer_id,
        gc.full_name,
        gc.city,
        SUM(s.total_amount) AS total_spent
    FROM gold_customers gc
    LEFT JOIN sales s ON gc.customer_id = s.customer_id
    GROUP BY gc.customer_id, gc.full_name, gc.city
)
SELECT 
    full_name,
    city,
    COALESCE(total_spent, 0) AS total_spent
FROM gold_spending
ORDER BY total_spent DESC NULLS LAST;


/*
Q5. CTE for payment method analysis
Using a CTE, calculate the total revenue and number of transactions for each 
payment method (M-Pesa, Cash, Card). Then show the results with a percentage 
column showing each method's share of total revenue.
Hint: Use a second CTE or a subquery to get the grand total for the percentage calculation.
*/

WITH payment_summary AS (
    SELECT 
        s.payment_method,
        COUNT(*) AS num_transactions,
        SUM(s.total_amount) AS method_revenue
    FROM sales s
    GROUP BY s.payment_method
),
grand_total AS (
    SELECT SUM(method_revenue) AS total_revenue
    FROM payment_summary
)
SELECT 
    ps.payment_method,
    ps.num_transactions,
    ROUND(ps.method_revenue::NUMERIC, 2) AS method_revenue,
    ROUND((ps.method_revenue / gt.total_revenue * 100)::NUMERIC, 2) AS revenue_percentage
FROM payment_summary ps
CROSS JOIN grand_total gt
ORDER BY ps.method_revenue DESC;


/*
Q6. CTE replacing a complex subquery
Rewrite your answer to Q5 (total revenue per shop above 50,000) using a CTE 
instead of a FROM subquery. The result should be identical — this question is 
about recognising that CTEs and FROM subqueries are often interchangeable.
*/

WITH shop_revenue_analysis AS (
    SELECT 
        sh.shop_id,
        sh.shop_name,
        COALESCE(SUM(s.total_amount), 0) AS total_revenue
    FROM shops sh
    LEFT JOIN sales s ON sh.shop_id = s.shop_id
    GROUP BY sh.shop_id, sh.shop_name
)
SELECT 
    shop_name,
    total_revenue
FROM shop_revenue_analysis
WHERE total_revenue > 50000
ORDER BY total_revenue DESC;


/*
Q7. CTE with date grouping
Write a CTE that groups all sales by month (use DATE_TRUNC). For each month, 
show: month, total_revenue, and number of transactions. Then query the CTE to 
show only months with more than 5 transactions.
*/

WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', s.sale_date)::DATE AS sale_month,
        COUNT(*) AS num_transactions,
        SUM(s.total_amount) AS total_revenue
    FROM sales s
    GROUP BY DATE_TRUNC('month', s.sale_date)
)
SELECT 
    sale_month,
    num_transactions,
    ROUND(total_revenue::NUMERIC, 2) AS total_revenue
FROM monthly_sales
WHERE num_transactions > 5
ORDER BY sale_month;


/*
Q8. CTE + ranking
Write a CTE that calculates total quantity sold per product. Then use 
ROW_NUMBER() on that CTE result to rank products from best-selling to 
least-selling. Show: rank, product_name, category, total_qty_sold.
*/

WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(si.quantity), 0) AS total_qty_sold
    FROM products p
    LEFT JOIN sale_items si ON p.product_id = si.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY total_qty_sold DESC) AS rank,
        product_name,
        category,
        total_qty_sold
    FROM product_sales
)
SELECT *
FROM ranked_products
ORDER BY rank;
