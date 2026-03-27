# Case Study #2 - Pizza Runner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" width="300">

Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Case Study Questions

## A. Pizza Metrics
### Question 1
How many pizzas were ordered?
```sql
SELECT COUNT(pizza_id) as pizza_order_count
FROM customer_orders;
```
**Result**
| pizza_order_count | 
|-------------|
| 14         | 

### Question 2
How many unique customer orders were made?
```sql
SELECT COUNT(DISTINCT order_id) AS order_count
FROM customer_orders;
```
**Result**
| order_count | 
|-------------|
| 10        | 

### Question 3
How many successful orders were delivered by each runner?
```sql
SELECT 
    runner_id,
    COUNT(order_id) as order_count
FROM runner_orders
WHERE cancellation = ''
GROUP BY runner_id;
```
**Result**
| runner_id | order_count |
|-------------|--------------|
| 1         | 4         |
| 2         | 3         |
| 3         | 1         |

### Question 4
How many of each type of pizza was delivered?
```sql
SELECT 
    p.pizza_name,
    COUNT(r.order_id) AS pizza_count
FROM runner_orders r
INNER JOIN customer_orders c
    ON r.order_id = c.order_id
INNER JOIN pizza_names p
    ON c.pizza_id = p.pizza_id
WHERE r.cancellation = ''
GROUP BY p.pizza_name;
```
**Result**
| pizza_name | pizza_count |
|-------------|--------------|
| Meatlovers         | 9         |
| Vegetarian         | 3         |

### Question 5
How many Vegetarian and Meatlovers were ordered by each customer?
```sql
SELECT
    c.customer_id,
    p.pizza_name,
    COUNT(c.order_id) as order_count
FROM customer_orders c
INNER JOIN pizza_names p
    ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;
```
**Result**
| customer_id | pizza_name |order_count |
|-------------|--------------|--------------|
| 101         | Meatlovers         |2         |
| 101         | Vegetarian         |1         |
| 102         | Meatlovers         |2         |
| 102         | Vegetarian         |1         |
| 103         | Meatlovers         |3         |
| 103         | Vegetarian         |1         |
| 104         | Meatlovers         |3         |
| 105         | Vegetarian         |1         |

### Question 6
What was the maximum number of pizzas delivered in a single order?
```sql
SELECT
    r.order_id,
    COUNT(c.pizza_id) AS pizza_delivered
FROM runner_orders r
INNER JOIN customer_orders c
    ON r.order_id = c.order_id
WHERE r.cancellation = ''
GROUP BY r.order_id
ORDER BY pizza_delivered DESC
LIMIT 1;
```
**Result**
| order_id | pizza_delivered |
|-------------|--------------|
| 4         | 3         |

### Question 7
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
SELECT 
  c.customer_id,
  SUM(
    CASE WHEN c.exclusions <> '' OR c.extras <> '' THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN c.exclusions = '' AND c.extras = '' THEN 1 
    ELSE 0
    END) AS no_change
FROM customer_orders AS c
JOIN runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;
```
**Result**
| customer_id | at_least_1_change |no_change |
|-------------|--------------|--------------|
| 101         | 0         |2         |
| 102         | 0         |3         |
| 103         | 3         |0         |
| 104         | 2         |1         |
| 105         | 1         |0         |


### Question 8
How many pizzas were delivered that had both exclusions and extras?
```sql
SELECT COUNT(c.order_id) AS total_pizza
FROM customer_orders c
INNER JOIN runner_orders r
    ON c.order_id = r.order_id
WHERE
    r.cancellation = ''
    AND c.exclusions != ''
    AND c.extras != '';
```
**Result**
| total_pizza |
|-------------|
| 1         |

### Question 9
What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT
    HOUR(order_time) AS hour_of_day,
    COUNT(order_id) AS total_pizza
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;
```
**Result**
| hour_of_day | total_pizza |
|-------------|--------------|
| 11         | 1         |
| 13         | 3         |
| 18         | 3         |
| 19         | 1         |
| 21         | 3         |
| 23         | 3         |

### Question 10
What was the volume of orders for each day of the week?
```sql
SELECT
    DAYNAME(order_time) AS day_of_week,
    COUNT(order_id) AS total_pizza
FROM customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;
```
**Result**
| day_of_week | total_pizza |
|-------------|--------------|
| Friday         | 1         |
| Saturday         | 5         |
| Thursday         | 3         |
| Wednesday         | 5         |


## B. Runner and Customer Experience
### Question 1
How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?
```sql
SELECT
  FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1 AS week_number,
  COUNT(*) AS runner_count
FROM runners
GROUP BY week_number
ORDER BY week_number;
```
**Result**
| week_number | runner_count |
|-------------|--------------|
| 1         | 2         |
| 2         | 1         |
| 3         | 1         |

### Question 2
What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
SELECT
    r.runner_id,
    AVG(TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_arrival_time
FROM runner_orders r
INNER JOIN customer_orders c
ON r.order_id = c.order_id
GROUP BY r.runner_id
ORDER BY r.runner_id;
```
**Result**
| runner_id | avg_arrival_time |
|-------------|--------------|
| 1         | 15.3333         |
| 2         | 23.4000         |
| 3         | 10.0000         |

### Question 3
Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
WITH pizza_count AS (
    SELECT
        c.order_id,
        COUNT(c.order_id) as pizza_order,
        c.order_time,
        r.pickup_time,
        TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time
    FROM customer_orders c
    INNER JOIN runner_orders r
        ON c.order_id = r.order_id
    WHERE r.cancellation = ''
    GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT
    pizza_order,
    AVG(prep_time) AS avg_prep_time
FROM pizza_count
GROUP BY pizza_order;
```
**Result**
| pizza_order | avg_prep_time |
|-------------|--------------|
| 1         | 12.0000         |
| 2         | 18.0000         |
| 3         | 29.0000         |


### Question 4
What was the average distance travelled for each customer?
```sql
SELECT
    c.customer_id,
    AVG(r.distance) AS avg_distance
FROM customer_orders c
INNER JOIN runner_orders r
    ON c.order_id = r.order_id
    AND r.cancellation = ''
GROUP BY c.customer_id;
```
**Result**
| customer_id | avg_distance |
|-------------|--------------|
| 101         | 20         |
| 102         | 16.7333         |
| 103         | 23.3999         |
| 104         | 10         |
| 105         | 25         |

### Question 5
What was the difference between the longest and shortest delivery times for all orders?
```sql
SELECT
    MIN(duration) AS min_delivery_time,
    MAX(duration) AS max_delivery_time,
    MAX(duration) - MIN(duration) AS dif_delivery_time
FROM runner_orders;
```
**Result**
| min_delivery_time | max_delivery_time |dif_delivery_time |
|-------------|--------------|--------------|
| 10         | 40         |30         |

### Question 6
What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql
SELECT 
    runner_id,
    order_id, 
    round(AVG(distance*60/duration),2) as avg_speed 
FROM runner_orders
where cancellation = ""
GROUP BY runner_id, order_id
ORDER BY runner_id, order_id;
```
**Result**
| runner_id | order_id |avg_speed |
|-------------|--------------|--------------|
| 1         | 1         |37.5         |
| 1         | 2         |44.44         |
| 1         | 3         |40.2         |
| 1         | 10         |60         |
| 2         | 4         |35.1         |
| 2         | 7         |60         |
| 2         | 8         |93.6         |
| 3         | 5         |40         |

### Question 7
What is the successful delivery percentage for each runner?
```sql
SELECT
    runner_id,
    ROUND(100 * SUM(
        CASE WHEN cancellation = '' THEN 1 
        ELSE 0 END) / COUNT(*), 2) AS success_percentage
FROM runner_orders
GROUP BY runner_id;
```
**Result**
| runner_id | success_percentage |
|-------------|--------------|
| 1         | 100.00         |
| 2         | 75.00         |
| 3         | 50.00         |

## C. Ingredient Optimisation
### Question 1
What are the standard ingredients for each pizza?
```sql
CREATE TEMPORARY TABLE pizza_recipes_toppings AS
SELECT 
    p.pizza_id,
    TRIM(jt.topping_id) AS topping_id,
    pt.topping_name
FROM pizza_recipes p
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(p.toppings, ',', '","'), '"]'),
    '$[*]' COLUMNS (
        topping_id VARCHAR(10) PATH '$'
    )
) AS jt
JOIN pizza_toppings pt
    ON TRIM(jt.topping_id) = pt.topping_id;

SELECT *
FROM pizza_recipes_toppings
ORDER BY pizza_id, topping_id;
```
**Result**
| pizza_id | topping_id |topping_name |
|-------------|--------------|--------------|
| 1         | 1         |Bacon         |
| 1         | 10         |Salami         |
| 1         | 2         |BBQ Sauce         |
| 1         | 3         |Beef         |
| 1         | 4         |Cheese         |
| 1         | 5         |Chicken         |
| 1         | 6         |Mushrooms         |
| 1         | 8         |Pepperoni         |
| 2         | 11         |Tomatoes         |
| 2         | 12        |Tomato Sauce         |
| 2         | 4         |Cheese         |
| 2         | 6         |Mushrooms         |
| 2         | 7         |Onions         |
| 2         | 9         |Peppers         |

### Question 2
What was the most commonly added extra?
```sql
WITH extras_split AS (
    SELECT
        c.order_id,
        CAST(TRIM(jt.extra_id) AS UNSIGNED) AS topping_id
    FROM customer_orders c
    JOIN JSON_TABLE(
        CONCAT('["', REPLACE(c.extras, ',', '","'), '"]'),
        '$[*]' COLUMNS (
            extra_id VARCHAR(10) PATH '$'
        )
    ) AS jt
    WHERE c.extras != ''
)

SELECT
    pt.topping_name,
    COUNT(*) AS total_added
FROM extras_split e
JOIN pizza_toppings pt
    ON e.topping_id = pt.topping_id
GROUP BY pt.topping_name
ORDER BY total_added DESC
LIMIT 1;
```
**Result**
| topping_name | total_added |
|-------------|--------------|
| Bacon         | 4         |

### Question 3
What was the most common exclusion?
```sql
WITH exclusions_split AS (
    SELECT
        c.order_id,
        CAST(TRIM(jt.exclusion_id) AS UNSIGNED) AS topping_id
    FROM customer_orders c
    JOIN JSON_TABLE(
        CONCAT('["', REPLACE(c.exclusions, ',', '","'), '"]'),
        '$[*]' COLUMNS (
            exclusion_id VARCHAR(10) PATH '$'
        )
    ) AS jt
    WHERE c.exclusions != ''
)

SELECT
    pt.topping_name,
    COUNT(*) AS total_excluded
FROM exclusions_split e
JOIN pizza_toppings pt
    ON e.topping_id = pt.topping_id
GROUP BY pt.topping_name
ORDER BY total_excluded DESC
LIMIT 1;
```
**Result**
| topping_name | total_excluded |
|-------------|--------------|
| Cheese         | 4         |

### Question 4
Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
```sql
SELECT
    c.order_id,
    CONCAT(
        p.pizza_name,
        IF(
            c.exclusions IS NOT NULL AND c.exclusions NOT IN ('', 'null'),
            CONCAT(
                ' - Exclude ',
                (
                    SELECT GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ')
                    FROM JSON_TABLE(
                        CONCAT('["', REPLACE(c.exclusions, ',', '","'), '"]'),
                        '$[*]' COLUMNS (id VARCHAR(10) PATH '$')
                    ) jt
                    JOIN pizza_toppings pt
                        ON pt.topping_id = CAST(jt.id AS UNSIGNED)
                )
            ),
            ''
        ),
        IF(
            c.extras IS NOT NULL AND c.extras NOT IN ('', 'null'),
            CONCAT(
                ' - Extra ',

                (
                    SELECT GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ')
                    FROM JSON_TABLE(
                        CONCAT('["', REPLACE(c.extras, ',', '","'), '"]'),
                        '$[*]' COLUMNS (id VARCHAR(10) PATH '$')
                    ) jt
                    JOIN pizza_toppings pt
                        ON pt.topping_id = CAST(jt.id AS UNSIGNED)
                )
            ),
            ''
        )
    ) AS order_item
FROM customer_orders c
JOIN pizza_names p
    ON c.pizza_id = p.pizza_id;
```
**Result**
| order_id | order_item |
|-------------|--------------|
| 1         | Meatlovers         |
| 2         | Meatlovers         |
| 3         | Meatlovers         |
| 3         | Vegetarian         |
| 4         | Meatlovers - Exclude Cheese         |
| 4         | Meatlovers - Exclude Cheese         |
| 4         | Vegetarian - Exclude Cheese         |
| 5         | Meatlovers - Extra Bacon        |
| 6         | Vegetarian         |
| 7         | Vegetarian - Extra Bacon         |
| 8         | Meatlovers         |
| 9         | Meatlovers - Exclude Cheese - Extra Bacon, Chicken         |
| 10         | Meatlovers         |
| 10         | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese         |

### Question 5
Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
```sql

```
**Result**

### Question 6
What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
```sql

```
**Result**