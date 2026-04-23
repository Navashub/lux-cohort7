-- =====================================================
-- SALES & INVENTORY DATABASE - SUBQUERIES SCRIPT
-- Questions 51-60: Using Subqueries
-- =====================================================

-- Q51: Which customers have spent more than the average spending of all customers?
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.total_amount) AS total_spent
FROM assignment.customers c
LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(s.total_amount) > (
    SELECT AVG(customer_spending) 
    FROM (
        SELECT SUM(total_amount) AS customer_spending
        FROM assignment.sales
        GROUP BY customer_id
    ) AS avg_spending
)
ORDER BY total_spent DESC;

-- Q52: Which products are priced higher than the average price of all products?
SELECT 
    product_id,
    product_name,
    category,
    price
FROM assignment.products
WHERE price > (
    SELECT AVG(price) FROM assignment.products
)
ORDER BY price DESC;

-- Q53: Which customers have never made a purchase?
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    membership_status
FROM assignment.customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM assignment.sales
)
ORDER BY customer_id;

-- Q54: Which products have never been sold?
SELECT 
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM assignment.products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM assignment.sales
)
ORDER BY product_id;

-- Q55: Which customer made the single most expensive purchase?
SELECT 
    s.sale_id,
    c.customer_id,
    c.first_name,
    c.last_name,
    p.product_name,
    s.total_amount,
    s.sale_date
FROM assignment.sales s
INNER JOIN assignment.customers c ON s.customer_id = c.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE s.total_amount = (
    SELECT MAX(total_amount) FROM assignment.sales
);

-- Q56: Which products have total sales greater than the average total sales across all products?
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(s.total_amount) AS product_total_sales
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING SUM(s.total_amount) > (
    SELECT AVG(product_sales)
    FROM (
        SELECT SUM(total_amount) AS product_sales
        FROM assignment.sales
        GROUP BY product_id
    ) AS sales_by_product
)
ORDER BY product_total_sales DESC;

-- Q57: Which customers registered earlier than the average registration date?
SELECT 
    customer_id,
    first_name,
    last_name,
    registration_date,
    membership_status,
    email
FROM assignment.customers
WHERE registration_date < (
    SELECT TO_TIMESTAMP(AVG(EXTRACT(EPOCH FROM registration_date)))::DATE 
    FROM assignment.customers
)
ORDER BY registration_date ASC;

-- Q58: Which products have a price higher than the average price within their own category?
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM assignment.products p
WHERE p.price > (
    SELECT AVG(price)
    FROM assignment.products
    WHERE category = p.category
)
ORDER BY p.category, p.price DESC;

-- Q59: Which customers have spent more than the customer with ID = 10?
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.total_amount) AS total_spent
FROM assignment.customers c
LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(s.total_amount) > (
    SELECT SUM(total_amount)
    FROM assignment.sales
    WHERE customer_id = 10
)
ORDER BY total_spent DESC;

-- Q60: Which products have total quantity sold greater than the overall average quantity sold?
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(s.quantity_sold) AS total_quantity_sold
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category
HAVING SUM(s.quantity_sold) > (
    SELECT AVG(total_qty)
    FROM (
        SELECT SUM(quantity_sold) AS total_qty
        FROM assignment.sales
        GROUP BY product_id
    ) AS qty_by_product
)
ORDER BY total_quantity_sold DESC;
