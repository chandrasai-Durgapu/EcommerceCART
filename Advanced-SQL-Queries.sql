

USE EcommerceCart;
GO


--Orders with Payment Details
SELECT 
    o.order_id,
    o.order_date,
    p.payment_status,
    p.payment_date,
    o.customer_id
FROM orders o
INNER JOIN payments p ON o.order_id = p.order_id;


--Customers and their Last Order
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

--Products never ordered
SELECT 
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;


--Highest paying customer
SELECT customer_id, first_name + ' ' + last_name AS full_name
FROM customers
WHERE customer_id = (
    SELECT TOP 1 o.customer_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
    ORDER BY SUM(oi.total_price) DESC
);


--Products More Expensive Than Category Average
SELECT product_id, product_name, price
FROM products p
WHERE price > (
    SELECT AVG(price)
    FROM products
    WHERE category_id = p.category_id
);


--Customer Order Count Ranking
WITH CustomerOrders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT *, RANK() OVER (ORDER BY total_orders DESC) AS order_rank
FROM CustomerOrders;


--

WITH DeliveryDates AS ( SELECT CAST(GETDATE() AS DATE) AS delivery_date 
UNION ALL SELECT DATEADD(DAY, 1, delivery_date) FROM DeliveryDates 
WHERE delivery_date < DATEADD(DAY, 9, GETDATE()) ) 

SELECT * FROM DeliveryDates;


--Customer Cumulative Spending
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(oi.total_price) OVER(PARTITION BY c.customer_id ORDER BY o.order_date) AS cumulative_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id;


--Orders with Previous and Next Order Dates
SELECT *
FROM (
    SELECT 
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS previous_order,
        LEAD(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS next_order
    FROM orders
) AS o
WHERE previous_order IS NOT NULL
  AND next_order IS NOT NULL;


--













SELECT p.product_name, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id;

--cte Number of Products per Category
WITH ProductCounts AS (
    SELECT 
        c.category_id,
        c.category_name,
        COUNT(p.product_id) AS total_products
    FROM categories c
    LEFT JOIN products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name
)
SELECT * FROM ProductCounts WHERE total_products > 5

--CTE: Categories with No Products
WITH EmptyCategories AS (
    SELECT 
        c.category_id,
        c.category_name
    FROM categories c
    LEFT JOIN products p ON c.category_id = p.category_id
    WHERE p.product_id IS NULL
)
SELECT * FROM EmptyCategories;

--View: Categories with Total Stock from Products
CREATE VIEW vw_CategoryStockSummary AS
SELECT 
    c.category_id,
    c.category_name,
    SUM(i.stock_remaining) AS total_stock
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN inventory i ON p.product_id = i.product_id
GROUP BY c.category_id, c.category_name;

SELECT * FROM vw_CategoryStockSummary WHERE total_stock > 100;



--Table-Valued Function: Category Details with Product Count
CREATE FUNCTION dbo.fn_GetCategoryDetails(@min_product_count INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        c.category_id,
        c.category_name,
        COUNT(p.product_id) AS product_count
    FROM categories c
    LEFT JOIN products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name
    HAVING COUNT(p.product_id) >= @min_product_count
);

SELECT * FROM dbo.fn_GetCategoryDetails(3);


--Scalar Function: Get Category Name by ID
CREATE FUNCTION dbo.fn_GetCategoryName (@category_id INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @name VARCHAR(100)
    SELECT @name = category_name FROM categories WHERE category_id = @category_id
    RETURN @name
END;

SELECT dbo.fn_GetCategoryName(2) AS CategoryName;







select c.category_name , count(p.product_id) as product_count from categories as c 
join products as p 
on p.category_id=c.category_id
group by c.category_name


select c.category_name, 
	count(p.product_id) as product_count, 
	rank() over(order by count(p.product_id) desc) as highest_rank
	from categories as c 
	join products as p 
	on p.category_id=c.category_id
	group by c.category_name


--------------------------------
/**** Advanced sql queries***/
--------------------------------

/**--1. top selling products 
--query top 10 products by total sales value

--first need to find total quantity sold and total sales value
**/

select top 10 oi.product_id, p.product_name, sum(oi.total_price) as total_sale, count(o.order_id) as total_orders
from orders o join order_items oi on oi.order_id=o.order_id
join products as p on p.product_id = oi.product_id
group by oi.product_id, p.product_name
order by total_sale desc 


/**--2. revenue by category
--Calculate total revenue generated by each product category.

---need to find percentage contribution of each category to total revenue
---i got error:---  arthmetic error so convert to bigint and add sum function and cast as decimal and apply percentage to it
**/
SELECT 
    p.category_id,
    c.category_name,
    SUM(CAST(oi.total_price AS BIGINT)) AS total_sale,
    CAST(SUM(CAST(oi.total_price AS BIGINT)) AS DECIMAL(38,2)) /
    CAST((SELECT SUM(CAST(total_price AS BIGINT)) FROM order_items) AS DECIMAL(38,2)) * 100 AS ratio
FROM order_items oi
JOIN products AS p ON p.product_id = oi.product_id
LEFT JOIN categories AS c ON c.category_id = p.category_id
GROUP BY p.category_id, c.category_name
ORDER BY total_sale DESC;


/**--3. Average Order value
--computet the average order value for each customer

--include only customers with more than 2 orders
**/
select c.customer_id,
		c.first_name +''+ c.last_name as full_name,
		sum(total_price) /count(o.order_id)  as AVG_value,
		count(o.order_id) as total_orders
from orders as o join customers as c
on c.customer_id=o.customer_id
join order_items as oi on oi.order_id=o.order_id
group by c.customer_id, c.first_name +''+ c.last_name
having count(o.order_id) > 2


/**--4. Monthly sales trend
--querymonthly total sales over the past time

--select last one year data and select their total sales and their previous month sales by using lag() function
--convert total sales as big-int to avoid below error
--i got error:-- Arithmetic overflow error converting expression to data type int.
**/

SELECT 
    year,
    month,
    total_sales AS current_month_sale,
    LAG(total_sales, 1) OVER (ORDER BY year, month) AS last_month_sale
FROM (
    SELECT 
        YEAR(o.order_date) AS year,
        MONTH(o.order_date) AS month,
        SUM(CAST(oi.total_price AS BIGINT)) AS total_sales
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id 
    WHERE o.order_date >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY 
        YEAR(o.order_date),
        MONTH(o.order_date)
) AS monthly_sales
ORDER BY year, month;


/**--5. Customers with no purchase
--find the customers who have registered but never placed an order
**/

/**--approach-1   list the customers details and the time since their registration
**/
select * from customers
where customer_id not in (
select distinct(customer_id) from orders
)

/**--another approach-2
--select * from customers as c left join orders as o on c.customer_id=o.customer_id 
--where o.customer_id is null
**/

/**--6. Least selling category by state

--Identify the best selling product category fro each state
--include total sales for that category within each state
**/
with ranking_content as(
select c.state,
ct.category_name,
sum(oi.total_price) as total_sales,
rank() over(partition by ct.category_name order by sum(oi.total_price) desc) as rank
from orders as o join customers as c on c.customer_id=o.customer_id
join order_items as oi on oi.order_id=o.order_id
join products as p on p.product_id=o.product_id
join categories as ct on ct.category_id=p.category_id
group by c.state, ct.category_name
--order by ct.category_name, sum(oi.total_price) 

)

select * from ranking_content where rank=1


/**7. customer life time value
--Calculate total value of orders placed by each customer over their lifetime

--rank customers based on customer lifetime value
**/

select c.customer_id,
c.first_name + '' + c.last_name as full_name,
sum(oi.total_price) as CLTV,
DENSE_RANK() over(order by sum(oi.total_price)) as cx_ranking
from orders as o join customers as c on o.customer_id=c.customer_id
join order_items as oi on oi.order_id=o.order_id
group by c.customer_id, c.first_name + '' + c.last_name


/** --8. Inventory stock Alerts
Query products with stock levels below a certain threshold (e.g less than 10 units).

--Include last restock_date and warehouse information.
**/


select  i.inventory_id,
		i.stock_remaining as current_stock_left,
		product_name ,
		i.restock_date as last_stock_date
		from inventory as i
join products as p on p.product_id=i.product_id
where stock_remaining < 10


/**9. Shipping delays 
Identify orders where the shipping date is later than 7 days or 5 days after the order date

--include customer, order details and delivery provider
**/

-- Shipping delays: orders shipped more than 5 days or 7 days after being placed

SELECT 
    o.order_id,
    o.order_date,
    s.shipping_date,
    DATEDIFF(DAY, o.order_date, s.shipping_date) AS days_to_ship,
    o.customer_id,
    c.first_name,
    c.last_name,
	s.delivery_status
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN shipping AS s ON o.order_id = s.order_id
WHERE DATEDIFF(DAY, o.order_date, s.shipping_date) > 5 OR DATEDIFF(DAY, o.order_date, s.shipping_date) > 7


/**10. Payment success rate 
--calculate the percentage of successful payments across all orders

--include breakdowns by payment status(eg:-- failed pending)
**/

SELECT 
    p.payment_status,
    COUNT(*) AS total_count,
    CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM payments) * 100 AS ratio
FROM orders AS o
JOIN payments AS p ON p.order_id = o.order_id
GROUP BY p.payment_status;



/** 11. Top performing sellers
-- find the top 5 sellers based on total sales values.

--include both failed orders and successful orders and display the percentage of successful orders
**/

select * from orders as o 
join sellers as s
on s.seller_id=o.seller_id
join order_items as oi
on oi.order_id=o.order_id

--Top 3 Categories by Total Inventory
SELECT 
    c.category_id,
    c.category_name,
    SUM(i.stock_remaining) AS TotalStock
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN inventory i ON p.product_id = i.product_id
GROUP BY c.category_id, c.category_name
ORDER BY TotalStock DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;  -- Top 3 categories


CREATE FUNCTION dbo.fn_InventoryStatusByCategory (@category_id INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.product_id,
        p.product_name,
        i.stock_remaining,
        CASE 
            WHEN i.stock_remaining = 0 THEN 'Out of Stock'
            WHEN i.stock_remaining < 10 THEN 'Low Stock'
            ELSE 'In Stock'
        END AS StockStatus
    FROM Products p
    JOIN Inventory i ON p.product_id = i.product_id
    WHERE p.category_id = @category_id
);


--select * from inventory i join products p on i.product_id=p.product_id where p.category_id=1



select * from [dbo].[fn_InventoryStatusByCategory](1)


