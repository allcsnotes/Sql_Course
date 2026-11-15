# M17-L05 · When Indexes Hurt: Writes, Unused Indexes, Low-Variety Columns

> Video: Module 17, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- Why every index has a price: each insert, update and delete must update every index too
- How 4 indexes made inserting 99,999 rows almost 5 times slower
- How to find indexes nobody uses with `pg_stat_user_indexes`, and remove them with `DROP INDEX`
- Why PostgreSQL skips an index when most rows match (a **low-variety** column like `branch_id`)
- When an index helps: when the search narrows the table down to a few rows

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses `big_orders` (99,999 rows after [M17-L04](../m17-l04-explain-and-explain-analyze-reading-a-query-plan/)) and **adds** two tables, `copy_plain` and `copy_idx`.
- Timings on your laptop will differ. The pattern (slower inserts with indexes, plan types) will not.

## Files in this folder

| File | What it is |
|---|---|
| `when_indexes_hurt.sql` | Every query from the video in order, with the video's result as a comment |
| `setup.sql` | `copy_plain` and `copy_idx` filled with 99,999 rows, `copy_idx` with its 3 remaining indexes. Only for a rebuild |

## Follow along

Think of a book with an index at the back. Add a new page, and someone must update the index too. Four indexes means four updates for every new row, so writes get slower. And if nobody ever looks anything up, that index is just extra work and extra space.

So when does an index help? When your search narrows the table down to a **few** rows: one customer, or one order number. When most rows match, PostgreSQL skips the index and simply reads the whole table, because that is faster. A column with only a few values (like yes or no) is a poor choice for an index.

### 1. Two empty copies

`(LIKE big_orders)` copies the columns, not the rows. `CREATE INDEX ON` with no name lets PostgreSQL pick one: table, column, `idx`.

```sql
CREATE TABLE copy_plain
(LIKE big_orders);
```

```sql
CREATE TABLE copy_idx (LIKE big_orders);
CREATE INDEX ON copy_idx (customer_id);
CREATE INDEX ON copy_idx (branch_id);
CREATE INDEX ON copy_idx (total);
CREATE INDEX ON copy_idx (customer_id, branch_id);
```

`copy_plain` has no indexes. `copy_idx` gets four.

### 2. Insert the same rows into both

```sql
EXPLAIN ANALYZE
INSERT INTO copy_plain
SELECT * FROM big_orders;
```

```sql
EXPLAIN ANALYZE
INSERT INTO copy_idx
SELECT * FROM big_orders;
```

In the video:

| Table | Indexes | Execution Time |
|---|---|---|
| copy_plain | 0 | 112.858 ms |
| copy_idx | 4 | 551.724 ms |

Almost five times slower, just to update four indexes. (Here `EXPLAIN ANALYZE` really inserts the rows: that is the point.)

### 3. Are the indexes used?

`pg_stat_user_indexes` counts how often each index was used (`idx_scan`). `pg_relation_size` gives its size on disk.

```sql
SELECT indexrelname AS index_name,
       idx_scan AS times_used,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE relname = 'copy_idx';
```

You should see:

| index_name | times_used | size |
|---|---|---|
| copy_idx_customer_id_idx | 0 | 1112 kB |
| copy_idx_branch_id_idx | 0 | 672 kB |
| copy_idx_total_idx | 0 | 1008 kB |
| copy_idx_customer_id_branch_id_idx | 0 | 2264 kB |

Zero for all four, and together they take about 5 megabytes.

### 4. A column with only 10 values

The video ran `ANALYZE copy_idx;` first (off screen) so the planner knows about the new rows. Run it too:

```sql
ANALYZE copy_idx;
```

Now search every branch except 3:

```sql
EXPLAIN ANALYZE
SELECT * FROM copy_idx
WHERE branch_id <> 3;
```

In the video:

```text
Seq Scan on copy_idx  (... rows=88860.00 loops=1)
  Filter: (branch_id <> 3)
  Rows Removed by Filter: 11139
...
Execution Time: 12.308 ms
```

Almost 89,000 rows match, so it is a Seq Scan: the index is skipped. Now one branch:

```sql
EXPLAIN ANALYZE
SELECT * FROM copy_idx
WHERE branch_id = 3;
```

In the video:

```text
Bitmap Heap Scan on copy_idx  (... rows=11139.00 loops=1)
  ->  Bitmap Index Scan on copy_idx_branch_id_idx  (... rows=11139.00 ...)
        Index Cond: (branch_id = 3)
...
Execution Time: 2.289 ms
```

One branch out of ten, and the index is used: about 2 milliseconds.

### 5. Drop an unused index

```sql
DROP INDEX copy_idx_total_idx;
```

## Common mistakes

1. **Indexing every column.** Our four indexes made inserts five times slower. Index only the columns you search by.
2. **Keeping indexes nobody uses.** Check `times_used` in `pg_stat_user_indexes`, and drop the ones at zero with `DROP INDEX`. (Give them some time first: the count starts when the index is made.)
3. **Indexing a column where most rows match.** PostgreSQL ignores it. Index columns that narrow the search.

## Try it yourself

1. Check the indexes on `big_orders`. Are they used? (The video's task.)
2. Run step 3 again after step 4. Which `times_used` changed?
3. Would you index a `paid` column that is `true` for 98% of orders? Why?

## Answers

1. Yes, keep both.

   ```sql
   SELECT indexrelname AS index_name,
          idx_scan AS times_used,
          pg_size_pretty(pg_relation_size(indexrelid)) AS size
   FROM pg_stat_user_indexes
   WHERE relname = 'big_orders';
   ```

   In the video:

   | index_name | times_used | size |
   |---|---|---|
   | idx_big_total | 2 | 720 kB |
   | idx_big_cust_branch | 3 | 1640 kB |

   Your counts depend on how many queries you ran in lessons 2 to 4.

2. `copy_idx_branch_id_idx` went from 0 to 1: the `branch_id = 3` search used it.
3. No. A search for `paid = true` matches almost every row, so PostgreSQL would read the whole table anyway, and every insert would pay for the index.

## Next

[M18-L01 · The Usual Slow Patterns: SELECT *, Functions on Columns, Leading % in LIKE](../../m18-making-queries-fast/m18-l01-the-usual-slow-patterns-select-star-functions-on-columns-leading-percent-in-like/)
