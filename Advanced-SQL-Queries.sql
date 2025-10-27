/*******************************************************************************************
    FILE: EcommerceCart_Practice_Set.sql
    DATABASE: EcommerceCart
    DESCRIPTION:
        Full SQL Server Practice Collection — Basic, Medium, Advanced Queries
        + Additional analytical and practical queries (joins, CTEs, window functions)
*******************************************************************************************/

USE EcommerceCart;
GO


-- =========================================================================================
--  BASIC LEVEL QUERIES (1–20)
-- =========================================================================================

-- 1️ List all customers with their state and country
SELECT customer_id, first_name, last_name, state, country
FROM customers;

-- 2️ Find all sellers located in ‘California’
SELECT seller_name, state, country
FROM sellers
WHERE state = 'California';

-- 3️ Display all products and their categories
SELECT p.product_name, c.category_name
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- 4️ Show total number of customers by country
SELECT country, COUNT(*) AS total_customers
FROM customers
GROUP BY country
ORDER BY total_customers DESC;

-- 5️ Find the highest-priced product
SELECT TOP 1 product_name, price
FROM products
ORDER BY price DESC;

-- 6️ Get all orders placed by a specific customer (example: ID = 10)
SELECT order_id, order_date, order_status
FROM orders
WHERE customer_id = 10;

-- 7️ Show all payments and their statuses
SELECT payment_id, payment_mode, payment_status, payment_date
FROM payments;

-- 8️ Count how many orders each seller has fulfilled
SELECT s.seller_name, COUNT(o.order_id) AS total_orders
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
GROUP BY s.seller_name;

-- 9️ Orders with Payment Details
SELECT 
    o.order_id,
    o.order_date,
    p.payment_status,
    p.payment_date,
    o.customer_id
FROM orders o
INNER JOIN payments p ON o.order_id = p.order_id;

-- 🔟 Customers and their Last Order
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 11️ Products never ordered
SELECT 
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

-- 12️ Highest paying customer
SELECT customer_id, first_name + ' ' + last_name AS full_name
FROM customers
WHERE customer_id = (
    SELECT TOP 1 o.customer_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
    ORDER BY SUM(oi.total_price) DESC
);

-- 13️ Products more expensive than their category’s average price
SELECT product_id, product_name, price
FROM products p
WHERE price > (
    SELECT AVG(price)
    FROM products
    WHERE category_id = p.category_id
);

-- 14️ Count number of items in each order
SELECT order_id, COUNT(order_item_id) AS item_count
FROM order_items
GROUP BY order_id;

-- 15️ Show all shipping records that are still in transit
SELECT order_id, carrier, delivery_status
FROM shipping
WHERE delivery_status = 'In Transit';

-- 16️ List all sellers and their business types
SELECT seller_name, brand_type, business_type
FROM sellers;

-- 17️ Generate 10 sequential delivery dates using recursive CTE
WITH DeliveryDates AS (
    SELECT CAST(GETDATE() AS DATE) AS delivery_date
    UNION ALL
    SELECT DATEADD(DAY, 1, delivery_date)
    FROM DeliveryDates
    WHERE delivery_date < DATEADD(DAY, 9, GETDATE())
)
SELECT * FROM DeliveryDates;

-- 18️ Orders with Previous and Next Order Dates
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

-- 19️ Customer Cumulative Spending
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(oi.total_price) OVER(PARTITION BY c.customer_id ORDER BY o.order_date) AS cumulative_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id;

-- 20️ Customer Order Count Ranking
WITH CustomerOrders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT *, RANK() OVER (ORDER BY total_orders DESC) AS order_rank
FROM CustomerOrders;



-- =========================================================================================
--  MEDIUM LEVEL QUERIES (21–35)
-- =========================================================================================

-- 21️ Find the top 3 highest-revenue sellers
SELECT TOP 3 s.seller_name, SUM(oi.total_price) AS total_revenue
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.seller_name
ORDER BY total_revenue DESC;

-- 22️ Total revenue by category
SELECT c.category_name, SUM(oi.total_price) AS total_sales
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_name;

-- 23️ Customers with total spend greater than $5000
SELECT c.customer_id, c.first_name, SUM(oi.total_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name
HAVING SUM(oi.total_price) > 5000;

-- 24️ Number of orders per month in current year
SELECT DATENAME(MONTH, order_date) AS month, COUNT(*) AS total_orders
FROM orders
WHERE YEAR(order_date) = YEAR(GETDATE())
GROUP BY DATENAME(MONTH, order_date)
ORDER BY MIN(order_date);

-- 25️ Sellers with products in multiple categories
SELECT s.seller_name, COUNT(DISTINCT p.category_id) AS categories_sold
FROM sellers s
JOIN products p ON s.seller_id = p.seller_id
GROUP BY s.seller_name
HAVING COUNT(DISTINCT p.category_id) > 1;

-- 26️ Average shipping delay (days)
SELECT AVG(DATEDIFF(DAY, o.order_date, s.shipping_date)) AS avg_ship_days
FROM orders o
JOIN shipping s ON o.order_id = s.order_id;

-- 27️ Total number of returned shipments per carrier
SELECT carrier, COUNT(*) AS total_returns
FROM shipping
WHERE return_date IS NOT NULL
GROUP BY carrier;

-- 28️ Customers who bought from more than 3 sellers
SELECT c.customer_id, c.first_name, COUNT(DISTINCT o.seller_id) AS unique_sellers
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name
HAVING COUNT(DISTINCT o.seller_id) > 3;

-- 29️ Seller and their best-selling product
SELECT s.seller_name, p.product_name, SUM(oi.quantity) AS total_sold
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY s.seller_name, p.product_name;


-- 30️ Customers active in the last 3 months 
SELECT 
    c.customer_id,
    c.first_name,
    COUNT(o.order_id) AS total_orders_last_3_months
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_date >= DATEADD(MONTH, -3, GETDATE())
GROUP BY c.customer_id, c.first_name
ORDER BY total_orders_last_3_months DESC;


-- 31️ Highest profit margin per category
SELECT category_id, product_name, (price - cogs) AS profit_margin
FROM products p
WHERE (price - cogs) = (
    SELECT MAX(price - cogs)
    FROM products p2
    WHERE p2.category_id = p.category_id
);


--32 Monthly revenue per seller using YEAR() and MONTH()
SELECT 
    s.seller_name, 
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(oi.total_price) AS monthly_revenue
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 
    s.seller_name, 
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY 
    s.seller_name, 
    order_year, 
    order_month;


-- 33️ Customers with pending payments
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status <> 'Completed';

-- 34️ Low-stock inventory (below 10)
SELECT i.product_id, p.product_name, i.stock_remaining
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE i.stock_remaining < 10;

-- 35️ Average quantity sold per product
SELECT p.product_name, AVG(oi.quantity) AS avg_qty_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name;



-- =========================================================================================
--  ADVANCED / HARD LEVEL QUERIES (36–50)
-- =========================================================================================


--36 Monthly revenue per seller with ranking (using YEAR() and MONTH())
SELECT 
    s.seller_name,
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    SUM(oi.total_price) AS revenue,
    RANK() OVER (
        PARTITION BY YEAR(o.order_date), MONTH(o.order_date) 
        ORDER BY SUM(oi.total_price) DESC
    ) AS seller_rank
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 
    s.seller_name,
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY 
    order_year, 
    order_month, 
    seller_rank;


-- 37️ 3-Month Rolling Average Seller Revenue (using YEAR() and MONTH())
-- 37️ 3-Month Rolling Average Seller Revenue (simpler version)
WITH SellerMonthly AS (
    SELECT 
        s.seller_id,
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,
        SUM(oi.total_price) AS monthly_revenue
    FROM sellers s
    JOIN orders o ON s.seller_id = o.seller_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY s.seller_id, YEAR(o.order_date), MONTH(o.order_date)
)
SELECT 
    seller_id,
    order_year,
    order_month,
    monthly_revenue,
    AVG(monthly_revenue) OVER (
        PARTITION BY seller_id
        ORDER BY (order_year * 12 + order_month)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_avg
FROM SellerMonthly
ORDER BY seller_id, order_year, order_month;



--38 Monthly revenue with previous month and percentage change (Month-over-Month Revenue Change (%)) 
WITH MonthlyRev AS (
    SELECT 
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,
        SUM(oi.total_price) AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date)
)
SELECT 
    order_year,
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_year, order_month) AS prev_month,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_year, order_month)) * 100.0 /
        NULLIF(LAG(total_revenue) OVER (ORDER BY order_year, order_month), 0), 2
    ) AS pct_change
FROM MonthlyRev
ORDER BY order_year, order_month;

-- 39️ Sellers with Consecutive Revenue Declines
-- Seller revenue trend: 3 consecutive decreasing months (simpler)
-- Seller revenue trend: 3 consecutive decreasing months with seller name
WITH SellerTrend AS (
    SELECT 
        s.seller_id,
        YEAR(o.order_date) AS yr,
        MONTH(o.order_date) AS mon,
        SUM(oi.total_price) AS revenue
    FROM sellers s
    JOIN orders o ON s.seller_id = o.seller_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY s.seller_id, YEAR(o.order_date), MONTH(o.order_date)
),
TrendWithLag AS (
    SELECT
        st.seller_id,
        (SELECT seller_name FROM sellers WHERE seller_id = st.seller_id) AS seller_name,
        yr,
        mon,
        revenue,
        LAG(revenue, 1) OVER (PARTITION BY seller_id ORDER BY yr, mon) AS prev_month,
        LAG(revenue, 2) OVER (PARTITION BY seller_id ORDER BY yr, mon) AS two_months_ago
    FROM SellerTrend st
)
SELECT *
FROM TrendWithLag
WHERE revenue < prev_month
  AND prev_month < two_months_ago
ORDER BY seller_id, yr, mon;

-- 40️ Forecast Next Restock Date per Product
WITH RestockHistory AS (
    SELECT 
        product_id,
        restock_date,
        LAG(restock_date) OVER (PARTITION BY product_id ORDER BY restock_date) AS prev_date
    FROM inventory
)
SELECT 
    product_id,
    AVG(DATEDIFF(DAY, prev_date, restock_date)) AS avg_interval_days,
    DATEADD(DAY, AVG(DATEDIFF(DAY, prev_date, restock_date)), MAX(restock_date)) AS next_estimated_restock
FROM RestockHistory
WHERE prev_date IS NOT NULL
GROUP BY product_id;

-- 41️ Seller Performance Tiers Using Percentiles
WITH SellerRevenue AS (
    SELECT 
        s.seller_id, 
        SUM(oi.total_price) AS total_revenue
    FROM sellers s
    JOIN orders o ON s.seller_id = o.seller_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY s.seller_id
),
SellerRank AS (
    SELECT 
        seller_id,
        total_revenue,
        NTILE(10) OVER (ORDER BY total_revenue DESC) AS decile_rank
    FROM SellerRevenue
)
SELECT 
    seller_id,
    total_revenue,
    CASE 
        WHEN decile_rank = 1 THEN 'Top 10%'
        WHEN decile_rank <= 5 THEN 'Mid Performer'
        ELSE 'Low Performer'
    END AS performance_tier
FROM SellerRank
ORDER BY total_revenue DESC;


-- 42️ Customer Lifetime Value (LTV)
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    SUM(oi.total_price) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 43️ Detect Longest Shipping Delays
SELECT TOP 10 
    o.order_id,
    DATEDIFF(DAY, o.order_date, s.shipping_date) AS delay_days,
    s.carrier
FROM orders o
JOIN shipping s ON o.order_id = s.order_id
ORDER BY delay_days DESC;

-- 44️ Rank Top 3 Products per Category by Profit
SELECT 
    c.category_name,
    p.product_name,
    (p.price - p.cogs) AS profit_margin,
    RANK() OVER (PARTITION BY c.category_name ORDER BY (p.price - p.cogs) DESC) AS rank_in_category
FROM products p
JOIN categories c ON p.category_id = c.category_id;

-- 45️ Country-wise Seller Market Share
WITH TotalCountryRevenue AS (
    SELECT s.country, SUM(oi.total_price) AS total_rev
    FROM sellers s
    JOIN orders o ON s.seller_id = o.seller_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY s.country
)
SELECT 
    s.country,
    s.seller_name,
    SUM(oi.total_price) AS seller_revenue,
    ROUND(SUM(oi.total_price) * 100.0 / tc.total_rev, 2) AS market_share_pct
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN TotalCountryRevenue tc ON s.country = tc.country
GROUP BY s.country, s.seller_name, tc.total_rev
ORDER BY s.country, market_share_pct DESC;

GO


--Customer Cumulative Spending Change
WITH CustomerDaily AS (
    SELECT 
        c.customer_id,
        o.order_date,
        SUM(oi.total_price) AS order_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, o.order_date
),
CustomerCumulative AS (
    SELECT
        customer_id,
        order_date,
        SUM(order_total) OVER (PARTITION BY customer_id ORDER BY order_date) AS cumulative_spent
    FROM CustomerDaily
),
CustomerWithPrev AS (
    SELECT
        customer_id,
        order_date,
        cumulative_spent,
        LAG(cumulative_spent) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_cumulative
    FROM CustomerCumulative
)
SELECT
    customer_id,
    order_date,
    cumulative_spent,
    prev_cumulative,
    ROUND(
        (cumulative_spent - prev_cumulative) * 100.0 / NULLIF(prev_cumulative, 0), 2
    ) AS pct_change_cumulative
FROM CustomerWithPrev
ORDER BY customer_id, order_date;
