# M21-L01 · Cleaning Messy Data: Duplicates, Extra Spaces, Wrong Formats

> Video: Module 21, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- The four kinds of mess in imported data: extra spaces, random capital letters, dates written two ways, and the same person twice
- How to see invisible spaces by wrapping each value in square brackets
- `TRIM`, `LOWER` and `INITCAP` to fix spaces and capitals
- Why casting mixed dates with `::date` fails, or worse, is silently wrong, and how `TO_DATE` with a format fixes it
- `ROW_NUMBER()` to number the copies of each person, and building a clean copy with `CREATE TABLE ... AS`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver (or psql) connected to `chai_corner`.
- This lesson creates two new tables, `messy_signups` and `clean_signups` (DB update 14).

## Files in this folder

| File | What it is |
|------|------------|
| `cleaning_messy_data.sql` | Every query from the video, in order, with the real results as comments |
| `setup.sql` | DB update 14: rebuilds `messy_signups` (7 rows) and `clean_signups` (5 rows). Re-runnable. Use it to bring your database up to date if you skip the lesson |

If you already ran `setup.sql`, drop the two tables first (`DROP TABLE clean_signups, messy_signups;`) so you can follow the lesson from the start.

## Follow along

### 1. The four kinds of mess

| Mess | Fix |
|------|-----|
| Spaces before or after the text | `TRIM` removes them |
| Capital letters all over the place | `LOWER` and `INITCAP` make them the same |
| Dates written in two formats | `TO_DATE` reads each one correctly |
| Repeats: the same person, signed up twice | `ROW_NUMBER` finds them |

### 2. A small messy import

Seven sign ups, with a name, an email, a city and a date, all stored as text:

```sql
CREATE TABLE messy_signups (id int, name text, email text, city text, signed_on text);
INSERT INTO messy_signups VALUES
 (1, '  asha  ', 'Asha@Example.com',   'pune',    '2026-03-01'),
 (2, 'LUKAS',    'lukas@example.com ', 'Mumbai ', '02/03/2026'),
 (3, 'priya',    'priya@example.com',  ' mumbai', '2026-03-05'),
 (4, 'Asha',     'asha@example.com',   'Pune',    '01/03/2026'),
 (5, 'rahul ',   'RAHUL@EXAMPLE.COM',  'Delhi',   '2026-03-09'),
 (6, 'Kabir',    'kabir@example.com',  'delhi',   '25/03/2026'),
 (7, 'Priya',    ' PRIYA@example.com', 'Mumbai',  '2026-03-05');
```

Spaces are invisible, so wrap each value in square brackets (`||` joins text):

```sql
SELECT id, '[' || name || ']' AS name, '[' || email || ']' AS email,
       '[' || city || ']' AS city, signed_on
FROM messy_signups ORDER BY id;
```

You should see:

| id | name | email | city | signed_on |
|----|------|-------|------|-----------|
| 1 | [  asha  ] | [Asha@Example.com] | [pune] | 2026-03-01 |
| 2 | [LUKAS] | [lukas@example.com ] | [Mumbai ] | 02/03/2026 |
| 3 | [priya] | [priya@example.com] | [ mumbai] | 2026-03-05 |
| 4 | [Asha] | [asha@example.com] | [Pune] | 01/03/2026 |
| 5 | [rahul ] | [RAHUL@EXAMPLE.COM] | [Delhi] | 2026-03-09 |
| 6 | [Kabir] | [kabir@example.com] | [delhi] | 25/03/2026 |
| 7 | [Priya] | [ PRIYA@example.com] | [Mumbai] | 2026-03-05 |

### 3. How many people really signed up?

```sql
SELECT COUNT(*) AS all_rows, COUNT(DISTINCT email) AS raw_emails,
       COUNT(DISTINCT LOWER(TRIM(email))) AS real_people
FROM messy_signups;
```

You should see:

| all_rows | raw_emails | real_people |
|----------|------------|-------------|
| 7 | 7 | 5 |

Seven rows and seven different emails. After cleaning the emails, only five people.

### 4. Spaces and capitals

`TRIM` cuts the spaces from both ends. `LOWER` turns the email into small letters. `INITCAP` gives each word one capital letter, so `pune` and `Pune` both become `Pune`.

```sql
SELECT id, INITCAP(TRIM(name)) AS name, LOWER(TRIM(email)) AS email, INITCAP(TRIM(city)) AS city
FROM messy_signups ORDER BY id;
```

You should see:

| id | name | email | city |
|----|------|-------|------|
| 1 | Asha | asha@example.com | Pune |
| 2 | Lukas | lukas@example.com | Mumbai |
| 3 | Priya | priya@example.com | Mumbai |
| 4 | Asha | asha@example.com | Pune |
| 5 | Rahul | rahul@example.com | Delhi |
| 6 | Kabir | kabir@example.com | Delhi |
| 7 | Priya | priya@example.com | Mumbai |

Now Asha appears twice, with exactly the same email. The repeat is easy to spot.

### 5. Dates, the quick way (and why it fails)

Cast the text to a date with `::date`:

```sql
SELECT id, signed_on, signed_on::date AS signed_date
FROM messy_signups ORDER BY id;
```

You should see an error:

```text
SQL Error [22008]: ERROR: date/time field value out of range: "25/03/2026"
  Hint: Perhaps you need a different "DateStyle" setting.
```

Day 25, month 3 does not fit, because PostgreSQL reads `25/03/2026` as month 25. Skip Kabir's row and it runs:

```sql
SELECT id, signed_on, signed_on::date AS signed_date
FROM messy_signups WHERE id <> 6 ORDER BY id;
```

You should see:

| id | signed_on | signed_date |
|----|-----------|-------------|
| 1 | 2026-03-01 | 2026-03-01 |
| 2 | 02/03/2026 | 2026-02-03 |
| 3 | 2026-03-05 | 2026-03-05 |
| 4 | 01/03/2026 | 2026-01-03 |
| 5 | 2026-03-09 | 2026-03-09 |
| 7 | 2026-03-05 | 2026-03-05 |

Look closely: the second of March became the third of February. No error, just wrong.

### 6. Tell SQL the format

If the text has a slash, read it as day, month, year. Otherwise, year, month, day:

```sql
SELECT id, signed_on,
       CASE WHEN signed_on LIKE '%/%' THEN TO_DATE(signed_on, 'DD/MM/YYYY')
            ELSE TO_DATE(signed_on, 'YYYY-MM-DD') END AS signed_date
FROM messy_signups ORDER BY id;
```

You should see:

| id | signed_on | signed_date |
|----|-----------|-------------|
| 1 | 2026-03-01 | 2026-03-01 |
| 2 | 02/03/2026 | 2026-03-02 |
| 3 | 2026-03-05 | 2026-03-05 |
| 4 | 01/03/2026 | 2026-03-01 |
| 5 | 2026-03-09 | 2026-03-09 |
| 6 | 25/03/2026 | 2026-03-25 |
| 7 | 2026-03-05 | 2026-03-05 |

Every date is right. Lukas signed up on the second of March.

### 7. Find the repeats with ROW_NUMBER

`ROW_NUMBER()` counts the copies of each email (a window function from Module 15). The first copy gets 1, a repeat gets 2:

```sql
SELECT id, LOWER(TRIM(email)) AS email,
       ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY id) AS copy_no
FROM messy_signups ORDER BY email, copy_no;
```

You should see:

| id | email | copy_no |
|----|-------|---------|
| 1 | asha@example.com | 1 |
| 4 | asha@example.com | 2 |
| 6 | kabir@example.com | 1 |
| 2 | lukas@example.com | 1 |
| 3 | priya@example.com | 1 |
| 7 | priya@example.com | 2 |
| 5 | rahul@example.com | 1 |

Asha and Priya each have a copy number 2. Those are the rows to drop.

### 8. Put it together in a clean copy

Every fix in one `WITH`, keep only copy number 1, and save it as a new table:

```sql
CREATE TABLE clean_signups AS
WITH fixed AS (
  SELECT id, INITCAP(TRIM(name)) AS name, LOWER(TRIM(email)) AS email,
         INITCAP(TRIM(city)) AS city,
         CASE WHEN signed_on LIKE '%/%' THEN TO_DATE(signed_on, 'DD/MM/YYYY')
              ELSE TO_DATE(signed_on, 'YYYY-MM-DD') END AS signed_date,
         ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY id) AS copy_no
  FROM messy_signups)
SELECT id, name, email, city, signed_date FROM fixed WHERE copy_no = 1;
```

You should see `Updated Rows 5` in DBeaver (`SELECT 5` in psql). Then:

```sql
SELECT * FROM clean_signups ORDER BY id;
```

| id | name | email | city | signed_date |
|----|------|-------|------|-------------|
| 1 | Asha | asha@example.com | Pune | 2026-03-01 |
| 2 | Lukas | lukas@example.com | Mumbai | 2026-03-02 |
| 3 | Priya | priya@example.com | Mumbai | 2026-03-05 |
| 5 | Rahul | rahul@example.com | Delhi | 2026-03-09 |
| 6 | Kabir | kabir@example.com | Delhi | 2026-03-25 |

One clean row per person. And `messy_signups` is still there, untouched.

## Common mistakes

- **Cleaning the original table in place.** Keep the raw data, and build a clean copy.
- **Casting mixed dates directly.** Some fail, and some are silently wrong. Always give the format with `TO_DATE`.
- **Counting before cleaning.** `DISTINCT` sees a capital A as a different person. Clean first, then count.

## Try it yourself

1. Two emails are the same except for a capital R, a space in front of one, and a space after the other: `' Ravi@Example.com'` and `'ravi@example.com '`. After `TRIM` and `LOWER`, how many people?
2. Write a query that shows only the rows of `messy_signups` that are repeats (copy number 2 or more).
3. What does `INITCAP(TRIM('  new delhi '))` return?

## Answers

1. One person.
   ```sql
   SELECT COUNT(DISTINCT LOWER(TRIM(e))) AS people
   FROM (VALUES (' Ravi@Example.com'), ('ravi@example.com ')) AS t(e);
   -- 1
   ```
2. Wrap the `ROW_NUMBER` query in a `WITH` and filter:
   ```sql
   WITH numbered AS (
     SELECT id, LOWER(TRIM(email)) AS email,
            ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(email)) ORDER BY id) AS copy_no
     FROM messy_signups)
   SELECT * FROM numbered WHERE copy_no > 1;
   -- 2 rows: id 4 asha@example.com, id 7 priya@example.com
   ```
3. `New Delhi`.

## Next

[M21-L02 · Date Reports: Filling Missing Days, Week and Month Buckets](../m21-l02-date-reports-filling-missing-days-week-and-month-buckets/)
