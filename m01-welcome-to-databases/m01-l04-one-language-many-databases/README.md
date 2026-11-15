# M01-L04 · One Language, Many Databases

> Video: Module 1, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- That SQL is one language understood by many databases: PostgreSQL, MySQL, SQLite, SQL Server and BigQuery
- What a **dialect** is: the small habits that differ from one database to another
- Two real dialect differences: dividing whole numbers, and joining text with `||`
- Which database is usually used where
- Why this course uses PostgreSQL 18

This is mostly an idea lesson. The files below let you repeat the video's comparison later: in PostgreSQL once you have the Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/), and optionally in MySQL 8.4 and SQLite if you have them.

## Files in this folder

| File | What it is |
|---|---|
| `same.sql` | The three queries the video types into all three databases, with each database's real answer |
| `dialects.sql` | The fixes: `7 / 2.0` in PostgreSQL, `SHOW WARNINGS` and `CONCAT` in MySQL |
| `menu.sql` | Creates the 10-row `menu_items` table, for MySQL or SQLite (PostgreSQL already has it) |

## Key ideas

### 1. Same question, same answer

In the last lesson PostgreSQL answered: which menu items cost less than ₹30? The video types the very same question into three databases:

```sql
SELECT name, price FROM menu_items WHERE price < 30 ORDER BY price;
```

PostgreSQL (psql):

```text
     name     | price
--------------+-------
 Cutting Chai |    20
 Samosa       |    25
(2 rows)
```

MySQL 8.4:

```text
+--------------+-------+
| name         | price |
+--------------+-------+
| Cutting Chai |    20 |
| Samosa       |    25 |
+--------------+-------+
2 rows in set (0.00 sec)
```

SQLite:

```text
name          price
------------  -----
Cutting Chai  20
Samosa        25
```

The question is the same letter for letter. Only the look of the answer changes: psql adds a row count, MySQL draws boxes, SQLite prints plain columns. The rows are the same, which is why most of this course works in every database.

### 2. Five names you will hear

| Database | In one line |
|---|---|
| **PostgreSQL** | free, open source, very powerful; many new apps choose it |
| **MySQL** | free; runs a huge number of websites, including most WordPress sites |
| **SQLite** | a tiny database in a single file, built into every phone and every web browser |
| **SQL Server** | from Microsoft; popular in big companies that already use Microsoft tools |
| **BigQuery** | from Google; runs in the cloud, made for scanning huge amounts of data |

### 3. Dialects

Each database has its own small habits, called **dialects**: like English in India and English in Britain, the same language with a few different words.

**Dividing whole numbers:**

```sql
SELECT 7 / 2 AS result;
```

| Database | Answer |
|---|---|
| PostgreSQL | `3` |
| SQLite | `3` |
| MySQL | `3.5000` |

PostgreSQL and SQLite divide whole numbers as whole numbers. To get 3.5 in PostgreSQL, write `7 / 2.0`:

```text
postgres=# SELECT 7 / 2.0 AS result;
       result
--------------------
 3.5000000000000000
(1 row)
```

**Joining text:** two straight lines, `||`, join text together.

```sql
SELECT 'Chai' || ' Corner' AS shop;
```

PostgreSQL and SQLite give `Chai Corner`. In MySQL `||` means OR, so the answer is `0`, with 3 warnings (`1 row in set, 3 warnings`). MySQL uses the word `CONCAT` (short for concatenate) instead:

```sql
SELECT CONCAT('Chai', ' Corner') AS shop;
```

```text
+-------------+
| shop        |
+-------------+
| Chai Corner |
+-------------+
```

### 4. Which database is used where

- An app on your phone usually keeps its data in **SQLite**.
- A website or online shop often uses **MySQL** or **PostgreSQL**.
- A large company with Microsoft tools may use **SQL Server**.
- A team studying billions of rows, like every click on a big website, may use **BigQuery**.

### 5. Why this course uses PostgreSQL

- It is free, and installs on Windows, Mac and Linux.
- It follows the official SQL standard closely, so what you learn moves easily to other databases.
- It is powerful enough for real companies, and one of the most loved databases by developers.
- It is what Chai Corner runs on. The course uses **PostgreSQL 18**.

### 6. Three beginner mistakes

1. **Thinking you must learn a new language for every database.** Learn SQL once; only the small habits change.
2. **Copying an answer from the internet without checking which database it was written for.** The `||` example shows why.
3. **Thinking SQLite is a toy.** It runs on billions of devices. It is simply made for one app and one file.

## Try it yourself

1. The video's task: guess what `7 / 2.0` gives in MySQL. Write down your guess.
2. After Module 2, run `same.sql` in psql on your Chai Corner database. Do you get `3` for `7 / 2`?
3. Which database would you pick for: (a) a to-do app on a phone, (b) an online shop, (c) studying every click on a huge website?

## Answers

1. `3.5000`. MySQL already keeps the decimals for `7 / 2`, and `7 / 2.0` gives the same `3.5000` (checked on MySQL 8.4).
2. Yes: `3`, because both numbers are whole numbers. `7 / 2.0` gives `3.5000000000000000`.
3. (a) SQLite, (b) MySQL or PostgreSQL, (c) BigQuery.

## Next

[M01-L05 · The Course Map and the Chai Corner Database](../m01-l05-the-course-map-and-the-chai-corner-database/)
