
----------------
/** sellers table **/
----------------

use
EcommerceCart
go

select * from sellers

-- Basic filter
SELECT * FROM sellers WHERE country = 'USA';

-- Multiple conditions
SELECT * FROM sellers WHERE country = 'India' AND business_type = 'LG';

-- Pattern match
SELECT * FROM sellers WHERE seller_name LIKE 'F%';  -- starts with F

-- NULL check
SELECT * FROM sellers WHERE brand_type IS NOT NULL;


-- Order alphabetically by seller name
SELECT * FROM sellers ORDER BY seller_name ASC;

-- Group by country and count sellers
SELECT country, COUNT(*) AS total_sellers
FROM sellers
GROUP BY country;

-- Group by business_type and filter using HAVING
SELECT business_type, COUNT(*) AS seller_count
FROM sellers
GROUP BY business_type
HAVING COUNT(*) > 1;


SELECT 
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT country) AS total_countries
FROM sellers;


-- Get sellers from countries that have more than one seller
SELECT * 
FROM sellers
WHERE country IN (
    SELECT country
    FROM sellers
    GROUP BY country
    HAVING COUNT(*) > 1
);


CREATE VIEW vw_USA_Sellers AS
SELECT seller_id, seller_name, business_type, state
FROM sellers
WHERE country = 'USA';

-- Use the view
SELECT * FROM vw_USA_Sellers;


SELECT 
    seller_id,
    seller_name,
    country,
    COUNT(*) OVER(PARTITION BY country) AS sellers_in_country,
    ROW_NUMBER() OVER(ORDER BY seller_name) AS row_num
FROM sellers;


CREATE INDEX idx_sellers_country ON sellers(country);
CREATE INDEX idx_sellers_business_type ON sellers(business_type);


SELECT 
    seller_name,
    country,
    CASE 
        WHEN country = 'India' THEN 'Domestic'
        ELSE 'International'
    END AS seller_category
FROM sellers;



WITH SellerCounts AS (
    SELECT country, COUNT(*) AS total_sellers
    FROM sellers
    GROUP BY country
)
SELECT * FROM SellerCounts WHERE total_sellers > 1;
