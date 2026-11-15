# M08-L04 · Relationships: One to One, One to Many, Many to Many

> Video: Module 8, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- The three kinds of **relationship** (link) between tables: one to many, many to many, one to one
- Where the foreign key goes in a one to many link (on the many side)
- Why many to many needs a **junction table** (`order_items`) with two foreign keys
- Why the pair `(order_id, item_id)` is the junction table's primary key
- Why one to one is rare and often lives in one table

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need Chai Corner update 4 (`orders` and `order_items`) from [M08-L03](../m08-l03-foreign-keys-linking-tables-together/).
- DBeaver connected to `chai_corner`. The one `INSERT` here fails on purpose, so nothing changes.

## Files in this folder

| File | What it is |
|---|---|
| `relationships.sql` | Every statement of the video, in order, with the result or error as a comment |

## Follow along

### 1. One to many: one branch, many orders

One branch has many orders, but each order belongs to just one branch. Count the orders for each branch:

```sql
SELECT branch_id, COUNT(*) AS orders
FROM orders
GROUP BY branch_id
ORDER BY branch_id;
```

You should see:

| branch_id | orders |
|---|---|
| 1 | 1522 |
| 2 | 976 |
| 3 | 502 |

Pune (1) has 1,522 orders, Mumbai (2) 976, Delhi (3) 502.

The rule: **the foreign key goes on the many side.** Each order stores one `branch_id`. The branch stores nothing about its orders.

```text
branches (one)              orders (many)
branch_id 1 Pune  <-------  order 2  branch_id 1
                  <-------  order 3  branch_id 1
                  <-------  order 4  branch_id 1 ...
```

### 2. Many to many: orders and menu items

One order can have many items, and one item is in many orders. One column cannot hold this, so a **junction table** sits in the middle: `order_items`. Each row links one order to one item.

```sql
SELECT * FROM order_items ORDER BY order_id, item_id LIMIT 8;
```

You should see:

| order_id | item_id | qty |
|---|---|---|
| 1 | 3 | 1 |
| 2 | 3 | 1 |
| 2 | 7 | 2 |
| 2 | 8 | 1 |
| 3 | 4 | 1 |
| 3 | 8 | 1 |
| 4 | 3 | 3 |
| 5 | 1 | 1 |

Order 2 has three rows: item 3 (Cutting Chai), item 7 (Masala Chai) and item 8 (Samosa).

### 3. One item, many orders

```sql
SELECT item_id, COUNT(*) AS orders
FROM order_items
GROUP BY item_id
ORDER BY item_id;
```

You should see 10 rows:

| item_id | orders |
|---|---|
| 1 | 575 |
| 2 | 375 |
| 3 | 920 |
| 4 | 407 |
| 5 | 528 |
| 6 | 396 |
| 7 | 961 |
| 8 | 534 |
| 9 | 606 |
| 10 | 228 |

Item 7, Masala Chai, appears in 961 orders.

### 4. The junction key

In the junction table, the pair `(order_id, item_id)` is the primary key. Try to add Cutting Chai (item 3) to order 1 again:

```sql
INSERT INTO order_items VALUES (1, 3, 1);
```

Refused:

```text
SQL Error [23505]: ERROR: duplicate key value violates unique constraint "order_items_pkey"
  Detail: Key (order_id, item_id)=(1, 3) already exists.
```

Each pair appears only once. To sell two cups, change the `qty`. Do not add a second row.

### 5. One to one

The rarest kind. One branch has one manager, and one manager runs one branch. Often these simply live in the same table (a `manager` column on `branches`).

## Common mistakes

- **Many values in one cell**, like `'Masala Chai, Samosa'`. You cannot count them or link them. Use one row per item.
- **The foreign key on the wrong side.** A branch cannot store every order ID. The many side holds the key.
- **Many to many without a junction table.** Two lists of IDs never stay in step. Add a table in the middle.

## Try it yourself

1. How many orders did Kabir place? Kabir is customer 5. Guess first, then run it.
2. Which customer placed the most orders, and how many?
3. Customers and orders: which kind of relationship is it, and which table holds the foreign key?

## Next

[M08-L05 · Normalisation: 1NF, 2NF, 3NF](../m08-l05-normalisation-1nf-2nf-3nf/)

## Answers

1. 188 orders:
   ```sql
   SELECT COUNT(*) AS kabir_orders FROM orders WHERE customer_id = 5;
   ```
2. Customer 14 (Tara), 218 orders:
   ```sql
   SELECT customer_id, COUNT(*) AS orders
   FROM orders
   GROUP BY customer_id
   ORDER BY orders DESC
   LIMIT 1;
   ```
3. One to many: one customer has many orders, each order has one customer. `orders.customer_id` is the foreign key (the many side).
