-- =====================================================
-- SALES & INVENTORY DATABASE - CTEs SCRIPT
-- Questions 61-70: Common Table Expressions
-- =====================================================

-- Q61: Top 5 highest spending customers using CTE
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.membership_status,
        COALESCE(SUM(s.total_amount), 0) AS total_spent
    FROM assignment.customers c
    LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_status
)
SELECT 
    customer_id,
    first_name,
    last_name,
    membership_status,
    total_spent
FROM customer_spending
WHERE total_spent > 0
ORDER BY total_spent DESC
LIMIT 5;

-- Q62: Top 3 most sold products using CTE
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        SUM(s.quantity_sold) AS total_quantity_sold
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.price
)
SELECT 
    product_id,
    product_name,
    category,
    price,
    total_quantity_sold
FROM product_sales
WHERE total_quantity_sold IS NOT NULL
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q63: Category with highest revenue using CTE
WITH category_revenue AS (
    SELECT 
        p.category,
        SUM(s.total_amount) AS total_revenue,
        COUNT(s.sale_id) AS number_of_sales
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.category
)
SELECT 
    category,
    total_revenue,
    number_of_sales
FROM category_revenue
ORDER BY total_revenue DESC NULLS LAST
LIMIT 1;

-- Q64: Customers who purchased more than twice using CTE
WITH customer_purchase_count AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        COUNT(s.sale_id) AS purchase_count
    FROM assignment.customers c
    LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email
)
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    purchase_count
FROM customer_purchase_count
WHERE purchase_count > 2
ORDER BY purchase_count DESC;

-- Q65: Products sold more than average quantity using CTE
WITH product_quantity AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        SUM(s.quantity_sold) AS total_quantity_sold
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
average_quantity AS (
    SELECT AVG(total_quantity_sold) AS avg_qty
    FROM product_quantity
)
SELECT 
    pq.product_id,
    pq.product_name,
    pq.category,
    pq.total_quantity_sold,
    aq.avg_qty,
    (pq.total_quantity_sold - aq.avg_qty) AS above_average
FROM product_quantity pq
CROSS JOIN average_quantity aq
WHERE pq.total_quantity_sold > aq.avg_qty
ORDER BY pq.total_quantity_sold DESC;

-- Q66: Customers who spent more than average using CTE
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.membership_status,
        COALESCE(SUM(s.total_amount), 0) AS total_spent
    FROM assignment.customers c
    LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_status
),
average_spending AS (
    SELECT AVG(total_spent) AS avg_spent
    FROM customer_spending
    WHERE total_spent > 0
)
SELECT 
    cs.customer_id,
    cs.first_name,
    cs.last_name,
    cs.membership_status,
    cs.total_spent,
    av.avg_spent
FROM customer_spending cs
CROSS JOIN average_spending av
WHERE cs.total_spent > av.avg_spent
ORDER BY cs.total_spent DESC;

-- Q67: Products ordered by revenue (highest to lowest) using CTE
WITH product_revenue AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        p.supplier,
        COALESCE(SUM(s.total_amount), 0) AS total_revenue,
        COALESCE(SUM(s.quantity_sold), 0) AS total_quantity
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.price, p.supplier
)
SELECT 
    product_id,
    product_name,
    category,
    price,
    supplier,
    total_revenue,
    total_quantity
FROM product_revenue
ORDER BY total_revenue DESC;

-- Q68: Month with highest revenue using CTE
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM s.sale_date) AS sale_year,
        EXTRACT(MONTH FROM s.sale_date) AS sale_month,
        SUM(s.total_amount) AS monthly_revenue,
        COUNT(s.sale_id) AS number_of_sales,
        SUM(s.quantity_sold) AS total_quantity
    FROM assignment.sales s
    GROUP BY EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
)
SELECT 
    sale_year,
    sale_month,
    TO_CHAR(DATE '2000-01-01' + (sale_month - 1) * INTERVAL '1 month', 'Month') AS month_name,
    monthly_revenue,
    number_of_sales,
    total_quantity
FROM monthly_sales
ORDER BY monthly_revenue DESC
LIMIT 1;

-- Q69: Products purchased by more than 3 unique customers using CTE
WITH product_customer_count AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        COUNT(DISTINCT s.customer_id) AS unique_customers,
        COUNT(s.sale_id) AS total_sales,
        SUM(s.quantity_sold) AS total_quantity
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT 
    product_id,
    product_name,
    category,
    unique_customers,
    total_sales,
    total_quantity
FROM product_customer_count
WHERE unique_customers > 3
ORDER BY unique_customers DESC;

-- Q70: Products sold less than average quantity using CTE
WITH product_quantity AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        COALESCE(SUM(s.quantity_sold), 0) AS total_quantity_sold
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category, p.price
),
average_quantity AS (
    SELECT AVG(total_quantity_sold) AS avg_qty
    FROM product_quantity
    WHERE total_quantity_sold > 0
)
SELECT 
    pq.product_id,
    pq.product_name,
    pq.category,
    pq.price,
    pq.total_quantity_sold,
    aq.avg_qty
FROM product_quantity pq
CROSS JOIN average_quantity aq
WHERE pq.total_quantity_sold < aq.avg_qty 
  AND pq.total_quantity_sold > 0
ORDER BY pq.total_quantity_sold;
