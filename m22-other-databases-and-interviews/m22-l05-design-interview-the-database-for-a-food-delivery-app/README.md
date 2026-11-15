# M22-L05 · Design Interview: the Database for a Food Delivery App

> Video: Module 22, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- How to answer a database design interview one step at a time: there is no single right answer, the interviewer watches how you think
- Step 1: find the nouns in one sentence, and make each noun a table (plus `order_items` for many dishes per order)
- Step 2: the simple tables, each with an ID primary key, in their own schema
- Step 3: `orders` links everything with four foreign keys, a `CHECK` on the status, and `order_items` with a two-column primary key and the price at the time of the order
- Step 4: test the design with real queries: a receipt, a bill, a broken rule, and a price change

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- **Run `setup.sql`.** It is DB update 18: it creates a separate **schema** (a named folder of tables inside the database) called `delivery`, with the 7 tables and the sample data. The Chai Corner tables are not touched. It drops and rebuilds `delivery`, so it is safe to run more than once.

## Files in this folder

| File | What it is |
|---|---|
| `setup.sql` | DB update 18: `CREATE SCHEMA delivery`, the 7 tables (steps 2 and 3) and the sample data |
| `food_delivery_design.sql` | The test queries from the video in order (step 4 on), with the real result as a comment |

## Follow along

### 1. Find the nouns

Say the app in one sentence: *a customer orders food from a restaurant, and a rider brings it to an address.* Each noun becomes a table: `customers`, `restaurants`, `menu_items`, `riders`, `addresses` and `orders`. One more: an order can have many dishes, so the dishes of each order get their own table, `order_items`.

```text
customers ──< addresses
customers ──< orders >── restaurants ──< menu_items
riders    ──< orders >── addresses
orders    ──< order_items >── menu_items
```

(`──<` means "one to many": one customer has many orders.)

### 2. The simple tables

`CREATE SCHEMA delivery` gives the app its own space, away from the Chai Corner tables, and `SET search_path TO delivery` makes the next statements use it. Every table gets an `id` primary key. Customers, restaurants and riders stand on their own. Addresses point to a customer, because one customer can have a home and an office, and menu items point to their restaurant:

```sql
CREATE TABLE customers (id int PRIMARY KEY, name text NOT NULL, phone text UNIQUE);
CREATE TABLE addresses (id int PRIMARY KEY, customer_id int REFERENCES customers,
  line text NOT NULL, city text NOT NULL);
CREATE TABLE restaurants (id int PRIMARY KEY, name text NOT NULL, city text NOT NULL);
CREATE TABLE menu_items (id int PRIMARY KEY, restaurant_id int REFERENCES restaurants,
  name text NOT NULL, price int CHECK (price > 0));
CREATE TABLE riders (id int PRIMARY KEY, name text NOT NULL, phone text UNIQUE);
```

### 3. The orders table links everything

```sql
CREATE TABLE orders (id int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES customers,
  restaurant_id int NOT NULL REFERENCES restaurants,
  address_id int NOT NULL REFERENCES addresses,
  rider_id int REFERENCES riders,
  status text NOT NULL CHECK (status IN ('placed','cooking','on_the_way','delivered','cancelled')),
  placed_at timestamp NOT NULL);
CREATE TABLE order_items (order_id int REFERENCES orders, menu_item_id int REFERENCES menu_items,
  qty int NOT NULL CHECK (qty > 0), price_at_order int NOT NULL,
  PRIMARY KEY (order_id, menu_item_id));
```

- Each order stores four foreign keys: the customer, the restaurant, the address and the rider.
- `rider_id` can be empty (no `NOT NULL`), because no rider is picked when the order is placed.
- A `CHECK` rule allows only five statuses: placed, cooking, on the way, delivered or cancelled.
- `order_items` has a primary key made of two columns, the order and the dish, and saves `price_at_order`, the price at the moment of the order.

### 4. A little sample data

`setup.sql` adds two customers (Asha, Rahul), two restaurants (Spice Box in Pune, Dosa Hut in Kolkata), four dishes (Paneer Roll ₹120, Veg Biryani ₹180, Masala Dosa ₹90, Filter Coffee ₹40), one rider and two orders:

| order | customer | restaurant | status | dishes |
|---|---|---|---|---|
| 101 | Rahul | Spice Box | delivered | 2 Paneer Roll, 1 Veg Biryani |
| 102 | Asha | Dosa Hut | on_the_way | 2 Masala Dosa, 2 Filter Coffee |

Now switch to the schema for the test queries:

```sql
SET search_path TO delivery;
```

### 5. The receipt for order 101

Four joins walk from the order to the customer, the restaurant and each dish:

```sql
SELECT c.name AS customer, r.name AS restaurant, m.name AS item,
  oi.qty, oi.price_at_order, oi.qty * oi.price_at_order AS line_total
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN restaurants r ON r.id = o.restaurant_id
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_items m ON m.id = oi.menu_item_id
WHERE o.id = 101;
```

You should see:

| customer | restaurant | item | qty | price_at_order | line_total |
|---|---|---|---|---|---|
| Rahul | Spice Box | Paneer Roll | 2 | 120 | 240 |
| Rahul | Spice Box | Veg Biryani | 1 | 180 | 180 |

### 6. The bill for every order

Multiply the quantity by the price, and `SUM` it for each order:

```sql
SELECT o.id AS order_id, o.status, SUM(oi.qty * oi.price_at_order) AS total
FROM orders o JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, o.status ORDER BY o.id;
```

You should see:

| order_id | status | total |
|---|---|---|
| 101 | delivered | 420 |
| 102 | on_the_way | 260 |

### 7. The rules protect the data

Try a status called `lost`:

```sql
UPDATE orders SET status = 'lost' WHERE id = 102;
```

You should see:

```text
ERROR: new row for relation "orders" violates check constraint "orders_status_check"
DETAIL: Failing row contains (102, 1, 2, 1, 1, lost, 2026-03-10 19:40:00).
```

PostgreSQL refuses (error code 23514): the check fails.

### 8. Why save the price inside each order?

The Paneer Roll goes up to ₹150:

```sql
UPDATE menu_items SET price = 150 WHERE id = 1;
SELECT m.name AS item, m.price AS price_now, oi.price_at_order
FROM order_items oi JOIN menu_items m ON m.id = oi.menu_item_id
WHERE oi.order_id = 101;
```

You should see:

| item | price_now | price_at_order |
|---|---|---|
| Veg Biryani | 180 | 180 |
| Paneer Roll | 150 | 120 |

The menu shows the new price, but the bill for order 101 still says ₹120. Past bills never change.

In the interview, say these choices out loud, and ask questions: do we need payments, or ratings? Then add a table for each.

When you finish, go back to the Chai Corner tables with `SET search_path TO public;`.

## Common mistakes

- Jumping straight to `CREATE TABLE` without first saying the app in one sentence and listing the nouns.
- Putting the dishes as columns of `orders` (`item1`, `item2`): use an `order_items` table.
- Reading the price from `menu_items` for old bills: a price change rewrites history. Save `price_at_order`.
- Making `rider_id` `NOT NULL`: the order is placed before a rider is picked.
- Forgetting `SET search_path TO delivery;` and getting the Chai Corner `customers` or `menu_items` instead.
- Staying silent in the interview: explain each choice and ask about payments and ratings.

## Try it yourself

1. Find the money each restaurant earned.
2. How many dishes (sum of `qty`) did Asha order in total?
3. Add a `ratings` table: one rating from 1 to 5 per order.

## Answers

1. You should see Spice Box 420, Dosa Hut 260:

```sql
SELECT r.name AS restaurant, SUM(oi.qty * oi.price_at_order) AS revenue
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY r.name ORDER BY revenue DESC;
```

2. 4 (2 Masala Dosa and 2 Filter Coffee in order 102): `SELECT SUM(oi.qty) FROM orders o JOIN order_items oi ON oi.order_id = o.id JOIN customers c ON c.id = o.customer_id WHERE c.name = 'Asha';`
3. One possible answer: `CREATE TABLE ratings (order_id int PRIMARY KEY REFERENCES orders, stars int NOT NULL CHECK (stars BETWEEN 1 AND 5), comment text);` The primary key on `order_id` allows only one rating per order.

## Next

[M22-L06 · The Top 50 SQL Interview Questions, Answered](../m22-l06-the-top-50-sql-interview-questions-answered/)
