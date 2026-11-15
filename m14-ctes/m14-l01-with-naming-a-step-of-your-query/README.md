# M14-L01 · WITH: Naming a Step of Your Query

> Video: Module 14, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What a **CTE** (common table expression) is: a named step of a query, written with `WITH`
- How to turn 6,000 sales rows into one row per day, and call that result `daily`
- How the main query reads `daily` just like a table, as many times as it needs
- Why the same question written with subqueries gives the same answer but is harder to read
- Three beginner mistakes with `WITH`, and the real errors they give

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses the `sales` table (one row per item sold, January to March 2026, about 6,000 rows) from Build 1.
- DBeaver connected to `chai_corner`, or `psql`. Nothing in this lesson changes the database.

## Files in this folder

| File | What it is |
|---|---|
| `with_cte.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

Chai Corner asks: on which days did the cafe sell more than on an average day? That is two steps: first the total for each day, then the comparison. `WITH` lets you give the first step a name and then use that name like a table.

Think of a recipe. Step one: make the dough. Step two: use the dough to bake the bread. Here, step one turns the sales rows into one row per day (`daily`), and step two reads `daily` to give the answer. A CTE lives only while that one query runs.

### 1. Your first CTE

`WITH`, the name you choose (`daily`), `AS`, then a normal query in brackets. After the closing bracket comes the main query, which reads `daily` like a real table.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales
  GROUP BY day
)
SELECT * FROM daily ORDER BY day LIMIT 5;
```

You should see:

| day | total |
|---|---|
| 2026-01-02 | 60 |
| 2026-01-03 | 170 |
| 2026-01-04 | 445 |
| 2026-01-05 | 250 |
| 2026-01-06 | 370 |

Each row is one day. The first day, 2 January, sold ₹60.

### 2. The name works like a table

Because `daily` behaves like a table, you can ask anything about it: how many rows, and the average total.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales
  GROUP BY day
)
SELECT COUNT(*) AS days, ROUND(AVG(total), 2) AS avg_day FROM daily;
```

You should see:

| days | avg_day |
|---|---|
| 89 | 3047.92 |

89 days, and an average day sells about ₹3,048.

### 3. One name, used twice

Now the real question. The main query reads `daily` for the days and their totals, and the `WHERE` line reads `daily` a second time to find the average.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales
  GROUP BY day
)
SELECT day, total FROM daily
WHERE total > (SELECT AVG(total) FROM daily)
ORDER BY total DESC LIMIT 5;
```

You should see:

| day | total |
|---|---|
| 2026-03-23 | 7325 |
| 2026-03-27 | 6505 |
| 2026-03-20 | 6285 |
| 2026-03-28 | 6225 |
| 2026-03-21 | 6000 |

The best day was 23 March with ₹7,325. Every day here is above the average.

### 4. The same question without WITH

The same question with subqueries: the daily step is written once inside `FROM` and again inside `WHERE`.

```sql
SELECT day, total FROM (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales GROUP BY day
) d
WHERE total > (SELECT AVG(total) FROM (
  SELECT SUM(qty * price) AS total FROM sales GROUP BY sold_at::date
) d2)
ORDER BY total DESC LIMIT 5;
```

You should see exactly the same five days as step 3. `WITH` does not change the result; it makes the query easier to read.

## Common mistakes

All three were run for real in the video.

1. **Using the name in a new query.** `daily` lived only inside the last query.

   ```sql
   SELECT * FROM daily;
   ```

   ```text
   ERROR: relation "daily" does not exist   (SQLSTATE 42P01)
   ```

   Fix: write the `WITH daily AS (...)` part again, in the same query. A CTE lives for one query.

2. **A semicolon after the closing bracket.** It ends the query too early.

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales
     GROUP BY day
   );
   ```

   ```text
   ERROR: syntax error at end of input   (SQLSTATE 42601)
   ```

   (psql words it as `syntax error at or near ";"`.) Fix: one semicolon, at the very end, after the main query.

3. **Asking for a column the step does not have.** `daily` has only `day` and `total`.

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales
     GROUP BY day
   )
   SELECT branch, total FROM daily;
   ```

   ```text
   ERROR: column "branch" does not exist   (SQLSTATE 42703)
   ```

   Fix: add `branch` inside the step first. The step decides the columns.

## Try it yourself

1. Using `daily`, count how many days beat the average. (The video's task.)
2. Change step 3 to show the five **worst** days that were still above the average.
3. Write a CTE `monthly` that groups `sales` by `date_trunc('month', sold_at)` and shows the total for each month.

## Answers

1. 42 days.

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales
     GROUP BY day
   )
   SELECT COUNT(*) AS good_days FROM daily
   WHERE total > (SELECT AVG(total) FROM daily);
   ```

2. Change `ORDER BY total DESC` to `ORDER BY total ASC` and keep the same `WHERE`.

3. ```sql
   WITH monthly AS (
     SELECT date_trunc('month', sold_at) AS month, SUM(qty * price) AS total
     FROM sales
     GROUP BY month
   )
   SELECT * FROM monthly ORDER BY month;
   ```

   You get three rows: January, February and March 2026.

## Next

[M14-L02 · Many CTEs: Small, Readable Steps](../m14-l02-many-ctes-small-readable-steps/)
