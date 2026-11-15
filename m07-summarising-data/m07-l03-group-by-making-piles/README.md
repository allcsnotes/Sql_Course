# M07-L03 · GROUP BY: Making Piles

> Video: Module 7, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- `GROUP BY` puts the rows with the same value into one pile, then each summary runs once per pile
- `SUM`, `AVG` and every other summary work on the piles
- You can group by a calculation, like the year a customer joined
- `ORDER BY` at the end sorts the summary
- Every column in the `SELECT` must be in the `GROUP BY`, or inside a summary

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.
- Most queries span several lines. In DBeaver, put the cursor inside the query and press Ctrl+Enter.

## Files in this folder

| File | What it is |
|------|------------|
| `group_by.sql` | The four queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and the HAVING preview |

## Follow along

So far, `COUNT` gives one number for the whole table. But what if you want one number for each category? How many chai items, how many coffee items, and how many snacks? `GROUP BY` does exactly this. It makes piles, then summarises each pile.

### 1. Make the piles

```sql
SELECT category, COUNT(*) AS items FROM menu_items GROUP BY category ORDER BY category;
```

`GROUP BY category` puts the rows with the same category into one pile. The three chai rows go into the Chai pile, the two coffee rows and the five snack rows into theirs. Then `COUNT` runs once for each pile, so you get one row per pile:

| category | items |
|----------|------:|
| Chai | 3 |
| Coffee | 2 |
| Snack | 5 |

### 2. Summarise each pile

You can use any summary on the piles. `SUM` adds up the prices in each pile, and `AVG` gives each pile its own average:

```sql
SELECT category, SUM(price) AS total, ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category
ORDER BY category;
```

You should see:

| category | total | avg_price |
|----------|------:|----------:|
| Chai | 80 | 26.67 |
| Coffee | 120 | 60.00 |
| Snack | 220 | 44.00 |

Coffee totals ₹120, with an average of ₹60.

You can also group by a calculation. Group the customers by the year they joined:

```sql
SELECT EXTRACT(YEAR FROM joined_on) AS join_year, COUNT(*) AS customers
FROM customers
GROUP BY join_year
ORDER BY join_year;
```

You should see:

| join_year | customers |
|----------:|----------:|
| 2024 | 3 |
| 2025 | 9 |
| 2026 | 3 |

Nine customers joined in 2025. (PostgreSQL lets `GROUP BY` use the alias `join_year` from the `SELECT`.)

### 3. Sort the piles

Add `ORDER BY` at the end to sort the summary. `DESC` puts the biggest pile first:

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
ORDER BY items DESC;
```

You should see:

| category | items |
|----------|------:|
| Snack | 5 |
| Chai | 3 |
| Coffee | 2 |

## Common mistakes

The queries are in `mistakes.sql`.

**1. A column that is not in the GROUP BY.**

```sql
SELECT category, name, COUNT(*) AS items
FROM menu_items
GROUP BY category;
```

```text
SQL Error [42803]: ERROR: column "menu_items.name" must appear in the GROUP BY clause or be used in an aggregate function
```

Each pile holds many names, so PostgreSQL cannot show just one. Put the column in the `GROUP BY`, or wrap it in a summary like `COUNT`.

**2. Putting COUNT inside WHERE.**

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
WHERE COUNT(*) > 2
GROUP BY category;
```

```text
SQL Error [42803]: ERROR: aggregate functions are not allowed in WHERE
```

`WHERE` runs before the piles exist, so it cannot count them. To filter the piles, use `HAVING`, which is the next lesson:

```sql
SELECT category, COUNT(*) AS items
FROM menu_items
GROUP BY category
HAVING COUNT(*) > 2;
```

You should see Chai 3 and Snack 5.

**3. Grouping by a column that is different in every row.**

```sql
SELECT name, COUNT(*) AS items
FROM menu_items
GROUP BY name
ORDER BY name;
```

Each name becomes its own pile, so you get 10 rows and every count is 1. Group by the column that repeats, like `category`.

## Try it yourself

1. Find the total price of each category, with the biggest total first. Guess first, then run it.
2. Find the cheapest price in each category.
3. Count the customers who have an email, per join year.

## Answers

1. The task from the video:

   ```sql
   SELECT category, SUM(price) AS total
   FROM menu_items
   GROUP BY category
   ORDER BY total DESC;
   ```

   | category | total |
   |----------|------:|
   | Snack | 220 |
   | Coffee | 120 |
   | Chai | 80 |
2. `SELECT category, MIN(price) FROM menu_items GROUP BY category;` gives Chai 20, Coffee 40, Snack 25.
3. `SELECT EXTRACT(YEAR FROM joined_on) AS join_year, COUNT(email) FROM customers GROUP BY join_year ORDER BY join_year;` gives 2024 2, 2025 7, 2026 2.

## Next

[M07-L04 · HAVING vs WHERE](../m07-l04-having-vs-where/)
