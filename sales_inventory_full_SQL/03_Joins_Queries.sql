-- =====================================================
-- SALES & INVENTORY DATABASE - JOINS SCRIPT
-- Questions 13-50: Various JOIN operations
-- =====================================================

-- Q13: Find customers who purchased products with price > 1000
SELECT DISTINCT c.customer_id, c.first_name, c.last_name, p.product_name, p.price
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE p.price > 1000;

-- Q14: Join Sales and Products - Show product name and total sales amount per product
SELECT 
    p.product_id,
    p.product_name,
    COUNT(s.sale_id) AS number_of_sales,
    SUM(s.total_amount) AS total_sales_amount
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales_amount DESC;

-- Q15: Join Customers and Sales - Find total amount spent by each customer
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.total_amount) AS total_spent
FROM assignment.customers c
LEFT JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Q16: Join Customers, Sales, and Products - Show customer name, product name, and quantity sold
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.product_name,
    s.quantity_sold,
    s.total_amount
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
ORDER BY c.customer_id;

-- Q17: Self-join on Customers table - Find pairs with same membership status
SELECT 
    c1.customer_id AS customer_1_id,
    c1.first_name AS customer_1_name,
    c2.customer_id AS customer_2_id,
    c2.first_name AS customer_2_name,
    c1.membership_status
FROM assignment.customers c1
INNER JOIN assignment.customers c2 
    ON c1.membership_status = c2.membership_status 
    AND c1.customer_id < c2.customer_id
ORDER BY c1.membership_status, c1.customer_id;

-- Q18: Join Sales and Products - Calculate total sales for each product
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(s.sale_id) AS total_sales_count,
    SUM(s.quantity_sold) AS total_quantity_sold,
    SUM(s.total_amount) AS total_revenue
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category;

-- Q19: Find products with stock quantity < 10
SELECT 
    product_id,
    product_name,
    category,
    stock_quantity,
    price
FROM assignment.products
WHERE stock_quantity < 10;

-- Q20: Join Sales and Products - Find products with total sales quantity > 5
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.quantity_sold) AS total_quantity_sold
FROM assignment.products p
INNER JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(s.quantity_sold) > 5;

-- Q21: Customers who purchased Electronics or Appliances
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    p.category,
    p.product_name
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE p.category IN ('Electronics', 'Appliances')
ORDER BY c.customer_id;

-- Q22: Calculate total sales amount per product grouped by product name
SELECT 
    p.product_name,
    p.category,
    COUNT(s.sale_id) AS number_of_transactions,
    SUM(s.total_amount) AS total_sales
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_name, p.category
ORDER BY total_sales DESC;

-- Q23: Join Sales with Customers - Customers who made purchases in 2023
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(s.sale_id) AS purchase_count
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Q24: Find customers with highest total sales in 2023
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.total_amount) AS total_sales_2023
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_sales_2023 DESC
LIMIT 5;

-- Q25: Join Products and Sales - Select the most expensive product sold
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    p.category,
    s.sale_date,
    s.quantity_sold,
    s.total_amount
FROM assignment.products p
INNER JOIN assignment.sales s ON p.product_id = s.product_id
ORDER BY p.price DESC
LIMIT 1;

-- Q26: Total number of customers who purchased products worth > 500
SELECT COUNT(DISTINCT c.customer_id) AS customer_count
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE p.price > 500;

-- Q27: Join Products, Sales, and Customers - Total sales by Gold membership customers
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.membership_status,
    COUNT(s.sale_id) AS total_sales_count,
    SUM(s.total_amount) AS total_revenue
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE c.membership_status = 'Gold'
GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_status;

-- Q28: Join Products and Inventory - Find products with low stock (< 10)
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    i.stock_quantity
FROM assignment.products p
INNER JOIN assignment.inventory i ON p.product_id = i.product_id
WHERE i.stock_quantity < 10;

-- Q29: Find customers who purchased more than 5 products total quantity
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.quantity_sold) AS total_quantity_purchased
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(s.quantity_sold) > 5;

-- Q30: Average quantity sold per product
SELECT 
    p.product_id,
    p.product_name,
    AVG(s.quantity_sold) AS average_quantity_sold,
    COUNT(s.sale_id) AS number_of_sales
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name;

-- Q31: Number of sales made in December 2023
SELECT 
    COUNT(s.sale_id) AS december_2023_sales_count,
    SUM(s.total_amount) AS december_2023_total_amount
FROM assignment.sales s
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023 
  AND EXTRACT(MONTH FROM s.sale_date) = 12;

-- Q32: Total amount spent by each customer in 2023 (descending order)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.total_amount) AS total_spent_2023
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent_2023 DESC;

-- Q33: Find products sold with less than 5 units left in stock
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity,
    p.price
FROM assignment.products p
INNER JOIN assignment.sales s ON p.product_id = s.product_id
WHERE p.stock_quantity < 5
GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity, p.price;

-- Q34: Total sales for each product ordered by highest sales
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(s.total_amount) AS total_sales
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_sales DESC NULLS LAST;

-- Q35: Customers who bought products within 7 days of registration
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.registration_date,
    s.sale_date,
    p.product_name,
    (s.sale_date - c.registration_date) AS days_after_registration
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE (s.sale_date - c.registration_date) BETWEEN 0 AND 7
ORDER BY c.customer_id;

-- Q36: Join Sales with Products - Products priced between 100 and 500
SELECT 
    s.sale_id,
    c.first_name,
    c.last_name,
    p.product_name,
    p.price,
    s.quantity_sold,
    s.total_amount,
    s.sale_date
FROM assignment.sales s
INNER JOIN assignment.products p ON s.product_id = p.product_id
INNER JOIN assignment.customers c ON s.customer_id = c.customer_id
WHERE p.price BETWEEN 100 AND 500;

-- Q37: Most frequent customer who made purchases
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(s.sale_id) AS purchase_frequency,
    SUM(s.total_amount) AS total_spent
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY purchase_frequency DESC
LIMIT 1;

-- Q38: Total quantity of products sold per customer
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(s.quantity_sold) AS total_quantity_sold,
    COUNT(s.sale_id) AS number_of_purchases
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_quantity_sold DESC;

-- Q39: Products with highest and lowest stock
(SELECT product_id, product_name, stock_quantity, 'Highest' AS stock_status
 FROM assignment.products
 ORDER BY stock_quantity DESC
 LIMIT 1)
UNION ALL
(SELECT product_id, product_name, stock_quantity, 'Lowest' AS stock_status
 FROM assignment.products
 ORDER BY stock_quantity ASC
 LIMIT 1);

-- Q40: Products containing 'Phone' with total sales
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    COUNT(s.sale_id) AS total_sales_count,
    SUM(s.quantity_sold) AS total_quantity,
    SUM(s.total_amount) AS total_revenue
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
WHERE LOWER(p.product_name) LIKE '%phone%'
GROUP BY p.product_id, p.product_name, p.price;

-- Q41: INNER JOIN Customers and Sales - Gold members with total sales and product names
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.membership_status,
    p.product_name,
    s.quantity_sold,
    s.total_amount,
    s.sale_date
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
INNER JOIN assignment.products p ON s.product_id = p.product_id
WHERE c.membership_status = 'Gold';

-- Q42: Total sales of products by category
SELECT 
    p.category,
    COUNT(s.sale_id) AS number_of_sales,
    SUM(s.quantity_sold) AS total_quantity,
    SUM(s.total_amount) AS total_revenue,
    AVG(p.price) AS average_price
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Q43: Total sales for each product grouped by month and year
SELECT 
    p.product_id,
    p.product_name,
    EXTRACT(YEAR FROM s.sale_date) AS sale_year,
    EXTRACT(MONTH FROM s.sale_date) AS sale_month,
    COUNT(s.sale_id) AS sale_count,
    SUM(s.quantity_sold) AS total_quantity,
    SUM(s.total_amount) AS monthly_revenue
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, EXTRACT(YEAR FROM s.sale_date), EXTRACT(MONTH FROM s.sale_date)
ORDER BY sale_year DESC, sale_month DESC;

-- Q44: Join Sales and Inventory - Products sold with stock remaining
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity AS current_stock,
    SUM(s.quantity_sold) AS total_sold,
    (p.stock_quantity - SUM(s.quantity_sold)) AS remaining_stock
FROM assignment.products p
INNER JOIN assignment.sales s ON p.product_id = s.product_id
INNER JOIN assignment.inventory i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.category, p.stock_quantity, i.stock_quantity;

-- Q45: Top 5 customers with highest purchases
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.membership_status,
    SUM(s.total_amount) AS total_purchases
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_status
ORDER BY total_purchases DESC
LIMIT 5;

-- Q46: Total number of unique products sold in 2023
SELECT 
    COUNT(DISTINCT p.product_id) AS unique_products_sold_2023
FROM assignment.products p
INNER JOIN assignment.sales s ON p.product_id = s.product_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023;

-- Q47: Find products not sold in the last 6 months
SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category,
    MAX(s.sale_date) AS last_sale_date
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
WHERE s.sale_date IS NULL 
   OR s.sale_date < (CURRENT_DATE - INTERVAL '6 months')
GROUP BY p.product_id, p.product_name, p.category;

-- Q48: Products priced 200-800 with total quantity sold
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    SUM(s.quantity_sold) AS total_quantity_sold,
    COUNT(s.sale_id) AS number_of_sales
FROM assignment.products p
LEFT JOIN assignment.sales s ON p.product_id = s.product_id
WHERE p.price BETWEEN 200 AND 800
GROUP BY p.product_id, p.product_name, p.category, p.price;

-- Q49: Customers who spent the most in 2023
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.membership_status,
    SUM(s.total_amount) AS total_spent
FROM assignment.customers c
INNER JOIN assignment.sales s ON c.customer_id = s.customer_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2023
GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_status
ORDER BY total_spent DESC;

-- Q50: Products sold more than 100 times with price > 200
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COUNT(s.sale_id) AS sales_count,
    SUM(s.quantity_sold) AS total_quantity_sold
FROM assignment.products p
INNER JOIN assignment.sales s ON p.product_id = s.product_id
WHERE p.price > 200
GROUP BY p.product_id, p.product_name, p.category, p.price
HAVING COUNT(s.sale_id) > 100;
