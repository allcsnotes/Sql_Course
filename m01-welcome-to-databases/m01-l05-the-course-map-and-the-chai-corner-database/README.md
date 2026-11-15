# M01-L05 · The Course Map and the Chai Corner Database

> Video: Module 1, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- The seven levels of the course, from your first query to interview practice
- The pattern every lesson follows
- Who is who at Chai Corner, the made-up café chain used in every lesson
- The three tables the Chai Corner database starts with: `branches`, `menu_items`, `customers`
- Three beginner mistakes to avoid while you learn

This is an idea lesson. The tour at the end is something you can repeat yourself once the database is loaded in [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/).

## Key ideas

### 1. Seven levels

Each level builds on the one before.

| Level | Name | What you do |
|---|---|---|
| 1 | Foundations | install PostgreSQL and write your first queries |
| 2 | Working with data | types of data, handy functions, and summaries such as total sales per day |
| 3 | Many tables | design a database and join tables together |
| 4 | Creating and changing data | build tables, add and edit rows, keep every change safe |
| 5 | Advanced SQL | powerful tools like window functions, which data analysts use every day |
| 6 | Speed and safety | make slow queries fast, protect data with users and backups |
| 7 | Real world and career | SQL from code, data analysis, other databases, interview practice |

By the end you will write the kind of queries real companies use every day, and you will be ready for SQL interviews.

### 2. How every lesson works

1. It starts with a **question** the data can answer, and a picture from daily life.
2. An **animated diagram** shows what the database does, row by row.
3. The query is typed **live**. Before it runs, you guess the answer; then it runs and you check.
4. It ends with the **beginner mistakes**, so you can spot them before they happen to you.

Each module also ends with a **practice sheet**, and six **build projects** let you use everything on real business questions.

### 3. Meet Chai Corner

Chai Corner is a made-up chain of tea cafés with ten branches across India. **Meera** owns it, and she wants answers: which branch sells the most? Which customers stopped coming? **Asha**, **Lukas**, **Priya** and **Rahul** are some of the regular customers you will meet in the data. Every question Meera asks becomes a query you will write.

### 4. The database starts small

| Table | One row for | Columns |
|---|---|---|
| `branches` | each café | `branch_id`, `city`, `opened_on` (the day it opened) |
| `menu_items` | every drink and snack | `item_id`, `name`, `price` |
| `customers` | each person who buys from Chai Corner | `customer_id`, `name`, `joined_on` (the day they joined) |

As the course goes on, the database grows: orders, order items, staff and deliveries join in. By the end it is a full online ordering system, with about 100,000 orders.

### 5. A first look in PostgreSQL

The video takes a first look in psql. Do not worry about these words yet: you will learn every one of them, step by step.

`\dt` lists the tables. Three rows:

```text
chai_corner=# \dt
             List of tables
 Schema |    Name    | Type  |  Owner
--------+------------+-------+----------
 public | branches   | table | postgres
 public | customers  | table | postgres
 public | menu_items | table | postgres
(3 rows)
```

`SELECT * FROM branches;` shows every branch. Ten rows, one for each city, from Pune to Kochi:

```text
 branch_id |   city    | opened_on
-----------+-----------+------------
         1 | Pune      | 2019-04-12
         2 | Mumbai    | 2019-09-02
         3 | Delhi     | 2020-01-20
         4 | Bengaluru | 2020-07-15
         5 | Chennai   | 2021-02-08
         6 | Hyderabad | 2021-08-23
         7 | Kolkata   | 2022-03-14
         8 | Jaipur    | 2022-11-05
         9 | Ahmedabad | 2023-06-19
        10 | Kochi     | 2024-01-29
(10 rows)
```

`SELECT * FROM menu_items;` shows the whole menu, from Bun Maska to Veg Sandwich:

```text
 item_id |     name      | price
---------+---------------+-------
       1 | Bun Maska     |    35
       2 | Cold Coffee   |    80
       3 | Cutting Chai  |    20
       4 | Filter Coffee |    40
       5 | Ginger Chai   |    30
       6 | Maggi         |    60
       7 | Masala Chai   |    30
       8 | Samosa        |    25
       9 | Vada Pav      |    30
      10 | Veg Sandwich  |    70
(10 rows)
```

The `customers` table has 15 rows, from Asha (joined 2024-11-11) to Kiran (joined 2026-06-10).

### 6. Three beginner mistakes

1. **Skipping ahead to the advanced lessons.** Joins and window functions are much easier when the basics are solid.
2. **Only watching.** Type every query yourself. Your fingers learn SQL faster than your eyes.
3. **Being scared to break the database.** It is your own copy. If something goes wrong, you simply load it again ([M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) shows how).

## Try it yourself

1. The video's task: write down one question you would ask about a café's data.
2. Which of the three starting tables would answer each question? (a) When did the Kochi branch open? (b) How much is a Vada Pav? (c) When did Priya join?
3. Which level of the course will teach you to make a slow query fast?

## Answers

1. Any clear question works, for example "Which drink is the most expensive?" or "Which branch opened first?". You will answer questions like these from Module 3.
2. (a) `branches` (2024-01-29). (b) `menu_items` (₹30). (c) `customers` (2024-12-02).
3. Level 6, Speed and safety.

## Next

[M02-L01 · Installing PostgreSQL 18 on Windows and Mac](../../m02-setting-up/m02-l01-installing-postgresql-18-on-windows-and-mac/)
