# M07-L04 · HAVING vs WHERE

> Video: Module 7, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- `WHERE` filters the rows, before the piles are made
- `HAVING` filters the piles, after `GROUP BY`, and works with any summary
- How `WHERE`, `GROUP BY` and `HAVING` work together in one query
- Inside `HAVING`, write the summary itself (`COUNT(*)`), not its new name
- Put plain filters in `WHERE`, so rows are removed early

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.
- The queries span several lines. In DBeaver, put the cursor inside the query and press Ctrl+Enter.

## Files in this folder

| File | What it is |
|------|------------|
| `having_vs_where.sql` | The four queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and their fixes |

## Follow along

Last lesson, `GROUP BY` made piles. But what if you only want some of them? Say, only the categories with three or more items. Or only the items that cost ₹30 or more. SQL has two filters for this. `WHERE` filters the rows, before the piles are made. `HAVING` filters the piles, after.

### 1. HAVING keeps the piles you want

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING COUNT(*) >= 3;
```

First the piles are made: Chai has 3, Coffee has 2 and Snack has 5. Then `HAVING` checks each pile: is the count 3 or more? Coffee has only 2, so that pile is thrown away.

You should see:

| category | items |
|----------|------:|
| Chai | 3 |
| Snack | 5 |

`HAVING` works with any summary. Keep the categories whose average price is more than 40:

```sql
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category
HAVING AVG(price) > 40
ORDER BY category;
```

You should see:

| category | avg_price |
|----------|----------:|
| Coffee | 60.00 |
| Snack | 44.00 |

Chai averages under 40 (26.67), so it goes.

### 2. WHERE keeps the rows you want

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price >= 30
GROUP BY category
ORDER BY category;
```

`WHERE` runs first, before any piles exist. It checks one row at a time: does this item cost ₹30 or more? Cutting Chai costs ₹20 and Samosa ₹25, so both rows are thrown out. Then `GROUP BY` makes piles from the rows that are left:

| category | items |
|----------|------:|
| Chai | 2 |
| Coffee | 2 |
| Snack | 4 |

### 3. Use both together

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price >= 30
GROUP BY category
HAVING COUNT(*) >= 3;
```

1. `WHERE` keeps the 8 rows that cost ₹30 or more.
2. `GROUP BY` makes 3 piles (Chai 2, Coffee 2, Snack 4).
3. `HAVING` keeps only the piles with 3 or more items.

You should see one row:

| category | items |
|----------|------:|
| Snack | 4 |

## Common mistakes

The queries are in `mistakes.sql`.

**1. Using HAVING to check a plain column,** like `price`:

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING price > 30;
```

```text
SQL Error [42803]: ERROR: column "menu_items.price" must appear in the GROUP BY clause or be used in an aggregate function
```

A pile holds many prices, so `HAVING` cannot check just one. To check each row, use `WHERE`:

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price > 30
GROUP BY category
ORDER BY category;
```

You should see Coffee 2 and Snack 3 (no chai costs more than ₹30).

**2. Using the new name from the SELECT inside HAVING:**

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING items >= 3;
```

```text
SQL Error [42703]: ERROR: column "items" does not exist
```

Write the summary itself: `HAVING COUNT(*) >= 3`.

**3. A plain filter inside HAVING** still works:

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING category = 'Snack';
```

You get Snack 5, but every row is grouped first, and then most piles are thrown away. Put plain filters in `WHERE` instead, so the rows are removed early:

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE category = 'Snack'
GROUP BY category;
```

Same answer, Snack 5, with less work.

## Try it yourself

1. Find the categories whose total price is more than 100, with the biggest first. Guess first, then run it.
2. Find the join years with more than 2 customers who have an email.
3. Which categories have a cheapest item of ₹25 or more?

## Answers

1. The task from the video:

   ```sql
   SELECT category, SUM(price) AS total
   FROM menu_items
   GROUP BY category
   HAVING SUM(price) > 100
   ORDER BY total DESC;
   ```

   | category | total |
   |----------|------:|
   | Snack | 220 |
   | Coffee | 120 |

   Chai totals 80, so it goes.
2. `SELECT EXTRACT(YEAR FROM joined_on) AS join_year, COUNT(*) FROM customers WHERE email IS NOT NULL GROUP BY join_year HAVING COUNT(*) > 2;` gives 2025 with 7.
3. `SELECT category, MIN(price) FROM menu_items GROUP BY category HAVING MIN(price) >= 25;` gives Coffee 40 and Snack 25.

## Next

[M07-L05 · The Order SQL Runs Your Query](../m07-l05-the-order-sql-runs-your-query/)
