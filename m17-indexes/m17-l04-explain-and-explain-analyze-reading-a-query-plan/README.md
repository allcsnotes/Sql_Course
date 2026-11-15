# M17-L04 · EXPLAIN and EXPLAIN ANALYZE: Reading a Query Plan

> Video: Module 17, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- What a **query plan** is: the list of steps PostgreSQL takes to get your answer, like a recipe
- The difference between `EXPLAIN` (the plan, a guess, runs nothing) and `EXPLAIN ANALYZE` (really runs it)
- The words in a plan: cost, rows, width, actual time, loops
- Why you read a plan **from the bottom up**
- Three mistakes, including the one that really deletes a row

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses `big_orders` from [M17-L02](../m17-l02-creating-an-index-on-100000-orders/) with the indexes `idx_big_cust_branch` and `idx_big_total`.
- `big_orders` holds random data, so your numbers will differ from the video. The plan shapes will match.
- One step (mistake 1) **deletes** order 100000, as in the video. `setup.sql` in this folder makes the same change for a rebuild.

## Files in this folder

| File | What it is |
|---|---|
| `explain_analyze.sql` | Every query from the video in order, with the video's result as a comment |
| `setup.sql` | The one data change of this lesson: order 100000 deleted. Only for a rebuild |

## Follow along

A query plan is like a recipe: it lists the steps PostgreSQL takes to get your answer. Each step hands its rows up to the step above it, so **the first step is at the bottom**. To count orders per branch: first scan the table, then group the rows by branch, then sort the groups. Read a plan from the bottom up, the way the rows flow.

The words you will see:

| Word | Meaning |
|---|---|
| `cost` | A guess of the work, in made-up units. Lower is better |
| `rows` | How many rows the step expects |
| `width` | The size of one row, in bytes |
| `actual time` | With `ANALYZE`: real milliseconds, start..end |
| `rows` (after actual) | With `ANALYZE`: the real number of rows |
| `loops` | How many times that step ran |

### 1. EXPLAIN: the plan only

```sql
EXPLAIN
SELECT * FROM big_orders
WHERE branch_id = 3;
```

In the video:

```text
Seq Scan on big_orders  (cost=0.00..1826.00 rows=11140 width=16)
  Filter: (branch_id = 3)
```

One step: a Seq Scan on `big_orders`. Its guess is about 11,140 rows, with a filter on branch ID. Nothing has run yet.

### 2. EXPLAIN ANALYZE: the real numbers

```sql
EXPLAIN ANALYZE
SELECT * FROM big_orders
WHERE branch_id = 3;
```

In the video:

```text
Seq Scan on big_orders  (cost=0.00..1826.00 rows=11140 width=16) (actual time=0.054..5.940 rows=11139.00 loops=1)
  Filter: (branch_id = 3)
  Rows Removed by Filter: 88861
...
Planning Time: 0.038 ms
Execution Time: 6.218 ms
```

Same plan, plus the real numbers: 11,139 rows kept and 88,861 thrown away by the filter. At the bottom, **Execution Time**: about 6 milliseconds. That is the real time.

### 3. A plan with steps

```sql
EXPLAIN ANALYZE
SELECT branch_id, COUNT(*) AS orders
FROM big_orders
GROUP BY branch_id
ORDER BY orders DESC;
```

In the video (Buffers lines left out):

```text
Sort  (cost=2076.27..2076.29 rows=10 width=12) (actual time=20.928..20.929 rows=10.00 loops=1)
  Sort Key: (count(*)) DESC
  Sort Method: quicksort  Memory: 25kB
  ->  HashAggregate  (cost=2076.00..2076.10 rows=10 width=12) (actual time=18.656..18.658 rows=10.00 loops=1)
        Group Key: branch_id
        Batches: 1  Memory Usage: 32kB
        ->  Seq Scan on big_orders  (cost=0.00..1576.00 rows=100000 width=4) (actual time=0.056..4.673 rows=100000.00 loops=1)
Planning Time: 0.674 ms
Execution Time: 21.926 ms
```

Read from the bottom: **Seq Scan** reads every row, **HashAggregate** groups them by branch (10 groups), **Sort** puts them in order. Total: about 22 milliseconds.

## Common mistakes

1. **EXPLAIN ANALYZE really runs the query.** On a `DELETE`, the row is really gone.

   ```sql
   EXPLAIN ANALYZE
   DELETE FROM big_orders
   WHERE order_id = 100000;

   SELECT COUNT(*) AS all_rows FROM big_orders;
   ```

   | all_rows |
   |---|
   | 99999 |

   The table now has 99,999 rows. Use plain `EXPLAIN` first: it plans and deletes nothing.

   ```sql
   EXPLAIN
   DELETE FROM big_orders
   WHERE order_id = 99999;
   ```

   ```text
   Delete on big_orders  (cost=...)
     ->  Seq Scan on big_orders  (cost=...)
           Filter: (order_id = 99999)
   ```

2. **Trusting one run.** The same `GROUP BY` from step 3 took 21.926 ms, then 15.453 ms the next time. Run a query a few times before you compare.

3. **Reading from the top.** The top line finishes last. Start at the bottom, where the rows come from.

## Try it yourself

1. `EXPLAIN ANALYZE` the orders where `total = 500 AND branch_id = 3`. Which index does it use, and how many rows are left? (The video's task.)
2. Run step 3 three times and write down the execution times.
3. In the step 3 plan, which step has `rows=100000`, and why?

## Answers

1. A Bitmap Index Scan on `idx_big_total` finds 92 rows. The filter removes 80, and 12 are left (0.359 ms in the video; yours will differ).

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_orders
   WHERE total = 500 AND branch_id = 3;
   ```

   ```text
   Bitmap Heap Scan on big_orders  (... rows=12.00 loops=1)
     Recheck Cond: (total = 500)
     Filter: (branch_id = 3)
     Rows Removed by Filter: 80
     ->  Bitmap Index Scan on idx_big_total  (... rows=92.00 ...)
           Index Cond: (total = 500)
   ...
   Execution Time: 0.359 ms
   ```

2. They change from run to run, usually a little faster after the first.
3. The Seq Scan at the bottom: it reads every row of the table before the grouping starts. (In the video that ran before mistake 1, so all 100,000 rows; after the delete you see 99,999 actual rows.)

## Next

[M17-L05 · When Indexes Hurt: Writes, Unused Indexes, Low-Variety Columns](../m17-l05-when-indexes-hurt-writes-unused-indexes-low-variety-columns/)
