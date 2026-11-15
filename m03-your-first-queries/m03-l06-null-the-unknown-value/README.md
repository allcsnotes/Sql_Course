# M03-L06 · NULL: the Unknown Value

> Video: Module 3, Lesson 6. Watch it first, then follow along here.

## What you'll learn

- What `NULL` is: a special value meaning **we do not know** (not zero, not empty text)
- Why `= NULL` returns no rows, and why `NULL = NULL` is not true
- That any maths with NULL gives NULL
- How to test for it with `IS NULL` and `IS NOT NULL`
- Why NULL rows hide from `<>`, and how to keep them

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- **Run this lesson's `setup.sql` first** (Chai Corner update 1). It adds an `email` column to `customers`. Every later lesson expects it.

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | Chai Corner update 1: adds `customers.email`, filled for 11 customers and NULL for 4. Safe to run twice |
| `queries.sql` | The eight queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes |

## Follow along

Chai Corner asked every customer for an email address. Four customers did not give one. So what goes in their email box? Not zero. Not empty text. SQL puts a special value there, called **NULL**. It means: we do not know.

### 1. Get the new data

Run `setup.sql` on `chai_corner`:

- **DBeaver:** open the file (**File → Open File**, or drag it into DBeaver), make sure the toolbar shows `chai_corner`, and run the whole script with **Execute SQL Script** (Alt + X).
- **psql:** start psql in this folder, `\c chai_corner`, then `\i setup.sql`.

```sql
ALTER TABLE customers ADD COLUMN IF NOT EXISTS email varchar(60);
UPDATE customers SET email = lower(name) || '@example.com' WHERE customer_id NOT IN (2, 5, 8, 13);
CLUSTER customers USING customers_pkey;
```

`ALTER TABLE ... ADD COLUMN` adds the column (empty, so NULL, for everyone); the `UPDATE` fills it for everyone except customers 2, 5, 8 and 13. You will learn both commands properly in Level 4. The last line only keeps the rows stored in `customer_id` order, so the next query lists them 1 to 15 as in the video.

### 2. What NULL looks like

```sql
SELECT * FROM customers;
```

| customer_id | name | joined_on | email |
|---|---|---|---|
| 1 | Asha | 2024-11-11 | asha@example.com |
| 2 | Lukas | 2024-11-14 | [NULL] |
| 3 | Priya | 2024-12-02 | priya@example.com |
| 4 | Rahul | 2025-01-09 | rahul@example.com |
| 5 | Kabir | 2025-01-21 | [NULL] |
| ... | ... | ... | ... |
| 8 | Isha | 2025-04-12 | [NULL] |
| ... | ... | ... | ... |
| 13 | Dev | 2026-01-15 | [NULL] |
| 14 | Tara | 2026-03-27 | tara@example.com |
| 15 | Kiran | 2026-06-10 | kiran@example.com |

Fifteen rows. Lukas, Kabir, Isha and Dev have **NULL**, shown by DBeaver as `[NULL]` in grey square brackets (psql shows an empty space). NULL is a sign that says: this box is empty, we do not know what goes here.

### 3. The equals trap

The natural guess for "customers with no email":

```sql
SELECT name, email FROM customers WHERE email = NULL;
```

No error, but **0 rows**. Why? Ask SQL directly:

```sql
SELECT NULL = NULL;
```

The answer is not true. It is **NULL** again. Think of two people whose ages you do not know: are they the same age? You cannot say yes. The honest answer is "we do not know". `WHERE` only keeps a row when the answer is **true**, and "we do not know" is not true, so every row is dropped.

### 4. Maths with NULL

```sql
SELECT 5 + NULL;
```

The answer is **NULL**. Five plus an unknown number is still unknown. Any maths with NULL gives NULL.

### 5. IS NULL and IS NOT NULL

To test for NULL, SQL has special words:

```sql
SELECT name, email FROM customers WHERE email IS NULL;
```

| name | email |
|---|---|
| Lukas | [NULL] |
| Kabir | [NULL] |
| Isha | [NULL] |
| Dev | [NULL] |

```sql
SELECT name, email FROM customers WHERE email IS NOT NULL;
```

Eleven rows: everyone who gave an email. Four plus eleven is fifteen: every customer is counted exactly once.

### 6. NULL hides from not equal

Show every customer except Asha. Fourteen rows, right?

```sql
SELECT name, email FROM customers WHERE email <> 'asha@example.com';
```

Only **10 rows**. The four NULL customers are gone too. Is an unknown email different from Asha's? SQL says: we do not know. So those rows are dropped. To keep them:

```sql
SELECT name, email FROM customers WHERE email <> 'asha@example.com' OR email IS NULL;
```

Now **14 rows**: everyone except Asha.

## Common mistakes

- **Writing `= NULL`.** No error, but 0 rows. Always write `IS NULL`.
- **Putting NULL inside quotes** (`WHERE email = 'NULL'`). That looks for the word NULL written as text: 0 rows. NULL never goes inside quotes.
- **Thinking NULL means zero.** `5 + NULL` is not 5. It is NULL. NULL means unknown, not zero.

## Try it yourself

1. The video's task: show every customer who gave an email and joined in 2025. How many rows come back?
2. How many customers who joined in 2025 did **not** give an email?
3. What does `SELECT NULL <> NULL;` return?

## Answers

1. ```sql
   SELECT name, email FROM customers WHERE email IS NOT NULL AND joined_on BETWEEN '2025-01-01' AND '2025-12-31';
   ```
   **7 rows**: Rahul, Ananya, Rohan, Vikram, Neha, Arjun, Sara.
2. ```sql
   SELECT name FROM customers WHERE email IS NULL AND joined_on BETWEEN '2025-01-01' AND '2025-12-31';
   ```
   2 rows: Kabir and Isha.
3. NULL. Comparing anything with NULL, using any sign, gives NULL.

## Next

[M04-L01 · ORDER BY: Sorting Rows](../../m04-sorting-and-limiting/m04-l01-order-by-sorting-rows/)
