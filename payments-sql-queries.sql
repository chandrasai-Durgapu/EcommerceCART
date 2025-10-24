
use
EcommerceCart
go

----------
/** payments table **/
----------

select * from payments


--select all columns where paymnet_status==='Failed'
select * from payments where payment_status='Failed'

--select all columns where payment_status===='Pending'
select * from payments where payment_status='Pending'

--select all columns where payment_status=='Completed'
SELECT *
FROM payments
WHERE payment_status = 'Completed';

--total payments count
SELECT COUNT(*) AS total_payments
FROM payments;


--select all columns where payment_status is 'Pending' and 'Failed'
select * from payments where payment_status in ('Pending','Failed')

--select all column where payment_status is not in ('Pending', 'Failed')
select * from payments where payment_status not in ('Pending','Failed')

--select all columns where payment_mode==='Credit Card'
select * from payments where payment_mode='Credit Card'

--select all columns where payment_mode==='Net Banking'
select * from payments where payment_mode='Net Banking'

--select all columns where payment_mode in 'Net Banking' and 'UPI'
select * from payments where payment_mode in ('Net Banking','UPI')

--select all columns where payment_mode not in ('Net Banking','UPI')
select * from payments where payment_mode not in ('Net Banking','UPI')

--total count by the payment status (use group by)
SELECT payment_status, COUNT(*) AS count
FROM payments
GROUP BY payment_status;

--payments info based on payment_mode
SELECT payment_mode, COUNT(*) AS total
FROM payments
GROUP BY payment_mode;

--payments per order-id
SELECT order_id, COUNT(*) AS total_payments
FROM payments
GROUP BY order_id;


--payments made this year
SELECT *
FROM payments
WHERE YEAR(payment_date) = YEAR(GETDATE());

--
select *,YEAR(payment_date) as year,MONTH(payment_date) as month from payments


SELECT 
    order_id,
    YEAR(payment_date) AS year,
    MONTH(payment_date) AS month,
    COUNT(*) AS payment_count
FROM payments
GROUP BY 
    order_id,
    YEAR(payment_date),
    MONTH(payment_date)


	--count of payments per order per month:
SELECT 
    order_id,
    YEAR(payment_date) AS year,
    MONTH(payment_date) AS month,
    COUNT(*) AS payment_count
FROM payments
GROUP BY 
    order_id,
    YEAR(payment_date),
    MONTH(payment_date)
ORDER BY 
    order_id,
    year,
    month;

--Add or Subtract Dates
SELECT 
    payment_id,
    payment_date,
    DATEADD(DAY, 7, payment_date) AS payment_plus_7_days,
    DATEADD(MONTH, -1, payment_date) AS payment_minus_1_month
FROM payments


-- Days between payment and today
SELECT 
    payment_id,
    payment_date,
    DATEDIFF(DAY, payment_date, GETDATE()) AS days_since_payment
FROM payments;

-- Months between payment and today
SELECT 
    payment_id,
    payment_date,
    DATEDIFF(MONTH, payment_date, GETDATE()) AS months_since_payment
FROM payments;


--display payment_date greater than last month
select * from payments where payment_date >= DATEADD(month, -1, getdate())


--Get number of payments for a specific order
CREATE FUNCTION dbo.fn_GetPaymentsCount(@OrderID UNIQUEIDENTIFIER)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*)
    FROM payments
    WHERE order_id = @OrderID;

    RETURN ISNULL(@Count, 0);
END;
GO

--select * from payments where order_id='F0B7F307-02BC-4826-8921-AD35C7BBA99A'

-- Replace 'your_order_id_here' with an actual order_id from the orders table
SELECT dbo.fn_GetPaymentsCount('F0B7F307-02BC-4826-8921-AD35C7BBA99A') AS PaymentCount;


-- Index on payment_date for faster date queries
CREATE NONCLUSTERED INDEX IX_Payments_PaymentDate
ON payments(payment_date);

-- Index on payment_status for faster filtering
CREATE NONCLUSTERED INDEX IX_Payments_Status
ON payments(payment_status);

--Payments with Year and Month
CREATE VIEW dbo.vw_PaymentsWithDateParts
AS
SELECT 
    payment_id,
    payment_date,
    DATENAME(WEEKDAY, payment_date) AS payment_weekday,
    DATEPART(QUARTER, payment_date) AS payment_quarter,
    YEAR(payment_date) AS payment_year,
    MONTH(payment_date) AS payment_month,
    payment_mode,
    payment_status,
    order_id
FROM payments;
GO

--
SELECT * 
FROM dbo.vw_PaymentsWithDateParts
WHERE payment_year = 2025 AND payment_quarter = 3;
