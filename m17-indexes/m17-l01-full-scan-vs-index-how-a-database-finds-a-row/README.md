# M17-L01 · Full Scan vs Index: How a Database Finds a Row

> Video: Module 17, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- The two ways PostgreSQL can find a row: read every row (a **Seq Scan**), or jump to it with an **index**
- Why an index is like the index at the back of a recipe book: a sorted list that points to the right row
- How a **B-tree** (the tree PostgreSQL keeps for an index) finds order 1234 in three small steps
- How to list a table's indexes with `pg_indexes` and see the plan with `EXPLAIN`
- Three mistakes that hide an index: maths on the column, `OR` with an unindexed column, casting to text

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses the `orders` table: 3,900 orders, with `order_id` as the primary key.
- DBeaver connected to `chai_corner`, or `psql`. Nothing in this lesson changes the database.

## Files in this folder

| File | What it is |
|---|---|
| `full_scan_vs_index.sql` | Every query from the video in order, with the real result as a comment |

## Follow along

Chai Corner has 3,900 orders, and you ask for one of them: order 1234. PostgreSQL can read every row until it finds it, or it can jump straight to it. That jump needs an **index**.

Think of a thick recipe book. To find Samosa without help, you turn every page. But the index at the back is sorted from A to Z: Samosa, page 212, and you jump straight there. A database index works the same way: a sorted list that points to the right row.

**The slow way, a full scan.** To find customer 7, PostgreSQL reads row one, checks it, then row two, then row three. Row two is a match, but it cannot stop: customer 7 could be in any row. So it reads all 3,900 rows to find 267 orders. PostgreSQL calls this a **Seq Scan** (sequential scan).

**The fast way, the index.** PostgreSQL keeps an index as a **B-tree**. The top box splits the order IDs into ranges. Looking for 1234? It is below 1300, so go left, then pick the box from 1200 to 1299. Inside that box sits 1234, with a pointer to its row. Three small steps, not 3,900.

### 1. List the indexes on orders

`pg_indexes` is a built-in view that lists every index.

```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'orders';
```

You should see:

| indexname | indexdef |
|---|---|
| orders_pkey | CREATE UNIQUE INDEX orders_pkey ON public.orders USING btree (order_id) |

`orders` already has one index: `orders_pkey`, a B-tree on `order_id`. The primary key made it for us.

### 2. Find order 1234

`EXPLAIN` shows the **plan**: the way PostgreSQL will find the rows. It does not run the query.

```sql
EXPLAIN
SELECT * FROM orders
WHERE order_id = 1234;
```

You should see:

```text
Index Scan using orders_pkey on orders  (cost=0.28..8.30 rows=1 width=20)
  Index Cond: (order_id = 1234)
```

**Index Scan, using orders_pkey**: the jump.

### 3. Find customer 7

```sql
EXPLAIN
SELECT * FROM orders
WHERE customer_id = 7;
```

You should see:

```text
Seq Scan on orders  (cost=0.00..73.75 rows=267 width=20)
  Filter: (customer_id = 7)
```

There is no index on `customer_id`, so it is a Seq Scan, with a **filter** that checks every row.

### 4. A range of IDs

```sql
EXPLAIN
SELECT * FROM orders
WHERE order_id BETWEEN 100 AND 105;
```

You should see:

```text
Index Scan using orders_pkey on orders  (cost=0.28..8.40 rows=6 width=20)
  Index Cond: ((order_id >= 100) AND (order_id <= 105))
```

Ranges work too, because the tree is sorted: find 100, then walk along to 105.

## Common mistakes

All three were run in the video, and all three give a Seq Scan even though `order_id` has an index.

1. **Doing maths on the column.**

   ```sql
   EXPLAIN SELECT * FROM orders WHERE order_id + 1 = 1235;
   ```

   ```text
   Seq Scan on orders  (cost=0.00..83.50 rows=20 width=20)
     Filter: ((order_id + 1) = 1235)
   ```

   The index is sorted by `order_id`, not by `order_id + 1`. Keep the column alone: `WHERE order_id = 1234`.

2. **Using OR with a column that has no index.**

   ```sql
   EXPLAIN SELECT * FROM orders WHERE order_id = 1234 OR customer_id = 7;
   ```

   ```text
   Seq Scan on orders  (cost=0.00..83.50 rows=268 width=20)
     Filter: ((order_id = 1234) OR (customer_id = 7))
   ```

   PostgreSQL must check every row for customer 7 anyway. Index that column too.

3. **Turning the column into text.**

   ```sql
   EXPLAIN SELECT * FROM orders WHERE order_id::text = '1234';
   ```

   ```text
   Seq Scan on orders  (cost=0.00..93.25 rows=20 width=20)
     Filter: ((order_id)::text = '1234'::text)
   ```

   The cast hides the index. Compare a number with a number.

## Try it yourself

1. `EXPLAIN` order 50 for customer 7: `WHERE order_id = 50 AND customer_id = 7`. Which scan do you get? (The video's task.)
2. `EXPLAIN` the orders where `order_id < 10`. Index Scan or Seq Scan?
3. List the indexes on `menu_items` with `pg_indexes`. Which column is indexed?

## Answers

1. An **Index Scan**, with a filter. The index finds order 50, then PostgreSQL checks that one row for customer 7.

   ```sql
   EXPLAIN
   SELECT * FROM orders
   WHERE order_id = 50 AND customer_id = 7;
   ```

   ```text
   Index Scan using orders_pkey on orders  (cost=0.28..8.30 rows=1 width=20)
     Index Cond: (order_id = 50)
     Filter: (customer_id = 7)
   ```

2. An Index Scan using `orders_pkey`: a small range on the sorted tree.
3. `menu_items_pkey`, a B-tree on `item_id`. Every primary key makes one.

## Next

[M17-L02 · Creating an Index on 100,000 Orders](../m17-l02-creating-an-index-on-100000-orders/)
