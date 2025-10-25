
-----------------
/** products table**/
----------------

use EcommerceCart
go

select * from products

--total products count
select count(*) as total_products_count from products

--minimum price
select min(price) from products

--maximum price 
select max(price) from products

--average price
select avg(CAST(price AS BIGINT)) from products

--total sum of price
select sum(CAST(price as BIGINT)) from products

--minimum of cogs
select min(cogs) from products

--maximum of cogs
select max(cogs) from products

--total sum of cogs
select sum(cast(cogs as bigint)) from products

--average of cogs
select avg(cast(cogs as bigint)) from products


--select product_id is not null
select * from products where product_id is not null

--group by product_id
SELECT 
    product_id,
    SUM(CAST(price AS bigint)) AS total_sum
FROM products
GROUP BY product_id;

--price of all products greater than minimum price
select * from products where price > (select min(price) from products)


select product_id,
sum(CAST(price as BIGINT)) as total_price from products
group by product_id
having sum(CAST(price as BIGINT)) > min(price)


--rank the products with highest price
select * , rank() over(order by price desc) as highest_rank from products

--rank the products with lowest price
select * , rank() over(order by price asc) as lowest_rank from products

--select top 5 products with highest price using order by
select top 5 * from products
order by price desc

--select top 5 products with lowest price using order by
select top 5 * from products order by price asc

--select top 5 products with lowest price using rank() function
select * from (select * , rank() over(order by price asc) as lowest_rank from products)e
where lowest_rank <=5

--select top 5 products with highest price using rank() function
select * from (select * , rank() over(order by price desc) as highest_rank from products)e
where highest_rank <=5


--create index on price
create index idx_products_price on products(price)

--create index on product_name
create index idx_products_product_name on products(product_name)
