-- =====================================================
-- SALES & INVENTORY DATABASE - ADVANCED ANALYTICAL SCRIPT
-- Questions 81-139: Advanced Analytical & Additional Topics
-- =====================================================

-- =====================================================
-- ADVANCED ANALYTICAL QUESTIONS (81-100)
-- =====================================================

-- Q81: Which customers bought products in more than one category?
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT p.category) AS category_count
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY category_count DESC;

-- Q82: Customers who purchased within 7 days of registering
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.registration_date,
    p.product_name,
    s.sale_date,
    (s.sale_date - c.registration_date) AS days_to_first_purchase
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE (s.sale_date - c.registration_date) BETWEEN 0 AND 7
ORDER BY c.customer_id;

-- Q83: Products with lower stock remaining than average stock quantity
SELECT 
    product_id,
    product_name,
    category,
    stock_quantity,
    price,
    (SELECT AVG(stock_quantity) FROM assignment.products) AS avg_stock
FROM assignment.products
WHERE stock_quantity < (SELECT AVG(stock_quantity) FROM assignment.products)
ORDER BY stock_quantity;

-- Q84: Customers who purchased the same product more than once
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.product_name,
    COUNT(s.sale_id) AS purchase_frequency,
    SUM(s.quantity_sold) AS total_quantity_purchased
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name, p.product_name
HAVING COUNT(s.sale_id) > 1
ORDER BY c.customer_id, purchase_frequency DESC;

-- Q85: Product categories with highest total revenue
SELECT 
    p.category,
    SUM(s.total_amount) AS category_revenue,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    COUNT(s.sale_id) AS total_sales,
    SUM(s.quantity_sold) AS total_quantity,
    AVG(p.price) AS avg_product_price
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY category_revenue DESC NULLS LAST;

-- Q86: Top 3 most sold products
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    SUM(s.quantity_sold) AS total_quantity_sold,
    COUNT(s.sale_id) AS number_of_sales,
    SUM(s.total_amount) AS total_revenue
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY total_quantity_sold DESC NULLS LAST
LIMIT 3;

-- Q87: Customers who purchased the most expensive product
WITH most_expensive AS (
    SELECT product_id FROM assignment.products
    ORDER BY price DESC LIMIT 1
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.product_name,
    p.price,
    s.sale_date,
    s.quantity_sold
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE p.product_id = (SELECT product_id FROM most_expensive);

-- Q88: Products purchased by highest number of unique customers
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COUNT(DISTINCT s.customer_id) AS unique_customers,
    SUM(s.quantity_sold) AS total_quantity,
    COUNT(s.sale_id) AS total_sales
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY unique_customers DESC;

-- Q89: Customers who made purchases above average sale amount
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    s.sale_id,
    p.product_name,
    s.total_amount,
    (SELECT AVG(total_amount) FROM assignment.sales) AS avg_sale_amount
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE s.total_amount > (SELECT AVG(total_amount) FROM assignment.sales)
ORDER BY s.total_amount DESC;

-- Q90: Customers who purchased more products than average quantity per customer
WITH customer_qty AS (
    SELECT 
        customer_id,
        SUM(quantity_sold) AS total_qty
    FROM assignment.sales
    GROUP BY customer_id
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    cq.total_qty,
    (SELECT AVG(total_qty) FROM customer_qty) AS avg_qty_per_customer
FROM assignment.customers c
INNER JOIN customer_qty cq ON c.customer_id = cq.customer_id
WHERE cq.total_qty > (SELECT AVG(total_qty) FROM customer_qty)
ORDER BY cq.total_qty DESC;

-- =====================================================
-- ADVANCED WINDOW + ANALYTICAL PROBLEMS (91-100)
-- =====================================================

-- Q91: Customers ranking in top 10% of spending
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(s.total_amount), 0) AS total_spent,
        PERCENT_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS spending_percentile
    FROM assignment.customers c
    LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_id,
    first_name,
    last_name,
    total_spent,
    ROUND(spending_percentile::numeric * 100, 2) AS percentile_rank
FROM customer_spending
WHERE spending_percentile <= 0.10 AND total_spent > 0
ORDER BY total_spent DESC;

-- Q92: Products contributing to top 50% of total revenue
WITH product_revenue AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(SUM(s.total_amount), 0) AS product_revenue,
        SUM(SUM(s.total_amount)) OVER () AS total_revenue,
        SUM(SUM(s.total_amount)) OVER (ORDER BY SUM(s.total_amount) DESC) AS cumulative_revenue,
        ROUND((SUM(SUM(s.total_amount)) OVER (ORDER BY SUM(s.total_amount) DESC) / SUM(SUM(s.total_amount)) OVER ())::numeric * 100, 2) AS revenue_cumulative_pct
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT 
    product_id,
    product_name,
    category,
    product_revenue,
    revenue_cumulative_pct
FROM product_revenue
WHERE revenue_cumulative_pct <= 50 OR product_revenue = 0
ORDER BY product_revenue DESC;

-- Q93: Customers who made purchases in consecutive months
SELECT 
    s1.customer_id,
    c.first_name,
    c.last_name,
    EXTRACT(YEAR FROM s1.sale_date)::INT AS year_1,
    EXTRACT(MONTH FROM s1.sale_date)::INT AS month_1,
    EXTRACT(YEAR FROM s2.sale_date)::INT AS year_2,
    EXTRACT(MONTH FROM s2.sale_date)::INT AS month_2
FROM assignment.sales s1
INNER JOIN assignment.sales s2 ON s1.customer_id = s2.customer_id
INNER JOIN assignment.customers c ON s1.customer_id = c.customer_id
WHERE (EXTRACT(YEAR FROM s1.sale_date) * 12 + EXTRACT(MONTH FROM s1.sale_date)) + 1 
    = (EXTRACT(YEAR FROM s2.sale_date) * 12 + EXTRACT(MONTH FROM s2.sale_date))
ORDER BY s1.customer_id;

-- Q94: Products with largest difference between stock quantity and total quantity sold
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity,
    COALESCE(SUM(s.quantity_sold), 0) AS total_quantity_sold,
    (p.stock_quantity - COALESCE(SUM(s.quantity_sold), 0)) AS stock_difference
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity
ORDER BY stock_difference DESC;

-- Q95: Customers with spending above their membership tier average
WITH tier_spending AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.membership_status,
        COALESCE(SUM(s.total_amount), 0) AS total_spent,
        AVG(SUM(s.total_amount)) OVER (PARTITION BY c.membership_status) AS tier_avg_spending
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
    tier_avg_spending,
    (total_spent - tier_avg_spending) AS above_tier_avg
FROM tier_spending
WHERE total_spent > tier_avg_spending
ORDER BY membership_status, total_spent DESC;

-- Q96: Products with higher sales than average within their category
WITH category_avg AS (
    SELECT 
        p.category,
        p.product_id,
        p.product_name,
        COALESCE(SUM(s.total_amount), 0) AS product_sales,
        AVG(SUM(s.total_amount)) OVER (PARTITION BY p.category) AS category_avg_sales
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT 
    category,
    product_id,
    product_name,
    product_sales,
    category_avg_sales
FROM category_avg
WHERE product_sales > category_avg_sales
ORDER BY category, product_sales DESC;

-- Q97: Customer with largest single purchase relative to their total spending
WITH customer_purchases AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        MAX(s.total_amount) AS largest_purchase,
        SUM(s.total_amount) AS total_spent,
        ROUND((MAX(s.total_amount) / SUM(s.total_amount) * 100)::numeric, 2) AS pct_of_total
    FROM assignment.customers c
    INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_id,
    first_name,
    last_name,
    largest_purchase,
    total_spent,
    pct_of_total
FROM customer_purchases
ORDER BY pct_of_total DESC;

-- Q98: Top 3 most sold products within each category
WITH ranked_products AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        SUM(s.quantity_sold) AS total_quantity,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(s.quantity_sold) DESC) AS category_rank
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT 
    product_id,
    product_name,
    category,
    total_quantity,
    category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY category, category_rank;

-- Q99: Customers tied for highest total spending
WITH customer_spending_ranked AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(s.total_amount), 0) AS total_spent,
        DENSE_RANK() OVER (ORDER BY SUM(s.total_amount) DESC) AS spending_rank
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
FROM customer_spending_ranked
WHERE spending_rank = 1;

-- Q100: Products generating sales every year present in dataset
WITH product_years AS (
    SELECT 
        p.product_id,
        p.product_name,
        COUNT(DISTINCT EXTRACT(YEAR FROM s.sale_date)::INT) AS years_with_sales
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name
),
total_years AS (
    SELECT COUNT(DISTINCT EXTRACT(YEAR FROM sale_date)::INT) AS total_distinct_years
    FROM assignment.sales
)
SELECT 
    py.product_id,
    py.product_name,
    py.years_with_sales,
    ty.total_distinct_years
FROM product_years py
CROSS JOIN total_years ty
WHERE py.years_with_sales = ty.total_distinct_years
ORDER BY py.product_id;

-- =====================================================
-- CASE WHEN & DATE FUNCTIONS (101-110)
-- =====================================================

-- Q101: Assign price_category to products
SELECT 
    product_id,
    product_name,
    category,
    price,
    CASE 
        WHEN price > 1000 THEN 'Expensive'
        WHEN price BETWEEN 500 AND 1000 THEN 'Moderate'
        ELSE 'Affordable'
    END AS price_category
FROM assignment.products
ORDER BY price DESC;

-- Q102: Assign customer_level based on total spending
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(SUM(s.total_amount), 0) AS total_spent,
    CASE 
        WHEN COALESCE(SUM(s.total_amount), 0) > 2000 THEN 'VIP'
        WHEN COALESCE(SUM(s.total_amount), 0) BETWEEN 1000 AND 2000 THEN 'Regular'
        ELSE 'New'
    END AS customer_level
FROM assignment.customers c
LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Q103: Assign stock_status to products
SELECT 
    product_id,
    product_name,
    stock_quantity,
    CASE 
        WHEN stock_quantity < 10 THEN 'Low Stock'
        ELSE 'Sufficient Stock'
    END AS stock_status
FROM assignment.products
ORDER BY stock_quantity;

-- Q104: Extract registration year from customers
SELECT 
    customer_id,
    first_name,
    last_name,
    registration_date,
    EXTRACT(YEAR FROM registration_date) AS registration_year
FROM assignment.customers
ORDER BY registration_year, registration_date;

-- Q105: Count customers registered in each year
SELECT 
    EXTRACT(YEAR FROM registration_date)::INT AS registration_year,
    COUNT(*) AS customer_count
FROM assignment.customers
GROUP BY EXTRACT(YEAR FROM registration_date)
ORDER BY registration_year;

-- Q106: Total sales amount for each month
SELECT 
    EXTRACT(YEAR FROM sale_date)::INT AS year,
    EXTRACT(MONTH FROM sale_date)::INT AS month,
    TO_CHAR(sale_date, 'Month') AS month_name,
    COUNT(sale_id) AS sale_count,
    SUM(total_amount) AS monthly_total
FROM assignment.sales
GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date), TO_CHAR(sale_date, 'Month')
ORDER BY year DESC, month DESC;

-- Q107: Show all sales made in 2023
SELECT 
    s.sale_id,
    c.first_name,
    c.last_name,
    p.product_name,
    s.quantity_sold,
    s.total_amount,
    s.sale_date
FROM assignment.sales s
INNER JOIN assignment.customers c ON s.customer_id = c.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
ORDER BY s.sale_date;

-- Q108: Total sales amount for each year
SELECT 
    EXTRACT(YEAR FROM sale_date)::INT AS year,
    COUNT(sale_id) AS sale_count,
    SUM(quantity_sold) AS total_quantity,
    SUM(total_amount) AS yearly_total
FROM assignment.sales
GROUP BY EXTRACT(YEAR FROM sale_date)
ORDER BY year DESC;

-- Q109: Number of days each customer registered (from registration to current date)
SELECT 
    customer_id,
    first_name,
    last_name,
    registration_date,
    CURRENT_DATE,
    (CURRENT_DATE - registration_date) AS days_registered
FROM assignment.customers
ORDER BY days_registered DESC;

-- Q110: Extract year and month from sale date
SELECT 
    sale_id,
    customer_id,
    product_id,
    sale_date,
    EXTRACT(YEAR FROM sale_date)::INT AS sale_year,
    EXTRACT(MONTH FROM sale_date)::INT AS sale_month,
    TO_CHAR(sale_date, 'YYYY-MM') AS year_month
FROM assignment.sales
ORDER BY sale_date DESC;

-- =====================================================
-- NULL HANDLING & DATA QUALITY (111-115)
-- =====================================================

-- Q111: Replace null email values with default text
SELECT 
    customer_id,
    first_name,
    last_name,
    COALESCE(email, 'No Email Provided') AS email,
    phone_number
FROM assignment.customers
ORDER BY customer_id;

-- Q112: Find customers without email
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    phone_number
FROM assignment.customers
WHERE email IS NULL
ORDER BY customer_id;

-- Q113: Find products never sold (subquery)
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

-- Q114: Find customers with no purchases (subquery)
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    membership_status,
    registration_date
FROM assignment.customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM assignment.sales
)
ORDER BY customer_id;

-- Q115: Assign price_category (Premium, Standard, Budget)
SELECT 
    product_id,
    product_name,
    price,
    CASE 
        WHEN price > 1000 THEN 'Premium'
        WHEN price BETWEEN 200 AND 1000 THEN 'Standard'
        ELSE 'Budget'
    END AS price_category
FROM assignment.products
ORDER BY price DESC;

-- =====================================================
-- FUNCTIONS & STORED PROCEDURES (116-122)
-- =====================================================

-- Q116: Create function to get products exceeding revenue threshold
CREATE OR REPLACE FUNCTION get_products_by_revenue(p_min_revenue DECIMAL)
RETURNS TABLE(
    product_id INT,
    product_name VARCHAR,
    total_revenue DECIMAL,
    sales_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.product_id,
        p.product_name,
        COALESCE(SUM(s.total_amount), 0)::DECIMAL AS total_revenue,
        COUNT(s.sale_id) AS sales_count
    FROM assignment.products p
    LEFT JOIN assignment.sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name
    HAVING COALESCE(SUM(s.total_amount), 0) > p_min_revenue
    ORDER BY total_revenue DESC;
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT * FROM get_products_by_revenue(1000);

-- Q117: Create function to get customer total spending
CREATE OR REPLACE FUNCTION get_customer_total_spent(p_customer_id INT)
RETURNS DECIMAL AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(total_amount), 0)
    INTO v_total
    FROM assignment.sales
    WHERE customer_id = p_customer_id;
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT get_customer_total_spent(1);

-- Q118: Create function for sales within date range
CREATE OR REPLACE FUNCTION get_orders_between_dates(p_start_date DATE, p_end_date DATE)
RETURNS TABLE(
    sale_id INT,
    customer_name VARCHAR,
    product_name VARCHAR,
    sale_date DATE,
    total_amount DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.sale_id,
        (c.first_name || ' ' || c.last_name)::VARCHAR,
        p.product_name,
        s.sale_date,
        s.total_amount
    FROM assignment.sales s
    INNER JOIN assignment.customers c ON s.customer_id = c.customer_id
    INNER JOIN assignment.products p ON s.product_id = p.product_id
    WHERE s.sale_date BETWEEN p_start_date AND p_end_date
    ORDER BY s.sale_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT * FROM get_orders_between_dates('2023-01-01', '2023-12-31');

-- Q119: Create procedure to insert new sale
CREATE OR REPLACE PROCEDURE insert_new_sale(
    p_sale_id INT,
    p_customer_id INT,
    p_product_id INT,
    p_quantity_sold INT,
    p_sale_date DATE,
    p_total_amount DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO assignment.sales (sale_id, customer_id, product_id, quantity_sold, sale_date, total_amount)
    VALUES (p_sale_id, p_customer_id, p_product_id, p_quantity_sold, p_sale_date, p_total_amount);
    COMMIT;
    RAISE NOTICE 'Sale inserted successfully: Sale ID %', p_sale_id;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error inserting sale: %', SQLERRM;
    ROLLBACK;
END;
$$;

-- Usage: CALL insert_new_sale(16, 25, 3, 2, '2024-03-15', 999.98);

-- =====================================================
-- INDEXES (120-121)
-- =====================================================

-- Q120: Create index on product_id in sales table
CREATE INDEX IF NOT EXISTS idx_sales_product_id ON assignment.sales(product_id);

-- Q121: Create index on registration_date in customers table
CREATE INDEX IF NOT EXISTS idx_customers_registration_date ON assignment.customers(registration_date);

-- =====================================================
-- TRANSACTIONS (122-123)
-- =====================================================

-- Q122: Transaction to insert sale and update stock
BEGIN TRANSACTION;

INSERT INTO assignment.sales (sale_id, customer_id, product_id, quantity_sold, sale_date, total_amount)
VALUES (16, 25, 3, 2, '2024-03-15', 999.98);

UPDATE assignment.products
SET stock_quantity = stock_quantity - 2
WHERE product_id = 3;

COMMIT;

-- Q123: Transaction with rollback for invalid email
BEGIN TRANSACTION;

UPDATE assignment.customers
SET email = 'invalid-email-without-at'
WHERE customer_id = 1;

-- Check if email is valid (contains @)
IF NOT EXISTS (SELECT 1 FROM assignment.customers WHERE customer_id = 1 AND email LIKE '%@%') THEN
    ROLLBACK;
    RAISE NOTICE 'Invalid email format. Transaction rolled back.';
ELSE
    COMMIT;
    RAISE NOTICE 'Email updated successfully.';
END IF;

-- =====================================================
-- VIEWS (124-125)
-- =====================================================

-- Q124: Create view for total revenue per product
CREATE OR REPLACE VIEW vw_product_revenue AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COALESCE(SUM(s.total_amount), 0) AS total_revenue,
    COALESCE(COUNT(s.sale_id), 0) AS sales_count,
    COALESCE(SUM(s.quantity_sold), 0) AS total_quantity_sold
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price;

-- Usage: SELECT * FROM vw_product_revenue ORDER BY total_revenue DESC;

-- Q125: Create view for customer total spending
CREATE OR REPLACE VIEW vw_customer_spending AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.membership_status,
    c.email,
    COALESCE(SUM(s.total_amount), 0) AS total_spending,
    COALESCE(COUNT(s.sale_id), 0) AS number_of_purchases
FROM assignment.customers c
LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_status, c.email;

-- Usage: SELECT * FROM vw_customer_spending ORDER BY total_spending DESC;

-- =====================================================
-- SET OPERATIONS (126-129)
-- =====================================================

-- Q126: UNION to combine customer first names and product names
SELECT first_name AS name, 'Customer' AS type
FROM assignment.customers
UNION
SELECT product_name, 'Product'
FROM assignment.products
ORDER BY name;

-- Q127: INTERSECT to find customers who made purchases
SELECT customer_id FROM assignment.customers
INTERSECT
SELECT customer_id FROM assignment.sales
ORDER BY customer_id;

-- Q128: Anti-join to find products never sold
SELECT p.*
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
WHERE s.sale_id IS NULL;

-- Q129: NOT EXISTS to find customers with no purchases
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM assignment.customers c
WHERE NOT EXISTS (
    SELECT 1 FROM assignment.sales s WHERE s.customer_id = c.customer_id
);

-- =====================================================
-- TYPE CASTING & FORMATTING (130-139)
-- =====================================================

-- Q130: Cast price to integer
SELECT 
    product_id,
    product_name,
    price::DECIMAL(10,2) AS original_price,
    price::INT AS price_as_integer,
    CAST(price AS INT) AS price_casted
FROM assignment.products
ORDER BY price DESC;

-- Q131: Convert registration_date to YYYY-MM format
SELECT 
    customer_id,
    first_name,
    last_name,
    registration_date,
    TO_CHAR(registration_date, 'YYYY-MM') AS registration_month
FROM assignment.customers
ORDER BY registration_date;

-- Q132: FIX - Proper GROUP BY usage
SELECT 
    s.product_id,
    p.product_name,
    SUM(s.total_amount) AS total_sales
FROM assignment.sales s
INNER JOIN assignment.products p ON s.product_id = p.product_id
GROUP BY s.product_id, p.product_name;

-- Q133: FIX - Use HAVING instead of WHERE for aggregates
SELECT 
    product_id,
    SUM(total_amount) AS total_sales
FROM assignment.sales
GROUP BY product_id
HAVING SUM(total_amount) > 1000;

-- Q134: FIX - Correct join condition
SELECT 
    s.*,
    p.product_name,
    p.price
FROM assignment.sales s
INNER JOIN assignment.products p ON s.product_id = p.product_id;

-- Q135: Replace NULL emails using COALESCE
SELECT 
    customer_id,
    first_name,
    last_name,
    COALESCE(email, 'No Email Provided') AS email
FROM assignment.customers;

-- Q136: Trim leading/trailing spaces from first names
SELECT 
    customer_id,
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name,
    email
FROM assignment.customers;

-- Q137: Convert emails to lowercase
SELECT 
    customer_id,
    first_name,
    last_name,
    LOWER(email) AS email_lowercase
FROM assignment.customers;

-- Q138: Replace empty strings in phone numbers with NULL
SELECT 
    customer_id,
    NULLIF(phone_number, '') AS phone_number
FROM assignment.customers;

-- Q139: Extract year from registration_date with NULL handling
SELECT 
    customer_id,
    first_name,
    COALESCE(EXTRACT(YEAR FROM registration_date), 0)::INT AS registration_year
FROM assignment.customers
ORDER BY registration_year;
