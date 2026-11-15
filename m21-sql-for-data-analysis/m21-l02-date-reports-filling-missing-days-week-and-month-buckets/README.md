# M21-L02 · Date Reports: Filling Missing Days, Week and Month Buckets

> Video: Module 21, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- Why a plain `GROUP BY` day report silently drops the days with no sales
- `generate_series` to make a list of every day
- `LEFT JOIN` plus `COALESCE` to turn a missing day into a zero
- `date_trunc('week', ...)` and `date_trunc('month', ...)` to put dates into week and month buckets

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver (or psql) connected to `chai_corner`.
- This lesson creates one new table, `stall_sales` (DB update 15). The monthly report uses the existing `orders` table.

## Files in this folder

| File | What it is |
|------|------------|
| `date_reports.sql` | Every query from the video, in order, with the real results as comments |
| `setup.sql` | DB update 15: rebuilds `stall_sales` (8 rows). Re-runnable. Use it to bring your database up to date if you skip the lesson |

If you already ran `setup.sql`, run `DROP TABLE stall_sales;` first so you can follow the lesson from the start.

## Follow along

### 1. The idea in three steps

1. Make a list of every day, with `generate_series`.
2. Join your sales to that list. A day with no sales gets a zero.
3. For weeks or months, cut each date back to the start of its week or month with `date_trunc`, then group.

### 2. A small tea stall

Cups sold per day, from the first to the tenth of March. Eight rows:

```sql
CREATE TABLE stall_sales (sold_on date, cups int);
INSERT INTO stall_sales VALUES
 ('2026-03-01', 40), ('2026-03-02', 35), ('2026-03-03', 52),
 ('2026-03-05', 48), ('2026-03-06', 61),
 ('2026-03-08', 30), ('2026-03-09', 44), ('2026-03-10', 57);
```

You should see `Updated Rows 8` in DBeaver. Now a daily report:

```sql
SELECT sold_on, SUM(cups) AS cups
FROM stall_sales
GROUP BY sold_on
ORDER BY sold_on;
```

You should see 8 rows:

| sold_on | cups |
|---------|------|
| 2026-03-01 | 40 |
| 2026-03-02 | 35 |
| 2026-03-03 | 52 |
| 2026-03-05 | 48 |
| 2026-03-06 | 61 |
| 2026-03-08 | 30 |
| 2026-03-09 | 44 |
| 2026-03-10 | 57 |

Look closely: after the 3rd comes the 5th, and after the 6th comes the 8th. The stall was closed on the 4th and the 7th. Those days are not zero, they are just missing, and a chart would join straight across the gap.

### 3. Make every day

`generate_series` makes a list of values. Give it a start date, an end date and a step of one day. `::date` keeps just the date, with no time:

```sql
SELECT day::date AS day
FROM generate_series('2026-03-01'::date,
                     '2026-03-10'::date,
                     interval '1 day') AS day;
```

You should see 10 rows, one for every day from `2026-03-01` to `2026-03-10`, including the 4th and the 7th.

### 4. Fill the gaps

Start from the list of days and `LEFT JOIN` the sales on the date. Every day stays, even with no match. A day with no match gets `NULL` for cups, and `COALESCE` turns that `NULL` into zero:

```sql
SELECT day::date AS day,
       COALESCE(s.cups, 0) AS cups
FROM generate_series('2026-03-01'::date,
                     '2026-03-10'::date,
                     interval '1 day') AS day
LEFT JOIN stall_sales s ON s.sold_on = day
ORDER BY day;
```

You should see:

| day | cups |
|-----|------|
| 2026-03-01 | 40 |
| 2026-03-02 | 35 |
| 2026-03-03 | 52 |
| 2026-03-04 | 0 |
| 2026-03-05 | 48 |
| 2026-03-06 | 61 |
| 2026-03-07 | 0 |
| 2026-03-08 | 30 |
| 2026-03-09 | 44 |
| 2026-03-10 | 57 |

Ten rows. The 4th and the 7th now show zero, so a chart drops to zero on those days.

### 5. Week buckets

`date_trunc('week', ...)` cuts each date back to the Monday of its week. Group by that Monday and add up the cups:

```sql
SELECT date_trunc('week', sold_on)::date AS week_start,
       SUM(cups) AS cups
FROM stall_sales
GROUP BY week_start
ORDER BY week_start;
```

You should see:

| week_start | cups |
|------------|------|
| 2026-02-23 | 40 |
| 2026-03-02 | 226 |
| 2026-03-09 | 101 |

Three weeks. The first of March 2026 was a Sunday, so it belongs to the week that started on Monday 23 February.

### 6. Month buckets on the real orders table

Months work the same way:

```sql
SELECT date_trunc('month', ordered_at)::date AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;
```

You should see:

| month | orders |
|-------|--------|
| 2026-01-01 | 383 |
| 2026-02-01 | 932 |
| 2026-03-01 | 1685 |
| 2026-04-01 | 900 |

383 orders in January, and 1,685 in March.

## Common mistakes

- **A plain `GROUP BY` on the sales table.** Days with no sales vanish. Start from `generate_series`.
- **Filtering the sales in `WHERE`, after the `LEFT JOIN`.** That throws the zero days away again. Put the condition in the `ON` part. For example, `... LEFT JOIN stall_sales s ON s.sold_on = day WHERE s.cups >= 40` gives only 6 rows, while `... LEFT JOIN stall_sales s ON s.sold_on = day AND s.cups >= 40` keeps all 10 days.
- **Grouping by the month number alone** (`EXTRACT(MONTH FROM ...)`). March 2025 and March 2026 get added together. `date_trunc` keeps the year.

## Try it yourself

1. `generate_series` from the 1st to the 31st of March, one day at a time. How many rows?
2. Change step 4 to cover 1 to 14 March. How many rows have zero cups?
3. Add up all the cups in `stall_sales`. Does it match the three weekly totals added together?

## Answers

1. 31 rows.
   ```sql
   SELECT day::date FROM generate_series('2026-03-01'::date, '2026-03-31'::date, interval '1 day') AS day;
   ```
2. 6 rows: the 4th, the 7th, and the 11th to the 14th (the data stops on the 10th).
3. Yes: `SELECT SUM(cups) FROM stall_sales;` gives 367, and 40 + 226 + 101 = 367.

## Next

[M21-L03 · Pivoting Rows into Columns](../m21-l03-pivoting-rows-into-columns/)
