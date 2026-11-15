# M15-L05 · LAG and LEAD

> Video: Module 15, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- How `LAG` takes a value from the row **before**, and `LEAD` from the row **after**
- How to work out the change from yesterday: `total - LAG(total)`
- How to give `LAG` a default instead of NULL
- Why `PARTITION BY` keeps each branch looking only at its own rows
- Three mistakes: `LAG` in `WHERE`, no partition, and mixing up `LAG` and `LEAD`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads the `sales` table (first days of January 2026). It changes nothing.

## Files in this folder

| File | What it is |
|---|---|
| `lag_lead.sql` | Every query from the video in order (mistakes included), with the real result as a comment |

## Follow along

Did we sell more today than yesterday? Each row needs to see the row before it. On 4 January we sold ₹445; the day before, ₹170. So the change is +275.

```text
LAG  -> takes the value from one row UP   (each row looks one step back)
LEAD -> takes the value from one row DOWN (each row can see tomorrow)
```

### 1. LAG

`LAG(total)`, then `OVER (ORDER BY day)`. The order tells `LAG` which row comes before.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAG(total) OVER (ORDER BY day) AS yesterday
FROM daily ORDER BY day;
```

You should see:

| day | total | yesterday |
|---|---|---|
| 2026-01-02 | 60 | NULL |
| 2026-01-03 | 170 | 60 |
| 2026-01-04 | 445 | 170 |
| 2026-01-05 | 250 | 445 |
| 2026-01-06 | 370 | 250 |
| 2026-01-07 | 260 | 370 |
| 2026-01-08 | 485 | 260 |
| 2026-01-09 | 655 | 485 |

The first row has nothing before it, so it gets NULL (an empty cell in DBeaver shows `[NULL]`).

### 2. The change from yesterday

Today minus yesterday:

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  total - LAG(total) OVER (ORDER BY day) AS change
FROM daily ORDER BY day;
```

You should see `change`: NULL, 110, 275, -195, 120, -110, 225, 170. 4 January went up by 275; 5 January went down, -195. A plus means sales grew; a minus means they dropped.

### 3. LEAD

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LEAD(total) OVER (ORDER BY day) AS tomorrow
FROM daily ORDER BY day;
```

You should see `tomorrow`: 170, 445, 250, 370, 260, 485, 655, NULL. 2 January shows 170, the total of 3 January; the last row gets NULL because there is no next day.

### 4. A default instead of NULL

`LAG(total, 1, 0)`: the `1` means one row back, and the `0` is used when there is no row.

```sql
WITH daily AS (
  SELECT sold_at::date AS day, SUM(qty * price) AS total
  FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
)
SELECT day, total,
  LAG(total, 1, 0) OVER (ORDER BY day) AS yesterday
FROM daily ORDER BY day;
```

Now the first row shows `0` instead of NULL.

## Common mistakes

All three were run for real in the video.

1. **Using `LAG` in `WHERE`.**

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
   )
   SELECT day, total
   FROM daily
   WHERE total > LAG(total) OVER (ORDER BY day);
   ```

   ```text
   ERROR: window functions are not allowed in WHERE   (SQLSTATE 42P20)
   ```

   Fix: work out `LAG` in a CTE first, then filter:

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
   ), d2 AS (
     SELECT day, total, LAG(total) OVER (ORDER BY day) AS yesterday
     FROM daily
   )
   SELECT day, total, yesterday FROM d2
   WHERE total > yesterday ORDER BY day;
   ```

   | day | total | yesterday |
   |---|---|---|
   | 2026-01-03 | 170 | 60 |
   | 2026-01-04 | 445 | 170 |
   | 2026-01-06 | 370 | 250 |
   | 2026-01-08 | 485 | 260 |
   | 2026-01-09 | 655 | 485 |

   Five days that grew.

2. **Leaving out the partition.** With one row per branch per day and `LAG(total) OVER (ORDER BY branch, day)`, Mumbai's first day gets Delhi's last total, 250:

   | branch | day | total | yesterday |
   |---|---|---|---|
   | Delhi | 2026-01-03 | 145 | NULL |
   | Delhi | 2026-01-04 | 250 | 145 |
   | Mumbai | 2026-01-02 | 60 | 250 |
   | Mumbai | 2026-01-03 | 25 | 60 |
   | ... | | | |

   Fix: `LAG(total) OVER (PARTITION BY branch ORDER BY day)`. Now the first day of each branch is NULL (both queries are in `lag_lead.sql`).

3. **Mixing them up.** `LEAD(total) AS yesterday` makes 2 January show 170, the *next* day. `LAG` is the row before, `LEAD` the row after. For yesterday, use `LAG`.

## Try it yourself

1. Show each day's total next to the total from two days before. (The video's task.)
2. Show each day's change compared with tomorrow (`LEAD(total) - total`).
3. Using the partitioned branch query, find each branch's change from its previous day.

## Answers

1. `LAG(total, 2)`: two rows back.

   ```sql
   WITH daily AS (
     SELECT sold_at::date AS day, SUM(qty * price) AS total
     FROM sales WHERE sold_at < '2026-01-10' GROUP BY 1
   )
   SELECT day, total,
     LAG(total, 2) OVER (ORDER BY day) AS two_days_ago
   FROM daily ORDER BY day;
   ```

   `two_days_ago`: NULL, NULL, 60, 170, 445, 250, 370, 260.

2. 110, 275, -195, 120, -110, 225, 170, NULL (the same numbers as step 2, moved up one row).

3. `total - LAG(total) OVER (PARTITION BY branch ORDER BY day)`: Delhi NULL, 105; Mumbai NULL, -35, 25, 130; Pune NULL, -75.

## Next

[M15-L06 · FIRST_VALUE, LAST_VALUE and NTILE](../m15-l06-first-value-last-value-and-ntile/)
