# M09-L01 · INNER JOIN: Pairing Matching Rows

> Video: Module 9, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What a **join** does: puts two tables side by side and pairs the rows that belong together
- How to write `FROM orders INNER JOIN customers ON ...`
- Why you write the table name before each column (`orders.order_id`)
- How the same pattern turns item IDs into item names
- The three classic join mistakes: an ambiguous column, a forgotten `ON`, the wrong columns

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`, `order_items`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `inner_join.sql` | Every query of the video, in order, with the result as a comment |

## Follow along

### 1. Who is customer 5?

```sql
SELECT order_id, customer_id
FROM orders
ORDER BY order_id
LIMIT 5;
```

| order_id | customer_id |
|---|---|
| 1 | 5 |
| 2 | 7 |
| 3 | 6 |
| 4 | 11 |
| 5 | 9 |

Order 1 says customer 5, but the name lives in another table:

```sql
SELECT customer_id, name
FROM customers
ORDER BY customer_id;
```

You should see 15 rows: 1 Asha, 2 Lukas, 3 Priya, 4 Rahul, 5 Kabir, 6 Ananya, 7 Rohan, 8 Isha, 9 Vikram, 10 Neha, 11 Arjun, 12 Sara, 13 Dev, 14 Tara, 15 Kiran.

### 2. Pairing rows, by hand

Take the first order: its `customer_id` is 5. Look for 5 in `customers`: Kabir. That pair becomes one row. Do the same for every order: order 2 finds Rohan, order 3 finds Ananya, and so on.

That is an **inner join**: it keeps every pair that matches.

### 3. Writing the join

- Start with `FROM orders`, then add `INNER JOIN customers`, the second table.
- The word `ON` tells the database how to pair them: the `customer_id` in `orders` must equal the `customer_id` in `customers`.
- Write the table name before each column, like `orders.order_id`, so nothing gets mixed up.

```sql
SELECT orders.order_id, customers.name
FROM orders
INNER JOIN customers
  ON orders.customer_id = customers.customer_id
ORDER BY orders.order_id
LIMIT 5;
```

You should see:

| order_id | name |
|---|---|
| 1 | Kabir |
| 2 | Rohan |
| 3 | Ananya |
| 4 | Arjun |
| 5 | Vikram |

### 4. Joining items

`order_items` stores only item IDs. Join it to `menu_items` to get the names:

```sql
SELECT order_items.order_id, menu_items.name, order_items.qty
FROM order_items
INNER JOIN menu_items
  ON order_items.item_id = menu_items.item_id
WHERE order_items.order_id = 2;
```

You should see:

| order_id | name | qty |
|---|---|---|
| 2 | Cutting Chai | 1 |
| 2 | Masala Chai | 2 |
| 2 | Samosa | 1 |

Real names, not numbers.

## Common mistakes

**1. A column that both tables have, without its table name.**

```sql
SELECT order_id, customer_id, name
FROM orders
INNER JOIN customers
  ON orders.customer_id = customers.customer_id;
```

```text
SQL Error [42702]: ERROR: column reference "customer_id" is ambiguous
  Position: 18
```

Write `orders.customer_id` (or `customers.customer_id`).

**2. Forgetting `ON`.** The database cannot know which rows belong together. In PostgreSQL, `FROM orders INNER JOIN customers;` with no `ON` is a `syntax error at or near ";"`. Always say how to pair them.

**3. Matching the wrong columns,** like `ON orders.order_id = customers.customer_id`. You still get names, but the wrong ones (order 1 would show Asha instead of Kabir). Match the foreign key to its primary key.

## Try it yourself

1. Which city was order 1 placed in? Join `orders` to `branches`. Guess first, then run it.
2. Show order 3's items with their names and quantities.
3. List the first 5 orders with the customer's name *and* the `ordered_at` time.

## Next

[M09-L02 · LEFT JOIN and RIGHT JOIN: Keeping Rows With No Match](../m09-l02-left-join-and-right-join-keeping-rows-with-no-match/)

## Answers

1. Mumbai:
   ```sql
   SELECT orders.order_id, branches.city
   FROM orders
   INNER JOIN branches
     ON orders.branch_id = branches.branch_id
   WHERE orders.order_id = 1;
   ```
2. Filter Coffee 1, Samosa 1: the step 4 query with `WHERE order_items.order_id = 3`.
3. Add `orders.ordered_at` to the `SELECT` list of the step 3 query. Order 1 is Kabir at 2026-02-24 20:03:00.
