/*
==============================================================================
NAIROBI BIZ SQL - SUBQUERIES QUESTIONS & SOLUTIONS
==============================================================================
This file contains 10 Subquery exercises covering:
- Scalar subqueries in SELECT and WHERE clauses
- List subqueries with IN and NOT IN
- FROM subqueries (derived tables)
- Correlated subqueries
- EXISTS and NOT EXISTS

Each question is clearly commented with the requirement.
The PostgreSQL solution query appears directly below each question.
==============================================================================
*/

SET search_path TO nairobi_biz;


/*
Q1. Scalar subquery - compare to average
Find all employees whose salary is above the average salary of all employees. 
Show: full name, job_title, salary, and the average salary as a column next to each row.
*/

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.job_title,
    e.salary,
    (SELECT AVG(salary) FROM employees) AS avg_salary
FROM employees e
WHERE e.salary > (SELECT AVG(salary) FROM employees)
ORDER BY e.salary DESC;


/*
Q2. Scalar subquery in SELECT
Show each sale_id, total_amount, and a column called 'vs_average' that shows 
how much the sale is above or below the average sale amount 
(positive = above, negative = below). Round to 2 decimal places.
*/

SELECT 
    s.sale_id,
    s.total_amount,
    ROUND((s.total_amount - (SELECT AVG(total_amount) FROM sales))::NUMERIC, 2) AS vs_average
FROM sales s
ORDER BY s.sale_id;


/*
Q3. List subquery with IN
Find all employees who work in Electronics shops. Use a subquery to get 
the shop IDs first, then use IN to filter employees. 
Show: full name, job_title, salary.
*/

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.job_title,
    e.salary
FROM employees e
WHERE e.shop_id IN (
    SELECT shop_id 
    FROM shops 
    WHERE category = 'Electronics'
)
ORDER BY e.salary DESC;


/*
Q4. List subquery with NOT IN
Find all products that have NEVER been sold. Use NOT IN with a subquery on sale_items. 
Show: product_name, category, unit_price, stock_qty.
*/

SELECT 
    p.product_name,
    p.category,
    p.unit_price,
    p.stock_qty
FROM products p
WHERE p.product_id NOT IN (
    SELECT DISTINCT product_id 
    FROM sale_items
)
ORDER BY p.product_name;


/*
Q5. FROM subquery
Using a subquery in the FROM clause, first calculate total revenue per shop. 
Then from that result, show only shops with total revenue above KES 50,000.
*/

SELECT 
    shop_name,
    total_revenue
FROM (
    SELECT 
        sh.shop_id,
        sh.shop_name,
        SUM(s.total_amount) AS total_revenue
    FROM shops sh
    LEFT JOIN sales s ON sh.shop_id = s.shop_id
    GROUP BY sh.shop_id, sh.shop_name
) AS shop_revenue
WHERE total_revenue > 50000
ORDER BY total_revenue DESC;


/*
Q6. Subquery with MAX
Find the customer who has spent the most in total across all their sales. 
Show their full_name, city, loyalty_tier, and total amount spent.
*/

SELECT 
    c.full_name,
    c.city,
    c.loyalty_tier,
    SUM(s.total_amount) AS total_spent
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.full_name, c.city, c.loyalty_tier
HAVING SUM(s.total_amount) = (
    SELECT MAX(total_customer_spend)
    FROM (
        SELECT SUM(total_amount) AS total_customer_spend
        FROM sales
        GROUP BY customer_id
    ) AS customer_totals
)
ORDER BY total_spent DESC;


/*
Q7. EXISTS subquery
Find all shops that have received at least one supplier delivery. Use EXISTS. 
Show shop_name and category.
*/

SELECT 
    sh.shop_name,
    sh.category
FROM shops sh
WHERE EXISTS (
    SELECT 1 
    FROM supplier_deliveries sd 
    WHERE sd.shop_id = sh.shop_id
)
ORDER BY sh.shop_name;


/*
Q8. NOT EXISTS subquery
Find all shops that have NEVER received any supplier delivery. Use NOT EXISTS. 
Show shop_name, category, and location.
*/

SELECT 
    sh.shop_name,
    sh.category,
    sh.location
FROM shops sh
WHERE NOT EXISTS (
    SELECT 1 
    FROM supplier_deliveries sd 
    WHERE sd.shop_id = sh.shop_id
)
ORDER BY sh.shop_name;


/*
Q9. Correlated subquery
For each employee, show their full name, salary, and whether they earn above 
or below the average salary of their OWN shop. Label this column 'shop_salary_status' 
(show 'Above Shop Average' or 'Below Shop Average').
This is a correlated subquery - the inner query references the outer query's shop_id.
*/

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.salary,
    CASE 
        WHEN e.salary > (
            SELECT AVG(salary) 
            FROM employees e2 
            WHERE e2.shop_id = e.shop_id
        ) THEN 'Above Shop Average'
        ELSE 'Below Shop Average'
    END AS shop_salary_status
FROM employees e
ORDER BY e.shop_id, e.salary DESC;


/*
Q10. HAVING with subquery
Find all shops whose average sale amount is greater than the overall average sale 
amount across ALL shops. Show shop_name and their average sale amount.
*/

SELECT 
    sh.shop_name,
    ROUND(AVG(s.total_amount)::NUMERIC, 2) AS avg_sale_amount
FROM shops sh
INNER JOIN sales s ON sh.shop_id = s.shop_id
GROUP BY sh.shop_id, sh.shop_name
HAVING AVG(s.total_amount) > (
    SELECT AVG(total_amount) 
    FROM sales
)
ORDER BY avg_sale_amount DESC;
