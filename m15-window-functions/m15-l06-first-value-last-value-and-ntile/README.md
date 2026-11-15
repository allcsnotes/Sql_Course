# M15-L06 · FIRST_VALUE, LAST_VALUE and NTILE

> Video: Module 15, Lesson 6. Watch it first, then follow along here.

## What you'll learn

- `FIRST_VALUE`: the value from the first row of the window, on every row
- `LAST_VALUE` and its trap: the default frame only reaches the current row
- `NTILE(n)`: split sorted rows into n groups (busiest quarter, quietest quarter)
- The median with `PERCENTILE_CONT` and a real value with `PERCENTILE_DISC`
- Three mistakes: the default frame, a missing `WITHIN GROUP`, and expecting equal groups

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads the `sales` table (the first 8 days of January 2026). The queries change nothing.
- After the lesson, run `setup.sql` (DB update 7): it adds the `newsletter` table that [M15-L07](../m15-l07-top-n-per-group-and-removing-duplicates/) cleans up.

## Files in this folder

| File | What it is |
|---|---|
| `first_last_ntile.sql` | Every query from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | DB update 7: creates the `newsletter` table with 6 sign-ups (Asha and Ravi twice). Run it once after this lesson |

## Follow along

How does each day compare with the very first day? And which days were the busiest? The first day sold ₹60, the last day ₹655, and the busiest days go in the top group.

```text
FIRST_VALUE -> every row looks back to the start (60)
NTILE(4)    -> sort busiest to quietest, cut into 4 groups of 2 days
```

All queries use the same `daily` CTE: one row per day for the first 8 days (sales before 10 January).

### 1. FIRST_VALUE

`FIRST_VALUE(total) OVER (ORDER BY day)`. The order decides which row is first.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  FIRST_VALUE(total) OVER (ORDER BY day) AS first_day
FROM daily ORDER BY day;
```

You should see `first_day` = 60 on all 8 rows (the total of 2 January). Now each day can be compared with how you started.

### 2. LAST_VALUE has a trap

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAST_VALUE(total) OVER (ORDER BY day) AS last_day
FROM daily ORDER BY day;
```

You would expect 655 on every row, but each row just shows its own total:

| day | total | last_day |
|---|---|---|
| 2026-01-02 | 60 | 60 |
| 2026-01-03 | 170 | 170 |
| 2026-01-04 | 445 | 445 |
| ... | ... | ... |
| 2026-01-09 | 655 | 655 |

By default, with `ORDER BY`, the window (the **frame**) only reaches the current row, so the last row it sees is itself.

### 3. The fix: the full frame

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAST_VALUE(total) OVER (
    ORDER BY day
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS last_day
FROM daily ORDER BY day;
```

Now the window covers every row, and every row shows `655`, the total of 9 January.

### 4. NTILE

`NTILE(4) OVER (ORDER BY total DESC)` sorts the days, busiest first, and splits them into 4 groups.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  NTILE(4) OVER (ORDER BY total DESC) AS band
FROM daily ORDER BY total DESC;
```

You should see:

| day | total | band |
|---|---|---|
| 2026-01-09 | 655 | 1 |
| 2026-01-08 | 485 | 1 |
| 2026-01-04 | 445 | 2 |
| 2026-01-06 | 370 | 2 |
| 2026-01-07 | 260 | 3 |
| 2026-01-05 | 250 | 3 |
| 2026-01-03 | 170 | 4 |
| 2026-01-02 | 60 | 4 |

8 days into 4 groups is 2 days each. Handy for top-quarter and bottom-quarter reports.

### 5. The median

`PERCENTILE_CONT(0.5)` (continuous) `WITHIN GROUP (ORDER BY total)`: 0.5 means halfway. `PERCENTILE_DISC(0.5)` (discrete) picks a real value from the list instead.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) AS median,
  PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY total) AS real_day
FROM daily;
```

You should see:

| median | real_day |
|---|---|
| 315 | 260 |

With 8 days there is no single middle day, so `PERCENTILE_CONT` takes the point halfway between 260 and 370. `PERCENTILE_DISC` picks the real value 260.

## Common mistakes

All three were run for real in the video.

1. **`LAST_VALUE` with the default frame.** Each row just gets its own total (step 2). Fix: add the full frame, `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.

2. **Leaving out `WITHIN GROUP`.**

   ```sql
   SELECT PERCENTILE_CONT(0.5) AS median
   FROM daily;
   ```

   (with the same `daily` CTE in front)

   ```text
   ERROR: function percentile_cont(numeric) does not exist   (SQLSTATE 42883)
   ```

   Fix: write `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total)`. Then the median is 315.

3. **Expecting equal groups.** `NTILE(3)` on 8 days gives groups of 3, 3 and 2: band 1 is 655, 485, 445; band 2 is 370, 260, 250; band 3 is 170, 60. The first groups get the extra rows.

## Try it yourself

1. Split the days into a busy half and a quiet half. (The video's task.)
2. Show each day's total minus the first day's total (`total - FIRST_VALUE(total) OVER (ORDER BY day)`).
3. Find the 25th percentile of the daily totals with `PERCENTILE_CONT(0.25)`.

## Answers

1. `NTILE(2)`:

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
   )
   SELECT day, total,
     NTILE(2) OVER (ORDER BY total DESC) AS half
   FROM daily ORDER BY total DESC;
   ```

   Half 1 (busy): 655, 485, 445, 370. Half 2 (quiet): 260, 250, 170, 60.

2. 0, 110, 385, 190, 310, 200, 425, 595.

3. 230: three quarters of the way from 170 to 250 in the sorted list (60, 170, 250, 260, ...).

## Next

[M15-L07 · Top N per Group, and Removing Duplicates](../m15-l07-top-n-per-group-and-removing-duplicates/)
