-- ============================================================
-- E-COMMERCE SALES & RETURNS ANALYSIS
-- Author: Pruthviraj Kadam
-- Dataset: 5,000 orders | Indian E-commerce Platform
-- ============================================================

CREATE TABLE ecommerce_orders (
    OrderID         VARCHAR(15) PRIMARY KEY,
    CustomerID      VARCHAR(10),
    OrderDate       DATE,
    Month           VARCHAR(15),
    Quarter         VARCHAR(5),
    Category        VARCHAR(30),
    SubCategory     VARCHAR(30),
    City            VARCHAR(20),
    Channel         VARCHAR(20),
    PaymentMethod   VARCHAR(20),
    Quantity        INT,
    UnitPrice       DECIMAL(10,2),
    DiscountPct     INT,
    DiscountAmt     DECIMAL(10,2),
    Revenue         DECIMAL(10,2),
    Cost            DECIMAL(10,2),
    Profit          DECIMAL(10,2),
    ProfitMarginPct DECIMAL(5,2),
    IsReturned      INT,
    ReturnReason    VARCHAR(30),
    CustomerRating  INT,
    DeliveryDays    INT
);

-- ============================================================
-- SECTION 1: BUSINESS KPIs
-- ============================================================

-- 1.1 Overall business summary
SELECT
    COUNT(*)                              AS total_orders,
    COUNT(DISTINCT CustomerID)            AS unique_customers,
    ROUND(SUM(Revenue), 0)               AS total_revenue,
    ROUND(SUM(Profit), 0)                AS total_profit,
    ROUND(AVG(Revenue), 0)               AS avg_order_value,
    ROUND(SUM(Profit)/SUM(Revenue)*100,2) AS overall_margin_pct,
    ROUND(AVG(IsReturned)*100, 2)        AS return_rate_pct,
    ROUND(AVG(CustomerRating), 2)        AS avg_rating
FROM ecommerce_orders;

-- 1.2 Monthly revenue trend
SELECT
    Quarter,
    Month,
    COUNT(*)                  AS total_orders,
    ROUND(SUM(Revenue), 0)   AS monthly_revenue,
    ROUND(SUM(Profit), 0)    AS monthly_profit,
    ROUND(AVG(Revenue), 0)   AS avg_order_value,
    SUM(IsReturned)          AS total_returns,
    ROUND(AVG(IsReturned)*100, 2) AS return_rate_pct
FROM ecommerce_orders
GROUP BY Quarter, Month
ORDER BY MIN(OrderDate);

-- 1.3 Quarter-over-quarter comparison
SELECT
    Quarter,
    ROUND(SUM(Revenue), 0)        AS quarterly_revenue,
    ROUND(SUM(Profit), 0)         AS quarterly_profit,
    COUNT(*)                       AS total_orders,
    ROUND(AVG(Revenue), 0)        AS avg_order_value,
    ROUND(AVG(IsReturned)*100, 2) AS return_rate_pct
FROM ecommerce_orders
GROUP BY Quarter
ORDER BY Quarter;


-- ============================================================
-- SECTION 2: CATEGORY & PRODUCT ANALYSIS
-- ============================================================

-- 2.1 Revenue and profit by category
SELECT
    Category,
    COUNT(*)                               AS total_orders,
    ROUND(SUM(Revenue), 0)                AS total_revenue,
    ROUND(SUM(Profit), 0)                 AS total_profit,
    ROUND(AVG(ProfitMarginPct), 2)        AS avg_margin_pct,
    ROUND(AVG(Revenue), 0)               AS avg_order_value,
    ROUND(AVG(IsReturned)*100, 2)         AS return_rate_pct,
    ROUND(AVG(CustomerRating), 2)         AS avg_rating
FROM ecommerce_orders
GROUP BY Category
ORDER BY total_revenue DESC;

-- 2.2 Top performing subcategories
SELECT
    Category,
    SubCategory,
    COUNT(*)                       AS orders,
    ROUND(SUM(Revenue), 0)        AS revenue,
    ROUND(SUM(Profit), 0)         AS profit,
    ROUND(AVG(ProfitMarginPct),2) AS margin_pct,
    ROUND(AVG(IsReturned)*100,2)  AS return_rate_pct
FROM ecommerce_orders
GROUP BY Category, SubCategory
ORDER BY revenue DESC
LIMIT 15;

-- 2.3 Discount impact on profit margin
SELECT
    CASE
        WHEN DiscountPct = 0       THEN 'No Discount'
        WHEN DiscountPct <= 10     THEN 'Low (1-10%)'
        WHEN DiscountPct <= 20     THEN 'Medium (11-20%)'
        ELSE 'High (21%+)'
    END AS discount_band,
    COUNT(*)                        AS orders,
    ROUND(AVG(ProfitMarginPct), 2) AS avg_margin_pct,
    ROUND(AVG(IsReturned)*100, 2)  AS return_rate_pct,
    ROUND(AVG(CustomerRating), 2)  AS avg_rating,
    ROUND(SUM(Revenue), 0)         AS total_revenue
FROM ecommerce_orders
GROUP BY discount_band
ORDER BY avg_margin_pct DESC;


-- ============================================================
-- SECTION 3: RETURN ANALYSIS
-- ============================================================

-- 3.1 Return rate by category
SELECT
    Category,
    COUNT(*)                           AS total_orders,
    SUM(IsReturned)                    AS returned_orders,
    ROUND(AVG(IsReturned)*100, 2)     AS return_rate_pct,
    ROUND(SUM(CASE WHEN IsReturned=1 THEN Revenue ELSE 0 END), 0) AS revenue_lost
FROM ecommerce_orders
GROUP BY Category
ORDER BY return_rate_pct DESC;

-- 3.2 Return reasons analysis
SELECT
    ReturnReason,
    COUNT(*)                    AS return_count,
    ROUND(COUNT(*)*100.0 /
        SUM(COUNT(*)) OVER(),2) AS pct_of_returns,
    ROUND(AVG(Revenue), 0)     AS avg_order_value
FROM ecommerce_orders
WHERE IsReturned = 1
GROUP BY ReturnReason
ORDER BY return_count DESC;

-- 3.3 Return rate by payment method
SELECT
    PaymentMethod,
    COUNT(*)                       AS total_orders,
    SUM(IsReturned)               AS returns,
    ROUND(AVG(IsReturned)*100,2)  AS return_rate_pct
FROM ecommerce_orders
GROUP BY PaymentMethod
ORDER BY return_rate_pct DESC;

-- 3.4 High return + low margin categories (problem areas)
SELECT
    Category,
    SubCategory,
    COUNT(*) AS orders,
    ROUND(AVG(ProfitMarginPct),2) AS avg_margin_pct,
    ROUND(AVG(IsReturned)*100,2)  AS return_rate_pct,
    ROUND(SUM(Revenue),0)         AS revenue,
    CASE
        WHEN AVG(ProfitMarginPct) < 20 AND AVG(IsReturned)*100 > 15
        THEN 'HIGH RISK — Review Needed'
        WHEN AVG(ProfitMarginPct) < 25 OR AVG(IsReturned)*100 > 12
        THEN 'MODERATE RISK'
        ELSE 'Healthy'
    END AS business_health
FROM ecommerce_orders
GROUP BY Category, SubCategory
HAVING orders > 30
ORDER BY return_rate_pct DESC;


-- ============================================================
-- SECTION 4: CITY & CHANNEL ANALYSIS
-- ============================================================

-- 4.1 Revenue by city
SELECT
    City,
    COUNT(*)                       AS orders,
    ROUND(SUM(Revenue), 0)        AS total_revenue,
    ROUND(AVG(Revenue), 0)        AS avg_order_value,
    ROUND(AVG(IsReturned)*100,2)  AS return_rate_pct,
    ROUND(AVG(CustomerRating),2)  AS avg_rating
FROM ecommerce_orders
GROUP BY City
ORDER BY total_revenue DESC;

-- 4.2 Channel performance
SELECT
    Channel,
    COUNT(*)                       AS orders,
    ROUND(SUM(Revenue), 0)        AS revenue,
    ROUND(SUM(Profit), 0)         AS profit,
    ROUND(AVG(Revenue), 0)        AS avg_order_value,
    ROUND(AVG(IsReturned)*100,2)  AS return_rate_pct,
    ROUND(AVG(CustomerRating),2)  AS avg_rating
FROM ecommerce_orders
GROUP BY Channel
ORDER BY revenue DESC;

-- 4.3 Best channel per category
WITH channel_rank AS (
    SELECT
        Category,
        Channel,
        ROUND(SUM(Revenue), 0) AS revenue,
        RANK() OVER (PARTITION BY Category ORDER BY SUM(Revenue) DESC) AS rnk
    FROM ecommerce_orders
    GROUP BY Category, Channel
)
SELECT Category, Channel, revenue
FROM channel_rank
WHERE rnk = 1
ORDER BY revenue DESC;


-- ============================================================
-- SECTION 5: CUSTOMER ANALYSIS
-- ============================================================

-- 5.1 Repeat vs one-time customers
WITH customer_orders AS (
    SELECT
        CustomerID,
        COUNT(*)             AS order_count,
        ROUND(SUM(Revenue),0) AS total_spend,
        ROUND(AVG(Revenue),0) AS avg_order_value,
        SUM(IsReturned)      AS total_returns
    FROM ecommerce_orders
    GROUP BY CustomerID
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count <= 3 THEN 'Occasional (2-3)'
        WHEN order_count <= 6 THEN 'Regular (4-6)'
        ELSE 'Loyal (7+)'
    END AS customer_segment,
    COUNT(*)                   AS customer_count,
    ROUND(AVG(total_spend),0)  AS avg_lifetime_value,
    ROUND(AVG(avg_order_value),0) AS avg_order_value,
    ROUND(AVG(total_returns),2)   AS avg_returns
FROM customer_orders
GROUP BY customer_segment
ORDER BY avg_lifetime_value DESC;

-- 5.2 Top 10 customers by revenue
SELECT
    CustomerID,
    COUNT(*)             AS total_orders,
    ROUND(SUM(Revenue),0) AS total_revenue,
    ROUND(SUM(Profit),0)  AS total_profit,
    SUM(IsReturned)      AS returns,
    ROUND(AVG(CustomerRating),1) AS avg_rating
FROM ecommerce_orders
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- SECTION 6: ADVANCED — CTEs & WINDOW FUNCTIONS
-- ============================================================

-- 6.1 Month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT
        Month,
        MIN(OrderDate) AS month_start,
        ROUND(SUM(Revenue), 0) AS revenue
    FROM ecommerce_orders
    GROUP BY Month
),
with_lag AS (
    SELECT
        Month,
        revenue,
        LAG(revenue) OVER (ORDER BY month_start) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT
    Month,
    revenue,
    prev_month_revenue,
    ROUND((revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2) AS mom_growth_pct
FROM with_lag
WHERE prev_month_revenue IS NOT NULL
ORDER BY Month;

-- 6.2 Running total revenue by quarter
SELECT
    Quarter,
    OrderDate,
    ROUND(Revenue, 0) AS daily_revenue,
    ROUND(SUM(Revenue) OVER (PARTITION BY Quarter ORDER BY OrderDate), 0) AS running_total
FROM ecommerce_orders
ORDER BY OrderDate;

-- 6.3 Category revenue contribution (% of total)
WITH category_totals AS (
    SELECT
        Category,
        SUM(Revenue) AS category_revenue
    FROM ecommerce_orders
    GROUP BY Category
),
grand_total AS (
    SELECT SUM(Revenue) AS total FROM ecommerce_orders
)
SELECT
    c.Category,
    ROUND(c.category_revenue, 0) AS revenue,
    ROUND(c.category_revenue * 100.0 / g.total, 2) AS revenue_share_pct,
    ROUND(SUM(c.category_revenue) OVER (ORDER BY c.category_revenue DESC) * 100.0 / g.total, 2) AS cumulative_pct
FROM category_totals c, grand_total g
ORDER BY revenue DESC;

-- 6.4 Delivery speed vs rating vs returns
SELECT
    CASE
        WHEN DeliveryDays <= 2  THEN 'Express (1-2 days)'
        WHEN DeliveryDays <= 5  THEN 'Standard (3-5 days)'
        WHEN DeliveryDays <= 8  THEN 'Slow (6-8 days)'
        ELSE 'Very Slow (9+ days)'
    END AS delivery_speed,
    COUNT(*)                       AS orders,
    ROUND(AVG(CustomerRating),2)  AS avg_rating,
    ROUND(AVG(IsReturned)*100,2)  AS return_rate_pct,
    ROUND(AVG(Revenue),0)         AS avg_order_value
FROM ecommerce_orders
GROUP BY delivery_speed
ORDER BY avg_rating DESC;
