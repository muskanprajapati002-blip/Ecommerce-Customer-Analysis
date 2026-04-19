CREATE DATABASE IF NOT EXISTS olist_db;
USE olist_db;
-- TABLE 1: customers
CREATE TABLE customers(
	customer_id VARCHAR(50),
	customer_unique_id VARCHAR(50), 
	customer_zipcode VARCHAR(50),
	customer_city VARCHAR(50),
	customer_state VARCHAR(50)
);
-- TABLE 2: orders

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp VARCHAR(30),
    order_approved_at VARCHAR(30),
    order_delivered_carrier_date VARCHAR(30),
    order_delivered_customer_date VARCHAR(30),
    order_estimated_delivery_date VARCHAR(30)
);
-- TABLE 3: order_items
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date VARCHAR(30),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

-- TABLE 4: Products
CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(50),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- TABLE 5: Sellers
CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code VARCHAR(10),
    seller_city VARCHAR(50),
    seller_state VARCHAR(5)
);

-- TABLE 6: Payments
CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

-- TABLE 7: Reviews
CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_creation_date VARCHAR(30),
    review_answer_timestamp VARCHAR(30)
);

LOAD DATA LOCAL INFILE '/Users/muskanprajapati/Desktop/ecommerce-analysis/olist_customers_dataset_utf8.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/muskanprajapati/Desktop/ecommerce-analysis/olist_orders_dataset_utf8.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/muskanprajapati/Desktop/ecommerce-analysis/olist_order_items_dataset_utf8.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/muskanprajapati/Desktop/ecommerce-analysis/olist_products_dataset_utf8.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/muskanprajapati/Desktop/ecommerce-analysis/olist_sellers_dataset_utf8.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/muskanprajapati/Desktop/ecommerce-analysis/olist_order_payments_dataset_utf8.csv'
INTO TABLE payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/muskanprajapati/Desktop/ecommerce-analysis/olist_order_reviews_dataset_utf8.csv'
INTO TABLE reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 'customers'  AS table_name, COUNT(*) AS total_rows FROM customers UNION ALL
SELECT 'orders',    COUNT(*) FROM orders UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items UNION ALL
SELECT 'products',  COUNT(*) FROM products UNION ALL
SELECT 'sellers',   COUNT(*) FROM sellers UNION ALL
SELECT 'payments',  COUNT(*) FROM payments UNION ALL
SELECT 'reviews',   COUNT(*) FROM reviews;


SELECT 
	c.customer_unique_id, 
	COUNT(DISTINCT o.order_id) AS total_orders,
	ROUND(SUM(p.payment_value),2) AS lifetime_value,
    RANK() OVER (ORDER BY SUM(p.payment_value)DESC) AS customer_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC
LIMIT 10;    
    
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        ROUND(SUM(p.payment_value), 2)AS revenue
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
    ORDER BY month
)
SELECT 
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month)  AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY month)) / LAG(revenue, 1) OVER (ORDER BY month) * 100, 2)AS growth_pct
FROM monthly_revenue
ORDER BY month;
    


SET GLOBAL wait_timeout = 600;
SET GLOBAL interactive_timeout = 600;
SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;


USE olist_db;
CREATE TEMPORARY TABLE seller_orders AS
SELECT 
    oi.seller_id,
    oi.order_id,
    o.order_delivered_customer_date,
    o.order_purchase_timestamp,
    o.order_estimated_delivery_date
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

CREATE TEMPORARY TABLE seller_reviews AS
SELECT 
    oi.seller_id,
    r.review_score
FROM order_items oi
JOIN reviews r ON oi.order_id = r.order_id;




SELECT 
    oi.seller_id,
    COUNT(DISTINCT oi.order_id)AS total_orders,
    ROUND(AVG(r.review_score), 2)AS avg_review_score,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp)), 1)AS avg_days_to_deliver
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN reviews r ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
HAVING total_orders >= 30
ORDER BY avg_review_score ASC
LIMIT 10;

SELECT 
    DAYNAME(order_purchase_timestamp)AS day_of_week,
    HOUR(order_purchase_timestamp)AS hour_of_day,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM orders
GROUP BY day_of_week, hour_of_day
ORDER BY total_orders DESC
LIMIT 10;

SELECT 
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    COUNT(DISTINCT CASE 
        WHEN order_counts.order_count = 1 
        THEN c.customer_unique_id 
    END)AS one_time_customers,
    COUNT(DISTINCT CASE 
        WHEN order_counts.order_count > 1 
        THEN c.customer_unique_id 
    END) AS repeat_customers,
    ROUND(COUNT(DISTINCT CASE 
        WHEN order_counts.order_count = 1 
        THEN c.customer_unique_id 
    END) * 100.0 / COUNT(DISTINCT c.customer_unique_id), 2) AS one_time_pct,
    ROUND(COUNT(DISTINCT CASE 
        WHEN order_counts.order_count > 1 
        THEN c.customer_unique_id 
    END) * 100.0 / COUNT(DISTINCT c.customer_unique_id), 2) AS repeat_pct
FROM customers c
JOIN (SELECT 
        c2.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c2
    JOIN orders o ON c2.customer_id = o.customer_id
    GROUP BY c2.customer_unique_id
) AS order_counts ON c.customer_unique_id = order_counts.customer_unique_id;


SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER(), 2) AS pct_of_transactions,
    ROUND(AVG(payment_value), 2)AS avg_payment_value,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(AVG(payment_installments), 2)AS avg_installments,
    MAX(payment_installments) AS max_installments
FROM payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


SELECT 
    CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, 
             o.order_purchase_timestamp) <= 7  
             THEN 'Fast'
        WHEN DATEDIFF(o.order_delivered_customer_date, 
             o.order_purchase_timestamp) <= 14 
             THEN 'Normal'
        WHEN DATEDIFF(o.order_delivered_customer_date, 
             o.order_purchase_timestamp) <= 21 
             THEN 'Slow'
        ELSE 'Very Slow'
    END AS delivery_speed,
    COUNT(*) AS total_orders,
    ROUND(AVG(r.review_score), 2)AS avg_review_score
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date != ''
GROUP BY delivery_speed
ORDER BY avg_review_score DESC;


SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(payment_value), 2) AS monthly_revenue,
    ROUND(SUM(SUM(payment_value)) 
        OVER (ORDER BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')), 2) AS running_total
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

SELECT 
    p.product_category_name,
    COUNT(DISTINCT oi.order_id)  AS total_orders,
    ROUND(SUM(oi.price), 2)  AS total_revenue,
    ROUND(AVG(oi.price), 2)AS avg_price,
    ROUND(AVG(r.review_score), 2)AS avg_review_score,
    DENSE_RANK() OVER 
        (ORDER BY SUM(oi.price) DESC)AS revenue_rank
FROM products p
JOIN order_items oi  ON p.product_id  = oi.product_id
JOIN orders o ON oi.order_id   = o.order_id
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND p.product_category_name IS NOT NULL
AND p.product_category_name != ''
GROUP BY p.product_category_name
ORDER BY revenue_rank
LIMIT 10;

SELECT 
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(total_spent), 2)AS avg_spent,
    ROUND(AVG(total_orders), 2)AS avg_orders,
    ROUND(SUM(total_spent), 2)AS segment_revenue
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id)AS total_orders,
        ROUND(SUM(p.payment_value), 2) AS total_spent,
        CASE NTILE(4) OVER (ORDER BY SUM(p.payment_value) DESC)
            WHEN 1 THEN 'Premium'
            WHEN 2 THEN 'Good'
            WHEN 3 THEN 'Regular'
            WHEN 4 THEN 'Budget' END AS customer_segment
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id  = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS segmented
GROUP BY customer_segment
ORDER BY avg_spent DESC;