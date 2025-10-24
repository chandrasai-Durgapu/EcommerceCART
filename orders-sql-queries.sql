--list all orders
select * from orders

--Find the latest order per customer
SELECT customer_id, MAX(order_date) AS latest_order
FROM orders
GROUP BY customer_id;


--Count orders by status
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;


--Total orders for a seller
SELECT seller_id, COUNT(*) AS total_orders
FROM orders
GROUP BY seller_id
ORDER BY total_orders DESC

--Extract parts of a date
SELECT 
    order_id,
    customer_id,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DAY(order_date) AS order_day,
    DATENAME(WEEKDAY, order_date) AS order_weekday
FROM orders;



-- Orders in January 2025
SELECT *
FROM orders
WHERE order_date >= '2025-01-01'
  AND order_date < '2025-02-01'


--select orders greater than last month
SELECT *
FROM orders
WHERE order_date >= DATEADD(DAY, -30, GETDATE());



-- Orders in 2024, March
SELECT *
FROM orders
WHERE YEAR(order_date) = 2024
  AND MONTH(order_date) = 3;



--
SELECT 
    order_id,
    DATEDIFF(DAY, order_date, GETDATE()) AS days_since_order
FROM orders


--Group orders by month/year
SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;


--Get Quarter of the Year
SELECT 
    order_id,
    order_date,
    DATEPART(QUARTER, order_date) AS order_quarter
FROM orders;

--To display the month name of orders in the 3rd quarter along with the weekday, you can use DATENAME(MONTH, order_date):
SELECT 
    order_id,
    order_date,
    DATENAME(WEEKDAY, order_date) AS order_weekday,
    DATENAME(MONTH, order_date) AS order_month
FROM orders
WHERE DATEPART(QUARTER, order_date) = 3;



CREATE FUNCTION dbo.fn_GetCustomerTotalOrders
(
    @CustomerID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalOrders INT;

    SELECT @TotalOrders = COUNT(*)
    FROM orders
    WHERE customer_id = @CustomerID;

    RETURN ISNULL(@TotalOrders, 0);
END;
GO

--select * from orders where customer_id=309699

SELECT dbo.fn_GetCustomerTotalOrders(309699) AS TotalOrders;



CREATE FUNCTION dbo.fn_GetOrderRevenue
(
    @OrderID UNIQUEIDENTIFIER
)
RETURNS BIGINT
AS
BEGIN
    DECLARE @Revenue BIGINT;

    SELECT @Revenue = SUM(CAST(total_price AS BIGINT))
    FROM order_items
    WHERE order_id = @OrderID;

    RETURN ISNULL(@Revenue, 0);
END;
GO

--total_price column is present in order_items table not within orders table
DROP FUNCTION IF EXISTS dbo.fn_GetOrderRevenue;
GO


--SELECT dbo.fn_GetOrderRevenue('some-order-id') AS OrderRevenue;

--Index on customer_id
CREATE NONCLUSTERED INDEX IDX_orders_customer
ON orders(customer_id);


--Index on seller_id
CREATE NONCLUSTERED INDEX IDX_orders_seller
ON orders(seller_id);

--Index on order_date
CREATE NONCLUSTERED INDEX IDX_orders_orderdate
ON orders(order_date);



