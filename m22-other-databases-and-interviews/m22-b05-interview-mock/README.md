# M22-B05 · Interview Mock

> Video: Build 5 (Module 22). Watch it first, then follow along here.

## What you'll build

A practice SQL interview, with a timer. You get ten questions about the Chai Corner database. For each one:

1. Read the question, and pause the video (or cover the answer below).
2. Give yourself **three minutes**. Write your query in DBeaver, and run it.
3. Then check your answer with the one here, and keep score: **one point** for each right answer.

The ten questions use almost everything in the course: joins, `GROUP BY`, `NOT EXISTS`, `date_trunc`, a self join, a CTE, `ROW_NUMBER`, `HAVING` with `string_agg`, a window over a `SUM`, and `MIN` on a date.

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- Question 8 needs the `staff.salary` column from [M22-L03](../m22-l03-classic-interview-problems-1-second-highest-salary-duplicates-nth-row/) (DB update 16).
- A timer: your phone is fine. This build changes no data.

## Files in this folder

| File | What it is |
|---|---|
| `interview_mock.sql` | The ten answers from the video, in order, each with the real result as a comment |

## Build it step by step

Your answer can look different and still be right: what matters is that it returns the same rows. Rows with equal values may come back in a different order.

### Question 1: orders per branch city, biggest first

Join `orders` to `branches` using the branch ID. Then `GROUP BY` the city, count the rows, and sort by that count, biggest first.

```sql
SELECT b.city, COUNT(*) AS orders
FROM orders o
JOIN branches b USING (branch_id)
GROUP BY b.city
ORDER BY orders DESC;
```

You should see:

| city | orders |
|---|---|
| Pune | 1999 |
| Mumbai | 1281 |
| Delhi | 620 |

### Question 2: the three items that sold the most, by quantity

Join `order_items` to `menu_items`. `SUM` the quantity for each item, sort it biggest first, and keep only three rows with `LIMIT`.

```sql
SELECT m.name, SUM(oi.qty) AS sold
FROM order_items oi
JOIN menu_items m USING (item_id)
GROUP BY m.name
ORDER BY sold DESC
LIMIT 3;
```

You should see:

| name | sold |
|---|---|
| Masala Chai | 1704 |
| Cutting Chai | 1592 |
| Vada Pav | 1045 |

### Question 3: branches that have never had a single order

Use `NOT EXISTS`. For each branch, ask one question: is there any order with this branch ID? Keep the branches where the answer is no.

```sql
SELECT b.branch_id, b.city
FROM branches b
WHERE NOT EXISTS (
  SELECT 1 FROM orders o
  WHERE o.branch_id = b.branch_id)
ORDER BY b.branch_id;
```

You should see 7 rows, from Bengaluru to Kochi. Only Pune, Mumbai and Delhi take orders so far.

| branch_id | city |
|---|---|
| 4 | Bengaluru |
| 5 | Chennai |
| 6 | Hyderabad |
| 7 | Kolkata |
| 8 | Jaipur |
| 9 | Ahmedabad |
| 10 | Kochi |

### Question 4: total revenue in each month

Revenue is quantity times price. Join three tables, and cut each order time down to its month with `date_trunc`. Then `SUM` it for each month.

```sql
SELECT date_trunc('month', o.ordered_at)::date AS month,
       SUM(oi.qty * m.price) AS revenue
FROM orders o
JOIN order_items oi USING (order_id)
JOIN menu_items m USING (item_id)
GROUP BY month
ORDER BY month;
```

You should see (March is the best month, ₹150,005):

| month | revenue |
|---|---|
| 2026-01-01 | 34490 |
| 2026-02-01 | 86770 |
| 2026-03-01 | 150005 |
| 2026-04-01 | 83245 |

### Question 5: every staff member, with the name of their manager

A self join: join `staff` to itself, with a second name, `m`, for the manager. Use a `LEFT JOIN`, so the boss still shows.

```sql
SELECT s.name, s.role, m.name AS manager
FROM staff s
LEFT JOIN staff m ON m.staff_id = s.manager_id
ORDER BY s.staff_id;
```

You should see 10 rows. Meera is the owner, so she has no manager, and you see NULL:

| name | role | manager |
|---|---|---|
| Meera | Owner | NULL |
| Imran | Area Manager | Meera |
| Pooja | Branch Manager | Imran |
| Sameer | Branch Manager | Imran |
| Kavya | Branch Manager | Imran |
| Ravi | Barista | Pooja |
| Nisha | Barista | Pooja |
| Aman | Barista | Sameer |
| Leela | Cashier | Kavya |
| Farhan | Trainee | Imran |

### Question 6: the average order value in each branch

Two steps. First, a CTE adds up the total of each order. Then take the average of those totals for each city, rounded to two places.

```sql
WITH totals AS (
  SELECT o.order_id, o.branch_id, SUM(oi.qty * m.price) AS total
  FROM orders o
  JOIN order_items oi USING (order_id)
  JOIN menu_items m USING (item_id)
  GROUP BY o.order_id, o.branch_id)
SELECT b.city, ROUND(AVG(total), 2) AS avg_order
FROM totals JOIN branches b USING (branch_id)
GROUP BY b.city ORDER BY avg_order DESC;
```

You should see:

| city | avg_order |
|---|---|
| Pune | 91.12 |
| Mumbai | 90.73 |
| Delhi | 90.56 |

### Question 7: the top two items in each branch

Sum the quantity for each branch and item. Then number the rows with `ROW_NUMBER`, partitioned by the branch, biggest first. Keep numbers one and two.

```sql
WITH sales AS (
  SELECT o.branch_id, m.name, SUM(oi.qty) AS sold,
    ROW_NUMBER() OVER (PARTITION BY o.branch_id ORDER BY SUM(oi.qty) DESC) AS rn
  FROM orders o JOIN order_items oi USING (order_id)
  JOIN menu_items m USING (item_id)
  GROUP BY o.branch_id, m.name)
SELECT b.city, s.name, s.sold, s.rn FROM sales s
JOIN branches b USING (branch_id) WHERE rn <= 2;
```

You should see (in every branch, Masala Chai first and Cutting Chai second; in Pune they are only six apart):

| city | name | sold | rn |
|---|---|---|---|
| Pune | Masala Chai | 848 | 1 |
| Pune | Cutting Chai | 842 | 2 |
| Mumbai | Masala Chai | 570 | 1 |
| Mumbai | Cutting Chai | 488 | 2 |
| Delhi | Masala Chai | 286 | 1 |
| Delhi | Cutting Chai | 262 | 2 |

### Question 8: salaries shared by more than one person, and who has them

`GROUP BY` the salary, and keep only the groups `HAVING` a count above one. `string_agg` puts the names together in one line.

```sql
SELECT salary, COUNT(*) AS people,
       string_agg(name, ', ') AS who
FROM staff
GROUP BY salary
HAVING COUNT(*) > 1
ORDER BY salary DESC;
```

You should see three salaries, each shared by two people:

| salary | people | who |
|---|---|---|
| 45000 | 2 | Pooja, Sameer |
| 22000 | 2 | Ravi, Nisha |
| 20000 | 2 | Aman, Leela |

(The order of the names inside `who` is not guaranteed. Add `ORDER BY name` inside `string_agg` if you need it fixed.)

### Question 9: revenue of each category, and its percent of the total

`SUM` the revenue for each category. For the percent, divide by the sum of all the sums, with `OVER` and empty brackets.

```sql
SELECT m.category,
       SUM(oi.qty * m.price) AS revenue,
       ROUND(100.0 * SUM(oi.qty * m.price)
             / SUM(SUM(oi.qty * m.price)) OVER (), 1) AS pct
FROM order_items oi
JOIN menu_items m USING (item_id)
GROUP BY m.category
ORDER BY revenue DESC;
```

You should see (the total is ₹354,510):

| category | revenue | pct |
|---|---|---|
| Snack | 154300 | 43.5 |
| Chai | 121250 | 34.2 |
| Coffee | 78960 | 22.3 |

### Question 10: top five customers by number of orders, with their first order date

Join `customers` to `orders`, and group by each customer. `COUNT` gives the orders, and `MIN` of the order time gives the first one. Then sort, and `LIMIT` five.

```sql
SELECT c.name,
       COUNT(*) AS orders,
       MIN(o.ordered_at)::date AS first_order
FROM customers c
JOIN orders o USING (customer_id)
GROUP BY c.customer_id, c.name
ORDER BY orders DESC, c.name
LIMIT 5;
```

You should see (Isha is the top customer, just one more than Kiran):

| name | orders | first_order |
|---|---|---|
| Isha | 273 | 2026-01-05 |
| Kiran | 272 | 2026-01-04 |
| Ananya | 267 | 2026-01-07 |
| Rohan | 267 | 2026-01-03 |
| Vikram | 267 | 2026-01-07 |

## Check your work

Add up your points:

| Score | What to do next |
|---|---|
| 8 or more | You are ready for a real SQL interview |
| 5 to 7 | Try the ones you missed again tomorrow, without looking |
| Under 5 | Go back to the joins ([Module 9](../../m09-joins/)) and grouping ([Module 7](../../m07-summarising-data/)) modules, and take this test again next week |

Quick self-checks that catch most wrong answers:

- Q1 totals 3900 orders (1999 + 1281 + 620). If yours is bigger, you joined `order_items` too and counted items, not orders.
- Q4 adds up to 354,510, the same total as Q9. Two different queries agreeing is a good sign.
- Q5 must show 10 rows. If Meera is missing, you used an inner `JOIN` instead of `LEFT JOIN`.

In a real interview, think out loud. Say your plan before you type, and check that the answer makes sense.

## Common mistakes

- Q1: `COUNT(*)` after also joining `order_items`, which counts item lines instead of orders.
- Q3: `NOT IN (SELECT branch_id FROM orders)` works here, but returns no rows at all if that list ever holds a NULL. `NOT EXISTS` is the safe habit.
- Q4: grouping by `ordered_at` itself instead of its month: you get one row per order time.
- Q5: an inner self join drops Meera, who has no manager.
- Q6: `AVG(oi.qty * m.price)` without the CTE averages item lines, not whole orders.
- Q7: `LIMIT 2` gives the top two of the whole chain, not of each branch: you need `PARTITION BY`.
- Q8: `WHERE COUNT(*) > 1` fails: a condition on a group goes in `HAVING`.
- Q9: `100 * x / total` with whole numbers rounds down to whole percents: use `100.0`.

## Next

[M22-B06 · Capstone: Raw CSV to a Final Report](../m22-b06-capstone/)
