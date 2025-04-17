-- APPLE RETAIL SALES PROJECT

SELECT *FROM category;
SELECT *FROM products;
SELECT *FROM stores; 
SELECT *FROM sales;
SELECT *FROM warranty;

-- EDA

SELECT DISTINCT repair_status FROM warranty;
SELECT COUNT(*) FROM sales;

-- IMPROVE QUERY PERFORMANCE

-- INDEX CREATION ON product_id COLUMN
EXPLAIN ANALYZE											-- THIS WILL GIVE US THE TIME REQUIRED TO EXECUTE THIS QUERY BEFORE INDEX
SELECT *FROM sales
WHERE product_id='P-44';	

CREATE INDEX sales_product_id ON sales(product_id);	-- NOW AGAIN RUN ANALYZE QUERY AND OBSERVE THE TIME REQUIRED FOR EXECUTION

-- INDEX CREATION ON store_id COLUMN
EXPLAIN ANALYZE
SELECT *FROM sales
WHERE store_id='ST-31';

CREATE INDEX sales_store_id ON sales(store_id);		-- NOW AGAIN RUN ANALYZE QUERY AND OBSERVE THE TIME REQUIRED FOR EXECUTION

-- INDEX CREATION ON sale_date COLUMN
CREATE INDEX sales_sale_date ON sales(sale_date);

-- BUSINESS PROBLEMS

-- 1. Find the number of stores in each country
SELECT *FROM stores;

SELECT country, COUNT(store_id) AS store_count 
FROM stores
GROUP BY country
ORDER BY store_count DESC;

-- 2. Calculate the total number of units sold by each store.
SELECT *FROM stores;
SELECT *FROM sales;

SELECT st.store_name, COALESCE(SUM(sa.quantity),0) AS total_units_sold
FROM stores st
LEFT JOIN sales sa
ON st.store_id=sa.store_id
GROUP BY st.store_name
ORDER BY total_units_sold DESC;

-- 3. IDENTIFY HOW MANY SALES OCCURRED IN DECEMBER 2023
SELECT *FROM sales;

SELECT COUNT(sale_id) AS total_sale FROM sales
WHERE sale_date >= '2023-12-01' AND sale_date < '2024-01-01';

-- 4. DETERMINE HOW MANY STORES HAVE NEVER HAD A WARRANTY CLAIM FILED.
SELECT *FROM stores;
SELECT *FROM sales;
SELECT *FROM warranty;

SELECT COUNT(*) as stores_without_warranty_claim FROM stores
WHERE store_id NOT IN	(
							SELECT DISTINCT store_id
							FROM sales AS sa
							RIGHT JOIN warranty AS w
							ON sa.sale_id=w.sale_id
						);

-- 5. CALCULATE THE PERCENTAGE OF WARRANTY CLAIMS MARKED AS "Warranty Void"

SELECT *FROM warranty;

SELECT ROUND(COUNT(claim_id)/(SELECT COUNT(*) FROM warranty)::numeric *100,2) AS warranty_void_percentage
FROM warranty
WHERE repair_status='Warranty Void';

-- 6. IDENTIFY WHICH STORE HAD THE HIGHEST TOTAL UNIT SOLD IN THE LAST YEAR

SELECT *FROM stores;
SELECT *FROM sales;

SELECT sa.store_id, st.store_name, SUM(sa.quantity) as total_unit_sold
FROM sales sa
JOIN stores st
ON sa.store_id=st.store_id
WHERE sa.sale_date >= (CURRENT_DATE - INTERVAL '1 YEAR')
GROUP BY sa.store_id, st.store_name
ORDER BY total_unit_sold DESC
LIMIT 1;

-- 7. COUNT THE NUMBER OF UNIQUE PRODUCTS SOLD IN THE LAST YEAR
SELECT *FROM sales;
SELECT *FROM products;

SELECT COUNT(DISTINCT s.product_id) as unique_product_sold
FROM sales s
WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 YEAR');

-- 8. FIND THE AVERAGE PRICE OF PRODUCTS IN EACH CATEGORY
SELECT *FROM category;
SELECT *FROM products;

SELECT c.category_id, c.category_name, AVG(p.price) AS average_price
FROM category c
JOIN products p
ON c.category_id=p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY average_price DESC;


-- 9. HOW MANY WARRANTY CLAIMS WERE FILED IN 2020
SELECT *FROM warranty;

SELECT COUNT(*) AS warranty_claim
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date)=2020;

-- 10. FOR EACH STORE, IDENTIFY THE BEST-SELLING DAY BASED ON HIGHEST QUANTITY SOLD.
SELECT *FROM stores;
SELECT *FROM sales;

SELECT *FROM
(
	SELECT store_id, TO_CHAR(sale_date, 'Day') AS day_name, SUM(quantity) AS total_unit_sold,
	RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rank
	FROM sales
	GROUP BY store_id, day_name
) AS t1
WHERE rank=1;

-- 11. IDENTIFY THE LEAST SELLING PRODUCT IN EACH COUNTRY FOR EACH YEAR BASED ON TOTAL UNITS SOLD
SELECT *FROM stores;
SELECT *FROM sales;
SELECT *FROM products;

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

-- 12. CALCULATE HOW MANY WARRANTY CLAIMS WERE FILED WITHIN 180 DAYS OF PRODUCT SALE.

SELECT *FROM warranty;
SELECT *FROM sales;

SELECT COUNT(*) as no_of_claim_received_within_180_days
FROM warranty w 
LEFT JOIN sales s
ON w.sale_id=s.sale_id
WHERE w.claim_date-s.sale_date<=180;

-- 13. DETERIMNE HOW MANY WARRANTY CLAIMS WERE FILED FOR PRODUCTS LAUNCHED IN THE LAST TWO YEARS

SELECT *FROM products;
SELECT *FROM sales;
SELECT *FROM warranty;

SELECT p.product_name, COUNT(w.claim_id) as no_of_claim, COUNT(s.sale_id)
FROM warranty as w
RIGHT JOIN sales as s
ON w.sale_id=s.sale_id
JOIN products as p
ON s.product_id=p.product_id
WHERE p.launch_date >= CURRENT_DATE - INTERVAL '2 YEARS'
GROUP BY p.product_name;

-- 14. LIST THE MONTHS IN THE LAST THREE YEARS WHERE SALES EXCEEDED 5000 UNITS IN THE USA

SELECT *FROM sales;
SELECT *FROM stores;

SELECT TO_CHAR(sale_date, 'MM-YYYY') AS months, SUM(s.quantity) AS total_unit_sold
FROM sales AS s
JOIN stores AS st
ON s.store_id=st.store_id
WHERE st.country='USA' AND s.sale_date >= CURRENT_DATE - INTERVAL '3 YEAR'
GROUP BY 1
HAVING SUM(s.quantity) > 5000;

-- 15. IDENTIFY THE PRODUCT CATEGORY WITH THE MOST WARRANTY CLAIMS FILED IN THE LAST TWO YEARS
SELECT *FROM category;
SELECT *FROM products;
SELECT *FROM sales;
SELECT *FROM warranty;

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

-- 16. DETERMINE THE PERCENTAGE CHANCE OF RECEIVING WARRANTY CLAIMS AFTER EACH PURCHASE FOR EACH COUNTRY

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

-- 17. ANALYZE YEAR BY YEAR GROWTH RATIO FOR EACH STORE

SELECT *FROM stores;
SELECT *FROM sales;
SELECT *FROM products;

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

-- 18. CALCULATE THE CORRELATION BETWEEN PRODUCT PRICE AND WARRANTY CLAIMS FOR PRODUCTS SOLD IN THE LAST FIVE YEARS, SEGMENTED BY PRICE RANGE.

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

-- 19. IDENDITY THE STORE WITH THE HIGHEST PERCENTAGE OF "Paid Repaired" CLAIMS RELATIVE TO TOTAL CLAIMS FILED 

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

-- 20. WRITE A QUERY TO CALCULATE THE MONTHLY RUNNING TOTAL OF SALES FOR EACH STORE OVER THE PAST FOUR YEARS AND COMPARE TRENDS DURING THIS PERIOD

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

-- 21. ANALYZE PRODUCT SALES TRENDS OVER TIME, SEGMENTED INTO KEY PERIODS: FROM LAUNCH TO 6 MONTHS, 6-12 MONTHS, 12-18 MONTHS, AND BEYOND 18 MONTHS

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














