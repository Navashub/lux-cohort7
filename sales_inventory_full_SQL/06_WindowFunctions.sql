-- =====================================================
-- SALES & INVENTORY DATABASE - WINDOW FUNCTIONS SCRIPT
-- Questions 71-80: Window Functions
-- =====================================================

-- Q71: Rank customers based on total amount spent
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
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_spending
WHERE total_spent > 0
ORDER BY spending_rank;

-- Q72: Rank products based on total quantity sold
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(s.quantity_sold), 0) AS total_quantity
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT 
    product_id,
    product_name,
    category,
    total_quantity,
    RANK() OVER (ORDER BY total_quantity DESC) AS quantity_rank
FROM product_sales
WHERE total_quantity > 0
ORDER BY quantity_rank;

-- Q73: Identify the 3rd highest spending customer
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(s.total_amount), 0) AS total_spent,
        RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS spending_rank
    FROM assignment.customers c
    LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_id,
    first_name,
    last_name,
    total_spent,
    spending_rank
FROM customer_spending
WHERE spending_rank = 3;

-- Q74: Identify the 2nd most expensive product
WITH product_ranking AS (
    SELECT 
        product_id,
        product_name,
        category,
        price,
        RANK() OVER (ORDER BY price DESC) AS price_rank
    FROM assignment.products
)
SELECT 
    product_id,
    product_name,
    category,
    price,
    price_rank
FROM product_ranking
WHERE price_rank = 2;

-- Q75: Ranking of products within each category based on price
SELECT 
    product_id,
    product_name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank_in_category,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_dense_rank
FROM assignment.products
ORDER BY category, price_rank_in_category;

-- Q76: Ranking of customers based on number of purchases
WITH customer_purchases AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(s.sale_id) AS purchase_count
    FROM assignment.customers c
    LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_id,
    first_name,
    last_name,
    purchase_count,
    RANK() OVER (ORDER BY purchase_count DESC) AS purchase_rank
FROM customer_purchases
WHERE purchase_count > 0
ORDER BY purchase_rank;

-- Q77: Running total of sales amounts ordered by sale_date
SELECT 
    s.sale_id,
    c.first_name,
    c.last_name,
    p.product_name,
    s.sale_date,
    s.total_amount,
    SUM(s.total_amount) OVER (ORDER BY s.sale_date) AS running_total,
    SUM(s.total_amount) OVER (ORDER BY s.sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_total
FROM assignment.sales s
INNER JOIN assignment.customers c ON s.customer_id = c.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
ORDER BY s.sale_date;

-- Q78: Previous sale amount for each sale ordered by sale_date
SELECT 
    s.sale_id,
    c.first_name,
    c.last_name,
    p.product_name,
    s.sale_date,
    s.total_amount,
    LAG(s.total_amount) OVER (ORDER BY s.sale_date) AS previous_sale_amount,
    (s.total_amount - LAG(s.total_amount) OVER (ORDER BY s.sale_date)) AS difference_from_previous
FROM assignment.sales s
INNER JOIN assignment.customers c ON s.customer_id = c.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
ORDER BY s.sale_date;

-- Q79: Next sale amount for each sale ordered by sale_date
SELECT 
    s.sale_id,
    c.first_name,
    c.last_name,
    p.product_name,
    s.sale_date,
    s.total_amount,
    LEAD(s.total_amount) OVER (ORDER BY s.sale_date) AS next_sale_amount,
    (LEAD(s.total_amount) OVER (ORDER BY s.sale_date) - s.total_amount) AS difference_to_next
FROM assignment.sales s
INNER JOIN assignment.customers c ON s.customer_id = c.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
ORDER BY s.sale_date;

-- Q80: Divide customers into 4 groups (quartiles) based on total spending
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
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 1 THEN 'Top 25% Spenders'
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 2 THEN '25-50% Spenders'
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 3 THEN '50-75% Spenders'
        ELSE 'Bottom 25% Spenders'
    END AS spending_group
FROM customer_spending
WHERE total_spent > 0
ORDER BY spending_quartile, total_spent DESC;
