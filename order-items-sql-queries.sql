

USE EcommerceCart;
GO


--list all order_items
select * from order_items

--list product_id, quantity and price_per_unit from order_items table
select product_id, price_per_unit, quantity from order_items


SELECT * FROM order_items WHERE quantity > 2;


SELECT * FROM order_items WHERE price_per_unit BETWEEN 500 AND 1500;


--all aggregate functions like sum(), min(), max(), avg(), count()
SELECT SUM(CAST(total_price AS BIGINT)) AS TotalRevenue FROM order_items;
SELECT AVG(CAST(price_per_unit AS BIGINT)) AS AvgPrice FROM order_items;
SELECT COUNT(*) AS TotalItems FROM order_items;
SELECT MAX(total_price) AS MaxOrderItem FROM order_items;
SELECT MIN(price_per_unit) AS MinPrice FROM order_items;


--group by product_id
SELECT SUM(CAST(total_price AS BIGINT)) AS TotalRevenue FROM order_items
group by product_id


SELECT product_id, SUM(total_price) AS TotalRevenue
FROM order_items
GROUP BY product_id
HAVING SUM(total_price) > 1000;


select product_id, count(product_id) as total_count from order_items
group by product_id
having count(product_id) > 1

--order items which are greater than average price per unit
SELECT * FROM order_items
WHERE price_per_unit > (SELECT AVG(CAST(price_per_unit AS BIGINT)) FROM order_items);

--order items which are greater than minimum price per unit
SELECT * FROM order_items
WHERE price_per_unit > (SELECT min(CAST(price_per_unit AS BIGINT)) FROM order_items);


--Find Product with Highest Total Revenue
with cte as (SELECT 
    product_id,
    SUM(CAST(total_price AS BIGINT)) AS total_revenue,
	rank() over(order by SUM(CAST(total_price AS BIGINT)) desc) as ranking
FROM order_items
group by product_id
)

select product_id,total_revenue from cte where ranking=1


--Find Product with Highest Total Revenue with TOP keyword
SELECT TOP 1
    product_id,
    SUM(CAST(total_price AS BIGINT)) AS total_revenue
	
FROM order_items
group by product_id
order by SUM(CAST(total_price AS BIGINT)) DESC


--Find Product with Lowest Total Revenue
SELECT TOP 1
    product_id,
    SUM(CAST(total_price AS BIGINT)) AS total_revenue
	
FROM order_items
group by product_id
order by SUM(CAST(total_price AS BIGINT))

--cte where TotalSales greater than 1000
WITH ProductSales AS (
    SELECT product_id, SUM(CAST(total_price AS BIGINT)) AS TotalSales
    FROM order_items
    GROUP BY product_id
)
SELECT * FROM ProductSales WHERE TotalSales > 1000;

--view with TotalRevenue
CREATE VIEW v_order_items_summary AS
SELECT product_id, SUM(quantity) AS TotalQuantity, SUM(total_price) AS TotalRevenue
FROM order_items
GROUP BY product_id;

SELECT * FROM v_order_items_summary



--indexing to improve the query performance
CREATE INDEX idx_orderitems_productid ON order_items(product_id);
CREATE INDEX idx_orderitems_orderid ON order_items(order_id);


--Scalar Function — Total Revenue per Product
CREATE FUNCTION dbo.fn_GetProductRevenue
(
    @ProductID INT
)
RETURNS BIGINT
AS
BEGIN
    DECLARE @TotalRevenue BIGINT;

    SELECT @TotalRevenue = SUM(CAST(total_price AS BIGINT))
    FROM order_items
    WHERE product_id = @ProductID;

    RETURN ISNULL(@TotalRevenue, 0);
END;
GO

--select * from order_items where product_id=7160

SELECT dbo.fn_GetProductRevenue(7160) AS TotalRevenue;


--Table-Valued Function — Sales Summary per Product
CREATE FUNCTION dbo.fn_GetProductSalesSummary
(
    @MinRevenue BIGINT = 0
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        product_id,
        SUM(quantity) AS total_quantity,
        SUM(CAST(total_price AS BIGINT)) AS total_revenue
    FROM order_items
    GROUP BY product_id
    HAVING SUM(CAST(total_price AS BIGINT)) >= @MinRevenue
);
GO

SELECT * FROM dbo.fn_GetProductSalesSummary(1000000);


