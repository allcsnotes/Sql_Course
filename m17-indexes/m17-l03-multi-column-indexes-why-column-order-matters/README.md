# M17-L03 · Multi-Column Indexes: Why Column Order Matters

> Video: Module 17, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- How one index can hold two columns: `ON big_orders (customer_id, branch_id)`
- Why the index is sorted like a phone book: by the first column, then by the second inside it
- The rule: a two-column index helps when your search includes the **first** column
- How to remove an index with `DROP INDEX`
- Three mistakes: searching only the second column, `OR` instead of `AND`, a missing comma

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses `big_orders` (100,000 random orders) and its index `idx_big_customer` from [M17-L02](../m17-l02-creating-an-index-on-100000-orders/).
- `big_orders` holds random data, so your row counts and timings will differ from the video. The plan types will match.

## Files in this folder

| File | What it is |
|---|---|
| `multi_column_indexes.sql` | Every query from the video in order, with the video's result as a comment |
| `setup.sql` | The index change this lesson makes (drop `idx_big_customer`, add `idx_big_cust_branch`). Only for a rebuild |

## Follow along

Think of a phone book. It is sorted by surname first, then by first name inside each surname. Our index works the same way: sorted by customer ID first, then by branch ID inside each customer.

- Customer 4242 in branch 3? Jump straight there.
- Just customer 4242? Jump to that block.
- Branch 3 alone? Those rows are spread all over the list. The index cannot help.

### 1. Start clean

`DROP INDEX` removes last lesson's one-column index. The table and its rows are not touched. (DBeaver asks you to confirm.)

```sql
DROP INDEX idx_big_customer;
```

### 2. One index, two columns

Same command as before, but two columns inside the brackets, with a comma between them. `customer_id` comes first, so it is sorted first.

```sql
CREATE INDEX idx_big_cust_branch
ON big_orders (customer_id, branch_id);
```

In the video it took 0.054 seconds.

### 3. Search both columns

```sql
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242 AND branch_id = 3;
```

In the video (key lines; yours will differ):

```text
Bitmap Heap Scan on big_orders  (... rows=4.00 loops=1)
  ->  Bitmap Index Scan on idx_big_cust_branch  (... rows=4.00 ...)
        Index Cond: ((customer_id = 4242) AND (branch_id = 3))
...
Execution Time: 0.294 ms
```

The new index is used: 4 rows, in about 0.3 milliseconds.

### 4. Only the first column

```sql
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE customer_id = 4242;
```

In the video:

```text
Bitmap Heap Scan on big_orders  (... rows=21.00 loops=1)
  ->  Bitmap Index Scan on idx_big_cust_branch  (... rows=21.00 ...)
        Index Cond: (customer_id = 4242)
...
Execution Time: 0.672 ms
```

Still a Bitmap Index Scan, finding customer 4242's 21 rows. The first column alone is enough.

### 5. Only the second column

```sql
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE branch_id = 3;
```

In the video:

```text
Seq Scan on big_orders  (... rows=11139.00 loops=1)
  Filter: (branch_id = 3)
  Rows Removed by Filter: 88861
...
Execution Time: 6.147 ms
```

A Seq Scan: it skipped 88,861 rows. Branch 3 is spread all over the index, so PostgreSQL reads the whole table instead.

## Common mistakes

1. **Searching only the second column.** That is step 5: a Seq Scan. Put the column you search alone **first** in the index.

2. **Using OR instead of AND.**

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_orders
   WHERE customer_id = 4242 OR branch_id = 3;
   ```

   ```text
   Seq Scan on big_orders  (... rows=11156.00 loops=1)
     Filter: ((customer_id = 4242) OR (branch_id = 3))
     Rows Removed by Filter: 88844
   ...
   Execution Time: 6.218 ms
   ```

   `OR` needs an index for each side. Here the branch side has none it can use, so every row is checked.

3. **Forgetting the comma.**

   ```sql
   CREATE INDEX idx_big_cb2
   ON big_orders (customer_id branch_id);
   ```

   ```text
   ERROR: operator class "branch_id" does not exist for access method "btree"   (SQLSTATE 42704)
   ```

   Without the comma, PostgreSQL reads `branch_id` as something else (an "operator class", a setting for how to sort the column). Separate the columns with a comma.

## Try it yourself

1. Swap the order inside `WHERE`: `branch_id = 3 AND customer_id = 4242`. Does it still use the index? (The video's task.)
2. Which of these can use `idx_big_cust_branch`: `WHERE customer_id = 10`, `WHERE branch_id = 7`, `WHERE customer_id = 10 AND branch_id = 7`?
3. You often search by branch alone and by branch plus customer. Which column should come first in the index?

## Answers

1. Yes. Only the order of the columns **inside the index** matters, not inside `WHERE`. In the video: Bitmap Index Scan on `idx_big_cust_branch`, 4 rows, 0.029 ms.

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_orders
   WHERE branch_id = 3 AND customer_id = 4242;
   ```

2. The first and the third. `WHERE branch_id = 7` alone is a Seq Scan.
3. `branch_id` first: `ON big_orders (branch_id, customer_id)`. Then both searches include the first column.

## Next

[M17-L04 · EXPLAIN and EXPLAIN ANALYZE: Reading a Query Plan](../m17-l04-explain-and-explain-analyze-reading-a-query-plan/)
