
------------
/** shipping table **/
------------

use 
EcommerceCart
go


-- View all shipments
SELECT * FROM shipping;

-- Filter by status
SELECT * FROM shipping WHERE delivery_status = 'Delivered';

-- Sort by shipping date
SELECT * FROM shipping ORDER BY shipping_date DESC;



-- Count shipments by carrier
SELECT carrier, COUNT(*) AS total_shipments
FROM shipping
GROUP BY carrier
ORDER BY total_shipments DESC;

-- Count shipments by delivery status
SELECT delivery_status, COUNT(*) AS shipment_count
FROM shipping
GROUP BY delivery_status;


-- Days since shipped (for undelivered orders)
SELECT 
    tracking_number,
    DATEDIFF(DAY, shipping_date, SYSDATETIME()) AS days_since_shipped
FROM shipping
WHERE delivery_status != 'Delivered';

-- For returned shipments
SELECT 
    tracking_number,
    DATEDIFF(DAY, shipping_date, return_date) AS days_until_returned
FROM shipping
WHERE return_date IS NOT NULL;


SELECT 
    carrier,
    shipping_date,
    LAG(shipping_date) OVER (PARTITION BY carrier ORDER BY shipping_date) AS prev_shipment,
    DATEDIFF(DAY, LAG(shipping_date) OVER (PARTITION BY carrier ORDER BY shipping_date), shipping_date) AS days_between_shipments
FROM shipping
ORDER BY carrier, shipping_date;


SELECT 
    tracking_number,
    delivery_status,
    CASE 
        WHEN delivery_status = 'Delivered' THEN ' Completed'
        WHEN delivery_status = 'Pending' THEN ' Awaiting Shipment'
        WHEN delivery_status = 'Returned' THEN ' Returned'
        ELSE ' Unknown'
    END AS status_label
FROM shipping;


--create indexes on tracking_number, carrier_status, delivery_status
CREATE INDEX idx_shipping_tracking_number ON shipping(tracking_number);
CREATE INDEX idx_shipping_carrier_status ON shipping(carrier, delivery_status);
