# M12-L01 · INSERT

> Video: Module 12, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- `INSERT INTO table (columns) VALUES (...)`: one value for each column, in the same order
- Many rows in one `INSERT`, with a comma between the rows
- `RETURNING`: get the new rows straight back, no second `SELECT` needed
- What a skipped column gets (NULL, or its default)
- Three mistakes: too many values, no column list, a reused ID

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need the empty `feedback` table from the task of [M11-L01](../../m11-creating-tables/m11-l01-create-table-columns-and-types/).
- This lesson puts 8 rows into `feedback`, and the next lessons use them.

## Files in this folder

| File | What it is |
|---|---|
| `insert.sql` | Every query from the video in order, with the real result or error as a comment |
| `setup.sql` | The 8 `feedback` rows (including the task's two). Run it only if you skipped the lesson |

## Follow along

Every table you built in Module 11 started empty. `INSERT` adds new rows: one row, many rows at once, and you can even get the new row straight back.

### 1. One row

The `feedback` table has five columns and no rows yet (`SELECT * FROM feedback;` shows only headers). Write `INSERT INTO feedback`, the column names in brackets, then `VALUES` with one value for each column, in the same order. Text and dates go inside single quotes.

```sql
INSERT INTO feedback (feedback_id, customer_id, rating, comment, given_on)
VALUES (1, 4, 5, 'Best masala chai in Pune', '2026-04-20');
```

You should see: `Updated Rows 1`. Feedback 1, from customer 4, five stars.

### 2. Many rows in one go

Write `VALUES` once, then each row in its own brackets, with a comma between the rows.

```sql
INSERT INTO feedback (feedback_id, customer_id, rating, comment, given_on)
VALUES (2, 7, 4, 'Samosa was hot and fresh', '2026-04-21'),
       (3, 12, 3, 'Chai came a bit late', '2026-04-22'),
       (4, 16, 5, 'Loved the Kulhad Chai', '2026-04-23');
```

You should see: `Updated Rows 3`.

```sql
SELECT * FROM feedback;
```

| feedback_id | customer_id | rating | comment | given_on |
|---|---|---|---|---|
| 1 | 4 | 5 | Best masala chai in Pune | 2026-04-20 |
| 2 | 7 | 4 | Samosa was hot and fresh | 2026-04-21 |
| 3 | 12 | 3 | Chai came a bit late | 2026-04-22 |
| 4 | 16 | 5 | Loved the Kulhad Chai | 2026-04-23 |

### 3. RETURNING

Add `RETURNING` at the end and name the columns you want back.

```sql
INSERT INTO feedback (feedback_id, customer_id, rating, comment, given_on)
VALUES (5, 9, 4, 'Friendly staff', '2026-04-24')
RETURNING feedback_id, rating, comment;
```

You should see:

| feedback_id | rating | comment |
|---|---|---|
| 5 | 4 | Friendly staff |

Postgres saves the row and shows it to you right away.

### 4. Skip a column

This time list only three columns. `RETURNING *` shows the whole new row.

```sql
INSERT INTO feedback (feedback_id, customer_id, rating)
VALUES (6, 2, 3)
RETURNING *;
```

You should see:

| feedback_id | customer_id | rating | comment | given_on |
|---|---|---|---|---|
| 6 | 2 | 3 | [NULL] | [NULL] |

`comment` and `given_on` are NULL because we gave them nothing. A column with a default would get its default instead.

## Common mistakes

All three were run for real in the video. Each one fails, and nothing is saved.

1. **Two columns, but three values.**

   ```sql
   INSERT INTO feedback (feedback_id, rating)
   VALUES (7, 4, 'Nice chai');
   ```

   ```text
   ERROR: INSERT has more expressions than target columns   (SQLSTATE 42601)
   ```

   One value per column.

2. **No column list, and the values in the wrong order.**

   ```sql
   INSERT INTO feedback
   VALUES (7, 'Great tea', 3, 5, '2026-04-25');
   ```

   ```text
   ERROR: invalid input syntax for type integer: "Great tea"   (SQLSTATE 22P02)
   ```

   The words land in `customer_id`, which only holds numbers. Always list the columns.

3. **Reusing an ID.**

   ```sql
   INSERT INTO feedback (feedback_id, customer_id, rating)
   VALUES (1, 3, 4);
   ```

   ```text
   ERROR: duplicate key value violates unique constraint "feedback_pkey"   (SQLSTATE 23505)
     Detail: Key (feedback_id)=(1) already exists.
   ```

   Every row needs its own ID.

## Try it yourself

1. Add two feedback rows in one `INSERT`, and return their IDs: feedback 7 from customer 11 (5 stars, 'Great tea') and feedback 8 from customer 18 (4 stars, 'Nice samosa'), with no date. What do you get back? (The video's task. Later lessons expect these rows.)
2. Count the rows in `feedback` now.
3. Which rows have no `given_on`? Write the query.

## Answers

1. ```sql
   INSERT INTO feedback (feedback_id, customer_id, rating, comment)
   VALUES (7, 11, 5, 'Great tea'),
          (8, 18, 4, 'Nice samosa')
   RETURNING feedback_id;
   ```

   You get back two rows: `7` and `8`.

2. `SELECT count(*) FROM feedback;` gives 8.
3. `SELECT * FROM feedback WHERE given_on IS NULL;` gives 3 rows: 6, 7 and 8.

## Next

[M12-L02 · UPDATE Safely](../m12-l02-update-safely/)
