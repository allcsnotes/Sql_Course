# M08-L03 · Foreign Keys: Linking Tables Together

> Video: Module 8, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What a **foreign key** is: a column that must match a primary key in another table
- How Chai Corner update 4 splits sales into `orders` and `order_items`, linked by foreign keys
- How to follow a link by hand: order 1 → branch 2 (Mumbai), customer 5 (Kabir)
- The two errors a foreign key gives: a made-up ID, and deleting a parent that is still used
- Parent and child tables

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). Update 4 builds on the `sales` table from [Build 1](../../m07-summarising-data/m07-b01-the-cafe-sales-report/).
- **Run `setup.sql` once** (Chai Corner update 4). In DBeaver: open the file, then SQL Editor > Execute SQL Script (Alt+X). In psql: `\i setup.sql`. If DBeaver underlines the new table names, use Database > Disconnect, then Connect.
- `setup.sql` creates tables, so run it only once. A second run stops with `relation "orders" already exists`.

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | Chai Corner update 4: creates `orders` (3,000 rows) and `order_items` (5,530 rows) with their keys |
| `foreign_keys.sql` | Every statement of the video, in order, with the result or error as a comment |

## What setup.sql does

```sql
CREATE TABLE orders (
  order_id    int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES customers (customer_id),
  branch_id   int NOT NULL REFERENCES branches (branch_id),
  ordered_at  timestamp NOT NULL
);
```

`REFERENCES customers (customer_id)` makes `customer_id` a foreign key: every value must already exist in `customers`. The file fills `orders` from the 3,000 orders in `sales` (one row per order, with a customer picked by `random()` after `setseed(0.43)`, so everyone gets the same customers), then creates `order_items` (`order_id`, `item_id`, `qty`, primary key `(order_id, item_id)`) with foreign keys to `orders` and `menu_items`. Check it worked:

```sql
SELECT COUNT(*), SUM(qty) FROM order_items;
```

```text
 count | sum
-------+------
  5530 | 7535
```

## Follow along

### 1. The new orders table

```sql
SELECT * FROM orders ORDER BY order_id LIMIT 5;
```

You should see:

| order_id | customer_id | branch_id | ordered_at |
|---|---|---|---|
| 1 | 5 | 2 | 2026-02-24 20:03:00 |
| 2 | 7 | 1 | 2026-03-10 18:34:00 |
| 3 | 6 | 1 | 2026-03-23 12:19:00 |
| 4 | 11 | 1 | 2026-03-04 17:12:00 |
| 5 | 9 | 3 | 2026-03-29 18:10:00 |

`order_id` is the primary key. `customer_id` and `branch_id` are foreign keys: in DBeaver their headers show a small foreign key icon.

### 2. Follow the links of order 1

```sql
SELECT * FROM branches WHERE branch_id = 2;
```

| branch_id | city | opened_on |
|---|---|---|
| 2 | Mumbai | 2019-09-02 |

```sql
SELECT customer_id, name FROM customers WHERE customer_id = 5;
```

| customer_id | name |
|---|---|
| 5 | Kabir |

So order 1 is Kabir, at the Mumbai branch.

### 3. The key guards the link

Add an order for branch 99. There is no branch 99:

```sql
INSERT INTO orders VALUES (3001, 1, 99, '2026-04-01 10:00');
```

PostgreSQL refuses:

```text
SQL Error [23503]: ERROR: insert or update on table "orders" violates foreign key constraint "orders_branch_id_fkey"
  Detail: Key (branch_id)=(99) is not present in table "branches".
```

Every `branch_id` in `orders` must already exist in `branches`. No made-up IDs, ever.

### 4. All the links in the database

`pg_constraint` is PostgreSQL's own list of constraints; `contype = 'f'` keeps the foreign keys, and `::regclass` turns a table number into its name:

```sql
SELECT conrelid::regclass AS from_table,
       confrelid::regclass AS points_to
FROM pg_constraint
WHERE contype = 'f'
ORDER BY 1, 2;
```

You should see 4 links:

| from_table | points_to |
|---|---|
| orders | branches |
| orders | customers |
| order_items | menu_items |
| order_items | orders |

### 5. Changing the parent table

Try to delete the Pune branch, `branch_id` 1:

```sql
DELETE FROM branches WHERE branch_id = 1;
```

Refused again:

```text
SQL Error [23503]: ERROR: update or delete on table "branches" violates foreign key constraint "orders_branch_id_fkey" on table "orders"
  Detail: Key (branch_id)=(1) is still referenced from table "orders".
```

1,522 orders still point to Pune. If Pune were deleted, they would point to nothing. The table being pointed to (`branches`) is the **parent**; the table that points (`orders`) is the **child**. A parent cannot leave while children still point to it.

## Common mistakes

- **Copying the name instead of the ID.** If `orders` stored the city name, we are back to the copy-paste problems of [M08-L01](../m08-l01-why-we-split-data-into-many-tables/). Store the branch ID.
- **Adding the child before the parent.** A new branch must be added to `branches` first. Only then can an order point to it.
- **Thinking a foreign key joins the tables for you.** It only guards the link. To read both tables together you need a `JOIN`, coming in Module 9.

## Try it yourself

1. Look at order number 2. Which customer placed it? Find the customer ID, then look it up in `customers`. Guess first, then run it.
2. Which branch was order 5 made at?
3. Try `INSERT INTO order_items VALUES (1, 99, 1);`. Which constraint stops it?

## Next

[M08-L04 · Relationships: One to One, One to Many, Many to Many](../m08-l04-relationships-one-to-one-one-to-many-many-to-many/)

## Answers

1. Customer 7, Rohan:
   ```sql
   SELECT * FROM orders WHERE order_id = 2;
   SELECT customer_id, name FROM customers WHERE customer_id = 7;
   ```
   Order 2: `customer_id` 7, `branch_id` 1. Customer 7 is Rohan.
2. `branch_id` 3: `SELECT * FROM branches WHERE branch_id = 3;` gives Delhi.
3. `order_items_item_id_fkey`: `Key (item_id)=(99) is not present in table "menu_items".`
