# M12-L03 · DELETE Safely, and Soft Delete

> Video: Module 12, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- `DELETE FROM table WHERE ...` removes rows, and there is no undo button
- The safe habit: `SELECT` with the exact `WHERE` first, then `DELETE` with the same `WHERE` and `RETURNING`
- A **soft delete**: a `hidden` flag you update instead of deleting, so the row can come back
- Every everyday query then needs `WHERE hidden = false`
- Three mistakes: `= NULL`, a row other tables point to, forgetting the filter

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need the 8 `feedback` rows from [M12-L01](../m12-l01-insert/).
- This lesson deletes one row and adds a `hidden` column to `feedback`; later lessons expect both.

## Files in this folder

| File | What it is |
|---|---|
| `delete_safely.sql` | Every query from the video in order, with the real result or error as a comment |
| `setup.sql` | The same end state for `feedback` (7 rows, `hidden` column, row 5 hidden). Run it only if you skipped the lesson |

## Follow along

Data also needs to leave: a customer takes back a review, or a row was added by mistake. `DELETE` removes rows from a table. There is no undo button: once a row is gone, it is gone.

### 1. Select first

```sql
SELECT feedback_id, customer_id, rating, comment
FROM feedback
ORDER BY feedback_id;
```

You should see 8 rows. Row 6 (customer 2, rating 3) has no comment at all: it is NULL. We want to remove empty feedback, so first a `SELECT` with the planned `WHERE`:

```sql
SELECT feedback_id, customer_id, rating, comment
FROM feedback
WHERE comment IS NULL;
```

One row comes back: `6 | 2 | 3 | [NULL]`. That is the only row we want gone.

### 2. The DELETE

The same `WHERE`, copied from the select:

```sql
DELETE FROM feedback
WHERE comment IS NULL
RETURNING feedback_id, customer_id, rating;
```

You should see:

| feedback_id | customer_id | rating |
|---|---|---|
| 6 | 2 | 3 |

`RETURNING` shows exactly what was removed. Save this output: it is your only record of that row.

### 3. Soft delete: a hidden flag

Sometimes you do not want a row truly gone: a review may come back later, or you need it for history. Add a flag instead:

```sql
ALTER TABLE feedback
ADD COLUMN hidden boolean NOT NULL DEFAULT false;
```

Every row starts as not hidden. To hide row 3, update it:

```sql
UPDATE feedback
SET hidden = true
WHERE feedback_id = 3
RETURNING feedback_id, comment, hidden;
```

You should see: `3 | Chai came a bit late | true`. The row is still in the table. This is called a **soft delete**.

### 4. Everyday reads skip hidden rows

```sql
SELECT feedback_id, rating, comment
FROM feedback
WHERE hidden = false
ORDER BY feedback_id;
```

You should see:

| feedback_id | rating | comment |
|---|---|---|
| 1 | 5 | Best masala chai in Pune |
| 2 | 4 | Samosa was hot and fresh |
| 4 | 5 | Loved the Kulhad Chai |
| 5 | 4 | Friendly staff |
| 7 | 5 | Great tea |
| 8 | 4 | Nice samosa |

Six rows. Row 3 is missing from the list, but it is safe.

### 5. Bring it back

```sql
UPDATE feedback
SET hidden = false
WHERE feedback_id = 3
RETURNING feedback_id, comment, hidden;
```

You should see: `3 | Chai came a bit late | false`. Row 3 returns. With a real delete, that is impossible.

## Common mistakes

All three were run for real in the video.

1. **`WHERE comment = NULL`.**

   ```sql
   DELETE FROM feedback
   WHERE comment = NULL;
   ```

   You see `Updated Rows 0`. Nothing is ever equal to NULL, so no row matches. Use `IS NULL`.

2. **Deleting a row that other tables point to.**

   ```sql
   DELETE FROM suppliers
   WHERE supplier_id = 1;
   ```

   ```text
   ERROR: update or delete on table "suppliers" violates foreign key constraint "restocks_supplier_id_fkey" on table "restocks"   (SQLSTATE 23503)
     Detail: Key (supplier_id)=(1) is still referenced from table "restocks".
   ```

   Supplier 1 still has restocks. Deal with the restocks first.

3. **Forgetting the hidden filter.** After the task below (feedback 5 hidden):

   ```sql
   SELECT count(*) FROM feedback;
   ```

   You get 7, but only 6 are visible. Every everyday query needs `WHERE hidden = false`.

## Try it yourself

1. Hide feedback 5. Then count the visible feedback. How many are left? (The video's task. Later lessons expect feedback 5 hidden.)
2. Write a query that lists only the hidden rows.
3. Why is `RETURNING` especially useful on a `DELETE`?

## Answers

1. ```sql
   UPDATE feedback
   SET hidden = true
   WHERE feedback_id = 5
   RETURNING feedback_id, rating, hidden;
   ```

   Returns `5 | 4 | true`. Then:

   ```sql
   SELECT count(*) FROM feedback
   WHERE hidden = false;
   ```

   6 visible rows are left (7 rows in the table, 1 hidden).

2. `SELECT * FROM feedback WHERE hidden = true;` gives 1 row: feedback 5, Friendly staff.
3. There is no undo. `RETURNING` shows exactly which rows went, so you have a record of them.

## Next

[M12-L04 · UPSERT: INSERT ... ON CONFLICT](../m12-l04-upsert-insert-on-conflict/)
