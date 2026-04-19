# E-Commerce Customer Analytics & Business Strategy
**Tools:** MySQL · Terminal  
**Dataset:** [Brazilian E-Commerce Dataset by Olist: Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
**Scale:** 100,000+ orders · 7 relational tables · 96,096 unique customers · 3,095 sellers

---

## Project Overview

Olist grew from $46K in October 2016 to $15.4M cumulative revenue by August 2018 — driven primarily by credit card installment payments and Beauty & Health products. However, the platform faces a critical retention crisis with 96.88% of customers never returning. The top 25% of customers generate 59% of revenue yet average only 1.09 orders each. Combined with poor seller performance and satisfaction collapse beyond 21-day delivery windows, the data points to three urgent priorities: seller quality control, logistics improvement, and a VIP retention program for Premium customers.

---

## Database Architecture

This project works with 7 relational tables requiring complex multi-table JOINs:

```
customers ──────────────────────────────────────────┐
    │ customer_id                                    │
    ▼                                                │
orders ◄────────────────────────────────────────────┘
    │ order_id
    ├──────────────► order_items ──► products
    │                    │
    │                    └────────► sellers
    ├──────────────► payments
    └──────────────► reviews
```

| Table | Rows | Description |
|-------|------|-------------|
| customers | 99,441 | Customer demographics |
| orders | 99,441 | Order status and timestamps |
| order_items | 112,650 | Products per order |
| products | 32,951 | Product details and categories |
| sellers | 3,095 | Seller location data |
| payments | 103,886 | Payment type and installments |
| reviews | 99,223 | Customer review scores |

---

## Technical Approach

### Data Loading & Cleaning
- Converted all 7 CSV files from latin1 to UTF-8 encoding using `iconv` in Terminal
- Loaded 7 relational tables into MySQL using `LOAD DATA LOCAL INFILE`
- Handled NULL values in product metadata columns — documented as non-critical to analysis
- Validated all 7 tables loaded correctly using `UNION ALL` data audit query
- Used Terminal directly for complex queries to bypass MySQL Workbench timeout limitations on large joins

### Advanced SQL Concepts Used
- Window functions: `RANK()`, `DENSE_RANK()`, `LAG()`, `NTILE()`, `SUM() OVER()`
- CTEs (`WITH` statements) for multi-step analysis
- Multi-table JOINs across up to 4 tables simultaneously
- Subqueries inside JOIN clauses
- `CASE WHEN` for bucketing and conditional aggregation
- `DATEDIFF()`, `DATE_FORMAT()`, `DAYNAME()`, `HOUR()` for time analysis
- `HAVING` for post-aggregation filtering

---

## Key Findings

### 1. Revenue Growth — $46K to $15.4M in Under 2 Years

| Period | Monthly Revenue | Cumulative |
|--------|----------------|------------|
| Oct 2016 | $46,566 | $46,566 |
| Jan 2017 | $127,545 | $174,132 |
| Nov 2017 | $1,153,528 | $6,126,287 |
| Aug 2018 | $985,414 | $15,422,461 |

**Finding:** Month-over-month analysis using `LAG()` revealed 650% growth in January 2017 indicating business launch, peaking at $1.15M in November 2017 — a 53% spike attributable to seasonal demand. Cumulative revenue doubled from $6.9M to $15.4M in just 8 months of 2018.

---

### 2. Customer Retention Crisis

| Metric | Value |
|--------|-------|
| Total unique customers | 96,096 |
| One-time customers | 93,099 (96.88%) |
| Repeat customers | 2,997 (3.12%) |

**Finding:** 96.88% of customers made only one purchase and never returned. The platform is entirely dependent on new customer acquisition rather than retention. Moving retention from 3% to 8% would represent a 160% improvement in repeat revenue.

---

### 3. Customer Segmentation by Lifetime Value

| Segment | Customers | Avg Spent | Total Revenue | % of Revenue |
|---------|-----------|-----------|---------------|--------------|
| Premium | 23,340 | $392.67 | $9,164,879 | 59% |
| Good | 23,339 | $140.97 | $3,290,127 | 21% |
| Regular | 23,339 | $83.55 | $1,950,017 | 13% |
| Budget | 23,339 | $43.59 | $1,017,439 | 7% |

**Finding:** The top 25% of customers (Premium segment) generate 59% of total platform revenue , nearly 9x more per customer than the Budget segment. Despite this, even Premium customers average only 1.09 orders, confirming the platform-wide retention crisis.

---

### 4. Seller Performance vs Customer Satisfaction

| Seller | Total Orders | Avg Review Score | Avg Days to Deliver |
|--------|-------------|-----------------|---------------------|
| Worst performer | 107 | 2.27 | 15.0 days |
| 2nd worst | 184 | 2.81 | 17.8 days |
| 3rd worst | 79 | 2.96 | 18.2 days |

**Finding:** Sellers with average delivery times exceeding 14 days consistently receive review scores below 3.1 out of 5. The worst performing seller processed 107 orders with a 2.27 average rating. Olist should implement a minimum 3.5 rating threshold for sellers to remain on platform.

---

### 5. Delivery Speed vs Customer Satisfaction

| Delivery Speed | Orders | Avg Review Score |
|---------------|--------|-----------------|
| Fast (≤7 days) | 30,679 | 4.41 ⭐ |
| Normal (8-14 days) | 37,985 | 4.30 ⭐ |
| Slow (15-21 days) | 16,169 | 4.12 ⭐ |
| Very Slow (21+ days) | 11,519 | 3.06 ⭐ |

**Finding:** Delivery speed is the strongest predictor of customer satisfaction. Orders taking 21+ days drop to 3.06 stars , a 1.35 point collapse from fast deliveries. With 11,519 orders in the Very Slow category, improving logistics for these orders would directly improve platform ratings.

---

### 6. Payment Behaviour Analysis

| Payment Type | Transactions | % Share | Avg Value | Avg Installments |
|-------------|-------------|---------|-----------|-----------------|
| Credit Card | 76,795 | 73.92% | $163.32 | 3.51 |
| Boleto | 19,784 | 19.04% | $145.03 | 1.00 |
| Voucher | 5,775 | 5.56% | $65.70 | 1.00 |
| Debit Card | 1,529 | 1.47% | $142.57 | 1.00 |

**Finding:** Credit card payments account for 73.92% of transactions with an average of 3.51 installments , revealing that Brazilian customers rely heavily on installment purchasing. The maximum of 24 installments suggests long-term financing behaviour. Debit card at only 1.47% represents a growth opportunity.

---

### 7. Peak Ordering Times

| Day | Hour | Orders |  
|-----|------|--------|
| Tuesday | 2PM | 1,124 |
| Monday | 9PM | 1,118 |
| Monday | 2PM | 1,096 |
| Monday | 4PM | 1,094 |

**Finding:** Peak ordering occurs on Monday and Tuesday between 11AM and 4PM , customers shop primarily during work hours. The platform should schedule flash sales and promotional emails between 10AM-4PM on weekdays for maximum conversion.

---

### 8. Top Product Categories by Revenue

| Category | Revenue | Avg Price | Avg Review |
|----------|---------|-----------|------------|
| Beauty & Health | $1,228,987 | $129.97 | 4.19 |
| Watches & Gifts | $1,160,290 | $199.19 | 4.07 |
| Bed & Bath | $1,027,334 | $93.52 | 3.92 |
| Sports & Leisure | $954,297 | $113.12 | 4.17 |
| Computer Accessories | $892,280 | $116.30 | 3.98 |

**Finding:** Beauty & Health leads revenue at $1.23M driven by high volume while Watches & Gifts commands the highest average price at $199. Bed & Bath despite ranking 3rd in revenue has the lowest satisfaction score (3.92) : suggesting quality or delivery issues worth investigating.

---

## Business Recommendations

**1. Implement a VIP Loyalty Program for Premium Customers**
The top 25% of customers generate 59% of revenue but average only 1.09 orders. A targeted retention program : personalized offers, early access, dedicated support — for these 23,340 customers could significantly increase repeat purchase rate without new customer acquisition costs.

**2. Enforce Seller Performance Standards**
Sellers with delivery times exceeding 21 days consistently score below 3.1 stars. Implementing a minimum 3.5 rating threshold and mandatory logistics improvement plans for underperforming sellers would directly improve platform reputation and customer satisfaction.

**3. Optimize Marketing for Peak Hours**
With peak ordering consistently occurring Monday-Tuesday between 11AM-4PM, scheduling promotional campaigns, push notifications, and flash sales during these windows would maximize conversion rates from existing traffic.

**4. Reduce 21+ Day Deliveries**
11,519 orders experienced Very Slow delivery (21+ days) resulting in 3.06 average review scores. Prioritizing logistics partnerships and warehouse distribution in underserved regions would move these orders into the Normal category and recover approximately 1.35 stars in average satisfaction.

---

## SQL Concepts Demonstrated

```sql
-- Window Functions
RANK(), DENSE_RANK(), NTILE(), LAG(), SUM() OVER()

-- CTEs
WITH customer_spending AS (...)

-- Multi-table JOINs
FROM orders o
JOIN payments p  ON o.order_id    = p.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN reviews r   ON o.order_id    = r.order_id

-- Conditional Aggregation
SUM(CASE WHEN condition THEN 1 ELSE 0 END)

-- Time Intelligence
DATEDIFF(), DATE_FORMAT(), DAYNAME(), HOUR()
```

---

## Repository Structure

```
ecommerce-customer-analysis/
├── README.md
└── sql/
    └── Ecommerse_Customer_Analysis.sql
```

---

## Author

**Muskan Prajapati**  
Aspiring Data Analyst | MySQL · Power BI · Excel · Tableau  
📧 muskanprajapati002@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/muskan-prajapati-6201b0231/) | [GitHub](https://github.com/muskanprajapati002-blip)

---

*Dataset sourced from Kaggle for portfolio and educational purposes. Analysis conducted entirely in MySQL using advanced SQL techniques.*
