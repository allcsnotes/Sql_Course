# M07-B01 · The Café Sales Report

> Video: Module 7, Build 1. Watch it first, then follow along here.

## What you'll build

Meera runs three Chai Corner cafés, in Pune, Mumbai and Delhi. Every Monday she asks the same questions:

- How much did we sell each day, each week and each month?
- Which items sell best?
- When are we busiest?
- How is each branch doing?

You answer every one of them with SQL, using only what Modules 5 to 7 taught: `SUM`, `COUNT(DISTINCT ...)`, `GROUP BY`, `DATE_TRUNC`, `EXTRACT`, casts and `FILTER`. You finish with one small table that shows the whole quarter, with a column for each branch.

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). The menu must have the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- Then run **`setup.sql`** from this folder as a whole script (DBeaver: Execute SQL Script, Alt+X; or `psql -d chai_corner -f setup.sql`). This is **Chai Corner update 3**: it creates the `sales` table, 6028 rows for 3000 orders from January to March 2026. It uses `setseed(0.42)`, so `random()` gives the same numbers for everyone and your results match the video. It is safe to run again.
- If DBeaver underlines `sales` in red after the update, use Database > Disconnect, then Connect, so it reloads the table list.

## Files in this folder

| File | What it is |
|------|------------|
| `setup.sql` | Chai Corner update 3: builds the `sales` table (run once, as a script) |
| `sales_report.sql` | Every report query from the video, in order, with its real result |
| `mistakes.sql` | The three beginner mistakes |

The `sales` table: one row = one item sold.

| Column | Meaning |
|--------|---------|
| `sale_id` | Row number (primary key) |
| `order_id` | The order this line belongs to (1 to 3000) |
| `branch` | Pune, Mumbai or Delhi |
| `item`, `category` | From `menu_items` |
| `qty` | How many (1 or 2) |
| `price` | Price of one, in rupees |
| `sold_at` | Date and time of the order |

## Build it step by step

### 1. Look at the data

```sql
SELECT branch, item, qty, price, sold_at
FROM sales
LIMIT 5;
```

You should see:

| branch | item | qty | price | sold_at |
|--------|------|----:|------:|---------|
| Mumbai | Cutting Chai | 1 | 20 | 2026-02-24 20:03:00.000 |
| Pune | Samosa | 1 | 25 | 2026-03-10 18:34:00.000 |
| Pune | Masala Chai | 2 | 30 | 2026-03-10 18:34:00.000 |
| Pune | Cutting Chai | 1 | 20 | 2026-03-10 18:34:00.000 |
| Pune | Filter Coffee | 1 | 40 | 2026-03-23 12:19:00.000 |

One order can have many rows. Look at order 2:

```sql
SELECT order_id, item, qty, price,
  qty * price AS line_total
FROM sales
WHERE order_id = 2;
```

| order_id | item | qty | price | line_total |
|---------:|------|----:|------:|-----------:|
| 2 | Samosa | 1 | 25 | 25 |
| 2 | Masala Chai | 2 | 30 | 60 |
| 2 | Cutting Chai | 1 | 20 | 20 |

A samosa, two masala chai and a cutting chai. Quantity times price gives the money for each line, so this order is ₹105.

So the plan has **two rules**:

- **Sales** = `SUM(qty * price)`
- **Orders** = `COUNT(DISTINCT order_id)`, because one order can have many rows

```sql
SELECT COUNT(DISTINCT order_id) AS orders,
  SUM(qty * price) AS sales
FROM sales;
```

| orders | sales |
|-------:|------:|
| 3000 | 271265 |

Across all three months: 3000 orders and ₹2,71,265 in sales.

### 2. Sales over time

**Daily.** `::date` turns each time into just a date. Group by that day and sum the sales:

```sql
SELECT sold_at::date AS day,
  SUM(qty * price) AS sales
FROM sales
GROUP BY day
ORDER BY day;
```

You get one row per day, in date order (89 rows):

| day | sales |
|-----|------:|
| 2026-01-02 | 60 |
| 2026-01-03 | 170 |
| 2026-01-04 | 445 |
| ... | ... |
| 2026-03-31 | 5970 |

**Weekly.** `DATE_TRUNC('week', ...)` rounds every time down to the Monday of its week:

```sql
SELECT DATE_TRUNC('week', sold_at)::date AS week,
  SUM(qty * price) AS sales
FROM sales
GROUP BY week
ORDER BY week;
```

| week | sales |
|------|------:|
| 2025-12-29 | 675 |
| 2026-01-05 | 3175 |
| 2026-01-12 | 7155 |
| 2026-01-19 | 10895 |
| 2026-01-26 | 15435 |
| 2026-02-02 | 16730 |
| 2026-02-09 | 20860 |
| 2026-02-16 | 24735 |
| 2026-02-23 | 25920 |
| 2026-03-02 | 27295 |
| 2026-03-09 | 30595 |
| 2026-03-16 | 36705 |
| 2026-03-23 | 41285 |
| 2026-03-30 | 9805 |

Sales grow from about ₹3,000 a week to over ₹30,000. (The first week starts on Monday 29 December 2025 and the last one has only two days, 30 and 31 March.)

**Monthly.** Swap `week` for `month`, and count the orders too:

```sql
SELECT DATE_TRUNC('month', sold_at)::date AS month,
  COUNT(DISTINCT order_id) AS orders,
  SUM(qty * price) AS sales
FROM sales
GROUP BY month
ORDER BY month;
```

| month | orders | sales |
|-------|-------:|------:|
| 2026-01-01 | 383 | 34490 |
| 2026-02-01 | 932 | 86770 |
| 2026-03-01 | 1685 | 150005 |

January sold ₹34,490, February about ₹87,000, March ₹1,50,005. The cafés are growing fast.

### 3. Best items and busy hours

Group by item and sort by sales, biggest first. `LIMIT 5` keeps the top five:

```sql
SELECT item,
  SUM(qty) AS sold,
  SUM(qty * price) AS sales
FROM sales
GROUP BY item
ORDER BY sales DESC
LIMIT 5;
```

| item | sold | sales |
|------|-----:|------:|
| Masala Chai | 1382 | 41460 |
| Cold Coffee | 503 | 40240 |
| Maggi | 516 | 30960 |
| Bun Maska | 764 | 26740 |
| Cutting Chai | 1294 | 25880 |

Masala Chai earns the most money, and Cold Coffee comes second. Now order the list by cups sold instead (`ORDER BY sold DESC`):

```sql
SELECT item,
  SUM(qty) AS sold,
  SUM(qty * price) AS sales
FROM sales
GROUP BY item
ORDER BY sold DESC
LIMIT 5;
```

| item | sold | sales |
|------|-----:|------:|
| Masala Chai | 1382 | 41460 |
| Cutting Chai | 1294 | 25880 |
| Vada Pav | 815 | 24450 |
| Bun Maska | 764 | 26740 |
| Samosa | 717 | 17925 |

Cutting Chai jumps to number two. It sells lots of cups, but each one costs only ₹20. So the best item depends on what you measure: cups, or money.

**Busy hours.** `EXTRACT(HOUR FROM ...)` pulls the hour out of each time. Count the orders in each hour:

```sql
SELECT EXTRACT(HOUR FROM sold_at) AS hour,
  COUNT(DISTINCT order_id) AS orders
FROM sales
GROUP BY hour
ORDER BY orders DESC
LIMIT 5;
```

| hour | orders |
|-----:|-------:|
| 9 | 438 |
| 18 | 392 |
| 17 | 294 |
| 8 | 291 |
| 20 | 163 |

Nine in the morning is the busiest, then six in the evening.

### 4. Each branch

```sql
SELECT branch,
  COUNT(DISTINCT order_id) AS orders,
  SUM(qty * price) AS sales,
  ROUND(SUM(qty * price)::numeric / COUNT(DISTINCT order_id), 2) AS avg_order
FROM sales
GROUP BY branch
ORDER BY sales DESC;
```

| branch | orders | sales | avg_order |
|--------|-------:|------:|----------:|
| Pune | 1522 | 138705 | 91.13 |
| Mumbai | 976 | 87545 | 89.70 |
| Delhi | 502 | 45015 | 89.67 |

Pune has the most orders and the most sales. The average order is sales divided by orders, and it is about ₹90 in every branch.

### 5. Make it cleaner

Meera wants one small table, with a column for each branch. `FILTER` does this. Each `SUM` gets its own `FILTER` for one branch, and the last column is the total:

```sql
SELECT DATE_TRUNC('month', sold_at)::date AS month,
  SUM(qty * price) FILTER (WHERE branch = 'Pune') AS pune,
  SUM(qty * price) FILTER (WHERE branch = 'Mumbai') AS mumbai,
  SUM(qty * price) FILTER (WHERE branch = 'Delhi') AS delhi,
  SUM(qty * price) AS total
FROM sales
GROUP BY month ORDER BY month;
```

| month | pune | mumbai | delhi | total |
|-------|-----:|-------:|------:|------:|
| 2026-01-01 | 18450 | 9310 | 6730 | 34490 |
| 2026-02-01 | 43985 | 29215 | 13570 | 86770 |
| 2026-03-01 | 76270 | 49020 | 24715 | 150005 |

Three rows, five columns, and the whole quarter on one screen. Pune alone sold ₹76,270 in March.

## Check your work

When the parts add up to the total, you can trust the report:

| Check | Sum | Total |
|-------|-----|------:|
| Three branches | 138705 + 87545 + 45015 | 271265 |
| Three months | 34490 + 86770 + 150005 | 271265 |
| Each row of the step 5 table | 18450 + 9310 + 6730 | 34490 |
| Orders per branch | 1522 + 976 + 502 | 3000 |

All match the quarter total from step 1: 3000 orders, ₹2,71,265.

## Common mistakes

The queries are in `mistakes.sql`.

**1. Counting orders with COUNT(*).**

```sql
SELECT branch,
  COUNT(*) AS orders,
  SUM(qty * price) AS sales
FROM sales
GROUP BY branch
ORDER BY sales DESC;
```

| branch | orders | sales |
|--------|-------:|------:|
| Pune | 3054 | 138705 |
| Mumbai | 1952 | 87545 |
| Delhi | 1022 | 45015 |

That counts rows, not orders, so Pune shows over 3000 orders. Use `COUNT(DISTINCT order_id)`.

**2. Dividing two whole numbers.**

```sql
SELECT branch,
  SUM(qty * price) / COUNT(DISTINCT order_id) AS avg_order
FROM sales
GROUP BY branch
ORDER BY avg_order DESC;
```

| branch | avg_order |
|--------|----------:|
| Pune | 91 |
| Delhi | 89 |
| Mumbai | 89 |

PostgreSQL drops the decimals, so Mumbai and Delhi both show 89 (and Delhi even comes above Mumbai). Turn the sales into numeric first, then divide, as in step 4.

**3. Missing days.**

```sql
SELECT COUNT(*) AS rows_on_jan_1
FROM sales
WHERE sold_at::date = '2026-01-01';
```

You get `0`. The daily report starts on 2 January, because 1 January had no sales. A day with no rows never shows up, so look for gaps.

## Try it yourself

1. Find the sales for each category, in March only. Guess which category wins, then run it.
2. Which branch sold the most Cold Coffee cups?
3. Make the step 5 table with orders instead of sales.

## Answers

1. The task from the video:

   ```sql
   SELECT category,
     SUM(qty * price) AS sales
   FROM sales
   WHERE sold_at >= '2026-03-01'
   GROUP BY category
   ORDER BY sales DESC;
   ```

   | category | sales |
   |----------|------:|
   | Snack | 66445 |
   | Chai | 49880 |
   | Coffee | 33680 |

   Snack wins.
2. `SELECT branch, SUM(qty) AS cups FROM sales WHERE item = 'Cold Coffee' GROUP BY branch ORDER BY cups DESC;` (Pune is first).
3. Replace each `SUM(qty * price)` with `COUNT(DISTINCT order_id)`: January gives 383 orders in total, as in step 2.

## Next

[M08-L01 · Why We Split Data into Many Tables](../../m08-designing-a-database/m08-l01-why-we-split-data-into-many-tables/)
