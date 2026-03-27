# Case Study #1 - Danny's Diner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" width="300">

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Case Study Questions

### Question 1
What is the total amount each customer spent at the restaurant?
```sql
SELECT 
    sales.customer_id,
    SUM(menu.price) AS total_sales
FROM sales
INNER JOIN menu
    ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;
```
**Result**
| customer_id | total_sales |
|-------------|--------------|
| A         | 76         |
| B         | 74         |
| C         | 36         |

### Question 2
How many days has each customer visited the restaurant?
```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS total_days
FROM sales
GROUP BY customer_id;
```
**Result**
| customer_id | total_days |
|-------------|--------------|
| A         | 4         |
| B         | 6         |
| C         | 2        |

### Question 3
What was the first item from the menu purchased by each customer?
```sql
WITH first_item AS (
SELECT
    customer_id,
    product_id,
    DENSE_RANK() OVER (
      PARTITION BY customer_id
      ORDER BY order_date) AS ranked
FROM sales
)

SELECT
    f.customer_id,
    m.product_name
FROM first_item f
INNER JOIN menu m
    ON f.product_id = m.product_id
WHERE f.ranked = 1;
```
**Result**
| customer_id | product_name |
|-------------|--------------|
| A         | sushi         |
| A         | curry         |
| B         | curry         |
| C         | ramen         |
| C         | ramen         |

### Question 4
What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
SELECT
    m.product_name,
    count(s.product_id) AS most_purchased
FROM sales s
INNER JOIN menu m
    ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY most_purchased DESC
LIMIT 1;
```
**Result**
| product_name | most_purchased |
|-------------|--------------|
| ramen         | 8         |

### Question 5
Which item was the most popular for each customer?
```sql
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
```
**Result**
| customer_id | product_name | product_name |
|-------------|--------------|--------------|
| A         | ramen         |3         |
| B         | curry         |2         |
| B         | sushi         |2         |
| B         | ramen         |2         |
| C         | ramen         |3         |

### Question 6
Which item was purchased first by the customer after they became a member?
```sql
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
WHERE members.join_date <= sales.order_date
)

SELECT
    customer_id,
    product_name
FROM first_purchase
WHERE rank_num = 1;
```
**Result**
| customer_id | product_name |
|-------------|--------------|
| A         | curry         |
| B         | sushi         |


### Question 7
Which item was purchased just before the customer became a member?
```sql
WITH last_purchase AS (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date DESC) AS ranked
    FROM sales s
    INNER JOIN members mm
        ON s.customer_id = mm.customer_id
    INNER JOIN menu m
        ON s.product_id = m.product_id
    WHERE mm.join_date > s.order_date
)

SELECT
    customer_id,
    order_date,
    product_name
FROM last_purchase
WHERE ranked = 1;
```
**Result**
| customer_id | order_date |product_name |
|-------------|--------------|--------------|
| A         | 2021-01-01         |sushi         |
| A         | 2021-01-01         |curry         |
| B         | 2021-01-04        |sushi         |

### Question 8
What is the total items and amount spent for each member before they became a member?
```sql
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
```
**Result**
| customer_id | total_items |amount_spent |
|-------------|--------------|--------------|
| B         | 3         |40         |
| A         | 2         |25         |

### Question 9
If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
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
```
**Result**
| customer_id | total_points |
|-------------|--------------|
| A         | 860         |
| B         | 940         |
| C         | 360        |

### Question 10
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
ITH jan_data AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        m.price,
        mem.join_date
    FROM sales s
    JOIN menu m
        ON s.product_id = m.product_id
    LEFT JOIN members mem
        ON s.customer_id = mem.customer_id
    WHERE s.order_date <= '2021-01-31'
),
points_cte AS (
    SELECT *,
        CASE
            WHEN join_date IS NOT NULL
             AND order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY)
                THEN price * 20
            WHEN product_name = 'sushi'
                THEN price * 20
            ELSE price * 10
        END AS points
    FROM jan_data
)

SELECT
    customer_id,
    SUM(points) AS total_points
FROM points_cte
WHERE customer_id IN ('A', 'B')
GROUP BY customer_id
ORDER BY customer_id;
```
**Result**
| customer_id | total_points |
|-------------|--------------|
| A         | 1370         |
| B         | 820         |

## Bonus Questions

### Join All The Things
Recreate a table output (Member Status)
```sql
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN mm.join_date > s.order_date THEN 'N'
        WHEN mm.join_date <= s.order_date THEN 'Y'
        ELSE 'N' END AS member
FROM sales s
LEFT JOIN members mm
    ON s.customer_id = mm.customer_id
INNER JOIN menu m
    ON s.product_id = m.product_id
ORDER BY s.customer_id, s.order_date;
```
**Result**
| customer_id | order_date |product_name |price |member |
|-------------|--------------|--------------|--------------|--------------|
| A         | 2021-01-01         |sushi         |10         |N         |
| A         | 2021-01-01         |curry         |15         |N         |
| A         | 2021-01-07         |curry         |15         |Y         |
| A         | 2021-01-10         |ramen         |12         |Y         |
| A         | 2021-01-11         |ramen         |12         |Y         |
| A         | 2021-01-11         |ramen         |12         |Y         |
| B         | 2021-01-01         |curry         |15         |N         |
| B         | 2021-01-02         |curry         |15         |N         |
| B         | 2021-01-04         |sushi         |10         |N         |
| B         | 2021-01-11         |sushi         |10         |Y         |
| B         | 2021-01-16         |ramen         |12         |Y         |
| B         | 2021-02-01         |ramen         |12         |Y         |
| C         | 2021-01-01         |ramen         |12         |N         |
| C         | 2021-01-01         |ramen         |12         |N         |
| C         | 2021-01-07         |ramen         |12         |N         |

### Rank All The Things
Recreate a table output (Member and Rank)
```sql
WITH member_cte AS (
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN mm.join_date > s.order_date THEN 'N'
        WHEN mm.join_date <= s.order_date THEN 'Y'
        ELSE 'N' END AS member
FROM sales s
LEFT JOIN members mm
    ON s.customer_id = mm.customer_id
INNER JOIN menu m
    ON s.product_id = m.product_id
ORDER BY s.customer_id, s.order_date
)

SELECT
    *,
    CASE WHEN member = 'N' THEN NULL
    ELSE RANK () OVER (
        PARTITION BY customer_id, member
        ORDER BY order_date) END AS ranking
FROM member_cte;
```
**Result**
| customer_id | order_date |product_name |price |member |ranking |
|-------------|--------------|--------------|--------------|--------------|--------------|
| A         | 2021-01-01    |sushi         |10         |N         |NULL       |
| A         | 2021-01-01    |curry         |15         |N         |NULL       |
| A         | 2021-01-07    |curry         |15         |Y         |1       |
| A         | 2021-01-10    |ramen         |12         |Y         |2       |
| A         | 2021-01-11    |ramen         |12         |Y         |3       |
| A         | 2021-01-11    |ramen         |12         |Y         |3       |
| B         | 2021-01-01    |curry         |15         |N         |NULL       |
| B         | 2021-01-02    |curry         |15         |N         |NULL       |
| B         | 2021-01-04    |sushi         |10         |N         |NULL       |
| B         | 2021-01-11    |sushi         |10         |Y         |1       |
| B         | 2021-01-16    |ramen         |12         |Y         |2       |
| B         | 2021-02-01    |ramen         |12         |Y         |3       |
| C         | 2021-01-01    |ramen         |12         |N         |NULL       |
| C         | 2021-01-01    |ramen         |12         |N         |NULL       |
| C         | 2021-01-07    |ramen         |12         |N         |NULL       |