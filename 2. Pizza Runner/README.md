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

```
**Result**

### Question 2
How many unique customer orders were made?
```sql

```
**Result**

### Question 3
How many successful orders were delivered by each runner?
```sql

```
**Result**

### Question 4
How many of each type of pizza was delivered?
```sql

```
**Result**

### Question 5
How many Vegetarian and Meatlovers were ordered by each customer?
```sql

```
**Result**

### Question 6
What was the maximum number of pizzas delivered in a single order?
```sql

```
**Result**

### Question 7
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql

```
**Result**

### Question 8
How many pizzas were delivered that had both exclusions and extras?
```sql

```
**Result**

### Question 9
What was the total volume of pizzas ordered for each hour of the day?
```sql

```
**Result**

### Question 10
What was the volume of orders for each day of the week?
```sql

```
**Result**


## B. Runner and Customer Experience
### Question 1
How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)?
```sql

```
**Result**

### Question 2
What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql

```
**Result**

### Question 3
Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql

```
**Result**

### Question 4
What was the average distance travelled for each customer?
```sql

```
**Result**

### Question 5
What was the difference between the longest and shortest delivery times for all orders?
```sql

```
**Result**

### Question 6
What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql

```
**Result**

### Question 7
What is the successful delivery percentage for each runner?
```sql

```
**Result**

## C. Ingredient Optimisation
### Question 1
What are the standard ingredients for each pizza?
```sql

```
**Result**

### Question 2
What was the most commonly added extra?
```sql

```
**Result**

### Question 3
What was the most common exclusion?
```sql

```
**Result**

### Question 4
Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
```sql

```
**Result**

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