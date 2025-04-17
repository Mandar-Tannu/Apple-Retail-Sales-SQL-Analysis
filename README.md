# Apple Retail Sales Analysis with SQL

## 👋 Introduction
Welcome to my SQL-based data analysis project focused on Apple retail sales!  
In this project, I explored a large-scale dataset of over 1 million records from Apple’s global store operations. It helped me sharpen my SQL skills by solving business-driven questions using structured queries.

## 📊 What This Project Covers
- Hands-on practice with advanced SQL concepts
- Realistic business scenarios
- Structured query writing and optimization
- Data analysis and interpretation

## 🔍 Dataset Overview
The dataset simulates Apple’s retail data, including:
- **Store** information by city and country
- **Product categories** and prices
- **Sales transactions** with date and quantity
- **Warranty claims** across different stores and products

I worked with 5 relational tables:  
`stores`, `category`, `products`, `sales`, and `warranty`.

## 🧩 Entity Relationship Diagram (ERD)

Here’s a quick look at how the tables relate to each other:

![ER Diagram](https://github.com/Mandar-Tannu/Apple-Retail-Sales-SQL-Analysis/blob/main/ER%20Diagram/ER%20Diagram.png?raw=true)

## 🗄️ Database Schema Summary

### `stores`
- `store_id`, `store_name`, `city`, `country`

### `category`
- `category_id`, `category_name`

### `products`
- `product_id`, `product_name`, `category_id`, `launch_date`, `price`

### `sales`
- `sale_id`, `sale_date`, `store_id`, `product_id`, `quantity`

### `warranty`
- `claim_id`, `claim_date`, `sale_id`, `repair_status`

---

## 🧠 My Learning Journey
I solved a range of questions from basic aggregations to complex joins and window functions.  
Here’s how the problems are structured:

### 🟢 Basic to Intermediate
- Units sold, top stores, warranty counts, average pricing, etc.

### 🟡 Intermediate to Advanced
- Warranty claim patterns, product performance by year, category-level analysis

### 🔴 Advanced/Complex
- Running totals, percentage analysis, price–warranty claim correlation, growth analysis

---

## 🔧 Key Concepts Practiced
- Multi-table JOINs
- GROUP BY with aggregations
- Subqueries & CTEs
- Window Functions (ROW_NUMBER, RANK, SUM OVER)
- Time-based filtering & segmentation
- CASE WHEN logic and custom calculations

---

## 💡 What I Gained
- Stronger grip on SQL querying patterns  
- Real-world problem-solving mindset  
- How to explore and present large datasets effectively

---

## ✅ Questions & Solutions

### Basic to Intermediate

Q1. FIND THE NUMBER OF STORES IN EACH COUNTRY
```sql
SELECT country, COUNT(store_id) AS store_count 
FROM stores
GROUP BY country
ORDER BY store_count DESC;
```

Q2. CALCULATE THE TOTAL NUMBER OF UNITS SOLD BY EACH STORE
```sql
SELECT st.store_name, COALESCE(SUM(sa.quantity),0) AS total_units_sold
FROM stores st
LEFT JOIN sales sa
ON st.store_id=sa.store_id
GROUP BY st.store_name
ORDER BY total_units_sold DESC;
```

Q3. IDENTIFY HOW MANY SALES OCCURRED IN DECEMBER 2023
```sql
SELECT COUNT(sale_id) AS total_sale FROM sales
WHERE sale_date >= '2023-12-01' AND sale_date < '2024-01-01';
```

Q4. DETERMINE HOW MANY STORES HAVE NEVER HAD A WARRANTY CLAIM FILED.
```sql
SELECT COUNT(*) as stores_without_warranty_claim FROM stores
WHERE store_id NOT IN(
SELECT DISTINCT store_id
FROM sales AS sa
RIGHT JOIN warranty AS w
ON sa.sale_id=w.sale_id);
```

Q5. CALCULATE THE PERCENTAGE OF WARRANTY CLAIMS MARKED AS "Warranty Void"
```sql
SELECT ROUND(COUNT(claim_id)/(SELECT COUNT(*) FROM warranty)::numeric *100,2) AS warranty_void_percentage
FROM warranty
WHERE repair_status='Warranty Void';
```

Q6. IDENTIFY WHICH STORE HAD THE HIGHEST TOTAL UNIT SOLD IN THE LAST YEAR
```sql
SELECT sa.store_id, st.store_name, SUM(sa.quantity) as total_unit_sold
FROM sales sa
JOIN stores st
ON sa.store_id=st.store_id
WHERE sa.sale_date >= (CURRENT_DATE - INTERVAL '1 YEAR')
GROUP BY sa.store_id, st.store_name
ORDER BY total_unit_sold DESC
LIMIT 1;
```

Q7. COUNT THE NUMBER OF UNIQUE PRODUCTS SOLD IN THE LAST YEAR
```sql
SELECT COUNT(DISTINCT s.product_id) as unique_product_sold
FROM sales s
WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 YEAR');
```

Q8. FIND THE AVERAGE PRICE OF PRODUCTS IN EACH CATEGORY
```sql
SELECT c.category_id, c.category_name, AVG(p.price) AS average_price
FROM category c
JOIN products p
ON c.category_id=p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY average_price DESC;
```

Q9. HOW MANY WARRANTY CLAIMS WERE FILED IN 2020
```sql
SELECT COUNT(*) AS warranty_claim
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date)=2020;
```

Q10. FOR EACH STORE, IDENTIFY THE BEST-SELLING DAY BASED ON HIGHEST QUANTITY SOLD.
```sql
SELECT *FROM
(
	SELECT store_id, TO_CHAR(sale_date, 'Day') AS day_name, SUM(quantity) AS total_unit_sold,
	RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rank
	FROM sales
	GROUP BY store_id, day_name
) AS t1
WHERE rank=1;
```

### Intermediate to Advanced

Q11. IDENTIFY THE LEAST SELLING PRODUCT IN EACH COUNTRY FOR EACH YEAR BASED ON TOTAL UNITS SOLD
```sql
WITH product_rank
AS
(
	SELECT st.country, p.product_name, SUM(sa.quantity) AS total_quantity_sold,
	RANK() OVER(PARTITION BY st.country ORDER BY SUM(sa.quantity)) as rank
	FROM sales AS sa
	JOIN
	stores AS st
	ON sa.store_id=st.store_id
	JOIN
	products p
	ON sa.product_id=p.product_id
	GROUP BY st.country, p.product_name
) 
SELECT *FROM product_rank
WHERE rank=1;
```

Q12. CALCULATE HOW MANY WARRANTY CLAIMS WERE FILED WITHIN 180 DAYS OF PRODUCT SALE.
```sql
SELECT COUNT(*) as no_of_claim_received_within_180_days
FROM warranty w 
LEFT JOIN sales s
ON w.sale_id=s.sale_id
WHERE w.claim_date-s.sale_date<=180;
```

Q13. DETERIMNE HOW MANY WARRANTY CLAIMS WERE FILED FOR PRODUCTS LAUNCHED IN THE LAST TWO YEARS
```sql
SELECT p.product_name, COUNT(w.claim_id) as no_of_claim, COUNT(s.sale_id)
FROM warranty as w
RIGHT JOIN sales as s
ON w.sale_id=s.sale_id
JOIN products as p
ON s.product_id=p.product_id
WHERE p.launch_date >= CURRENT_DATE - INTERVAL '2 YEARS'
GROUP BY p.product_name;
```

Q14. LIST THE MONTHS IN THE LAST THREE YEARS WHERE SALES EXCEEDED 5000 UNITS IN THE USA
```sql
SELECT TO_CHAR(sale_date, 'MM-YYYY') AS months, SUM(s.quantity) AS total_unit_sold
FROM sales AS s
JOIN stores AS st
ON s.store_id=st.store_id
WHERE st.country='USA' AND s.sale_date >= CURRENT_DATE - INTERVAL '3 YEAR'
GROUP BY 1
HAVING SUM(s.quantity) > 5000;
```

Q15. IDENTIFY THE PRODUCT CATEGORY WITH THE MOST WARRANTY CLAIMS FILED IN THE LAST TWO YEARS
```sql
SELECT c.category_name, COUNT(w.claim_id) AS total_claims
FROM warranty AS w
LEFT JOIN sales AS s
ON w.sale_id=s.sale_id
JOIN products AS p
ON p.product_id=s.product_id
JOIN category AS c
ON c.category_id=p.category_id
WHERE w.claim_date >= CURRENT_DATE - INTERVAL '2 YEAR'
GROUP BY c.category_name;
```

### Advanced/Complex

Q16. DETERMINE THE PERCENTAGE CHANCE OF RECEIVING WARRANTY CLAIMS AFTER EACH PURCHASE FOR EACH COUNTRY
```sql
SELECT country, total_sales, total_claims, ROUND(COALESCE(total_claims::numeric/total_sales::numeric * 100,0),2) AS percentage_warranty_claims
FROM
	(SELECT st.country, SUM(s.quantity) AS total_sales, COUNT(w.claim_id) AS total_claims
		FROM sales AS s
		JOIN stores AS st
		ON s.store_id = st.store_id
		LEFT JOIN
		warranty AS w
		ON s.sale_id = w.sale_id
		GROUP BY st.country) t1
ORDER BY percentage_warranty_claims DESC;
```

Q17. ANALYZE YEAR BY YEAR GROWTH RATIO FOR EACH STORE
```sql
WITH yearly_sales AS(
					SELECT st.store_id, st.store_name, EXTRACT(YEAR FROM s.sale_date) AS year, SUM(p.price * s.quantity ) AS total_sale
					FROM sales AS s
					JOIN
					products AS p
					ON s.product_id = p.product_id
					JOIN stores st
					ON s.store_id = st.store_id
					GROUP BY 1,2,3
					ORDER BY 1,2,3 
),
Growth_Ratio AS(
					SELECT store_name, year, LAG(total_sale,1) OVER(PARTITION BY store_name ORDER BY year) AS last_year_sale, total_sale AS current_year_sale
					FROM yearly_sales
)

SELECT store_name, year, last_year_sale, current_year_sale, ROUND((current_year_sale - last_year_sale)::numeric/last_year_sale::numeric * 100,3) AS growth_ratio
FROM growth_ratio
WHERE last_year_sale IS NOT NULL AND year<>EXTRACT(YEAR FROM CURRENT_DATE);
```

Q18. CALCULATE THE CORRELATION BETWEEN PRODUCT PRICE AND WARRANTY CLAIMS FOR PRODUCTS SOLD IN THE LAST FIVE YEARS, SEGMENTED BY PRICE RANGE.
```sql
SELECT
CASE
	WHEN p.price < 500 THEN 'LESS EXPENSIVE PRODUCT'
	WHEN p.price BETWEEN 500 AND 1000 THEN 'MID RANGE PRODUCT'
	ELSE 'EXPENSIVE PRODUCT'
	END AS price_Segment,
	COUNT(w.claim_id) AS Total_claims
FROM warranty AS w
LEFT JOIN sales AS s
ON w.sale_id = s.sale_id
JOIN products AS p
ON p.product_id =s.product_id
WHERE claim_date >= CURRENT_DATE - INTERVAL '5 year'
GROUP BY 1;
```

Q19. IDENDITY THE STORE WITH THE HIGHEST PERCENTAGE OF "Paid Repaired" CLAIMS RELATIVE TO TOTAL CLAIMS FILED 
```sql
WITH paid_repair AS(
					SELECT s.store_id, COUNT(w.claim_id) AS paid_repaired
					FROM sales AS s
					RIGHT JOIN warranty AS w
					ON s.sale_id = w.sale_id
					WHERE w.repair_status = 'Paid Repaired'
					GROUP BY 1
),

total_repaired AS(
					SELECT s.store_id, COUNT(w.claim_id) AS total_repaired
					FROM sales AS s
					RIGHT JOIN warranty AS w
					ON s.sale_id = w.sale_id
					GROUP BY 1
)

SELECT tr.store_id, st.store_name, pr.paid_repaired, tr.total_repaired, ROUND(pr.paid_repaired::numeric /tr.total_repaired::numeric *100,2) as percentage_paid_repaired
FROM paid_repair AS pr
JOIN total_repaired AS tr
ON pr.store_id = tr.store_id
JOIN stores AS st
ON st.store_id = tr.store_id
ORDER BY percentage_paid_repaired DESC;
```

Q20. WRITE A QUERY TO CALCULATE THE MONTHLY RUNNING TOTAL OF SALES FOR EACH STORE OVER THE PAST FOUR YEARS AND COMPARE TRENDS DURING THIS PERIOD
```sql
WITH monthly_sales AS(
					SELECT s.store_id, EXTRACT(YEAR FROM s.sale_date) AS year, EXTRACT(MONTH FROM s.sale_date) AS month, SUM(p.price * s.quantity) AS total_revenue
					FROM sales AS s
					JOIN products AS p
					ON p.product_id = s.product_id
					GROUP BY s.store_id, year, month
					ORDER BY s.store_id, year, month
)
SELECT store_id, month, year, total_revenue, SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year, month) AS running_total
FROM monthly_sales;
```

Q21. ANALYZE PRODUCT SALES TRENDS OVER TIME, SEGMENTED INTO KEY PERIODS: FROM LAUNCH TO 6 MONTHS, 6-12 MONTHS, 12-18 MONTHS, AND BEYOND 18 MONTHS
```sql
SELECT p.product_name,
CASE
  WHEN s.sale_date BETWEEN p.launch_date AND p.launch_date + INTERVAL '6 month' THEN '0-6 month'
  WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + INTERVAL '12 month' THEN '6-12 month'
  WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + INTERVAL '18 month' THEN '12-18 month'
  ELSE '18+ month'
END AS product_life_cycle,
SUM(s.quantity) AS total_quantity_sale
FROM sales AS s
JOIN products p
ON s.product_id = p.product_id
GROUP BY 1,2
ORDER BY 1,3 DESC;
```
