/*
==============================================================================
NAIROBI BIZ SQL - JOINS QUESTIONS & SOLUTIONS
==============================================================================
This file contains 10 JOIN exercises covering INNER JOIN, LEFT JOIN, 
RIGHT JOIN, SELF JOIN, and multi-table joins in PostgreSQL.

Each question is clearly commented with the requirement.
The PostgreSQL solution query appears directly below each question.
==============================================================================
*/

SET search_path TO nairobi_biz;


/*
Q1. Basic INNER JOIN
List all sales showing: sale_id, sale_date, customer full_name, and total_amount. 
Order by sale_date ascending.
*/

SELECT 
    s.sale_id,
    s.sale_date,
    c.full_name,
    s.total_amount
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
ORDER BY s.sale_date ASC;


/*
Q2. Three-table JOIN
Show every sale with: sale_id, customer full_name, employee full name (first + last), 
shop name, and total_amount. Order by total_amount descending.
*/

SELECT 
    s.sale_id,
    c.full_name AS customer_name,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    sh.shop_name,
    s.total_amount
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
INNER JOIN employees e ON s.employee_id = e.employee_id
INNER JOIN shops sh ON s.shop_id = sh.shop_id
ORDER BY s.total_amount DESC;


/*
Q3. LEFT JOIN — find missing links
List all customers and how many purchases they have made. Include customers 
who have never made a purchase (show 0 for them). 
Show: customer full_name, city, loyalty_tier, purchase_count.
*/

SELECT 
    c.full_name,
    c.city,
    c.loyalty_tier,
    COUNT(s.sale_id) AS purchase_count
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.full_name, c.city, c.loyalty_tier
ORDER BY c.full_name;


/*
Q4. LEFT JOIN + IS NULL — find non-buyers
Find all customers who have NEVER made a purchase. 
Show only their names and the city they are from.
*/

SELECT 
    c.full_name,
    c.city
FROM customers c
LEFT JOIN sales s ON c.customer_id = s.customer_id
WHERE s.sale_id IS NULL
ORDER BY c.full_name;


/*
Q5. Self JOIN — employee and manager
Show a list of every employee with their manager's name. Include employees who 
have no manager (show 'No Manager' for those). 
Columns: employee_name, job_title, manager_name.
Hint: Use COALESCE to replace NULL manager names with 'No Manager'.
*/

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.job_title,
    COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'No Manager') AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;


/*
Q6. JOIN with filter
Show all sales made via M-Pesa, with the customer's name, shop name, sale date, 
and amount. Order by sale_date.
*/

SELECT 
    s.sale_id,
    c.full_name AS customer_name,
    sh.shop_name,
    s.sale_date,
    s.total_amount
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
INNER JOIN shops sh ON s.shop_id = sh.shop_id
WHERE s.payment_method = 'M-Pesa'
ORDER BY s.sale_date;


/*
Q7. JOIN across four tables
List all sale items showing: sale_id, sale_date, customer full_name, 
product name, quantity, and line_total. Order by sale_date, then line_total descending.
*/

SELECT 
    s.sale_id,
    s.sale_date,
    c.full_name AS customer_name,
    p.product_name,
    si.quantity,
    si.line_total
FROM sale_items si
INNER JOIN sales s ON si.sale_id = s.sale_id
INNER JOIN customers c ON s.customer_id = c.customer_id
INNER JOIN products p ON si.product_id = p.product_id
ORDER BY s.sale_date, si.line_total DESC;


/*
Q8. JOIN with aggregation
For each shop, show: shop_name, category, number of employees, and average 
employee salary (round to 2 decimal places). Include shops that have no employees. 
Order by average salary descending.
*/

SELECT 
    sh.shop_name,
    sh.category,
    COUNT(e.employee_id) AS num_employees,
    ROUND(AVG(e.salary)::NUMERIC, 2) AS avg_salary
FROM shops sh
LEFT JOIN employees e ON sh.shop_id = e.shop_id
GROUP BY sh.shop_id, sh.shop_name, sh.category
ORDER BY avg_salary DESC NULLS LAST;


/*
Q9. JOIN with date filter
Show all deliveries received in January 2024. Include: supplier_name, product_name, 
shop_name, delivery_date, qty_delivered, cost_per_unit, and total delivery cost 
(qty_delivered × cost_per_unit).
*/

SELECT 
    sd.supplier_name,
    p.product_name,
    sh.shop_name,
    sd.delivery_date,
    sd.qty_delivered,
    sd.cost_per_unit,
    (sd.qty_delivered * sd.cost_per_unit) AS total_delivery_cost
FROM supplier_deliveries sd
INNER JOIN products p ON sd.product_id = p.product_id
INNER JOIN shops sh ON sd.shop_id = sh.shop_id
WHERE EXTRACT(YEAR FROM sd.delivery_date) = 2024 
  AND EXTRACT(MONTH FROM sd.delivery_date) = 1
ORDER BY sd.delivery_date;


/*
Q10. Challenge JOIN
Show each product's full sales history: product_name, shop_name (where it's sold from), 
sale_date, customer name, quantity sold, and line_total. For products that have never 
been sold, still show them with NULL for sale columns. Order by product_name, sale_date
*/

SELECT 
    p.product_name,
    sh.shop_name,
    s.sale_date,
    c.full_name AS customer_name,
    si.quantity,
    si.line_total
FROM products p
LEFT JOIN shops sh ON p.shop_id = sh.shop_id
LEFT JOIN sale_items si ON p.product_id = si.product_id
LEFT JOIN sales s ON si.sale_id = s.sale_id
LEFT JOIN customers c ON s.customer_id = c.customer_id
ORDER BY p.product_name, s.sale_date NULLS LAST;
