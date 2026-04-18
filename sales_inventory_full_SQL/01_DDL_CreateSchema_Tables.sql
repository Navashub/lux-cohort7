-- =====================================================
-- SALES & INVENTORY DATABASE - DDL SCRIPT
-- Data Definition Language: Schema and Tables
-- =====================================================

-- CREATE schema assignment
CREATE SCHEMA IF NOT EXISTS assignment;

-- CREATE Customers table in the assignment schema
CREATE TABLE IF NOT EXISTS assignment.customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(50),
    registration_date DATE,
    membership_status VARCHAR(10)
);

-- CREATE Products table in the assignment schema
CREATE TABLE IF NOT EXISTS assignment.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2),
    supplier VARCHAR(100),
    stock_quantity INT
);

-- CREATE Sales table in the assignment schema
CREATE TABLE IF NOT EXISTS assignment.sales (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity_sold INT,
    sale_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES assignment.customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES assignment.products(product_id)
);

-- CREATE Inventory table in the assignment schema
CREATE TABLE IF NOT EXISTS assignment.inventory (
    product_id INT PRIMARY KEY,
    stock_quantity INT,
    FOREIGN KEY (product_id) REFERENCES assignment.products(product_id)
);

-- Display the created tables
\dt assignment.*
