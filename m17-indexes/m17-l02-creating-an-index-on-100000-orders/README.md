# M17-L02 · Creating an Index on 100,000 Orders

> Video: Module 17, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- How to build a big practice table, `big_orders`, with 100,000 random rows using `generate_series`
- The command `CREATE INDEX name ON table (column)`, and how to name an index
- What `EXPLAIN ANALYZE` adds to `EXPLAIN`: it really runs the query and shows the real time
- Before and after: one customer's orders went from about 12 ms to about half a millisecond
- What a **Bitmap Index Scan** is, and three mistakes when creating an index

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner`, or `psql`.
- This lesson **adds** a table, `big_orders`, and two indexes. Step 1 below creates the table.
- `big_orders` is filled with **random** numbers, so your counts and timings will not match the video exactly. The plan types (Seq Scan, Bitmap Index Scan) will.

## Files in this folder

| File | What it is |
|---|---|
| `creating_an_index.sql` | Every query from the video in order, with the video's result as a comment |
| `setup.sql` | DB update 8: `big_orders` plus `idx_big_customer` and `idx_big_total`, with a fixed seed. Only for a rebuild: you do not need it if you follow the steps |

## Follow along

Picture the table on the left: the customer IDs are in random order, so to find customer 4242 you must look at every row. `CREATE INDEX` copies that one column, sorts it, and keeps a pointer back to each row. Now all the 4242s sit together: PostgreSQL jumps to them and follows the pointers. The table itself does not change.

### 1. Build big_orders

`generate_series(1, 100000)` makes the numbers 1 to 100,000, one row each. `random()` gives a number between 0 and 1, so each row gets a random customer (1 to 5,000), branch (1 to 10) and total (₹100 to ₹1,000).

```sql
CREATE TABLE big_orders AS
SELECT g AS order_id,
  (random() * 4999)::int + 1 AS customer_id,
  (random() * 9)::int + 1 AS branch_id,
  (random() * 900)::int + 100 AS total
FROM generate_series(1, 100000) AS g;
```

You should see `SELECT 100000`. The table has **no index** yet, not even a primary key.

### 2. Count the rows

```sql
SELECT COUNT(*) AS all_rows,
       COUNT(*) FILTER (WHERE customer_id = 4242) AS for_4242
FROM big_orders;
```

In the video (yours will differ, the data is random):

| all_rows | for_4242 |
|---|---|
| 100000 | 21 |

100,000 rows in all, and just 21 belong to customer 4242.

### 3. Before: time the search

`EXPLAIN ANALYZE` really runs the query and adds the real numbers to the plan.

```sql
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242;
```

In the video (the important lines; timings on your laptop will differ):

```text
Seq Scan on big_orders  (... rows=21.00 loops=1)
  Filter: (customer_id = 4242)
  Rows Removed by Filter: 99979
...
Execution Time: 12.278 ms
```

A Seq Scan: 99,979 rows read and thrown away to keep 21. About 12 milliseconds.

### 4. Create the index

The command has three parts: `CREATE INDEX` and a name you choose (`idx_big_customer`: idx for index, then the table, then the column), `ON` and the table, and the column inside round brackets.

```sql
CREATE INDEX idx_big_customer
ON big_orders (customer_id);
```

In the video it took 0.039 seconds.

### 5. After: the same search again

```sql
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242;
```

In the video:

```text
Bitmap Heap Scan on big_orders  (... rows=21.00 loops=1)
  Recheck Cond: (customer_id = 4242)
  ->  Bitmap Index Scan on idx_big_customer  (... rows=21.00 ...)
        Index Cond: (customer_id = 4242)
...
Execution Time: 0.574 ms
```

A **Bitmap Index Scan** on `idx_big_customer`. "Bitmap" just means it first marks the matching rows in the index, then fetches them from the table (the Bitmap Heap Scan above it). The same 21 rows, about half a millisecond: more than 20 times faster.

> Your plan has extra lines such as `Buffers:` and `Index Searches:`. PostgreSQL 18 adds them; you can ignore them for now.

## Common mistakes

All three were run in the video.

1. **Using the same name twice.**

   ```sql
   CREATE INDEX idx_big_customer
   ON big_orders (customer_id);
   ```

   ```text
   ERROR: relation "idx_big_customer" already exists   (SQLSTATE 42P07)
   ```

   Every index needs its own name.

2. **Searching a different column.** The index is on `customer_id`, so a search on `branch_id` is still a Seq Scan.

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_orders
   WHERE branch_id = 3;
   ```

   ```text
   Seq Scan on big_orders  (... rows=11139.00 loops=1)
     Filter: (branch_id = 3)
     Rows Removed by Filter: 88861
   ...
   Execution Time: 6.509 ms
   ```

   Index the column you search on.

3. **Forgetting the round brackets.**

   ```sql
   CREATE INDEX idx_big_total ON big_orders total;
   ```

   ```text
   ERROR: syntax error at or near "total"   (SQLSTATE 42601)
   ```

   Put the column inside brackets: `ON big_orders (total)`.

## Try it yourself

1. Create an index on `total`, then `EXPLAIN ANALYZE` the orders where `total = 500`. Which scan, and how many rows? (The video's task.)
2. Run step 5 three times. Does the execution time stay the same?
3. Write the `CREATE INDEX` for `branch_id`, but do not run it yet. (Lesson 5 shows why an index on a column with only 10 values is a poor choice.)

## Answers

1. A Bitmap Index Scan on `idx_big_total`. In the video it found 92 rows in 0.112 ms (your count will differ).

   ```sql
   CREATE INDEX idx_big_total
   ON big_orders (total);

   EXPLAIN ANALYZE
   SELECT * FROM big_orders
   WHERE total = 500;
   ```

2. No, it moves a little every run. The first run is often slower because the data is not yet in memory. Lesson 4 comes back to this.
3. `CREATE INDEX idx_big_branch ON big_orders (branch_id);`

## Next

[M17-L03 · Multi-Column Indexes: Why Column Order Matters](../m17-l03-multi-column-indexes-why-column-order-matters/)
