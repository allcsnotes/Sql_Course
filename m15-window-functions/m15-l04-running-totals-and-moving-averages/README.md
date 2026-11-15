# M15-L04 · Running Totals and Moving Averages

> Video: Module 15, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- What a **frame** is: the set of rows the window looks at for the current row
- A **running total** with `SUM(...) OVER (ORDER BY day)`
- A 3-day **moving average** with `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`
- One running total per branch, with `PARTITION BY`
- Three mistakes: empty `OVER ()`, a frame written backwards, and ties in `ORDER BY`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads the `sales` table (first days of January 2026). It changes nothing.

## Files in this folder

| File | What it is |
|---|---|
| `window_frames.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

How much have we sold so far? Day one sold ₹60. Day two adds ₹170, so the total so far is ₹230. That is a **running total**.

```text
running total:   frame starts at the first row and grows down to the current row
moving average:  frame is 3 rows (the current row and the 2 before it), sliding down one day at a time
```

### 1. A running total

A CTE `daily` adds up the sales for each day (the first 8 days). Then `SUM(total) OVER (ORDER BY day)`.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  SUM(total) OVER (ORDER BY day) AS running
FROM daily ORDER BY day;
```

You should see:

| day | total | running |
|---|---|---|
| 2026-01-02 | 60 | 60 |
| 2026-01-03 | 170 | 230 |
| 2026-01-04 | 445 | 675 |
| 2026-01-05 | 250 | 925 |
| 2026-01-06 | 370 | 1295 |
| 2026-01-07 | 260 | 1555 |
| 2026-01-08 | 485 | 2040 |
| 2026-01-09 | 655 | 2695 |

Each day adds to all the days before it. On the last day it reaches ₹2,695, the total for all eight days.

### 2. A moving average

After `ORDER BY day`, add a frame: `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`. Preceding means before, so each row looks at itself and the two rows before it.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  ROUND(AVG(total) OVER (
    ORDER BY day
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  )) AS avg3
FROM daily ORDER BY day;
```

You should see:

| day | total | avg3 |
|---|---|---|
| 2026-01-02 | 60 | 60 |
| 2026-01-03 | 170 | 115 |
| 2026-01-04 | 445 | 225 |
| 2026-01-05 | 250 | 288 |
| 2026-01-06 | 370 | 355 |
| 2026-01-07 | 260 | 293 |
| 2026-01-08 | 485 | 372 |
| 2026-01-09 | 655 | 467 |

Take 5 January: the frame holds 170, 445 and 250, and their average is 288. A moving average smooths out the jumps, so you can see the trend.

### 3. One running total per branch

Now `daily` has one row per branch per day, and `PARTITION BY branch` comes before `ORDER BY day`.

```sql
WITH daily AS (
  SELECT branch, sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-06' GROUP BY 1, 2
)
SELECT branch, day, total,
  SUM(total) OVER (PARTITION BY branch ORDER BY day) AS running
FROM daily ORDER BY branch, day;
```

You should see:

| branch | day | total | running |
|---|---|---|---|
| Delhi | 2026-01-03 | 145 | 145 |
| Delhi | 2026-01-04 | 250 | 395 |
| Mumbai | 2026-01-02 | 60 | 60 |
| Mumbai | 2026-01-03 | 25 | 85 |
| Mumbai | 2026-01-04 | 50 | 135 |
| Mumbai | 2026-01-05 | 180 | 315 |
| Pune | 2026-01-04 | 145 | 145 |
| Pune | 2026-01-05 | 70 | 215 |

Delhi goes up to 395; Mumbai starts again at 60; Pune starts again at 145. Each shop tracks its own sales so far.

## Common mistakes

All three were run for real in the video.

1. **Empty brackets after `OVER`.** `SUM(total) OVER () AS running` in the step 1 query: no order, so every row shows the grand total, 2695. Fix: add `ORDER BY day`.

2. **Writing the frame backwards.**

   ```sql
   ROWS BETWEEN CURRENT ROW AND 2 PRECEDING
   ```

   ```text
   ERROR: frame starting from current row cannot have preceding rows   (SQLSTATE 42P20)
   ```

   Fix: the start always comes first: `2 PRECEDING AND CURRENT ROW`.

3. **Ordering by a value that repeats.**

   ```sql
   SELECT sold_at::date AS day, qty * price AS amount,
     SUM(qty * price) OVER (ORDER BY sold_at::date) AS running
   FROM sales WHERE sold_at < '2026-01-04'
   ORDER BY sold_at;
   ```

   Rows on the same day get the same total, so it jumps: `60, 60, 230, 230, 230, 230`. Fix: add a unique column to break the tie:

   ```sql
   SELECT sold_at::date AS day, qty * price AS amount,
     SUM(qty * price) OVER (ORDER BY sold_at, sale_id) AS running
   FROM sales WHERE sold_at < '2026-01-04'
   ORDER BY sold_at, sale_id;
   ```

   Now it grows one sale at a time: `30, 60, 85, 125, 205, 230`.

## Try it yourself

1. Show a two-day total: each day plus the day before it. (The video's task.)
2. Change step 2 to a 5-day moving average.
3. Add a running count of days (`COUNT(*) OVER (ORDER BY day)`) to step 1.

## Answers

1. Frame `ROWS BETWEEN 1 PRECEDING AND CURRENT ROW`:

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
   )
   SELECT day, total,
     SUM(total) OVER (
       ORDER BY day
       ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
     ) AS two_days
   FROM daily ORDER BY day;
   ```

   `two_days`: 60, 230, 615, 695, 620, 630, 745, 1140.

2. Change `2 PRECEDING` to `4 PRECEDING`.

3. The new column counts 1, 2, 3 ... 8.

## Next

[M15-L05 · LAG and LEAD](../m15-l05-lag-and-lead/)
