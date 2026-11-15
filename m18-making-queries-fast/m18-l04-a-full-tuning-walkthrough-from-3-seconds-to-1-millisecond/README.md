# M18-L04 · A Full Tuning Walkthrough: From 3 Seconds to 1 Millisecond

> Video: Module 18, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- The tuning loop: **measure**, read the plan, fix **one** thing, measure again
- How to spot the slow step in a plan: the one that takes the most time, or runs too many times (`loops`)
- Fix 1: replace a subquery that runs once per customer with one `JOIN` and `GROUP BY`
- Fix 2: an index on the join column, so each customer's orders are found by a jump
- Why you always check that the fast query still gives the same answer

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses `big_customers` with its primary key from [M18-L02](../m18-l02-faster-paging-keyset-pagination-instead-of-big-offset/), and **adds** a table, `tune_orders` (1,000,000 rows), plus one index.
- The amounts are random, so your top 5 and every timing will differ. The plans and the speed-ups will be about the same.
- Creating 1,000,000 rows takes a second or two and about 50 MB of disk.

## Files in this folder

| File | What it is |
|---|---|
| `tuning_walkthrough.sql` | Every query from the video in order, with the video's result as a comment |
| `setup.sql` | DB update 11: `tune_orders` with a fixed seed, and `idx_tune_customer`. Only for a rebuild |

## Follow along

A report takes almost 3 seconds. After a few small steps it takes about 1 millisecond, with the same answer. No magic, just a loop:

1. **Measure.** Run `EXPLAIN ANALYZE` and write down the time.
2. **Read the plan.** Look for the step that takes the most time, or runs too many times.
3. **Fix only that one thing.**
4. **Measure again.** Faster? Keep it. If not, undo it and try the next idea.

The report: the top 5 spenders among the first 130 customers. The orders table has one million rows, 10 for each customer.

### 0. The orders table

```sql
CREATE TABLE tune_orders AS
SELECT g AS order_id,
  (g % 100000) + 1 AS customer_id,
  round((random() * 900 + 100)::numeric, 2) AS amount,
  date '2025-01-01' + (g % 500) AS ordered_on
FROM generate_series(1, 1000000) AS g;
```

```sql
ANALYZE tune_orders;
```

`g % 100000` is the remainder after dividing by 100,000, so every customer gets exactly 10 orders. The amount is a random ₹100 to ₹1,000 with 2 decimals. In the video this took 1.556 seconds.

### 1. Version 1 of the report

A small subquery adds up the orders for each customer:

```sql
SELECT c.customer_id, c.email,
  (SELECT SUM(o.amount) FROM tune_orders o
   WHERE o.customer_id = c.customer_id) AS spent
FROM big_customers c
WHERE c.customer_id <= 130
ORDER BY spent DESC
LIMIT 5;
```

In the video (random amounts, yours will differ):

| customer_id | email | spent |
|---|---|---|
| 14 | user14@mail.com | 7726.74 |
| 126 | user126@mail.com | 7360.33 |
| 97 | user97@mail.com | 7149.16 |
| 43 | user43@mail.com | 7109.51 |
| 2 | user2@mail.com | 7105.07 |

Customer 14 is on top, with 7,726.74.

### 2. Measure and read the plan

```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT c.customer_id, c.email,
  (SELECT SUM(o.amount) FROM tune_orders o
   WHERE o.customer_id = c.customer_id) AS spent
FROM big_customers c
WHERE c.customer_id <= 130
ORDER BY spent DESC
LIMIT 5;
```

In the video (Buffers lines left out):

```text
Limit (actual time=2937.791..2937.792 rows=5.00 loops=1)
  ->  Sort (actual time=2937.791..2937.791 rows=5.00 loops=1)
        Sort Key: ((SubPlan 1)) DESC
        ->  Index Scan using big_customers_pkey on big_customers c (actual time=40.205..2937.602 rows=130.00 loops=1)
              Index Cond: (customer_id <= 130)
              SubPlan 1
                ->  Aggregate (actual time=22.592..22.592 rows=1.00 loops=130)
                      ->  Seq Scan on tune_orders o (actual time=0.068..22.580 rows=10.00 loops=130)
                            Filter: (customer_id = c.customer_id)
                            Rows Removed by Filter: 999990
Planning Time: 0.092 ms
Execution Time: 2937.810 ms
```

2,938 milliseconds: almost 3 seconds. The slow step: the **Seq Scan on tune_orders** shows `loops=130`, and each loop throws away 999,990 rows. It reads all one million orders, 130 times: 130 million rows read to add up just 1,300 orders.

### 3. Fix 1: JOIN once and GROUP BY

Instead of one subquery per customer, join the two tables once and group by customer.

```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT c.customer_id, c.email, SUM(o.amount) AS spent
FROM big_customers c
JOIN tune_orders o ON o.customer_id = c.customer_id
WHERE c.customer_id <= 130
GROUP BY c.customer_id, c.email
ORDER BY spent DESC
LIMIT 5;
```

In the video (key lines):

```text
Hash Join (...)
  Hash Cond: (o.customer_id = c.customer_id)
  ->  Parallel Seq Scan on tune_orders o (...)
  ->  Hash (...)
        ->  Index Scan using big_customers_pkey on big_customers c (...)
...
Execution Time: 110.846 ms
```

One **Parallel Seq Scan** (several workers share the reading) reads the orders just once. 111 milliseconds: already 26 times faster.

### 4. Fix 2: an index

It still reads all one million orders. So the second fix: an index on the customer ID column.

```sql
CREATE INDEX idx_tune_customer
ON tune_orders (customer_id);
```

In the video it took 0.341 seconds.

### 5. Measure again

Run the step 3 `EXPLAIN` again. In the video (key lines):

```text
Limit (...)
  ->  Sort (...)
        ->  GroupAggregate (...)
              ->  Nested Loop (...)
                    ->  Index Scan using big_customers_pkey on big_customers c (... rows=130.00 loops=1)
                    ->  Index Scan using idx_tune_customer on tune_orders o (... rows=10.00 loops=130)
                          Index Cond: (customer_id = c.customer_id)
...
Execution Time: 1.223 ms
```

Now the plan is a **Nested Loop**: for each of the 130 customers, an Index Scan jumps straight to that customer's 10 orders. 1.2 milliseconds: from almost 3 seconds, more than 2,000 times faster.

### 6. Check the answer

```sql
SELECT c.customer_id, c.email, SUM(o.amount) AS spent
FROM big_customers c
JOIN tune_orders o ON o.customer_id = c.customer_id
WHERE c.customer_id <= 130
GROUP BY c.customer_id, c.email
ORDER BY spent DESC
LIMIT 5;
```

You should see exactly the same 5 rows as step 1: customer 14, then 126, 97, 43 and 2.

| Version | Execution Time (video) |
|---|---|
| Subquery per customer | 2937.810 ms |
| JOIN + GROUP BY | 110.846 ms |
| JOIN + GROUP BY + index | 1.223 ms |

## Common mistakes

1. **Guessing.** Adding random indexes without reading the plan. Always measure first.
2. **Changing many things at once.** Then you do not know which change helped. Change one thing, then measure.
3. **Not checking the answer.** A fast query with the wrong result is useless. Compare the rows before and after.

## Try it yourself

1. A query filters `tune_orders` by customer ID, and the plan shows a Seq Scan. What do you add? (The video's task.)
2. Run step 2 again now that the index exists. Is the subquery version fast too?
3. Drop the index (`DROP INDEX idx_tune_customer;`), run the step 5 `EXPLAIN` again, then create the index again. Which plan comes back without it?

## Answers

1. An index on customer ID: `CREATE INDEX idx_tune_customer ON tune_orders (customer_id);`. Here it took the time from 111 down to 1.2 milliseconds.
2. Yes, much faster: each of the 130 subqueries now finds its 10 orders through `idx_tune_customer` (a Bitmap Index Scan in our test) instead of a Seq Scan. The JOIN version is still the cleaner way to write it.
3. The fix 1 plan: a Hash Join with one Parallel Seq Scan on `tune_orders`, and the slower fix 1 time again. Recreate the index with step 4 so the database matches the video.

## Next

[M19-L01 · Users and Roles: GRANT, REVOKE and Least Privilege](../../m19-users-security-and-backups/m19-l01-users-and-roles-grant-and-revoke-least-privilege/)
