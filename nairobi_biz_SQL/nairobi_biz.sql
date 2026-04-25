CREATE SCHEMA IF NOT EXISTS nairobi_biz;

SET search_path TO nairobi_biz;


CREATE TABLE shops (
    shop_id       SERIAL PRIMARY KEY,
    shop_name     VARCHAR(100) NOT NULL,
    category      VARCHAR(50),   
    location      VARCHAR(100),
    monthly_rent  NUMERIC(10,2),
    opened_date   DATE,
    is_active     BOOLEAN DEFAULT TRUE
);


CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    shop_id       INTEGER REFERENCES shops(shop_id),
    job_title     VARCHAR(60),
    salary        NUMERIC(10,2),
    hire_date     DATE,
    gender        VARCHAR(10),
    manager_id    INTEGER REFERENCES employees(employee_id)  
);

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(50),
    loyalty_tier  VARCHAR(20),  -- Bronze, Silver, Gold
    registered_on DATE
);


CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50),
    unit_price    NUMERIC(10,2),
    stock_qty     INTEGER DEFAULT 0,
    shop_id       INTEGER REFERENCES shops(shop_id)
);


CREATE TABLE sales (
    sale_id       SERIAL PRIMARY KEY,
    customer_id   INTEGER REFERENCES customers(customer_id),
    employee_id   INTEGER REFERENCES employees(employee_id),
    shop_id       INTEGER REFERENCES shops(shop_id),
    sale_date     DATE,
    payment_method VARCHAR(30),  -- Cash, M-Pesa, Card
    total_amount  NUMERIC(10,2)
);


CREATE TABLE sale_items (
    item_id       SERIAL PRIMARY KEY,
    sale_id       INTEGER REFERENCES sales(sale_id),
    product_id    INTEGER REFERENCES products(product_id),
    quantity      INTEGER,
    unit_price    NUMERIC(10,2),
    line_total    NUMERIC(10,2)       
);

CREATE TABLE supplier_deliveries (
    delivery_id   SERIAL PRIMARY KEY,
    shop_id       INTEGER REFERENCES shops(shop_id),
    product_id    INTEGER REFERENCES products(product_id),
    supplier_name VARCHAR(100),
    delivery_date DATE,
    qty_delivered INTEGER,
    cost_per_unit NUMERIC(10,2)
);


INSERT INTO shops (shop_name, category, location, monthly_rent, opened_date, is_active) VALUES
('TechZone Electronics', 'Electronics', 'Westlands', 85000, '2019-03-15', TRUE),
('Savanna Clothing',      'Clothing',    'CBD',       55000, '2020-01-10', TRUE),
('Mama Pima Foods',       'Food',       'Eastleigh',  30000, '2018-07-20', TRUE),
('AfyaPlus Pharmacy',     'Pharmacy',   'Lavington',  70000, '2021-05-01', TRUE),
('Glamour Salon',         'Salon',      'Parklands',  40000, '2022-02-14', TRUE),
('Nairobi Gadgets',       'Electronics', 'CBD',       78000, '2020-09-05', TRUE),
('Urban Threads',         'Clothing',   'Westlands',  62000, '2019-11-30', TRUE),
('Spice Garden',          'Food',       'Kilimani',   35000, '2021-08-12', TRUE),
('MedCare Pharmacy',      'Pharmacy',   'Eastleigh',  50000, '2017-04-22', TRUE),
('Shine & Style',         'Salon',      'Ngong Road', 28000, '2023-01-05', TRUE),
('OldTown Grocery',       'Food',       'CBD',       25000, '2015-06-01', FALSE), 
('DigiPro Store',         'Electronics', 'Karen',     90000, '2023-06-15', TRUE);


INSERT INTO employees (first_name, last_name, shop_id, job_title, salary, hire_date, gender, manager_id) VALUES
('Kelvin',  'Omondi',  1, 'Shop Manager',   75000, '2019-03-15', 'Male',   NULL),    
('Brenda',  'Achieng', 1, 'Sales Associate', 42000, '2020-06-01', 'Female', 1),
('Tony',    'Karanja', 1, 'Technician',      50000, '2021-02-14', 'Male',   1),
('Fatuma',  'Hassan',  2, 'Shop Manager',   68000, '2020-01-10', 'Female', NULL),  
('David',   'Mutua',   2, 'Sales Associate', 38000, '2021-03-20', 'Male',   4),
('Grace',   'Wanjiku', 3, 'Shop Manager',   55000, '2018-07-20', 'Female', NULL),    
('Moses',   'Kipchoge',3, 'Cashier',         32000, '2022-05-01', 'Male',   6),
('Amina',   'Juma',    4, 'Pharmacist',      90000, '2021-05-01', 'Female', NULL),    
('Peter',   'Ngugi',   4, 'Pharmacy Tech',   48000, '2022-01-10', 'Male',   8),
('Joy',     'Otieno',  5, 'Senior Stylist',  60000, '2022-02-14', 'Female', NULL),    
('Sylvia',  'Mwenda', 5, 'Junior Stylist',  35000, '2023-03-01', 'Female', 10),
('Hassan',  'Abdi',    6, 'Shop Manager',   72000, '2020-09-05', 'Male',   NULL),   
('Cynthia', 'Waweru', 6, 'Sales Associate', 40000, '2021-11-15', 'Female', 12),
('Isaac',   'Korir',   7, 'Shop Manager',   65000, '2019-11-30', 'Male',   NULL),    
('Lydia',   'Chebet', 7, 'Sales Associate', 37000, '2023-07-01', 'Female', 14),
('Samuel',  'Gitonga', 8, 'Chef',            58000, '2021-08-12', 'Male',   NULL),    
('Esther',  'Njoroge',9, 'Pharmacist',      88000, '2017-04-22', 'Female', NULL),   
('Nancy',   'Kamau',   10, 'Senior Stylist', 55000, '2023-01-05', 'Female', NULL),    
('Brian',   'Maina',   12, 'Shop Manager',  80000, '2023-06-15', 'Male',   NULL),    
('Ivy',     'Waithaka',12, 'Sales Associate', 41000, '2024-01-10', 'Female', 19);


INSERT INTO customers (full_name, phone, city, loyalty_tier, registered_on) VALUES
('Alice Mwangi',   '0712345678', 'Nairobi',  'Gold',   '2021-01-15'),
('Bob Otieno',     '0723456789', 'Nairobi',  'Silver', '2022-03-10'),
('Carol Wanjiku',  '0734567890', 'Kiambu',   'Bronze', '2023-05-20'),
('Dan Kipchoge',   '0745678901', 'Nairobi',  'Gold',   '2020-08-05'),
('Eunice Adhiambo','0756789012', 'Nairobi',  'Silver', '2021-11-12'),
('Fred Kamau',     '0767890123', 'Nakuru',   'Bronze', '2022-07-18'),
('Gloria Hassan',  '0778901234', 'Mombasa',  'Silver', '2023-02-28'),
('Henry Njoroge',  '0789012345', 'Nairobi',  'Gold',   '2020-05-30'),
('Irene Chebet',   '0790123456', 'Eldoret',  'Bronze', '2024-01-20'),
('James Gitonga',  '0701234567', 'Nairobi',  'Gold',   '2019-12-01'),
('Karen Achieng',  '0722345678', 'Nairobi',  'Silver', '2022-09-15'),
('Liam Mwenda',    '0733456789', 'Kiambu',   'Bronze', '2023-04-07'),
('Mary Korir',     '0744567890', 'Nairobi',  'Gold',   '2021-06-25'),
('Nate Waweru',    '0755678901', 'Thika',    'Bronze', '2023-10-10'),
('Olivia Maina',   '0766789012', 'Nairobi',  'Silver', '2022-12-01');


INSERT INTO products (product_name, category, unit_price, stock_qty, shop_id) VALUES
('Samsung Galaxy A55', 'Phone',        65000, 15, 1),
('Bluetooth Earphones', 'Accessories',  3500,  40, 1),
('USB-C Charger',       'Accessories',  1200,  60, 1),
('Ankara Dress',        'Women Wear',   4500,  30, 2),
('Kanzu Set',           'Men Wear',     6000,  20, 2),
('Uji Mix 1kg',         'Dry Goods',    350,   100, 3),
('Cooking Oil 5L',      'Grocery',      1800,  45, 3),
('Paracetamol 500mg',   'Medicine',     150,   200, 4),
('Vitamin C 1000mg',    'Supplements',  850,   80, 4),
('Hair Relaxer Treatment','Service',     2500,  0,  5),
('HP Laptop 15"',       'Computers',    85000, 10, 6),
('Wireless Mouse',       'Accessories',  1800,  35, 6),
('Denim Jeans',         'Men Wear',     3200,  25, 7),
('Pilau Masala 100g',   'Spices',       220,   150, 8),
('Coriander Seeds 50g',  'Spices',       120,   120, 8),
('Amoxicillin 500mg',   'Medicine',     280,   180, 9),
('iPhone 15 Pro',        'Phone',        185000,8,  12),
('iPad Air',             'Tablet',        120000,6,  12);


INSERT INTO sales (customer_id, employee_id, shop_id, sale_date, payment_method, total_amount) VALUES
(1, 2,  1, '2024-01-15', 'M-Pesa', 68500),
(4, 2,  1, '2024-01-20', 'Card',   3500),
(8, 3,  1, '2024-02-05', 'Cash',   1200),
(10, 2, 1, '2024-02-18', 'M-Pesa', 65000),
(2, 5,  2, '2024-01-08', 'Cash',   4500),
(6, 5,  2, '2024-02-14', 'M-Pesa', 6000),
(11, 5, 2, '2024-03-01', 'Card',   9000),
(3, 7,  3, '2024-01-22', 'Cash',   2150),
(5, 7,  3, '2024-02-10', 'M-Pesa', 3600),
(13, 7, 3, '2024-03-15', 'Cash',   1800),
(1, 9,  4, '2024-01-30', 'Card',   1000),
(4, 9,  4, '2024-02-20', 'M-Pesa', 850),
(8, 8,  4, '2024-03-05', 'Cash',   300),
(10, 11,5, '2024-01-25', 'M-Pesa', 2500),
(5, 11, 5, '2024-02-08', 'Cash',   2500),
(13, 13,6, '2024-01-12', 'M-Pesa', 85000),
(3, 13, 6, '2024-02-22', 'Card',   1800),
(7, 15, 7, '2024-01-18', 'Cash',   3200),
(12, 15,7, '2024-02-15', 'M-Pesa', 6400),
(2, 16, 8, '2024-01-28', 'Cash',   780),
(9, 17, 9, '2024-02-02', 'Card',   560),
(14, 17,9, '2024-02-25', 'M-Pesa', 280),
(15, 19,12, '2024-03-10', 'Card',   185000),
(1, 20, 12, '2024-03-20', 'M-Pesa', 120000),
(4, 2,  1, '2024-03-25', 'Cash',   1200),
(8, 5,  2, '2024-04-02', 'M-Pesa', 4500),
(10, 7, 3, '2024-04-08', 'Cash',   700),
(13, 9, 4, '2024-04-10', 'Card',   1700),
(2, 13, 6, '2024-04-15', 'M-Pesa', 86800),
(6, 15, 7, '2024-04-20', 'Card',   3200),
(11, 16,8, '2024-04-22', 'Cash',   340),
(3, 17, 9, '2024-04-25', 'M-Pesa', 430),
(7, 18, 10, '2024-04-28', 'Cash',   1500),
(9, 19, 12, '2024-05-01', 'Card',   120000),
(5, 2,  1, '2024-05-05', 'M-Pesa', 3500);


INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, line_total) VALUES
(1, 1,  1, 65000, 65000),
(1, 2,  1, 3500,  3500),
(2, 2,  1, 3500,  3500),
(3, 3,  1, 1200,  1200),
(4, 1,  1, 65000, 65000),
(5, 4,  1, 4500,  4500),
(6, 5,  1, 6000,  6000),
(7, 4,  2, 4500,  9000),
(8, 6,  1, 350,   350),
(8, 7,  1, 1800,  1800),
(9, 6,  2, 350,   700),
(9, 7,  1, 1800,  1800),
(10, 7, 1, 1800,  1800),
(11, 8, 2, 150,   300),
(11, 9, 1, 850,   850),
(12, 9, 1, 850,   850),
(13, 8, 2, 150,   300),
(14, 10,1, 2500,  2500),
(15, 10,1, 2500,  2500),
(16, 11,1, 85000, 85000),
(17, 12,1, 1800,  1800),
(18, 13,1, 3200,  3200),
(19, 13,2, 3200,  6400),
(20, 14,2, 220,   440),
(20, 15,2, 120,   240),
(21, 16,2, 280,   560),
(22, 16,1, 280,   280),
(23, 17,1, 185000,185000),
(24, 18,1, 120000,120000),
(25, 3,  1, 1200,  1200),
(26, 4,  1, 4500,  4500),
(27, 6,  2, 350,   700),
(28, 8,  4, 150,   600),
(28, 9,  1, 850,   850),
(29, 11,1, 85000, 85000),
(29, 12,1, 1800,  1800),
(30, 13,1, 3200,  3200),
(31, 14,1, 220,   220),
(31, 15,1, 120,   120),
(32, 16,1, 280,   280),
(32, 8,  1, 150,   150),
(33, 10,1, 2500,  2500),
(34, 18,1, 120000,120000),
(35, 2,  1, 3500,  3500);


INSERT INTO supplier_deliveries (shop_id, product_id, supplier_name, delivery_date, qty_delivered, cost_per_unit) VALUES
(1, 1,  'Samsung Kenya Ltd',   '2023-12-01', 20, 52000),
(1, 2,  'AudioTech EA',        '2024-01-05', 50, 2800),
(1, 3,  'Cable World KE',      '2024-01-05', 100, 800),
(2, 4,  'Ankara Imports',      '2024-01-03', 40, 3000),
(2, 5,  'Coastal Textiles',    '2024-01-10', 30, 4200),
(3, 6,  'Unga Group Kenya',    '2024-01-08', 150, 280),
(3, 7,  'Bidco Africa',        '2024-01-12', 60, 1400),
(4, 8,  'PharmaChem EA',       '2024-01-06', 300, 90),
(4, 9,  'HealthPlus Dist',     '2024-01-15', 100, 650),
(6, 11, 'HP East Africa',      '2024-01-10', 15, 72000),
(6, 12, 'Logitech Dist',       '2024-01-20', 50, 1300),
(7, 13, 'Denim World EA',      '2024-01-18', 40, 2200),
(8, 14, 'Spice Route Kenya',   '2024-01-22', 200, 150),
(8, 15, 'Spice Route Kenya',   '2024-01-22', 180, 80),
(9, 16, 'PharmaChem EA',       '2024-01-08', 250, 200),
(12, 17, 'Apple Premium Dist', '2024-02-01', 10, 155000),
(12, 18, 'Apple Premium Dist', '2024-02-01', 8,  98000),
(1,  1,  'Samsung Kenya Ltd',   '2024-03-01', 10, 53000),
(4,  8,  'PharmaChem EA',       '2024-03-15', 200, 92),
(6,  11, 'HP East Africa',      '2024-04-01', 5,  73000);
