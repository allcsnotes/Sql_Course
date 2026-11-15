# M12-L02 · UPDATE Safely

> Video: Module 12, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- `UPDATE table SET column = value WHERE ...` changes rows that are already in a table
- The safe habit: write the `SELECT` first with the same `WHERE`, look at the rows, then update
- Using the old value (`quantity = quantity + 5`) and checking with `RETURNING`
- One `UPDATE` can change many rows
- Three mistakes: no `WHERE`, `AND` instead of a comma, a value the rules do not allow

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `deliveries` as it is after [M11-L04](../../m11-creating-tables/m11-l04-alter-table/) (columns `quantity`, `delivered_on`, `paid`).
- This lesson changes `deliveries`, and later lessons expect the result.

## Files in this folder

| File | What it is |
|---|---|
| `update_safely.sql` | Every query from the video in order, with the real result or error as a comment |
| `setup.sql` | The same end state for `deliveries`. Run it only if you skipped the lesson |

## Follow along

Data changes all the time: an order arrives, a number goes up, a bill gets paid. `UPDATE` changes rows that are already in a table. It is powerful, and one missing line can change every row. So: select first, then update, then check.

### 1. Look before you change

```sql
SELECT delivery_id, item, quantity, status, delivered_on, paid
FROM deliveries
ORDER BY delivery_id;
```

| delivery_id | item | quantity | status | delivered_on | paid |
|---|---|---|---|---|---|
| 1 | milk | 40 | ordered | [NULL] | false |
| 2 | tea leaves | 10 | ordered | [NULL] | false |
| 3 | samosa | 50 | delivered | [NULL] | false |

The tea leaves have arrived. Before changing anything, write a `SELECT` with the `WHERE` you plan to use:

```sql
SELECT delivery_id, item, status, delivered_on
FROM deliveries
WHERE delivery_id = 2;
```

One row comes back: `2 | tea leaves | ordered | [NULL]`. That is exactly the row we want to change.

### 2. The UPDATE

`UPDATE`, the table, then `SET` with the new values (a comma between them), then the same `WHERE`:

```sql
UPDATE deliveries
SET status = 'delivered', delivered_on = '2026-04-25'
WHERE delivery_id = 2;
```

You should see: `Updated Rows 1`. Check:

```sql
SELECT delivery_id, item, status, delivered_on
FROM deliveries
ORDER BY delivery_id;
```

| delivery_id | item | status | delivered_on |
|---|---|---|---|
| 1 | milk | ordered | [NULL] |
| 2 | tea leaves | delivered | 2026-04-25 |
| 3 | samosa | delivered | [NULL] |

The other rows did not move.

### 3. Use the old value

Five more cartons of milk came in:

```sql
UPDATE deliveries
SET quantity = quantity + 5
WHERE item = 'milk'
RETURNING delivery_id, item, quantity;
```

You should see:

| delivery_id | item | quantity |
|---|---|---|
| 1 | milk | 45 |

Postgres reads the old number, 40, adds 5, and saves 45. `RETURNING` shows the new value right away.

### 4. Many rows at once

```sql
UPDATE deliveries
SET paid = true
WHERE status = 'delivered'
RETURNING delivery_id, item, status, paid;
```

You should see:

| delivery_id | item | status | paid |
|---|---|---|---|
| 3 | samosa | delivered | true |
| 2 | tea leaves | delivered | true |

Every row that matches the `WHERE` changes. So always check how many rows your `SELECT` finds first.

## Common mistakes

All three were run for real in the video.

1. **`UPDATE` with the `WHERE` missing.** On a practice copy:

   ```sql
   CREATE TABLE practice AS SELECT * FROM deliveries;
   UPDATE practice SET status = 'cancelled';
   ```

   Every row became cancelled: `Updated Rows 3`. DBeaver warns you ("Execute dangerous queries"), but Postgres never asks. Clean up with `DROP TABLE practice;`.

2. **`AND` between the columns instead of a comma.**

   ```sql
   UPDATE deliveries
   SET status = 'delivered' AND paid = true
   WHERE delivery_id = 1;
   ```

   ```text
   ERROR: invalid input syntax for type boolean: "delivered"   (SQLSTATE 22P02)
   ```

   Postgres reads `'delivered' AND paid = true` as one true-or-false test, and fails. Put commas between the columns you set.

3. **A value the table's rules do not allow.**

   ```sql
   UPDATE deliveries
   SET quantity = 0
   WHERE delivery_id = 1;
   ```

   ```text
   ERROR: new row for relation "deliveries" violates check constraint "deliveries_qty_check"   (SQLSTATE 23514)
     Detail: Failing row contains (1, 2, milk, 0, PD-101, ordered, null, f).
   ```

   Nothing changes. The table protects itself.

## Try it yourself

1. The milk arrived on 26 April. Change its status to delivered. How many deliveries are still ordered? (The video's task. Later lessons expect this change.)
2. Write the `SELECT` you would run before marking every unpaid delivery as paid. How many rows does it find now?
3. You want to give only samosa a delivery date. Which `WHERE` is the safest, and why? (Just write it; the course keeps samosa's date empty.)

## Answers

1. ```sql
   UPDATE deliveries
   SET status = 'delivered', delivered_on = '2026-04-26'
   WHERE delivery_id = 1
   RETURNING delivery_id, item, status, delivered_on;
   ```

   Returns `1 | milk | delivered | 2026-04-26`. Then:

   ```sql
   SELECT count(*) AS still_ordered
   FROM deliveries
   WHERE status = 'ordered';
   ```

   `still_ordered` = 0. Every delivery has arrived.

2. `SELECT delivery_id, item, paid FROM deliveries WHERE paid = false;` finds 1 row: milk. (Do not run the update: in the course, milk stays unpaid.)
3. `WHERE delivery_id = 3`: the primary key matches exactly one row. `WHERE item = 'samosa'` would also change any future samosa deliveries.

## Next

[M12-L03 · DELETE Safely, and Soft Delete](../m12-l03-delete-safely-and-soft-delete/)
