# M09-L04 · Joining Three or More Tables

> Video: Module 9, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- How to chain joins: each `JOIN` adds one table, each `ON` follows one foreign key
- Three tables: every order with a customer name and a city
- Five tables: Rohan's full bill with `SUM(qty * price)`
- A real report: who spends the most at Chai Corner
- Three traps: a table you never joined, counting rows after a join, and the wrong road

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 (`orders`, `order_items`) from [M08-L03](../../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/).
- DBeaver connected to `chai_corner`. These queries are 5 to 9 lines long: drag the divider between the editor and the results down a little so you can see them whole. This lesson only reads data.

## Files in this folder

| File | What it is |
|---|---|
| `three_or_more.sql` | Every query of the video, in order, with the result as a comment |

## Follow along

### 1. Following the links

Order 2's receipt needs a name, a city, item names and prices: four different tables. Every foreign key is a road you can follow:

```text
customers <- orders -> branches
               ^
          order_items -> menu_items
```

`orders` sits in the middle: it points to `customers` and to `branches`. `order_items` points to `orders` and to `menu_items`. Each `JOIN` adds one table; each `ON` follows one road. (`JOIN` on its own means `INNER JOIN`.)

### 2. Three tables

Start from `orders`. Join `customers` on the customer ID, then `branches` on the branch ID:

```sql
SELECT orders.order_id, customers.name, branches.city
FROM orders
JOIN customers ON customers.customer_id = orders.customer_id
JOIN branches  ON branches.branch_id = orders.branch_id
ORDER BY orders.order_id
LIMIT 5;
```

You should see:

| order_id | name | city |
|---|---|---|
| 1 | Kabir | Mumbai |
| 2 | Rohan | Pune |
| 3 | Ananya | Pune |
| 4 | Arjun | Pune |
| 5 | Vikram | Delhi |

### 3. The full bill

Add `order_items` and `menu_items`. Order 2 becomes three rows, each with its price:

```sql
SELECT customers.name, menu_items.name AS item,
       order_items.qty, menu_items.price
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
WHERE orders.order_id = 2;
```

| name | item | qty | price |
|---|---|---|---|
| Rohan | Cutting Chai | 1 | 20 |
| Rohan | Masala Chai | 2 | 30 |
| Rohan | Samosa | 1 | 25 |

Now multiply quantity by price and sum it. Five tables in one query:

```sql
SELECT customers.name, branches.city,
       SUM(order_items.qty * menu_items.price) AS bill
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN branches    ON branches.branch_id = orders.branch_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
WHERE orders.order_id = 2
GROUP BY customers.name, branches.city;
```

| name | city | bill |
|---|---|---|
| Rohan | Pune | 105 |

Rohan's bill: 1 × 20 + 2 × 30 + 1 × 25 = ₹105.

### 4. A real report: who spends the most?

Group by customer, count the orders, and sum the money:

```sql
SELECT customers.name, COUNT(DISTINCT orders.order_id) AS orders,
       SUM(order_items.qty * menu_items.price) AS spent
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN order_items ON order_items.order_id = orders.order_id
JOIN menu_items  ON menu_items.item_id = order_items.item_id
GROUP BY customers.name
ORDER BY spent DESC
LIMIT 5;
```

You should see:

| name | orders | spent |
|---|---|---|
| Tara | 218 | 19940 |
| Kiran | 198 | 19585 |
| Isha | 204 | 19530 |
| Neha | 200 | 19305 |
| Lukas | 205 | 19055 |

Tara leads with ₹19,940.

## Common mistakes

**1. Using a table you never joined.** Here `menu_items` is missing:

```sql
SELECT customers.name, menu_items.name AS item
FROM orders
JOIN customers   ON customers.customer_id = orders.customer_id
JOIN order_items ON order_items.order_id = orders.order_id
WHERE orders.order_id = 2;
```

```text
SQL Error [42P01]: ERROR: missing FROM-clause entry for table "menu_items"
  Position: 24
```

Add its join.

**2. Counting rows after a join.** Each item line is a row:

```sql
SELECT COUNT(*) AS joined_rows,
       COUNT(DISTINCT orders.order_id) AS real_orders
FROM orders
JOIN order_items ON order_items.order_id = orders.order_id;
```

| joined_rows | real_orders |
|---|---|
| 5530 | 3000 |

You get 5,530, not 3,000 orders. Use `COUNT(DISTINCT ...)`, as in the report above.

**3. Following the wrong road,** like `ON menu_items.item_id = order_items.order_id`. It runs, but the numbers are nonsense. Match each foreign key to its own primary key.

## Try it yourself

1. What were Mumbai's total sales? Join four tables and sum quantity times price. Guess first, then run it.
2. Show the total sales of all three branches in one query.
3. Which menu item earned the most money?

## Next

[M09-L05 · Self Join: a Table Joined to Itself](../m09-l05-self-join-a-table-joined-to-itself/)

## Answers

1. ₹87,545:
   ```sql
   SELECT SUM(order_items.qty * menu_items.price) AS mumbai_sales
   FROM orders
   JOIN branches    ON branches.branch_id = orders.branch_id
   JOIN order_items ON order_items.order_id = orders.order_id
   JOIN menu_items  ON menu_items.item_id = order_items.item_id
   WHERE branches.city = 'Mumbai';
   ```
2. Replace the `WHERE` with `GROUP BY branches.city` and select `branches.city` too: Pune 138705, Mumbai 87545, Delhi 45015.
3. Masala Chai, ₹41,460 (then Cold Coffee 40,240):
   ```sql
   SELECT menu_items.name, SUM(order_items.qty * menu_items.price) AS earned
   FROM order_items
   JOIN menu_items ON menu_items.item_id = order_items.item_id
   GROUP BY menu_items.name
   ORDER BY earned DESC
   LIMIT 3;
   ```
