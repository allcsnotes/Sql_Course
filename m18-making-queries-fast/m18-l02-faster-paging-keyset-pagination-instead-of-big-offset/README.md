# M18-L02 · Faster Paging: Keyset Pagination Instead of a Big OFFSET

> Video: Module 18, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- Why `LIMIT 10 OFFSET 90000` still reads every row it skips: page 9,001 took 15 ms, page 1 took 0.03 ms
- **Keyset pagination**: remember the last ID you showed (a bookmark) and ask for the rows after it
- Why the bookmark column must be unique, and how to add a tie breaker with a row comparison
- Two traps: `DESC` with `>`, and why keyset cannot jump to page 50

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson uses `big_customers` (100,000 rows) from [M18-L01](../m18-l01-the-usual-slow-patterns-select-star-functions-on-columns-leading-percent-in-like/) and **adds** a primary key to it.
- `customer_id` and `email` are the same for everyone. The join dates are random, so the "ties" steps (7 to 10) show different IDs and counts for you. Timings will differ too.

## Files in this folder

| File | What it is |
|---|---|
| `keyset_paging.sql` | Every query from the video in order, with the video's result as a comment |
| `setup.sql` | The primary key `big_customers_pkey` on `customer_id`. Only for a rebuild |

## Follow along

`OFFSET 90000` means: count past 90,000 rows, throw them away, then keep the next 10. The deeper the page, the more rows it counts and throws away. Keyset pagination keeps a **bookmark** instead: the last ID you showed (here 90,000). The index jumps straight to the bookmark and reads just the next 10 rows.

How the app asks for the next page:

| Page | Query | Shows | New bookmark |
|---|---|---|---|
| 1 | `ORDER BY customer_id LIMIT 10` | 1 to 10 | 10 |
| 2 | `WHERE customer_id > 10 ORDER BY customer_id LIMIT 10` | 11 to 20 | 20 |
| 3 | `WHERE customer_id > 20 ...` | 21 to 30 | 30 |

Every page is the same quick jump, however deep you go.

### 1. A primary key

A primary key gives `big_customers` a sorted index on `customer_id` (`big_customers_pkey`).

```sql
ALTER TABLE big_customers
ADD PRIMARY KEY (customer_id);
```

### 2. Page 9,001 with OFFSET

```sql
SELECT customer_id, email
FROM big_customers
ORDER BY customer_id
LIMIT 10 OFFSET 90000;
```

You should see:

| customer_id | email |
|---|---|
| 90001 | user90001@mail.com |
| 90002 | user90002@mail.com |
| ... | ... |
| 90010 | user90010@mail.com |

### 3. The real work behind it

`COSTS OFF` hides the cost guesses so the plan is shorter.

```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT customer_id, email
FROM big_customers
ORDER BY customer_id
LIMIT 10 OFFSET 90000;
```

In the video:

```text
Limit (actual time=... rows=10.00 loops=1)
  ->  Index Scan using big_customers_pkey on big_customers (actual time=... rows=90010.00 loops=1)
...
Execution Time: 15.061 ms
```

The Index Scan read **90,010 rows** to show just 10. About 15 milliseconds.

### 4. Page 1, for comparison

```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT customer_id, email
FROM big_customers
ORDER BY customer_id
LIMIT 10 OFFSET 0;
```

In the video: the Index Scan reads only 10 rows, `Execution Time: 0.031 ms`.

### 5. Keyset: start after the bookmark

```sql
EXPLAIN (ANALYZE, COSTS OFF)
SELECT customer_id, email
FROM big_customers
WHERE customer_id > 90000
ORDER BY customer_id
LIMIT 10;
```

In the video:

```text
Limit (actual time=... rows=10.00 loops=1)
  ->  Index Scan using big_customers_pkey on big_customers (actual time=... rows=10.00 loops=1)
        Index Cond: (customer_id > 90000)
...
Execution Time: 0.786 ms
```

The index condition jumps right there: 10 rows read, under 1 millisecond.

### 6. The same page

```sql
SELECT customer_id, email
FROM big_customers
WHERE customer_id > 90000
ORDER BY customer_id
LIMIT 10;
```

You should see customers 90,001 to 90,010, exactly as in step 2.

### 7. The catch: ties

The bookmark column must be **unique**. Join dates are not:

```sql
SELECT joined_on, COUNT(*) AS customers
FROM big_customers
GROUP BY joined_on
ORDER BY joined_on
LIMIT 5;
```

In the video (random dates, yours will differ):

| joined_on | customers |
|---|---|
| 2024-01-01 | 72 |
| 2024-01-02 | 152 |
| 2024-01-03 | 127 |
| 2024-01-04 | 152 |
| 2024-01-05 | 168 |

72 customers joined on 1 January 2024.

### 8. Page 1 by join date, with a tie breaker

```sql
SELECT customer_id, joined_on
FROM big_customers
ORDER BY joined_on, customer_id
LIMIT 10;
```

In the video: customers 2190, 3199, 4565, 5067, 5395, 5672, 7564, 9764, 10762 and **13958**, all on 2024-01-01. The page ends at customer 13,958, still on 1 January.

### 9. Wrong: the date alone

```sql
SELECT customer_id, joined_on
FROM big_customers
WHERE joined_on > '2024-01-01'
ORDER BY joined_on, customer_id
LIMIT 10;
```

In the video it jumps to 2024-01-02 (1734, 2276, 2720, ...). The other 62 customers of 1 January are never shown.

### 10. Right: compare both columns together

`(joined_on, customer_id) > ('2024-01-01', 13958)` is a **row comparison**: first compare the dates, and only when they are equal compare the IDs.

```sql
SELECT customer_id, joined_on
FROM big_customers
WHERE (joined_on, customer_id) > ('2024-01-01', 13958)
ORDER BY joined_on, customer_id
LIMIT 10;
```

In the video, page two carries on with 1 January: 16145, 16853, 17889, 18742, 20348, 22259, 22791, 22833, 23523, 24614.

## Common mistakes

1. **No ORDER BY.** Rows then come back in no fixed order, and pages can repeat or skip rows. Always order by the bookmark column.

2. **Newest first with `ORDER BY ... DESC`, but still `>`.**

   ```sql
   SELECT customer_id, email
   FROM big_customers
   WHERE customer_id > 90000
   ORDER BY customer_id DESC
   LIMIT 5;
   ```

   You jump to the very end: 100000, 99999, 99998, 99997, 99996. With `DESC`, use `<`:

   ```sql
   SELECT customer_id, email
   FROM big_customers
   WHERE customer_id < 90000
   ORDER BY customer_id DESC
   LIMIT 5;
   ```

   Now you get 89999, 89998, 89997, 89996, 89995.

3. **Expecting keyset to jump to page 50.** It only goes to the next page. That fits Next buttons and endless scrolling. For a few small pages, `OFFSET` is fine.

## Try it yourself

1. Show the 5 customers after customer 50,000. (The video's task.)
2. Page 1 is customers 1 to 10. Write the query for page 2 with keyset.
3. Run step 8, take the last row of your own result, and write the query for page two with a row comparison.

## Answers

1. ```sql
   SELECT customer_id, email
   FROM big_customers
   WHERE customer_id > 50000
   ORDER BY customer_id
   LIMIT 5;
   ```

   Customers 50,001 to 50,005.

2. `SELECT customer_id, email FROM big_customers WHERE customer_id > 10 ORDER BY customer_id LIMIT 10;`
3. Put your last row's date and ID into `WHERE (joined_on, customer_id) > ('<date>', <id>)`, keeping `ORDER BY joined_on, customer_id LIMIT 10`.

## Next

[M18-L03 · How the Planner Decides: Statistics, ANALYZE and VACUUM](../m18-l03-how-the-planner-decides-statistics-analyze-and-vacuum/)
