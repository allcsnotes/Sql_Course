# M18-L01 · The Usual Slow Patterns: SELECT *, Functions on Columns, Leading % in LIKE

> Video: Module 18, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- Why `SELECT *` sends far more data than you need, measured with `EXPLAIN (ANALYZE, SERIALIZE)`
- Why a function on the column (`lower(email)`) hides it from the index, and how an **expression index** fixes it
- Why `LIKE '%4242...'` (percent sign at the start) cannot use an index, but `LIKE 'user4242@%'` can
- Three more traps: `upper` vs `lower`, `ILIKE`, and `date_trunc` on a date column

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson **adds** a table, `big_customers` (100,000 rows), and three indexes. Step 1 creates the table.
- The join dates are random, so your counts and timings will differ from the video. The plan types will match.
- **Collation.** The video's database uses collation C (the simple byte-by-byte sort order), so a plain index on `email` also serves `LIKE 'prefix%'`. Check yours:

  ```sql
  SELECT datcollate FROM pg_database WHERE datname = current_database();
  ```

  If it says `C`, follow the video exactly. If it says something else (for example `en_US.UTF-8`), write `('user' || g || '@mail.com') COLLATE "C" AS email` in step 1, as `setup.sql` does. Otherwise step 5's `LIKE 'user4242@%'` gives a Seq Scan.

## Files in this folder

| File | What it is |
|---|---|
| `slow_patterns.sql` | Every query from the video in order, with the video's result as a comment |
| `setup.sql` | DB update 9: `big_customers` with `idx_cust_email`, `idx_cust_lower` and `idx_cust_joined`, a fixed seed and `COLLATE "C"`. Only for a rebuild |

## Follow along

Same table, same index: one search takes half a millisecond, another takes sixteen. Usually it is one of three habits.

An index is like a phone book, sorted by email. Finding one email is a quick jump. But wrap the column in a function, like `lower(email)`, and the book is not sorted by that, so PostgreSQL reads every row. A percent sign at the **start** is the same: emails that end in 4242? The book is sorted by the start, so it cannot help. A percent sign at the **end** is fine: emails that start with `user4242`? Still a quick jump.

And `SELECT *`? Each customer row has four columns, and one of them, `notes`, is long. `SELECT *` sends every column back to you, even the ones you never read.

### 1. The practice table

```sql
CREATE TABLE big_customers AS
SELECT g AS customer_id,
  'user' || g || '@mail.com' AS email,
  DATE '2024-01-01' + (random() * 730)::int AS joined_on,
  repeat('note ', 40) AS notes
FROM generate_series(1, 100000) AS g;
```

```sql
CREATE INDEX idx_cust_email
ON big_customers (email);
```

```sql
VACUUM ANALYZE big_customers;
```

100,000 customers (`user1@mail.com` to `user100000@mail.com`), each with a join date in 2024 or 2025 and a 200-character note. `VACUUM ANALYZE` refreshes the statistics; lesson 3 explains it.

### 2. SELECT * vs named columns

`SERIALIZE` (new in PostgreSQL 17) makes `EXPLAIN ANALYZE` also measure the data sent back to you.

```sql
EXPLAIN (ANALYZE, SERIALIZE)
SELECT * FROM big_customers;
```

```sql
EXPLAIN (ANALYZE, SERIALIZE)
SELECT customer_id, email FROM big_customers;
```

In the video (the `Serialization` line):

| Query | output | Execution Time |
|---|---|---|
| `SELECT *` | 24491kB | 30.071 ms |
| `SELECT customer_id, email` | 3201kB | 20.374 ms |

About 24 megabytes vs about 3: seven times less data.

### 3. A function on the column

```sql
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE lower(email) = 'user4242@mail.com';
```

In the video: `Seq Scan`, `Rows Removed by Filter: 99999`, `Execution Time: 15.744 ms`. Compare the bare column:

```sql
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email = 'user4242@mail.com';
```

In the video: `Index Scan using idx_cust_email`, `Execution Time: 0.569 ms`.

### 4. Index the exact expression

If you really need `lower`, index that exact expression:

```sql
CREATE INDEX idx_cust_lower
ON big_customers (lower(email));
```

```sql
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE lower(email) = 'user4242@mail.com';
```

In the video:

```text
Bitmap Heap Scan on big_customers  (... rows=1.00 loops=1)
  ->  Bitmap Index Scan on idx_cust_lower  (... rows=1.00 ...)
        Index Cond: (lower(email) = 'user4242@mail.com'::text)
...
Execution Time: 0.451 ms
```

### 5. Leading % vs trailing %

```sql
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email LIKE '%4242@mail.com';
```

In the video: `Seq Scan`, 10 rows found (`user4242`, `user14242`, ...), `Rows Removed by Filter: 99990`, `Execution Time: 19.143 ms`.

```sql
EXPLAIN ANALYZE
SELECT * FROM big_customers
WHERE email LIKE 'user4242@%';
```

In the video:

```text
Index Scan using idx_cust_email on big_customers  (... rows=1.00 loops=1)
  Index Cond: ((email >= 'user4242@'::text) AND (email < 'user4242A'::text))
  Filter: (email ~~ 'user4242@%'::text)
...
Execution Time: 0.179 ms
```

With the percent sign at the end, PostgreSQL turns the `LIKE` into a range on the sorted index (`~~` is how a plan writes `LIKE`).

## Common mistakes

All three were run in the video.

1. **Index on `lower`, search with `upper`.** The function must match exactly.

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_customers
   WHERE upper(email) = 'USER4242@MAIL.COM';
   ```

   Seq Scan, 18.708 ms. Use the same function the index uses.

2. **ILIKE** ignores capital letters, so the plain index cannot help.

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_customers
   WHERE email ILIKE 'user4242@%';
   ```

   Seq Scan, 18.654 ms. Use `lower(email)` with `LIKE` instead:

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_customers
   WHERE lower(email) LIKE 'user4242@%';
   ```

   Bitmap Index Scan on `idx_cust_lower`, 0.065 ms.

3. **`date_trunc` on the join date**, to find March. Same problem.

   ```sql
   CREATE INDEX idx_cust_joined
   ON big_customers (joined_on);
   ```

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_customers
   WHERE date_trunc('month', joined_on) = '2025-03-01';
   ```

   Seq Scan, 4,302 rows, 23.249 ms. Write a range instead, from 1 March up to 1 April:

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_customers
   WHERE joined_on >= '2025-03-01'
     AND joined_on < '2025-04-01';
   ```

   Bitmap Index Scan on `idx_cust_joined`, the same 4,302 rows, 5.716 ms.

## Try it yourself

1. Which one uses the index: `LIKE 'user77%'` or `LIKE '%77'`? (The video's task.)
2. Rewrite `WHERE EXTRACT(YEAR FROM joined_on) = 2024` so it can use `idx_cust_joined`.
3. Measure `SELECT email FROM big_customers` with `SERIALIZE`. Is it smaller than 3201kB?

## Answers

1. The first one.

   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM big_customers
   WHERE email LIKE 'user77%';
   ```

   In the video: `Index Scan using idx_cust_email`, 1.862 ms. `LIKE '%77'` is a Seq Scan.

2. `WHERE joined_on >= '2024-01-01' AND joined_on < '2025-01-01'`. The plan becomes a Bitmap Index Scan on `idx_cust_joined`.
3. Yes: about 2333kB in our test, because the `customer_id` column no longer goes back.

## Next

[M18-L02 · Faster Paging: Keyset Pagination Instead of a Big OFFSET](../m18-l02-faster-paging-keyset-pagination-instead-of-big-offset/)
