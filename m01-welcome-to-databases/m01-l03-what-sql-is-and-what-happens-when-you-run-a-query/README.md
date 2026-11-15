# M01-L03 · What SQL Is and What Happens When You Run a Query

> Video: Module 1, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What SQL is, and why it is called a **declarative** language (you say what you want, not how)
- How to read a query word by word: `SELECT`, `FROM`, `WHERE` and the semicolon
- What happens when you press Enter: **parse**, **plan**, **execute**, and the result comes back
- How to see a plan with `EXPLAIN`
- Why the answer to a query is always a table, and three beginner mistakes

This is an idea lesson. The video runs its queries in psql on the demo database from the last lesson (with `orders` and a `phone` column). You will install PostgreSQL in [Module 2](../../m02-setting-up/m02-l01-installing-postgresql-18-on-windows-and-mac/) and type your own queries from Module 3.

## Key ideas

### 1. One short sentence

Our demo Chai Corner database holds 365,000 orders in four tables. What is Priya's phone number? Instead of scrolling, you write one sentence the database understands:

```sql
SELECT name, phone FROM customers WHERE customer_id = 3;
```

```text
 name  |    phone
-------+-------------
 Priya | 98200 11223
(1 row)

Time: 1.508 ms
```

The answer comes back in under two milliseconds.

### 2. What SQL is

**SQL** stands for **Structured Query Language**; a **query** is a question. It is the language for talking to relational databases such as PostgreSQL, MySQL and SQLite.

You only say **what** you want, never **how** to find it. At a chai counter you say "one Masala Chai, please"; you do not tell the cook how to boil the milk. In the same way you say "give me Priya's phone", and the database works out how to find it.

### 3. Reading a query word by word

| Part | What it says | In the example |
|---|---|---|
| `SELECT` | which columns you want | `name, phone` |
| `FROM` | which table to look in | `customers` |
| `WHERE` | which rows to keep | only `customer_id = 3` |
| `;` | my question is finished | |

Read it aloud and it is almost English: *select name and phone, from customers, where customer id is 3.*

One more: which menu items cost less than ₹30?

```sql
SELECT name, price FROM menu_items WHERE price < 30;
```

```text
     name     | price
--------------+-------
 Cutting Chai |    20
 Samosa       |    25
(2 rows)
```

### 4. What happens when you press Enter

```text
psql  ──query text──>  PostgreSQL server
                       1. parse    is this valid SQL?
                       2. plan     the fastest way to find the rows
                       3. execute  read the rows, build the answer
psql  <──result table──
```

Your query is just text. **psql**, the tool you type in, sends it to the database **server**: a program (PostgreSQL) that runs all the time and looks after the data on disk. The server parses, plans and executes, and the result travels back as a small table.

### 5. Watching the steps for real

**Parse.** Drop the last letter of `SELECT` and the grammar check stops it. Nothing is read; the server does not even look at the data:

```text
postgres=# SELEC name FROM customers;
ERROR:  syntax error at or near "SELEC"
LINE 1: SELEC name FROM customers;
        ^
```

**Plan.** Put `EXPLAIN` in front of a query to see the plan. Counting Priya's orders:

```sql
EXPLAIN SELECT count(*) FROM orders WHERE customer_id = 3;
```

```text
                            QUERY PLAN
-------------------------------------------------------------------
 Aggregate  (cost=6946.63..6946.64 rows=1 width=8)
   ->  Seq Scan on orders  (cost=0.00..6887.56 rows=23628 width=0)
         Filter: (customer_id = 3)
(3 rows)
```

**Seq Scan** (sequential scan) means: read every order, and keep the ones for customer 3. The plan is only a guess (`rows=23628`); it has not read anything yet.

**Execute.** Run the query itself:

```text
 count
-------
 24276
(1 row)

Time: 20.307 ms
```

It reads all 365,000 orders and finds 24,276 in about 20 milliseconds. Your timings will differ.

### 6. The answer is always a table

- `SELECT * FROM menu_items;` gives 10 rows and 3 columns (`item_id`, `name`, `price`).
- One count still gives a table: 1 row, 1 column.

And you are not the only one asking. At Chai Corner the billing counter, the owner's dashboard and the website all send SQL to the same server, which answers each of them many times a second.

### 7. Three beginner mistakes

1. **Forgetting the semicolon.** psql thinks you are still typing, and the prompt changes from `postgres=#` to `postgres-#`. Type `;` and press Enter:
   ```text
   postgres=# SELECT name FROM customers
   postgres-# WHERE customer_id = 3
   postgres-# ;
    name
   -------
    Priya
   (1 row)
   ```
2. **Double quotes around text.** Double quotes mean a column name, so the database looks for a column called Priya:
   ```text
   postgres=# SELECT name FROM customers WHERE name = "Priya";
   ERROR:  column "Priya" does not exist
   ```
   Write text in single quotes: `WHERE name = 'Priya'` returns Priya.
3. **Fearing a query will break your data.** `SELECT` only reads. It never changes a single row.

## Try it yourself

1. The video's task: write it in plain English first, then in SQL: show the name and price of every menu item.
2. Write a query for the name and price of the menu items that cost more than ₹50.
3. Which of the three steps (parse, plan, execute) stops `SELEC name FROM customers;`? Did the server read any rows?

## Answers

1. English: *select name and price, from menu items.* SQL:
   ```sql
   SELECT name, price FROM menu_items;
   ```
   You can run this one yourself on the Chai Corner database from Module 3: it returns all 10 items, from Bun Maska ₹35 to Veg Sandwich ₹70.
2. ```sql
   SELECT name, price FROM menu_items WHERE price > 50;
   ```
   On the Chai Corner menu: Cold Coffee 80, Maggi 60, Veg Sandwich 70.
3. Parse, step 1. No: a syntax error stops the query before any data is read.

## Next

[M01-L04 · One Language, Many Databases](../m01-l04-one-language-many-databases/)
