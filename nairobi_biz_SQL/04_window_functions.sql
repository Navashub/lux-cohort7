/*
==============================================================================
NAIROBI BIZ SQL - WINDOW FUNCTIONS QUESTIONS & SOLUTIONS
==============================================================================
This file contains 10 Window Function exercises covering:
- ROW_NUMBER, RANK, DENSE_RANK for ranking
- PARTITION BY to create subsets of data
- AVG OVER, SUM OVER for window aggregations
- LAG and LEAD for comparing rows
- NTILE for distribution
- Combined window functions

Each question is clearly commented with the requirement.
The PostgreSQL solution query appears directly below each question.
==============================================================================
*/

SET search_path TO nairobi_biz;


/*
Q1. ROW_NUMBER - overall ranking
Number all employees from 1 to 20 in order of their hire date (oldest first). 
Show: row_number, full name, shop_name, job_title, hire_date.
*/

SELECT 
    ROW_NUMBER() OVER (ORDER BY e.hire_date ASC) AS row_number,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    sh.shop_name,
    e.job_title,
    e.hire_date
FROM employees e
LEFT JOIN shops sh ON e.shop_id = sh.shop_id
ORDER BY e.hire_date ASC
LIMIT 20;


/*
Q2. RANK - salary ranking
Rank all employees by salary highest to lowest using RANK(). 
Show: rank, full name, salary. 
Notice what happens when two employees have the same salary — RANK skips numbers, 
DENSE_RANK does not.
*/

SELECT 
    RANK() OVER (ORDER BY e.salary DESC) AS rank,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.salary
FROM employees e
ORDER BY e.salary DESC;


/*
Q3. DENSE_RANK - same as Q2 but with DENSE_RANK
Repeat Q2 using DENSE_RANK instead of RANK. Add a column showing both RANK 
and DENSE_RANK side by side so the difference is visible. 
When do the two columns differ?
*/

SELECT 
    RANK() OVER (ORDER BY e.salary DESC) AS rank_result,
    DENSE_RANK() OVER (ORDER BY e.salary DESC) AS dense_rank_result,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.salary
FROM employees e
ORDER BY e.salary DESC;


/*
Q4. PARTITION BY - rank within shop
Rank employees within each shop by salary (highest first). 
Show: shop_name, full name, salary, shop_salary_rank. 
Only show rank 1 employees (the top earner per shop).
Hint: Wrap the window function in a subquery or CTE to filter by rank.
*/

WITH ranked_employees AS (
    SELECT 
        sh.shop_name,
        CONCAT(e.first_name, ' ', e.last_name) AS full_name,
        e.salary,
        RANK() OVER (PARTITION BY e.shop_id ORDER BY e.salary DESC) AS shop_salary_rank
    FROM employees e
    LEFT JOIN shops sh ON e.shop_id = sh.shop_id
)
SELECT 
    shop_name,
    full_name,
    salary,
    shop_salary_rank
FROM ranked_employees
WHERE shop_salary_rank = 1
ORDER BY shop_name;


/*
Q5. AVG OVER - compare to group average
For each employee, show their salary alongside the average salary of their shop 
(calculated as a window function, not GROUP BY). 
Show: full name, shop_name, salary, shop_avg_salary, and the difference 
(salary − shop average).
*/

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    sh.shop_name,
    e.salary,
    ROUND(AVG(e.salary) OVER (PARTITION BY e.shop_id)::NUMERIC, 2) AS shop_avg_salary,
    ROUND((e.salary - AVG(e.salary) OVER (PARTITION BY e.shop_id))::NUMERIC, 2) AS salary_diff
FROM employees e
LEFT JOIN shops sh ON e.shop_id = sh.shop_id
ORDER BY sh.shop_name, e.salary DESC;


/*
Q6. SUM OVER - running total
Show a running total of sale amounts ordered by sale_date. For each sale show: 
sale_id, sale_date, total_amount, and cumulative_revenue (running sum so far). 
Order by sale_date, sale_id.
*/

SELECT 
    s.sale_id,
    s.sale_date,
    s.total_amount,
    SUM(s.total_amount) OVER (ORDER BY s.sale_date, s.sale_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM sales s
ORDER BY s.sale_date, s.sale_id;


/*
Q7. LAG - previous sale comparison
For each sale (ordered by sale_date), show the current total_amount, the previous 
sale's amount using LAG(), and the difference between them. 
Label columns: sale_id, sale_date, total_amount, prev_sale_amount, change.
*/

SELECT 
    s.sale_id,
    s.sale_date,
    s.total_amount,
    LAG(s.total_amount) OVER (ORDER BY s.sale_date, s.sale_id) AS prev_sale_amount,
    ROUND((s.total_amount - LAG(s.total_amount) OVER (ORDER BY s.sale_date, s.sale_id))::NUMERIC, 2) AS change
FROM sales s
ORDER BY s.sale_date, s.sale_id;


/*
Q8. LEAD - next sale preview
For each sale (ordered by sale_date), show the current amount and the NEXT sale's 
amount using LEAD(). If there is no next sale, show 0. 
Label: sale_id, sale_date, total_amount, next_sale_amount.
*/

SELECT 
    s.sale_id,
    s.sale_date,
    s.total_amount,
    COALESCE(LEAD(s.total_amount) OVER (ORDER BY s.sale_date, s.sale_id), 0) AS next_sale_amount
FROM sales s
ORDER BY s.sale_date, s.sale_id;


/*
Q9. NTILE - customer quartiles
Divide all customers into 4 groups (quartiles) based on when they registered — 
oldest customers in group 1, newest in group 4. 
Show: full_name, registered_on, loyalty_tier, and quartile number.
*/

SELECT 
    c.full_name,
    c.registered_on,
    c.loyalty_tier,
    NTILE(4) OVER (ORDER BY c.registered_on ASC) AS quartile
FROM customers c
ORDER BY c.registered_on;


/*
Q10. Combined window function challenge
For each shop, show every sale with: sale_date, total_amount, shop's running 
revenue total (partitioned by shop_id), and the shop's monthly rank of that 
sale (rank from highest to lowest within the same month, partitioned by shop and month).
This question combines SUM OVER with PARTITION BY and RANK OVER with PARTITION BY 
in the same query.
*/

SELECT 
    sh.shop_name,
    s.sale_date,
    s.total_amount,
    SUM(s.total_amount) OVER (PARTITION BY s.shop_id ORDER BY s.sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS shop_running_total,
    RANK() OVER (
        PARTITION BY s.shop_id, DATE_TRUNC('month', s.sale_date) 
        ORDER BY s.total_amount DESC
    ) AS monthly_rank
FROM sales s
INNER JOIN shops sh ON s.shop_id = sh.shop_id
ORDER BY sh.shop_name, s.sale_date;
