# M14-L02 · Many CTEs: Small, Readable Steps

> Video: Module 14, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- How to write several named steps after one `WITH`, separated by commas
- How each step reads the step above it, and the main query reads the last one
- A three-step question: in which months did Chai Corner have its good days?
- Each branch's share of all sales, with two steps and a `CROSS JOIN`
- Four habits for reading a long query, and three mistakes with many CTEs

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads the `sales` table (January to March 2026). It changes nothing.
- [M14-L01](../m14-l01-with-naming-a-step-of-your-query/) showed one named step, `daily`.

## Files in this folder

| File | What it is |
|---|---|
| `many_ctes.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

Real questions often need three or four steps. "In which months did Chai Corner have its good days?" means: the total for each day, then keep the good days, then count them by month.

Think of a line of workers. Each one does one small job and passes the result to the next:

```text
sales  ->  daily (one row per day)  ->  good (days above average)  ->  main query (count per month)
```

### 1. Two steps, joined by a comma

`daily` is the same step as before. After its closing bracket comes a **comma**, then the next name `good`, `AS` and an open bracket. Do not write `WITH` a second time. Inside `good`, you read `daily` and keep the days whose total beats the average.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales GROUP BY day
), good AS (
  SELECT * FROM daily WHERE total > (SELECT AVG(total) FROM daily)
)
SELECT * FROM good ORDER BY day LIMIT 5;
```

You should see:

| day | total |
|---|---|
| 2026-02-12 | 4255 |
| 2026-02-14 | 3985 |
| 2026-02-16 | 3515 |
| 2026-02-17 | 3385 |
| 2026-02-18 | 4595 |

The first good day was 12 February, with ₹4,255.

### 2. Change only the main query

Take the month out of each day and count the good days in each month.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales GROUP BY day
), good AS (
  SELECT * FROM daily WHERE total > (SELECT AVG(total) FROM daily)
)
SELECT EXTRACT(MONTH FROM day) AS month, COUNT(*) AS good_days
FROM good GROUP BY month ORDER BY month;
```

You should see:

| month | good_days |
|---|---|
| 2 | 12 |
| 3 | 30 |

12 + 30 = 42, the same as last lesson. January is missing: not one day in January beat the average.

### 3. Each branch's share of all sales

Step one, `branch_sales`: the total for each branch. Step two, `overall`: reads `branch_sales` and adds the totals into one number. The main query joins the two steps with a `CROSS JOIN`, so every branch row gets the overall total, then divides.

```sql
WITH branch_sales AS (
  SELECT branch, SUM(qty * price) AS total FROM sales GROUP BY branch
), overall AS (
  SELECT SUM(total) AS all_total FROM branch_sales
)
SELECT branch, total, ROUND(100.0 * total / all_total, 1) AS pct
FROM branch_sales CROSS JOIN overall
ORDER BY total DESC;
```

You should see:

| branch | total | pct |
|---|---|---|
| Pune | 138705 | 51.1 |
| Mumbai | 87545 | 32.3 |
| Delhi | 45015 | 16.6 |

Pune makes 51% of all sales, Mumbai 32% and Delhi about 17%.

### 4. Four habits for reading a long query

1. Read it from top to bottom, one step at a time.
2. Give each step one small job, and a name that says what it holds.
3. A step can read any step above it, but never one below it.
4. To check a step, change the main query to `SELECT * FROM` that step, and run it.

## Common mistakes

All three were run for real in the video.

1. **Writing `WITH` again before the second step.** `), WITH good AS (` gives:

   ```text
   ERROR: syntax error at or near "WITH"   (SQLSTATE 42601)
   ```

   Fix: write `WITH` only once, at the very start.

2. **Forgetting the comma between steps.** `) good AS (` gives an error that points at the next name:

   ```text
   ERROR: syntax error at or near "good"   (SQLSTATE 42601)
   ```

   Fix: put a comma after each closing bracket (except the last one).

3. **A step that reads a step below it.** With `good` written first and `daily` second:

   ```text
   ERROR: relation "daily" does not exist   (SQLSTATE 42P01)
   DETAIL: There is a WITH item named "daily", but it cannot be referenced from this part of the query.
   ```

   Fix: move `daily` to the top.

## Try it yourself

1. Keep `daily` and `good`, and find the average total of the good days. (The video's task.)
2. Use habit 4: change the main query of step 3 to `SELECT * FROM overall` and check the single total.
3. Add a third step `best` that keeps the good days above ₹6,000, and count them.

## Answers

1. ₹4,619.40.

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales GROUP BY day
   ), good AS (
     SELECT * FROM daily WHERE total > (SELECT AVG(total) FROM daily)
   )
   SELECT ROUND(AVG(total), 2) AS good_avg FROM good;
   ```

2. One row: `all_total` 271265 (138705 + 87545 + 45015).

3. ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales GROUP BY day
   ), good AS (
     SELECT * FROM daily WHERE total > (SELECT AVG(total) FROM daily)
   ), best AS (
     SELECT * FROM good WHERE total > 6000
   )
   SELECT COUNT(*) FROM best;
   ```

   4 days: 23, 27, 20 and 28 March. 21 March sold exactly ₹6,000, so `> 6000` leaves it out.

## Next

[M14-L03 · Recursive CTEs: Trees and Chains](../m14-l03-recursive-ctes-trees-and-chains/)
