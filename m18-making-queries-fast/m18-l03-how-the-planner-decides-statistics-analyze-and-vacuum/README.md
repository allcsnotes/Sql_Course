# M18-L03 · How the Planner Decides: Statistics, ANALYZE and VACUUM

> Video: Module 18, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What the **planner** is (the part of PostgreSQL that picks a plan) and how it guesses row counts from **statistics**
- How old statistics make a bad guess: 344 rows guessed, 99,000 real
- `ANALYZE`: refresh the statistics, and where they live (`pg_stats`)
- **Dead rows**: why `UPDATE` and `DELETE` leave old copies behind, and how `VACUUM` clears them
- Why `VACUUM` does not shrink the file, what `VACUUM FULL` does, and what **autovacuum** does for you

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson **adds** a test table, `plan_demo` (100,000 rows), with autovacuum turned off for that one table only.
- The rows are not random, so you get the same counts and sizes as the video. `ANALYZE` reads a random sample, so the fresh guess in step 5 can be a little different.
- The counters in `pg_stat_user_tables` are updated about once a second. If a number shows 0 right after a big change, wait a moment and run the query again.

## Files in this folder

| File | What it is |
|---|---|
| `planner_stats.sql` | Every query from the video in order, with the real result as a comment |
| `setup.sql` | DB update 10: `plan_demo` as the video leaves it (upper-case cities, rewritten by `VACUUM FULL`). Only for a rebuild |

## Follow along

The planner is like a map app. Before every trip it picks a route, and to choose it reads its map: the **statistics**, a short summary of each table (how many rows, which values are common). `ANALYZE` redraws the map: it reads a sample of the rows and writes down fresh numbers. With an old map, the app picks a bad route.

The second job is cleaning up. When you `UPDATE` a row, PostgreSQL does not change it in place: it writes a new copy and marks the old one as **dead**. `DELETE` also leaves dead rows. They take space until `VACUUM` clears them, and then that space can be used again. You rarely run these by hand: **autovacuum** runs `VACUUM` and `ANALYZE` for you in the background.

### 1. A test table

`WITH (autovacuum_enabled = false)` stops the background helper for this table only, so you can see what happens without it.

```sql
CREATE TABLE plan_demo (id int, city text)
WITH (autovacuum_enabled = false);
```

```sql
INSERT INTO plan_demo
SELECT g, CASE WHEN g % 100 = 0 THEN 'Pune' ELSE 'Delhi' END
FROM generate_series(1, 100000) AS g;
```

One row in every hundred is Pune (1,000 rows), the rest are Delhi (99,000).

### 2. A bad guess

`TIMING OFF` keeps the real row counts but skips the timings, so the plan is easier to read.

```sql
EXPLAIN (ANALYZE, TIMING OFF)
SELECT * FROM plan_demo
WHERE city = 'Delhi';
```

You should see:

```text
Seq Scan on plan_demo  (cost=0.00..1399.84 rows=344 width=36) (actual rows=99000.00 loops=1)
  Filter: (city = 'Delhi'::text)
  Rows Removed by Filter: 1000
```

The planner guessed **344** rows. The real count: **99,000**.

### 3. Why: never analyzed

```sql
SELECT relname, n_live_tup, n_dead_tup, last_analyze
FROM pg_stat_user_tables
WHERE relname = 'plan_demo';
```

| relname | n_live_tup | n_dead_tup | last_analyze |
|---|---|---|---|
| plan_demo | 100000 | 0 | NULL |

`last_analyze` is NULL: this table was never analyzed, so the planner had no map.

### 4. Refresh the statistics

```sql
ANALYZE plan_demo;
```

A fraction of a second (0.054 s in the video).

### 5. The same EXPLAIN again

```sql
EXPLAIN (ANALYZE, TIMING OFF)
SELECT * FROM plan_demo
WHERE city = 'Delhi';
```

In the video:

```text
Seq Scan on plan_demo  (cost=0.00..1791.00 rows=98960 width=9) (actual rows=99000.00 loops=1)
  Filter: (city = 'Delhi'::text)
  Rows Removed by Filter: 1000
```

Now the guess is 98,960: very close to the real 99,000.

### 6. Look at the statistics

```sql
SELECT attname, most_common_vals, most_common_freqs
FROM pg_stats
WHERE tablename = 'plan_demo' AND attname = 'city';
```

In the video:

| attname | most_common_vals | most_common_freqs |
|---|---|---|
| city | {Delhi,Pune} | {0.9896,0.0104} |

The most common values: Delhi, about 99 percent, and Pune, about 1 percent. (From a sample, so your fractions may differ a little.)

### 7. Size on disk

```sql
SELECT pg_size_pretty(pg_relation_size('plan_demo')) AS size;
```

You should see `4328 kB`.

### 8. Update every row

```sql
UPDATE plan_demo
SET city = upper(city)
WHERE id > 0;
```

`UPDATE 100000`: every city is now upper case (DELHI, PUNE).

### 9. Live and dead rows

```sql
SELECT n_live_tup, n_dead_tup,
  pg_size_pretty(pg_relation_size('plan_demo')) AS size
FROM pg_stat_user_tables
WHERE relname = 'plan_demo';
```

| n_live_tup | n_dead_tup | size |
|---|---|---|
| 100000 | 100000 | 8656 kB |

100,000 live rows and 100,000 dead ones. The table doubled.

### 10. VACUUM

```sql
VACUUM plan_demo;
```

### 11. After VACUUM

```sql
SELECT n_live_tup, n_dead_tup,
  pg_size_pretty(pg_relation_size('plan_demo')) AS size
FROM pg_stat_user_tables
WHERE relname = 'plan_demo';
```

| n_live_tup | n_dead_tup | size |
|---|---|---|
| 100000 | 0 | 8656 kB |

Dead rows: zero. But the size is still 8,656 kB. `VACUUM` frees the space for new rows; it does not give it back.

### 12. VACUUM FULL

```sql
VACUUM FULL plan_demo;
SELECT pg_size_pretty(pg_relation_size('plan_demo')) AS size;
```

You should see `4328 kB` again: `VACUUM FULL` rewrote the whole table.

## Common mistakes

1. **Turning autovacuum off.** We did it only for this demo table. On a real database, leave it on.
2. **Running VACUUM FULL often.** It **locks** the table while it rewrites it, so nobody can read or write. Plain `VACUUM` is enough most of the time.
3. **Forgetting ANALYZE after a big load.** Autovacuum may not have caught up yet, so run `ANALYZE` yourself.

## Try it yourself

1. You just loaded lots of new rows, and the planner's guesses are way off. Which command fixes it? (The video's task.)
2. Delete the Pune rows (`DELETE FROM plan_demo WHERE city = 'PUNE';`), wait a second, then run the step 9 query. How many dead rows?
3. Run `ANALYZE plan_demo;` again and check `last_analyze` in `pg_stat_user_tables`.

## Answers

1. `ANALYZE`. Here it moved the guess from 344 to 98,960.
2. 1,000 dead rows (the 1,000 Pune rows). The size does not change until `VACUUM` (reuse) or `VACUUM FULL` (shrink). If you try this, run `setup.sql` afterwards to put the 100,000 rows back.
3. It now shows the date and time you ran it.

## Next

[M18-L04 · A Full Tuning Walkthrough: From 3 Seconds to 1 Millisecond](../m18-l04-a-full-tuning-walkthrough-from-3-seconds-to-1-millisecond/)
