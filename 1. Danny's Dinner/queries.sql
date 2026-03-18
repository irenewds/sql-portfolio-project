USE dannys_diner;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    sales.customer_id,
    SUM(menu.price) AS total_sales
FROM sales
INNER JOIN menu
    ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS total_days
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT 
    s.customer_id,
    m.product_name
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
JOIN (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order
    FROM sales
    GROUP BY customer_id
) first_orders
    ON s.customer_id = first_orders.customer_id
    AND s.order_date = first_orders.first_order;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
    m.product_name,
    count(s.product_id) AS most_purchased
FROM sales s
INNER JOIN menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY most_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH most_popular AS (
  SELECT 
    sales.customer_id, 
    menu.product_name, 
    COUNT(menu.product_id) AS order_count,
    DENSE_RANK() OVER (
      PARTITION BY sales.customer_id
      ORDER BY COUNT(sales.customer_id) DESC) AS ranked
  FROM menu
  INNER JOIN sales
    ON menu.product_id = sales.product_id
  GROUP BY sales.customer_id, menu.product_name
)

SELECT 
  customer_id, 
  product_name, 
  order_count
FROM most_popular 
WHERE ranked = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH first_purchase AS (
SELECT
    sales.customer_id,
    sales.order_date,
    members.join_date,
    sales.product_id,
    ROW_NUMBER() OVER (
        PARTITION BY sales.customer_id
        ORDER BY sales.order_date) AS rank_num,
    menu.product_name
FROM sales
INNER JOIN members
    ON sales.customer_id = members.customer_id
INNER JOIN menu
    ON sales.product_id = menu.product_id
WHERE members.join_date <= sales.order_date;
)

SELECT
    customer_id,
    product_name
FROM first_purchase
WHERE rank_num = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH last_purchase AS (
SELECT
    sales.customer_id,
    sales.order_date,
    members.join_date,
    sales.product_id,
    ROW_NUMBER() OVER (
        PARTITION BY sales.customer_id
        ORDER BY sales.order_date DESC) AS rank_num,
    menu.product_name
FROM sales
INNER JOIN members
    ON sales.customer_id = members.customer_id
INNER JOIN menu
    ON sales.product_id = menu.product_id
WHERE members.join_date > sales.order_date
)

SELECT
    customer_id,
    product_name
FROM last_purchase
WHERE rank_num = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
    sales.customer_id,
    COUNT(sales.product_id) AS total_items,
    SUM(menu.price)
FROM sales
INNER JOIN menu
    ON sales.product_id = menu.product_id
INNER JOIN members
    ON sales.customer_id = members.customer_id
    AND members.join_date > sales.order_date
GROUP BY sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS (
SELECT 
    product_id,
    CASE
        WHEN product_id = 1 THEN price * 20
        ELSE price * 10 END AS points
FROM menu
)

SELECT
    sales.customer_id,
    SUM(points_cte.points) AS total_points
FROM sales
INNER JOIN points_cte
    ON sales.product_id = points_cte.product_id
GROUP BY sales.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

