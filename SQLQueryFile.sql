
--list all products
select * from products


--list of all categories
select * from categories



--list all order_items
select * from order_items

--list all orders
select * from orders

--list all payments information
select * from payments

--list all sellers information
select * from sellers

--list all shipping information
select * from shipping

-------------------------------
/** categories table**/
-------------------------------
select category_id, category_name from categories

--first top 20 values from categories table
select top 20 category_id, category_name from categories

--display max value from category_name
select max(category_name) from categories

--display minimum value from category_name
select min(category_name) from categories

--display catgory_name column with category_id === 1
select category_name from categories where category_id =1

--display category_name from categories table where category_id greater than 1
select category_name from categories where category_id > 1

--display length of category_name
select len(category_name) from categories

--display category_name from categories table where category_id (between 1 and 10)
select category_name from categories where category_id between 1 and 10

--sort categories by category_name column alphabetically
select * from categories order by category_name asc

--sort categories by category_name descending order
select * from categories order by category_name desc

--sort categories by category_id in ascending order
select * from categories order by category_id asc

--sort categories by category_id column descending order
select * from categories order by category_id desc

--display categories table where category_name column it has pattern starts with 'a' 
select * from categories where category_name like 'a%'

--display total count of categories table
select count(*) as total_count from categories 

--display categories table where length() function of category_name column has greater than 10
select * from categories where len(category_name) > 10

--display maximum length of category_name column from categories table
select max(len(category_name)) as max_length from categories

select len(min(category_name)) from categories

select * from categories where len(category_name) > (select len(min(category_name)) from categories)






--display the length of Mobiles
select len('Mobiles') 

--select left() of Mobiles
select left('Mobiles', 3)

--select right() from Mobiles
select right('Mobiles',3)

--select substring 
select substring('Mobiles', 2,6)

--replace function
select replace('Mobiles','l','ccc')

--convert Mobiles to uppercase
select upper('Mobiles')

--convert Mobiles to lowercase
select lower('Mobiles')

--apply left trim on '  Mobiles'
select ltrim('  Mobiles')

--apply right trim on 'Mobiles   a'
select rtrim('Mobiles  a      ')

--remove space 
select trim('   Mobiles_a    ')

--concat 'Mobiles' with 12345
select concat('Mobiles', 12345)

--reverse Mobiles
select reverse('Mobiles')

--find the length() of category_name with add it with 3 and display it as new_column_length from the categories table
select len(category_name) as length from categories
select len(category_name) as length, cast (len(category_name) + 3 as int) as new_column_length from categories 

--use case to label tablet devcies and mobile devices on categories table
select category_name,
	case when category_name like 'Tabl%' then 'Tablet Devices'
		 when category_name like 'Mob%' then 'Mobile Devices'
		 else 'other'
		 end as category_type from categories



-------------------------
/** customers table**/
-------------------------
--list all customers table
select * from customers

--display max customer_id
select max(customer_id) from customers

--display minimum of customer_id
select min(customer_id) from customers

--concat first-name and last_name from customers table
select concat(first_name,last_name) as full_name from customers

--concat first_name and last_name without using concat() function
select first_name + '' + last_name as full_name from customers

--substring of address
select substring('"6182 Gregory Stream',2,6)

--substring on column
select substring(address,2,8) from customers

--select substring() function from first index===2 to last_index===using length() function of the '6182 Gregory Stream'
select substring('6182 Gregory Stream',2,len('6182 Gregory Stream')) as sub_part

--select substring() function on the address coulmn with first_index as 2 and last_index is the length() function of the address coulmn  in the customers table
select substring(address,2,len(address)) as sub_part from customers

--replace the address column with implement substring() of the first_index as 2 and last_index as 6  and finally apply as '@gmail.com' to it

select replace(address, substring(address,2,6), '@gmail.com') from customers


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


