# 🍏 Apple Retail Sales Analysis with SQL

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

![ER Diagram](https://github.com/Mandar-Tannu/Apple-Retail-Sales-SQL-Analysis/blob/main/ER%20Diagram.png?raw=true)

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
