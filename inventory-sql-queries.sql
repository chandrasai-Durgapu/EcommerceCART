
-------------------------------------------
/** Inventory Table related sql queries**/
-------------------------------------------

--list all columns in inventory table 
select * from inventory

select count(inventory_id) as total_count from inventory

--display top 50 rows of inventory table
select top 50 * from inventory

--display sum of stock_remaining in inventory table
--select product_id,stock_remaining,sum(stock_remaining) as total_sum from inventory 
--group by product_id, stock_remaining

--range of stock_reamining 
select max(stock_remaining)-min(stock_remaining) as range_stock_remaining from inventory

--display max stock_remaining as highest
select max(stock_remaining) as highest from inventory

--display all data from the year 2024
select * from inventory where YEAR(restock_date) > 2024

--display all data from year between 2023 and 2025
select * from inventory where Year(restock_date) between 2023 and 2025

--display year column from the restock_date  within inventory table
select *, YEAR(restock_date) as year from inventory 

--display month column from restock_date within inventory table
select *, MONTH(restock_date) as Month from inventory

--display days from restock_date column within inventory table
select *, DAY(restock_date) as Days from inventory

--display year column and month column from restock_date within inventory table
select *, YEAR(restock_date) as Year, MONTH(restock_date) as Month from inventory

--display Year column, Month column and Days column from inventory table
select *, YEAR(restock_date) as Years, MONTH(restock_date) as Months, DAY(restock_date) as Days from inventory

--sort by year wise ascending on restock_date column within inventory table
select *, YEAR(restock_date) as Year from inventory order by YEAR(restock_date) asc

--sort by month wise acsending on restock_date column within inventory table
select *, YEAR(restock_date) as year, MONTH(restock_date) as Month from inventory order by YEAR(restock_date), MONTH(restock_date) asc

--sort by day wise ascending order on restock_date column in inventory table
select *, YEAR(restock_date) as year, MONTH(restock_date) as Month, DAY(restock_date) as Days from inventory order by YEAR(restock_date), MONTH(restock_date), DAY(restock_date) asc

--sort by year wise descending on restock_date column within inventory table
select *, YEAR(restock_date) as Year from inventory order by YEAR(restock_date) desc

--sort by month wise descending on restock_date column within inventory table
select *, YEAR(restock_date) as year, MONTH(restock_date) as Month from inventory order by YEAR(restock_date), MONTH(restock_date) desc

--sort by day wise descending order on restock_date column in inventory table
select *, YEAR(restock_date) as year, MONTH(restock_date) as Month, DAY(restock_date) as Days from inventory order by YEAR(restock_date), MONTH(restock_date), DAY(restock_date) desc

--display year using datepart() function on restock_date within inventory table
select DATEPART(year,restock_date) as Year from inventory

--display month using datepart() function on restock_date column within inventory table
select DATEPART(month,restock_date) as Month from inventory

--display days using datepart() function on restock_date column within inventory table
select DATEPART(day,restock_date) as Days from inventory

--display hours using datepart() function on restock_date column within inventory table
select DATEPART(hour, restock_date) as Hours from inventory

--display minutes using datepart() function on restock-date column withtin inventory table
select DATEPART(minute,restock_date) as minutes from inventory

--display seconds using datepart() function on restock_date column within inventory table
select DATEPART(second,restock_date) as seconds from inventory

--display current date
select GETDATE()

--display day using datename() function from restock_date column wihtin inventory table
select *, DATENAME(day,restock_date) as day_of_month from inventory

--display weekdays using datename() function on restock_date column within inventory table
select *, DATENAME(weekday,restock_date) as day from inventory 

--display month name using datename() function on restock_date column within inventory table
select *, DATENAME(month,restock_date) as month_name from inventory 

select *, YEAR(restock_date) as Year, MONTH(restock_date) as Month, DAY(restock_date) as Day,DATENAME(month,restock_date) as Month_name,DATENAME(weekday,restock_date) as Week_day from inventory

--add 1 month to the current date using Dateadd() fucntion
SELECT DATEADD(month, 1, GETDATE()) AS NextMonth

--display upcoming month name using datename() function
select datename(month, DATEADD(month, 1, GETDATE())) as upcoming_month 

--add 7 days to the current date using Dateadd() function
select DATEADD(day,7,GETDATE()) 

--display upcoming week using datename() function 
select DATENAME(day,DATEADD(day,7,GETDATE())) as upcoming_day

--add 6 days using Dateadd() function to the restock_date column within inventory table
select *, DATEADD(day,6,restock_date) as new_date from inventory

--add 1 year using dateadd() function to the restock_date column within inventory table
select DATEADD(year,1,restock_date) as new_info from inventory

--add 30 minutes using dateadd() function to the restock_date column within inventory table
select DATEADD(minute,30,restock_date) as new_minutes from inventory

--subtract 6 days using dateadd() function on the restock-date column within inventory table
select DATEADD(day,-6,restock_date) as new_info from inventory

--apply datediff() function between two dates and display days
SELECT DATEDIFF(day, '2025-01-01', '2025-10-18') AS DaysDifference
-- Output: 290

--apply datediff() function between two dates and display month
SELECT DATEDIFF(month, '2024-10-01', '2025-10-01') AS MonthsDifference;
-- Output: 12


--apply datediff() function on restock_date column from new 1 year
select DATEDIFF(year,restock_date,DATEADD(year,1,restock_date)) as new_year from inventory

--restock_date inventory on saturday and sunday
SELECT 
    inventory_id,
    product_id,
    restock_date,
    DATENAME(weekday, restock_date) AS restock_day
FROM inventory
WHERE DATENAME(weekday, restock_date) IN ('Saturday', 'Sunday')


--Find Items With Low Stock and Older Than 90 Days
SELECT 
    inventory_id,
    product_id,
    stock_remaining,
    restock_date,
    DATEDIFF(day, restock_date, SYSDATETIME()) AS days_in_stock
FROM inventory
WHERE 
    stock_remaining < 10
    AND DATEDIFF(day, restock_date, SYSDATETIME()) > 90;


--Rank Products by Freshness (Least Days in Stock)
SELECT 
    inventory_id,
    product_id,
    stock_remaining,
    restock_date,
    DATEDIFF(day, restock_date, SYSDATETIME()) AS days_in_stock
FROM inventory
ORDER BY days_in_stock ASC;


--Create a View for Clean Inventory Access
create view InventoryWithProducts as
SELECT 
    i.product_id,
    p.product_name,
	p.price,
    i.restock_date,
    i.stock_remaining
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id



--cte with Inventory Status
with StockClassification as(
select i.product_id,
	   i.stock_remaining,
	case when i.stock_remaining = 0 then 'Quantity Sold'
		when i.stock_remaining < 10 then 'Low Stock'
		else 'In Stock'
		end as StockStatus
		from inventory as i
)
select StockStatus from StockClassification


--Top 5 Most Stocked Items with Row_number() Window Function and SubQuery
SELECT * 
FROM (
    SELECT  
        product_id,
        stock_remaining,
        ROW_NUMBER() OVER (ORDER BY stock_remaining DESC) AS StockRank
    FROM Inventory
) e
WHERE e.StockRank <= 5;



--Create a Scalar User Defined Function for Stock Status where stock status is less than 10 and stock status is zero

CREATE FUNCTION fn_GetStockStatus (@product_id INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @status VARCHAR(20)
    SELECT @status = 
        CASE 
            WHEN stock_remaining = 0 THEN 'Out of Stock'
            WHEN stock_remaining < 10 THEN 'Low Stock'
            ELSE 'In Stock'
        END
    FROM Inventory
    WHERE product_id = @product_id
    RETURN @status
END;


SELECT dbo.fn_GetStockStatus(1) AS StockStatus;


--calculate Running Total
SELECT 
    product_id,
    stock_remaining,
    SUM(stock_remaining) OVER (ORDER BY product_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Inventory


--Advanced CTE: Products with Stock Trend
WITH StockDiff AS (
    SELECT 
        product_id,
        stock_remaining,
        restock_date,
        LAG(stock_remaining) OVER (PARTITION BY product_id ORDER BY restock_date) AS PreviousStock
    FROM inventory
),

StockTrend AS (
    SELECT 
        product_id,
        restock_date,
        stock_remaining,
        PreviousStock,
        CASE 
            WHEN stock_remaining > PreviousStock THEN 'Restocked'
            WHEN stock_remaining < PreviousStock THEN 'Stock Decreased'
            WHEN stock_remaining = PreviousStock THEN 'No Change'
            ELSE 'First Record'  -- NULL PreviousStock
        END AS StockTrend
    FROM StockDiff
)
SELECT * FROM StockTrend;


