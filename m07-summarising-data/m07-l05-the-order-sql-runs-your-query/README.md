# M07-L05 · The Order SQL Runs Your Query

> Video: Module 7, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- You write `SELECT` first, but PostgreSQL runs `FROM` first and `SELECT` fifth
- The run order: `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `SELECT`, `ORDER BY`, `LIMIT`
- New names (aliases) are made in `SELECT`, so only `ORDER BY` can use them
- The written order is still fixed, starting with `SELECT`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `run_order.sql` | The two queries from the video, with the run order as comments |
| `mistakes.sql` | The three beginner mistakes and their fixes |

## Follow along

When you write a query, you write `SELECT` first. But PostgreSQL runs it in a different order. It runs `FROM` first, and `SELECT` almost last. Once you know the real order, the errors from the last lessons suddenly make sense.

### 1. Written order, and run order

Here is a query with all seven parts:

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE price >= 30
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY items DESC, category
LIMIT 2;
```

You should see:

| category | items |
|----------|------:|
| Snack | 4 |
| Chai | 2 |

| Written order | Run order |
|---------------|-----------|
| 1. SELECT | 1. FROM |
| 2. FROM | 2. WHERE |
| 3. WHERE | 3. GROUP BY |
| 4. GROUP BY | 4. HAVING |
| 5. HAVING | 5. SELECT |
| 6. ORDER BY | 6. ORDER BY |
| 7. LIMIT | 7. LIMIT |

### 2. Step by step

1. `FROM` picks the table: 10 rows.
2. `WHERE` keeps the 8 that cost ₹30 or more.
3. `GROUP BY` makes 3 piles: Chai 2, Coffee 2, Snack 4.
4. `HAVING` keeps the piles with 2 or more items, and all 3 piles stay.
5. Only now does `SELECT` run. It picks the columns and gives `COUNT(*)` its new name, `items`.
6. `ORDER BY` sorts the piles, biggest first (Chai and Coffee tie at 2, so `category` breaks the tie).
7. `LIMIT` keeps the top 2.

### 3. Why some names fail

Here `price * 2` gets the new name `two_cups`. `ORDER BY` can use that name, because it runs after `SELECT`, when the name already exists:

```sql
SELECT name, price * 2 AS two_cups
FROM menu_items
ORDER BY two_cups DESC
LIMIT 3;
```

You should see:

| name | two_cups |
|------|---------:|
| Cold Coffee | 160 |
| Veg Sandwich | 140 |
| Maggi | 120 |

But `WHERE` runs before `SELECT`. At that moment the name does not exist yet (mistake 1 below).

## Common mistakes

The queries are in `mistakes.sql`.

**1. Using a new name too early.**

```sql
SELECT name, price * 2 AS two_cups
FROM menu_items
WHERE two_cups > 100;
```

```text
SQL Error [42703]: ERROR: column "two_cups" does not exist
```

`WHERE` runs before `SELECT`, so the name does not exist yet. Repeat the calculation instead:

```sql
SELECT name, price * 2 AS two_cups
FROM menu_items
WHERE price * 2 > 100;
```

You should see Cold Coffee 160, Maggi 120 and Veg Sandwich 140.

**2. Writing the parts in the wrong order.** Here `LIMIT` comes before `ORDER BY`:

```sql
SELECT name, price
FROM menu_items
LIMIT 3
ORDER BY price DESC;
```

```text
SQL Error [42601]: ERROR: syntax error at or near "ORDER"
```

The written order is fixed: `ORDER BY` first, then `LIMIT`:

```sql
SELECT name, price
FROM menu_items
ORDER BY price DESC
LIMIT 3;
```

You should see Cold Coffee 80, Veg Sandwich 70 and Maggi 60.

**3. The same thing happens with HAVING.** It also runs before `SELECT`, so `HAVING items >= 3` fails with `column "items" does not exist` (you saw this in [M07-L04](../m07-l04-having-vs-where/)). Write the summary itself: `HAVING COUNT(*) >= 3`.

## Try it yourself

1. Find the highest price in each category, except Coffee, with the biggest first. Before you run it, say which part runs first.
2. In step 1's query, which parts may use the name `items`?
3. Write a query that shows `name` and `price * 3 AS three_cups` for items where three cups cost under ₹100.

## Answers

1. The task from the video:

   ```sql
   SELECT category, MAX(price) AS top
   FROM menu_items
   WHERE category <> 'Coffee'
   GROUP BY category
   ORDER BY top DESC;
   ```

   `FROM` runs first, then `WHERE` removes the coffee rows. You should see Snack 70 and Chai 30.
2. Only `ORDER BY` (and `LIMIT`, which does not need it). `WHERE`, `GROUP BY` and `HAVING` run before `SELECT` makes the name. (PostgreSQL also lets `GROUP BY` use a select name as a convenience, as in M07-L03.)
3. `SELECT name, price * 3 AS three_cups FROM menu_items WHERE price * 3 < 100;` (Cutting Chai 60, Samosa 75, and the three ₹30 items at 90).

## Next

[M07-L06 · FILTER: Many Counts in One Query](../m07-l06-filter-many-counts-in-one-query/)
