# M03-L01 · SELECT and FROM: Reading a Table

> Video: Module 3, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- How to open the `chai_corner` database in DBeaver (Show all databases)
- How to read a whole table with `SELECT * FROM table;`
- Why the database reads `FROM` first, then `SELECT`
- That capitals and new lines do not matter, but names must be exact
- The three most common first errors: a misspelled table, a missing `FROM`, a space in a name

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). No earlier lesson has a `setup.sql` yet.
- DBeaver connected to your server ([M02-L02](../../m02-setting-up/m02-l02-installing-dbeaver-and-connecting-to-your-database/)). psql works too: type `\c chai_corner` first.

## Files in this folder

| File | What it is |
|---|---|
| `queries.sql` | The five queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes, each failing on purpose, with the real error |

## Follow along

Think of Chai Corner's menu written in a register book: every row is one item, every column one detail about it (a number, a name, a price). To read it you only need to say two things: which columns you want, and which table to look in. In SQL that is `SELECT` and `FROM`.

### 1. Open Chai Corner in DBeaver

Your connection from M02-L02 opens the `postgres` database. Chai Corner sits right next to it, so show it:

1. Click **postgres** in the navigator and press **F4** (on a Mac you may need **fn + F4**). The connection settings open.
2. Turn on **Show all databases** and click **OK**.
3. Open **postgres → Databases**. There it is: **chai_corner**. Open it, then **Schemas → public → Tables**. All three tables are here.
4. Click **chai_corner**, open the **SQL Editor** menu and choose **New SQL script**. The toolbar now shows `chai_corner`: every query you run goes there.

### 2. Your first real query

```sql
SELECT * FROM menu_items;
```

| Part | Meaning |
|---|---|
| `SELECT` | show me |
| `*` (star) | every column |
| `FROM menu_items` | which table |
| `;` | ends the query |

Read it like a sentence: *show me every column, from the menu items table.*

How the database runs it: first it goes to the table after `FROM`, then `SELECT` picks the columns to show. **FROM first, then SELECT.**

Before you run it, guess: the menu has ten items. How many rows come back?

Run it with **Cmd + Return** (Mac), **Ctrl + Enter** (Windows), or the orange play button. You should see:

| item_id | name | price |
|---|---|---|
| 1 | Bun Maska | 35 |
| 2 | Cold Coffee | 80 |
| 3 | Cutting Chai | 20 |
| 4 | Filter Coffee | 40 |
| 5 | Ginger Chai | 30 |
| 6 | Maggi | 60 |
| 7 | Masala Chai | 30 |
| 8 | Samosa | 25 |
| 9 | Vada Pav | 30 |
| 10 | Veg Sandwich | 70 |

Ten rows, three columns. The grey numbers on the left of DBeaver's grid only count the rows; they are not part of the data. At the bottom: **10 row(s) fetched** in 0.003 s (yours will differ).

### 3. The other tables

```sql
SELECT * FROM branches;
```

Ten branches, each with a city and the date it opened:

| branch_id | city | opened_on |
|---|---|---|
| 1 | Pune | 2019-04-12 |
| 2 | Mumbai | 2019-09-02 |
| 3 | Delhi | 2020-01-20 |
| 4 | Bengaluru | 2020-07-15 |
| 5 | Chennai | 2021-02-08 |
| 6 | Hyderabad | 2021-08-23 |
| 7 | Kolkata | 2022-03-14 |
| 8 | Jaipur | 2022-11-05 |
| 9 | Ahmedabad | 2023-06-19 |
| 10 | Kochi | 2024-01-29 |

```sql
SELECT * FROM customers;
```

Fifteen customers, from Asha to Kiran (`customer_id`, `name`, `joined_on`).

### 4. Capitals and new lines do not matter

```sql
select * from menu_items;
```

Same 10 rows. We write keywords in capitals only so they stand out. (DBeaver may change the case of keywords as you type; that is fine.)

```sql
SELECT *
FROM menu_items;
```

Same 10 rows again. Only the semicolon ends the query.

## Common mistakes

- **A misspelled table name** (`menu_item`, no s):
  ```text
  ERROR: relation "menu_item" does not exist
  ```
  Copy the name exactly, from the navigator.
- **Forgetting FROM** (`SELECT * menu_items;`):
  ```text
  ERROR: syntax error at or near "menu_items"
  ```
  A **syntax error** means the words are not in an order SQL understands.
- **A space instead of the underscore** (`SELECT * FROM menu items;`): SQL reads two separate words, so it looks for a table called `menu`:
  ```text
  ERROR: relation "menu" does not exist
  ```

DBeaver shows these with a prefix such as `SQL Error [42P01]:` or `SQL Error [42601]:`. That code is just the error's number.

## Try it yourself

1. The video's task: run `SELECT * FROM customers;`. Who is customer number 7?
2. Run `SELECT * FROM branches;` in lower case, on two lines. Same answer?
3. What error do you get from `SELECT * FROM customer;`? Why?

## Answers

1. **Rohan** (customer 7, joined 2025-03-05).
2. Yes: the same 10 rows. Capitals and new lines do not matter.
3. `ERROR: relation "customer" does not exist`. The table is called `customers`, with an s. Names must be exact.

## Next

[M03-L02 · Choosing Columns, Maths and AS](../m03-l02-choosing-columns-maths-and-as/)
