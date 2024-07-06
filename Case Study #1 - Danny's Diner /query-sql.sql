-- 1. What is the total amount each customer spent at the restaurant?

SELECT a.customer_id, SUM(b.price) AS total_amount
FROM dbo.sales a
JOIN dbo.menu b
ON a.product_id = b.product_id
GROUP BY a.customer_id

-- Output:
+──────────────+──────────────+
| customer_id  | total_amount  |
+──────────────+──────────────+
| A            | 76           |
| B            | 74           |
| C            | 36           |
+──────────────+──────────────+  

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS cust_visit
FROM dbo.sales
GROUP BY customer_id

-- Output:
+──────────────+──────────────+
| customer_id  | cust_visit  |
+──────────────+──────────────+
| A            | 4           |
| B            | 6           |
| C            | 2           |
+──────────────+──────────────+  
  
-- 3. What was the first item from the menu purchased by each customer?

WITH rnk_cte AS (
SELECT a.*, b.product_name, RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
FROM dbo.sales a
JOIN dbo.menu b
ON a.product_id = b.product_id
)
SELECT customer_id, product_name
FROM rnk_cte
WHERE rnk = 1
GROUP BY customer_id, product_name

-- Output:
+──────────────+───────────────+
| customer_id  | product_name  |
+──────────────+───────────────+
| A            | sushi         |
| A	       | curry
| B            | curry         |
| C            | ramen         |
+──────────────+───────────────+
	
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

WITH cnt_cte AS (
SELECT product_id, COUNT(1) AS item_cnt
FROM dbo.sales
GROUP BY product_id
)
SELECT TOP 1 d.product_name, c.item_cnt
FROM cnt_cte c
JOIN dbo.menu d
ON c.product_id = d.product_id
ORDER BY item_cnt DESC

-- Output:
+──────────────+───────────────+
| product_name | item_cnt      |
+──────────────+───────────────+
| ramen        | 8             |
+──────────────+───────────────+

-- 5. Which item was the most popular for each customer?

WITH popular_cte AS (
SELECT customer_id, product_name, COUNT(product_name) AS item_cnt, RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS rnk
FROM dbo.sales s
JOIN dbo.menu m
ON s.product_id = m.product_id
GROUP BY customer_id, product_name
)

SELECT customer_id, product_name, item_cnt
FROM popular_cte
WHERE rnk = 1


-- Output:
+──────────────+───────────────+──────────────+
| customer_id  | product_name  | item_cnt     |
+──────────────+───────────────+──────────────+
| A            | ramen         | 3            |
| B            | ramen         | 2            |
| B            | curry         | 2            |
| B            | sushi         | 2            |
| C            | ramen         | 3            |
+──────────────+───────────────+──────────────+

-- 6. Which item was purchased first by the customer after they became a member?

WITH member_purchase_cte AS (
SELECT s.customer_id, s.order_date, me.product_name, m.join_date, DATEDIFF(DAY, s.order_date, m.join_date) AS date_diff, RANK() OVER(PARTITION BY s.customer_id ORDER BY DATEDIFF(DAY, s.order_date, m.join_date) DESC) AS rnk
FROM dbo.sales s
JOIN dbo.members m
ON s.customer_id = m.customer_id AND s.order_date > m.join_date
JOIN dbo.menu me
ON me.product_id = s.product_id
)
SELECT customer_id, product_name
FROM member_purchase_cte
WHERE rnk = 1

-- Output:
+──────────────+───────────────+
| customer_id  | product_name  |
+──────────────+───────────────+
| A            | ramen         |
| B            | sushi         |
+──────────────+───────────────+

-- 7. Which item was purchased just before the customer became a member?

WITH purchased_prior_member AS (
SELECT s.customer_id, s.order_date, me.product_name, m.join_date, DATEDIFF(DAY, s.order_date, m.join_date) AS date_diff, RANK() OVER(PARTITION BY s.customer_id ORDER BY DATEDIFF(DAY, s.order_date, m.join_date)) AS rnk
FROM dbo.sales s
JOIN dbo.members m
ON s.customer_id = m.customer_id AND s.order_date < m.join_date
JOIN dbo.menu me
ON me.product_id = s.product_id
)
SELECT customer_id, product_name
FROM purchased_prior_member
WHERE rnk = 1

-- Output:
+──────────────+───────────────+
| customer_id  | product_name  |
+──────────────+───────────────+
| A            | curry         |
| A            | sushi         |
| B            | sushi         |
+──────────────+───────────────+

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(m.product_name) AS total_items, SUM(m.price) AS amount_spent
FROM dbo.sales s
JOIN dbo.members me
ON s.customer_id = me.customer_id AND s.order_date < me.join_date
JOIN dbo.menu m
ON m.product_id = s.product_id
GROUP BY s.customer_id

-- Output:
+──────────────+──────────────+──────────────+
| customer_id  | total_items  | amount_spent |
+──────────────+──────────────+──────────────+
| A            | 2            | 25           |
| B            | 3            | 40           |
+──────────────+──────────────+──────────────+

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, SUM(CASE WHEN product_name = 'sushi' THEN 10 * 2 * price ELSE 10 * price END) AS loyalty_points
FROM dbo.sales s
JOIN dbo.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id

-- Output:
+──────────────+───────────────+
| customer_id  |loyalty_points |
+──────────────+───────────────+
| A            | 860           |
| B            | 940           |
| C            | 360           |
+──────────────+───────────────+
	
-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do 
--    customer A and B have at the end of January?

SELECT s.customer_id,
		SUM(CASE 
				WHEN product_name = 'sushi' THEN 10 * 2 * price
				WHEN DATEDIFF(DAY,  me.join_date, s.order_date) BETWEEN 0 AND 6 THEN 10 * 2 * price 
				ELSE 10 * price
			END) AS loyalty_points
FROM dbo.sales s
JOIN dbo.menu m
ON s.product_id = m.product_id
JOIN dbo.members me
ON s.customer_id = me.customer_id 
WHERE s.order_date < '2021-02-01'
GROUP BY s.customer_id

-- Output:
+──────────────+───────────────+
| customer_id  | loyalty_points|
+──────────────+───────────────+
| A            | 1370          |
| B            | 820           |
+──────────────+───────────────+
