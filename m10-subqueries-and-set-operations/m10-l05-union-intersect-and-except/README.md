# M10-L05 · UNION, INTERSECT and EXCEPT

> Video: Module 10, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- A `JOIN` puts tables side by side and adds columns. Today you **stack** results: the rows of one query on top of the rows of another
- `UNION`: everyone from both lists, each one once
- `UNION ALL`: every row from both lists, repeats kept (and faster)
- `INTERSECT`: only the rows found in both lists
- `EXCEPT`: the rows in the first list but not in the second (so the order matters)
- The three rules: same number of columns, matching types, one `ORDER BY` at the very end

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/).
- DBeaver connected to `chai_corner`. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `set_operations.sql` | Every query of the video, in order, with the result or error as a comment |

## Follow along

### 1. Two lists

Who came to the Pune branch (branch 1) in the first week of January?

```sql
SELECT DISTINCT customer_id
FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
ORDER BY customer_id;
```

You should see 7 customers: **5, 6, 7, 8, 9, 10, 15**.

Change `branch_id = 1` to `branch_id = 2` for Mumbai. You should see 8 customers: **1, 3, 4, 6, 7, 8, 10, 12**.

Customers 6, 7, 8 and 10 are on both lists. Watch what each keyword does with them.

| Pune (week 1) | Mumbai (week 1) |
|---|---|
| 5, 6, 7, 8, 9, 10, 15 | 1, 3, 4, 6, 7, 8, 10, 12 |

### 2. UNION

Write the two queries one under the other, with `UNION` between them:

```sql
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;
```

You should see 11 rows: 1, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15. Seven plus eight is fifteen, but `UNION` removes the repeats, so a customer on both lists appears only once.

### 3. UNION ALL

Add the word `ALL`, and nothing is removed:

```sql
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION ALL
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;
```

You should see 18 rows: 1, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 10, 10, 12, 15, 15. There is no `DISTINCT` here, so a customer who came more than once appears more than once. `UNION ALL` is also faster, because the database does not hunt for repeats. Use it when repeats are fine.

### 4. INTERSECT

`INTERSECT` keeps only the customers on both lists:

```sql
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
INTERSECT
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;
```

You should see 4 rows: **6, 7, 8, 10**. Four customers came to both branches.

### 5. EXCEPT

`EXCEPT` keeps every row of the first list, except the ones that are also in the second:

```sql
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
EXCEPT
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08'
ORDER BY customer_id;
```

You should see 3 rows: **5, 9, 15**. They came to Pune, but not to Mumbai. The order matters: swap the two queries and you get the Mumbai list minus the Pune list.

| Keyword | Pune and Mumbai, week 1 | Rows |
|---|---|---|
| `UNION` | in either list, once each | 11 |
| `UNION ALL` | every row of both | 18 |
| `INTERSECT` | in both lists | 4 |
| `EXCEPT` | in Pune, not in Mumbai | 3 |

## Common mistakes

**1. A different number of columns.** Two columns on top and one below:

```sql
SELECT customer_id, branch_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08';
```

```text
SQL Error [42601]: ERROR: each UNION query must have the same number of columns
```

**2. Types that do not match.** A number on top and text below cannot be stacked:

```sql
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
UNION
SELECT name FROM customers;
```

```text
SQL Error [42804]: ERROR: UNION types integer and character varying cannot be matched
```

**3. `ORDER BY` in the middle.** There is only one `ORDER BY`, at the very end. It sorts the whole result:

```sql
SELECT customer_id FROM orders
WHERE branch_id = 1 AND ordered_at < '2026-01-08'
ORDER BY customer_id
UNION
SELECT customer_id FROM orders
WHERE branch_id = 2 AND ordered_at < '2026-01-08';
```

```text
SQL Error [42601]: ERROR: syntax error at or near "UNION"
```

## Try it yourself

1. Who came to Delhi (branch 3) in the first week of January, but not to Pune? Guess first, then run it.
2. Swap the two queries of step 5: who came to Mumbai in week 1, but not to Pune?
3. How many different customers came to Pune, Mumbai **or** Delhi in week 1? Stack three queries with two `UNION`s.

## Next

[M10-B02 · Build 2: Customer Insights](../m10-b02-customer-insights/)

## Answers

1. 4 customers: 2, 3, 11, 12 (Lukas, Priya, Arjun, Sara). Delhi's week 1 list is 2, 3, 5, 11, 12, and only 5 also came to Pune.
   ```sql
   SELECT customer_id FROM orders
   WHERE branch_id = 3 AND ordered_at < '2026-01-08'
   EXCEPT
   SELECT customer_id FROM orders
   WHERE branch_id = 1 AND ordered_at < '2026-01-08'
   ORDER BY customer_id;
   ```
2. 4 customers: 1, 3, 4, 12 (Asha, Priya, Rahul, Sara).
3. 13 customers. Add `UNION SELECT customer_id FROM orders WHERE branch_id = 3 AND ordered_at < '2026-01-08'` to the query of step 2, then count the rows.
