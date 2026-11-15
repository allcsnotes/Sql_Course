# M09-L07 · JOIN Mistakes: Duplicates, Wrong Totals, Forgotten ON

> Video: Module 9, Lesson 7. Watch it first, then follow along here.

## What you'll learn

- Why the worst join mistakes give no error: the query runs, the numbers look fine, and they are wrong
- **Duplicated rows:** a join makes one row per match; fix with `DISTINCT`
- **Wrong counts and totals:** joining a table you do not need multiplies rows; fix with `COUNT(DISTINCT ...)` or by removing the join
- **The forgotten link:** a comma with no link is a hidden cross join; fix with `JOIN ... ON`
- Three quick checks to run on every join

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`, `order_items`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/) and update 5 (`staff`) from [M09-L03](../m09-l03-full-outer-join-everything-from-both-sides/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `join_mistakes.sql` | Every query of the video (each broken query, then its fix), with the result as a comment |

## Follow along

### 1. Duplicated rows

Which customers have ordered? Join `customers` to `orders` and show the names:

```sql
-- Which customers have ordered?
SELECT customers.name
FROM customers
JOIN orders ON orders.customer_id = customers.customer_id
ORDER BY customers.name;
```

You get 3,000 rows: Ananya, Ananya, Ananya, ... A join makes one row per order, so each customer repeats once for every order. Add `DISTINCT`:

```sql
SELECT DISTINCT customers.name
FROM customers
JOIN orders ON orders.customer_id = customers.customer_id
ORDER BY customers.name;
```

You should see 15 customers, each once: Ananya, Arjun, Asha, Dev, Isha, Kabir, Kiran, Lukas, Neha, Priya, Rahul, Rohan, Sara, Tara, Vikram.

### 2. Wrong counts

How many orders did Pune get? This time we also join `staff`, to see the team:

```sql
SELECT branches.city, COUNT(*) AS orders
FROM branches
JOIN orders ON orders.branch_id = branches.branch_id
JOIN staff  ON staff.branch_id  = branches.branch_id
WHERE branches.city = 'Pune'
GROUP BY branches.city;
```

| city | orders |
|---|---|
| Pune | 4566 |

But Pune only has 1,522 orders. Pune has 3 staff, so every order was copied 3 times. `COUNT(DISTINCT ...)` counts each one only once:

```sql
SELECT branches.city,
       COUNT(DISTINCT orders.order_id) AS orders,
       COUNT(DISTINCT staff.staff_id)  AS staff
FROM branches
JOIN orders ON orders.branch_id = branches.branch_id
JOIN staff  ON staff.branch_id  = branches.branch_id
WHERE branches.city = 'Pune'
GROUP BY branches.city;
```

| city | orders | staff |
|---|---|---|
| Pune | 1522 | 3 |

### 3. Wrong totals

Sums break the same way. With staff joined in:

```sql
-- Pune sales, with staff joined in
SELECT SUM(order_items.qty * menu_items.price) AS sales
FROM branches
JOIN orders      ON orders.branch_id = branches.branch_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
JOIN staff       ON staff.branch_id = branches.branch_id
WHERE branches.city = 'Pune';
```

`sales` shows 416115. Sales do not need staff, so remove that join:

```sql
SELECT SUM(order_items.qty * menu_items.price) AS sales
FROM branches
JOIN orders      ON orders.branch_id = branches.branch_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
WHERE branches.city = 'Pune';
```

The real total is 138705 (₹138,705), exactly one third. (`COUNT(DISTINCT ...)` cannot fix a sum: leave the extra table out.)

### 4. The forgotten ON

This older style lists two tables with a comma, but the link between them is missing:

```sql
-- How many orders did Rohan place?
SELECT COUNT(*) AS rohan_orders
FROM customers, orders
WHERE customers.name = 'Rohan';
```

`rohan_orders` is 3000: Rohan gets paired with every single order. Write a real `JOIN` with an `ON` link:

```sql
SELECT COUNT(*) AS rohan_orders
FROM customers
JOIN orders ON orders.customer_id = customers.customer_id
WHERE customers.name = 'Rohan';
```

Now the answer is right: 188.

## Common mistakes

These are the three quick checks for every join:

1. **Do names repeat?** If you want each one once, use `DISTINCT`.
2. **Is the number bigger than the real table?** Count with `DISTINCT`, and leave out tables you do not need.
3. **Does every table have its link?** A comma with no link is a hidden cross join. Each new table needs a `JOIN` with an `ON`.

## Try it yourself

1. Join Delhi's orders with its staff. How many rows do you get, and how many real orders? Guess first, then run it.
2. Mumbai has 2 staff. Predict the wrong `COUNT(*)` for Mumbai's orders with staff joined, then run it.
3. Which branches have ordered? Write it so that each city shows once.

## Next

[M10-L01 · A Query Inside a Query: Subquery in WHERE](../../m10-subqueries-and-set-operations/m10-l01-a-query-inside-a-query-subquery-in-where/)

## Answers

1. 1,004 rows, 502 real orders (Delhi has 2 staff):
   ```sql
   SELECT COUNT(*) AS rows_after_join,
          COUNT(DISTINCT orders.order_id) AS real_orders
   FROM branches
   JOIN orders ON orders.branch_id = branches.branch_id
   JOIN staff  ON staff.branch_id  = branches.branch_id
   WHERE branches.city = 'Delhi';
   ```
2. 976 orders × 2 staff = 1,952: the step 2 query with `'Mumbai'`.
3. `SELECT DISTINCT branches.city FROM branches JOIN orders ON orders.branch_id = branches.branch_id ORDER BY branches.city;` gives Delhi, Mumbai, Pune.
