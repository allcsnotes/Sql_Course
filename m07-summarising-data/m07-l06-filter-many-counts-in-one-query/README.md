# M07-L06 · FILTER: Many Counts in One Query

> Video: Module 7, Lesson 6. Watch it first, then follow along here.

## What you'll learn

- `COUNT(*) FILTER (WHERE ...)` counts only the rows that match
- Each summary can have its own `FILTER`, so one query gives many numbers in one pass over the table
- The old way, `SUM(CASE WHEN ... THEN 1 ELSE 0 END)`, and why `FILTER` is easier to read
- `FILTER` works inside each pile with `GROUP BY`
- Three beginner mistakes: no `WHERE` inside `FILTER`, the condition at the bottom, and no names

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `filter.sql` | The four queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes |

## Follow along

The manager asks three questions. How many items are on the menu? How many of them are chai? And how many cost ₹50 or more? You could write three queries. But `FILTER` answers all three in one query, with one number each.

### 1. FILTER counts only some rows

```sql
SELECT COUNT(*) AS all_items,
  COUNT(*) FILTER (WHERE category = 'Chai') AS chai,
  COUNT(*) FILTER (WHERE price >= 50) AS pricey
FROM menu_items;
```

You should see:

| all_items | chai | pricey |
|----------:|-----:|-------:|
| 10 | 3 | 3 |

- `COUNT(*)` counts all ten rows.
- `FILTER` goes right after the summary. Inside its brackets, `WHERE` picks the rows to count. Three items are chai.
- The next `FILTER` keeps only prices of ₹50 or more: Cold Coffee, Maggi and Veg Sandwich. That is three again.

Three numbers, one query, and one pass over the table.

### 2. The old way, using CASE WHEN

Before `FILTER`, people wrote `CASE WHEN` inside `SUM`:

```sql
SELECT COUNT(*) AS all_items,
  SUM(CASE WHEN category = 'Chai' THEN 1 ELSE 0 END) AS chai
FROM menu_items;
```

You should see `10 | 3`. Each chai row adds 1 and every other row adds 0. It also gives 3, but it is long and harder to read. `FILTER` says the same thing in plain words: count the rows where the category is Chai. Use `FILTER` in PostgreSQL, and keep `CASE WHEN` for databases that do not have it.

### 3. FILTER inside each pile

`FILTER` works with `GROUP BY` too. Each pile gets its total count, and a count of the items that cost ₹35 or more:

```sql
SELECT category, COUNT(*) AS items,
  COUNT(*) FILTER (WHERE price >= 35) AS big
FROM menu_items
GROUP BY category
ORDER BY category;
```

You should see:

| category | items | big |
|----------|------:|----:|
| Chai | 3 | 0 |
| Coffee | 2 | 2 |
| Snack | 5 | 3 |

Chai has three items, but zero big ones.

And you can ask many questions at once:

```sql
SELECT COUNT(*) AS customers,
  COUNT(*) FILTER (WHERE joined_on < '2025-01-01') AS y2024,
  COUNT(*) FILTER (WHERE joined_on >= '2025-01-01'
                     AND joined_on < '2026-01-01') AS y2025,
  COUNT(*) FILTER (WHERE joined_on >= '2026-01-01') AS y2026
FROM customers;
```

You should see:

| customers | y2024 | y2025 | y2026 |
|----------:|------:|------:|------:|
| 15 | 3 | 9 | 3 |

15 customers in total: 3 joined in 2024, 9 in 2025 and 3 in 2026.

## Common mistakes

The queries are in `mistakes.sql`.

**1. Forgetting a word inside FILTER:**

```sql
SELECT COUNT(*) AS all_items,
  COUNT(*) FILTER (category = 'Chai') AS chai
FROM menu_items;
```

```text
SQL Error [42601]: ERROR: syntax error at or near "category"
```

Inside the brackets, `WHERE` always comes first.

**2. Putting the condition at the bottom:**

```sql
SELECT COUNT(*) AS all_items,
  COUNT(*) FILTER (WHERE price >= 50) AS pricey
FROM menu_items
WHERE category = 'Chai';
```

| all_items | pricey |
|----------:|-------:|
| 3 | 0 |

`WHERE` at the bottom throws away rows for every count, so `all_items` shows 3, not 10. Put each condition inside its own `FILTER`.

**3. Forgetting the names:**

```sql
SELECT COUNT(*) FILTER (WHERE category = 'Chai'),
  COUNT(*) FILTER (WHERE category = 'Snack')
FROM menu_items;
```

Both columns are called `count` (3 and 5), and you cannot tell them apart. Give each one a name, like `AS chai` and `AS snack`.

## Try it yourself

1. In one query, count the coffee items and the items that cost under ₹30. Guess first, then run it.
2. In one query, count the customers with an email and those without one.
3. Per category, show the total price and the total of the items under ₹40.

## Answers

1. The task from the video:

   ```sql
   SELECT COUNT(*) FILTER (WHERE category = 'Coffee') AS coffee,
     COUNT(*) FILTER (WHERE price < 30) AS cheap
   FROM menu_items;
   ```

   | coffee | cheap |
   |-------:|------:|
   | 2 | 2 |

   The cheap ones are Cutting Chai and Samosa.
2. `SELECT COUNT(*) FILTER (WHERE email IS NOT NULL) AS with_email, COUNT(*) FILTER (WHERE email IS NULL) AS without_email FROM customers;` gives 11 and 4.
3. `SELECT category, SUM(price) AS total, SUM(price) FILTER (WHERE price < 40) AS small_total FROM menu_items GROUP BY category ORDER BY category;` gives Chai 80 80, Coffee 120 [NULL], Snack 220 90.

## Next

[M07-B01 · The Café Sales Report](../m07-b01-the-cafe-sales-report/)
