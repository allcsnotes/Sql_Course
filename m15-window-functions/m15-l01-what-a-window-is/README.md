# M15-L01 · What a Window Is

> Video: Module 15, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- Why `GROUP BY` cannot answer "is each item above or below the average price?"
- What a **window function** is: a calculation that looks at other rows but keeps every row
- How `OVER ()` turns `AVG`, `COUNT` and `SUM` into window functions over all the rows
- How to compare each row with the whole
- Three mistakes: a window in `WHERE`, a missing `OVER`, and `OVER` without brackets

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson reads `menu_items` (12 items, with the `category` column from Module 4). It changes nothing.

## Files in this folder

| File | What it is |
|---|---|
| `window_basics.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

Is each menu item above or below the average price? Every row needs two things: its own price, and the average of all the prices.

```text
GROUP BY:  12 rows in  ->  3 rows out (one per category, names gone)
Window:    12 rows in  -> 12 rows out (each row keeps name and price, plus a new column)
```

### 1. The old way: GROUP BY

```sql
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category ORDER BY category;
```

You should see:

| category | avg_price |
|---|---|
| Chai | 30.00 |
| Coffee | 60.00 |
| Snack | 51.67 |

Three rows, but the item names are gone.

### 2. The window way: OVER ()

Write `AVG(price)`, then the word `OVER`, then empty brackets. `OVER` makes `AVG` a window function; empty brackets mean the window is **all the rows**.

```sql
SELECT name, price,
  ROUND(AVG(price) OVER (), 2) AS avg_all
FROM menu_items ORDER BY price;
```

You should see all 12 rows, each with `45.83`:

| name | price | avg_all |
|---|---|---|
| Cutting Chai | 20 | 45.83 |
| Samosa | 25 | 45.83 |
| Masala Chai | 30 | 45.83 |
| Vada Pav | 30 | 45.83 |
| Ginger Chai | 30 | 45.83 |
| Bun Maska | 35 | 45.83 |
| Filter Coffee | 40 | 45.83 |
| Kulhad Chai | 40 | 45.83 |
| Maggi | 60 | 45.83 |
| Veg Sandwich | 70 | 45.83 |
| Cold Coffee | 80 | 45.83 |
| Paneer Roll | 90 | 45.83 |

Rows with the same price (the three ₹30 items) may come out in a different order on your machine: `ORDER BY price` does not decide between them.

### 3. Compare each row with the whole

Take the price and subtract the window average.

```sql
SELECT name, price,
  ROUND(price - AVG(price) OVER (), 2) AS vs_avg
FROM menu_items ORDER BY price DESC;
```

You should see:

| name | price | vs_avg |
|---|---|---|
| Paneer Roll | 90 | 44.17 |
| Cold Coffee | 80 | 34.17 |
| Veg Sandwich | 70 | 24.17 |
| Maggi | 60 | 14.17 |
| Filter Coffee | 40 | -5.83 |
| Kulhad Chai | 40 | -5.83 |
| Bun Maska | 35 | -10.83 |
| Vada Pav | 30 | -15.83 |
| Masala Chai | 30 | -15.83 |
| Ginger Chai | 30 | -15.83 |
| Samosa | 25 | -20.83 |
| Cutting Chai | 20 | -25.83 |

Paneer Roll is ₹44 above the average; Cutting Chai is ₹25.83 below it.

### 4. Any total can be a window

```sql
SELECT name, price,
  COUNT(*) OVER () AS items,
  SUM(price) OVER () AS menu_total
FROM menu_items ORDER BY price DESC;
```

You should see 12 rows, each with `items` = 12 and `menu_total` = 550, right next to each item.

## Common mistakes

All three were run for real in the video.

1. **A window inside `WHERE`.**

   ```sql
   SELECT name, price
   FROM menu_items
   WHERE price > AVG(price) OVER ();
   ```

   ```text
   ERROR: window functions are not allowed in WHERE   (SQLSTATE 42P20)
   ```

   Fix: work out the window in a CTE first, then filter it:

   ```sql
   WITH priced AS (
     SELECT name, price, AVG(price) OVER () AS avg_all
     FROM menu_items
   )
   SELECT name, price FROM priced
   WHERE price > avg_all ORDER BY price DESC;
   ```

   4 rows: Paneer Roll 90, Cold Coffee 80, Veg Sandwich 70, Maggi 60.

2. **Forgetting `OVER`.** Then `AVG` squashes the rows.

   ```sql
   SELECT name, price, AVG(price) AS avg_all
   FROM menu_items;
   ```

   ```text
   ERROR: column "menu_items.name" must appear in the GROUP BY clause or be used in an aggregate function   (SQLSTATE 42803)
   ```

   Fix: add `OVER ()` to keep every row.

3. **`OVER` without its brackets.**

   ```sql
   SELECT name, price, AVG(price) OVER AS avg_all
   FROM menu_items;
   ```

   ```text
   ERROR: syntax error at or near "AS"   (SQLSTATE 42601)
   ```

   Fix: always write `OVER`, then brackets: `OVER ()`.

## Try it yourself

1. What percent of the whole menu total is each item? (The video's task.)
2. Show each item with the cheapest price on the menu next to it (`MIN(price) OVER ()`).
3. List only the items below the average price, using a CTE.

## Answers

1. Paneer Roll is 16.4% of the menu total.

   ```sql
   SELECT name, price,
     ROUND(100.0 * price / SUM(price) OVER (), 1) AS pct
   FROM menu_items ORDER BY price DESC;
   ```

   | name | price | pct |
   |---|---|---|
   | Paneer Roll | 90 | 16.4 |
   | Cold Coffee | 80 | 14.5 |
   | Veg Sandwich | 70 | 12.7 |
   | Maggi | 60 | 10.9 |
   | Filter Coffee | 40 | 7.3 |
   | Kulhad Chai | 40 | 7.3 |
   | Bun Maska | 35 | 6.4 |
   | Vada Pav | 30 | 5.5 |
   | Masala Chai | 30 | 5.5 |
   | Ginger Chai | 30 | 5.5 |
   | Samosa | 25 | 4.5 |
   | Cutting Chai | 20 | 3.6 |

2. `SELECT name, price, MIN(price) OVER () AS cheapest FROM menu_items;` gives 20 on every row.

3. Same CTE as mistake 1, with `WHERE price < avg_all`: 8 items, from Kulhad Chai and Filter Coffee (40) down to Cutting Chai (20).

## Next

[M15-L02 · ROW_NUMBER, RANK, DENSE_RANK](../m15-l02-row-number-rank-dense-rank/)
