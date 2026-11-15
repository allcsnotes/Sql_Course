# M01-L02 · What a Database Is

> Video: Module 1, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- How a database splits data into **tables**, one table for one kind of thing
- What **columns**, **rows**, **cells** and **data types** are
- What a **primary key** is, and why names cannot be one
- What a **foreign key** is, and how it lets you store each fact once and link it everywhere
- What a **relational database** is, and three beginner mistakes in table design

This is an idea lesson. The video shows its examples on a small demo version of the orders; you will run your own queries on the real Chai Corner database from [Module 3](../../m03-your-first-queries/m03-l01-select-and-from-reading-a-table/).

## Key ideas

### 1. The puzzle

In the last lesson, Priya's phone number was typed again on every one of her orders: more than 24,000 times. When her number changed, one forgotten row gave two different answers. Every order must still show Priya's phone, but we want to type it only once. How?

**Answer:** split the data into separate tables, and link them together.

### 2. One table for one kind of thing

A real café does not keep everything in one book. It has a **customer register** (name and phone), a **menu card** (every item and its price) and an **order book** (each sale). A database works the same way: each book becomes a **table**, and a table holds one kind of thing.

The demo Chai Corner database in the video has four tables: `branches`, `customers`, `menu_items` and `orders`.

### 3. Columns, rows, cells and types

The video opens the `customers` table:

```text
 customer_id | name  |    phone
-------------+-------+-------------
           1 | Asha  | 99230 77810
           2 | Lukas | 98110 30542
           3 | Priya | 98200 11223
           4 | Meera | 98450 60317
           5 | Rahul | 98670 45128
```

- Each **column** is one property of a customer: `customer_id`, `name`, `phone`.
- Each **row** is one customer. Row 1 is Asha, row 3 is Priya.
- Every row has exactly the same columns. Where a row meets a column you get one value, a **cell**.
- Each column has a **data type**. `name` and `phone` hold text; `price` in `menu_items` holds a whole number. That is why the database refused the word `two` in the last lesson: a number column only accepts numbers.

### 4. The primary key

What if a second customer is also called Priya? Names repeat, so a name alone cannot tell two customers apart. Every table has a **primary key**: a column whose value is different for every row, like a roll number in a school.

Here the primary key is `customer_id`. Priya is customer 3; the new Priya is customer 16:

```text
 customer_id | name  |    phone
-------------+-------+-------------
           3 | Priya | 99300 44556
          16 | Priya | 90000 12345
```

The database protects it. Adding another customer with id 3 is refused:

```text
ERROR:  duplicate key value violates unique constraint "customers_pkey"
DETAIL:  Key (customer_id)=(3) already exists.
```

### 5. The foreign key

The `orders` table does not store Priya's name or phone at all. It stores just her customer id, 3:

```text
 order_id | order_date | branch_id | customer_id | item_id | qty
----------+------------+-----------+-------------+---------+-----
   364973 | 2026-11-10 |        10 |           3 |      10 |   1
   364965 | 2026-11-10 |        10 |           3 |       3 |   1
   364959 | 2026-11-10 |         9 |           3 |       9 |   1
```

That number points to row 3 in `customers`. A column like this is a **foreign key**: it links one table to another. In the same way `branch_id` points to `branches` and `item_id` points to `menu_items`.

When you ask for Priya's orders with her phone, the database follows the link and fills in the phone from `customers`:

```text
 order_id | order_date | name  |    phone
----------+------------+-------+-------------
   364973 | 2026-11-10 | Priya | 98200 11223
   364965 | 2026-11-10 | Priya | 98200 11223
   364959 | 2026-11-10 | Priya | 98200 11223
```

Priya gets a new number. It is changed **once, in one row** (`UPDATE 1`). Run the same question again and every one of Priya's **24,276 orders** shows the new number, `99300 44556`. Nothing is missed.

A foreign key protects the link too. An order for customer 99 is refused, because customer 99 does not exist:

```text
ERROR:  insert or update on table "orders" violates foreign key constraint "orders_customer_id_fkey"
DETAIL:  Key (customer_id)=(99) is not present in table "customers".
```

### 6. A relational database

```text
branches   1 ──< many  orders
customers  1 ──< many  orders
menu_items 1 ──< many  orders
```

One branch has many orders, one customer has many orders, one menu item appears in many orders. This is a **relational database**: its tables are related through keys. PostgreSQL, MySQL and SQLite all work this way. In the demo, 10 branches, 15 customers and 10 menu items are each stored just once; only `orders` grows big, with 365,000 small rows.

### 7. Three beginner mistakes

1. **A new table for every month** (`orders_january`, `orders_february`). Keep one `orders` table with a date column.
2. **A list in one cell**, like `masala chai, samosa`. One cell holds one value.
3. **Linking tables by name.** Names change and names repeat. Link with the id, the primary key.

## Try it yourself

1. The video's task: draw the tables for a small library: `books`, `members` and `loans`. Mark the primary keys and the foreign keys.
2. In the Chai Corner demo, which table would you change to give Bun Maska a new price, and how many rows change?
3. Why can `name` not be the primary key of `customers`?

## Answers

1. One possible design:
   ```text
   books   (book_id PK, title, author)
   members (member_id PK, name, phone)
   loans   (loan_id PK, book_id FK -> books, member_id FK -> members, loan_date)
   ```
   One book appears in many loans; one member has many loans.
2. `menu_items`, and only one row (Bun Maska's). Every order links to it by `item_id`, so every order sees the new price.
3. Names repeat (two customers called Priya) and names change. A primary key must be different for every row.

## Next

[M01-L03 · What SQL Is and What Happens When You Run a Query](../m01-l03-what-sql-is-and-what-happens-when-you-run-a-query/)
