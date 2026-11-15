# M09-L02 · LEFT JOIN and RIGHT JOIN: Keeping Rows With No Match

> Video: Module 9, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- Why an inner join drops rows that have no match (7 of the 10 branches)
- How `LEFT JOIN` keeps every row of the left table (the one right after `FROM`) and fills the gaps with `NULL`
- How `WHERE <right side> IS NULL` finds the rows with no match
- `RIGHT JOIN`, the mirror image
- Three traps: `WHERE` on the right table, `COUNT(*)`, and the tables the wrong way round

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `left_join.sql` | Every query of the video, in order, with the result as a comment |

## Follow along

### 1. Ten branches, but the inner join shows three

```sql
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
INNER JOIN orders
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC;
```

| city | orders |
|---|---|
| Pune | 1522 |
| Mumbai | 976 |
| Delhi | 502 |

Chai Corner has ten branches. The other seven have no orders: no match, so the inner join drops them.

### 2. Change one word: LEFT JOIN

Pune finds its orders, Mumbai and Delhi too. Bengaluru finds no orders at all: an inner join drops it, a **left join** keeps it and puts `NULL` where the order should be. A left join keeps every row from the left table, the one right after `FROM`.

```sql
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
```

You should see all ten branches:

| city | orders |
|---|---|
| Pune | 1522 |
| Mumbai | 976 |
| Delhi | 502 |
| Ahmedabad | 0 |
| Bengaluru | 0 |
| Chennai | 0 |
| Hyderabad | 0 |
| Jaipur | 0 |
| Kochi | 0 |
| Kolkata | 0 |

### 3. Finding the empty ones

Without the count, each lonely branch gets one row, and its `order_id` is `NULL`:

```sql
SELECT branches.city, orders.order_id
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
ORDER BY orders.order_id DESC, branches.city
LIMIT 9;
```

| city | order_id |
|---|---|
| Ahmedabad | NULL |
| Bengaluru | NULL |
| Chennai | NULL |
| Hyderabad | NULL |
| Jaipur | NULL |
| Kochi | NULL |
| Kolkata | NULL |
| Mumbai | 3000 |
| Mumbai | 2999 |

Seven NULLs (with `DESC`, PostgreSQL puts NULLs first). So ask for exactly those rows:

```sql
SELECT branches.city
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
WHERE orders.order_id IS NULL
ORDER BY branches.city;
```

You should see 7 branches that have never had a single order: Ahmedabad, Bengaluru, Chennai, Hyderabad, Jaipur, Kochi, Kolkata.

### 4. RIGHT JOIN

A right join is the mirror image: it keeps every row from the right table, the one after `JOIN`. Here `orders` comes first and `branches` second:

```sql
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM orders
RIGHT JOIN branches
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
```

Same ten rows as step 2. Most people simply swap the tables and use a left join.

## Common mistakes

**1. `WHERE` on the right table.** `NULL` fails the test, so the empty branches vanish:

```sql
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
WHERE orders.ordered_at >= '2026-03-01'
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
```

Back to 3 rows: Pune 857, Mumbai 551, Delhi 277. Put that condition inside `ON`:

```sql
SELECT branches.city, COUNT(orders.order_id) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
 AND orders.ordered_at >= '2026-03-01'
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
```

Now 10 rows: Pune 857, Mumbai 551, Delhi 277 and seven branches with 0.

**2. `COUNT(*)`.** It counts the row itself, so every empty branch shows 1, not 0:

```sql
SELECT branches.city, COUNT(*) AS orders
FROM branches
LEFT JOIN orders
  ON orders.branch_id = branches.branch_id
GROUP BY branches.city
ORDER BY orders DESC, branches.city;
```

Ahmedabad and the other six show 1. Count a column from the right table: `COUNT(orders.order_id)`.

**3. Tables the wrong way round.** A left join keeps the table after `FROM`. Put the table you want to keep first.

## Try it yourself

1. How many customers have never placed an order? Try a left join with `IS NULL`. Guess first, then run it.
2. Count the orders for each branch in February 2026 only, keeping all ten branches.
3. Rewrite the step 3 `IS NULL` query as a `RIGHT JOIN`.

## Next

[M09-L03 · FULL OUTER JOIN: Everything From Both Sides](../m09-l03-full-outer-join-everything-from-both-sides/)

## Answers

1. 0: every customer has ordered at least once.
   ```sql
   SELECT COUNT(*) AS never_ordered
   FROM customers
   LEFT JOIN orders
     ON orders.customer_id = customers.customer_id
   WHERE orders.order_id IS NULL;
   ```
2. Put both date conditions inside `ON`:
   ```sql
   SELECT branches.city, COUNT(orders.order_id) AS orders
   FROM branches
   LEFT JOIN orders
     ON orders.branch_id = branches.branch_id
    AND orders.ordered_at >= '2026-02-01'
    AND orders.ordered_at <  '2026-03-01'
   GROUP BY branches.city
   ORDER BY orders DESC, branches.city;
   ```
   Pune 463, Mumbai 313, Delhi 156, and seven branches with 0.
3. `FROM orders RIGHT JOIN branches ON orders.branch_id = branches.branch_id WHERE orders.order_id IS NULL` gives the same 7 cities.
