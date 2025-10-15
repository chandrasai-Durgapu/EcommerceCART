/****** Script for SelectTopNRows command from SSMS  ******/



 -- Ecommerce Cart Database with million rows of dataset

create database EcommerceCart

USE EcommerceCart;
GO


--1 category table
Create table categories(category_id int Primary key,
category_name varchar(100));

--2 customers table
Create table customers(customer_id int primary key,
first_name varchar(100),
last_name varchar(100),
state varchar(100),
address varchar(255),
country varchar(100)
);


CREATE TABLE sellers (
    seller_id       INT PRIMARY KEY,
    seller_name     VARCHAR(255),
    brand_type      VARCHAR(100),
    business_type   VARCHAR(100),
    email           VARCHAR(255),
    phone           NVARCHAR(100),
    country         VARCHAR(100),
    state           VARCHAR(100),
    address         NVARCHAR(1000)
);


-- 4. Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name NVARCHAR(255),
    price INT,
    cogs INT,
    category_id INT,
    seller_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);


--5. Orders table
CREATE TABLE orders (
    order_id UNIQUEIDENTIFIER PRIMARY KEY,
    order_date DATETIME2 NOT NULL,
    customer_id INT NOT NULL,
    order_status VARCHAR(100),
    product_id INT NOT NULL,
    seller_id INT NOT NULL,
    
    -- Foreign Keys
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);


--6. Order Items table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,              -- Unique identifier for the line item
    order_id UNIQUEIDENTIFIER NOT NULL,         -- Links to the orders table (Foreign Key)
    product_id INT NOT NULL,                    -- Links to the products table (Foreign Key)
    quantity INT NOT NULL,                      -- Quantity ordered
    price_per_unit INT NOT NULL,                -- Price at the time of order
    total_price INT NOT NULL,                   -- Calculated total price (quantity * price_per_unit)
    -- Constraints
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


--7. payments table
CREATE TABLE payments (
    payment_id UNIQUEIDENTIFIER PRIMARY KEY,
    payment_date DATETIME2 NOT NULL,
    payment_mode VARCHAR(50) ,
    payment_status VARCHAR(20) ,
    order_id UNIQUEIDENTIFIER NOT NULL,

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


--8. Shipping table
CREATE TABLE shipping (
    shipping_id UNIQUEIDENTIFIER PRIMARY KEY,
    order_id UNIQUEIDENTIFIER NOT NULL,
    delivery_status VARCHAR(50),
    tracking_number VARCHAR(50) NOT NULL, -- Removed UNIQUE
    shipping_date DATETIME2 NOT NULL,
    return_date DATETIME2 NULL,
    carrier VARCHAR(100),

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


--9. Inventory table
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    stock_remaining INT ,
    ware_house_id INT NOT NULL,
    restock_date DATETIME2 NOT NULL,

    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


--database diagram is not supported in this ssms version
-- Products

BULK INSERT categories
FROM 'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\categories.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


BULK INSERT products
FROM 'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


-- Customers
BULK INSERT customers
FROM 'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


-- Orders
BULK INSERT orders
FROM 
'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


BULK INSERT inventory
FROM 
'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\inventory.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


BULK INSERT order_items
FROM 
'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


BULK INSERT payments
FROM 
'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\payments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

--alter table sellers 
--drop column total_sales

BULK INSERT sellers
FROM 
'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\sellers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

--shipping
BULK INSERT shipping
FROM 
'G:\DataScienceProjects\sql-projects\Ecommerce-Cart\csv-files\shipping.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);



--
select * from categories

select count(*) from categories


select * from products

select count(*) TOTAL_ROWS from products


select * from customers

select count(*) TOTAL_ROWS from customers

select * from orders
select count(*) as Order_Total_Count from orders



select * from order_items

select count(*) as Total_count from order_items

select * from payments
select count(*) as Total_Count from payments

select * from sellers
select count(*) as total_count from sellers


select * from shipping
select count(*) as total from shipping
select * from shipping where return_date is null


select * from inventory

select count(*) as Total_Count from inventory




