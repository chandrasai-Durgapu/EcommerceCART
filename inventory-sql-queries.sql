
-------------------------------------------
/** Inventory Table related sql queries**/
-------------------------------------------

--list all columns in inventory table 
select * from inventory

select count(inventory_id) as total_count from inventory

--display top 50 rows of inventory table
select top 50 * from inventory

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

