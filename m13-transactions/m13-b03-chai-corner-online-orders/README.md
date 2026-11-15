# M13-B03 · Chai Corner Online Orders

> Video: Module 13, Build 3. Watch it first, then follow along here.

## What you'll build

Chai Corner wants to take orders online, and you build that from zero in four stages:

1. **Design** the tables: customers, orders, and the items inside each order.
2. **Create** them with rules that protect the data (`NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`, foreign keys).
3. **Load** some data: three online customers.
4. **Place** a real order inside a transaction, and watch a bad order roll back completely.

It brings together Module 11 (creating tables and rules), Module 12 (changing data) and Module 13 (transactions).

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `menu_items` (12 items). The build only reads it.
- DBeaver connected to `chai_corner`, or `psql`.

## Files in this folder

| File | What it is |
|---|---|
| `online_orders.sql` | The whole build in order: menu, three `CREATE TABLE`s, customers, order 1, the failed order 2, the three mistakes, with real results as comments |
| `setup.sql` | The three tables with their rows after the build and its task. Run it only if you skipped the build |

## Build it step by step

### Stage 1 · Design

Before typing any SQL, decide which tables you need.

```text
online_customers 1 ---- many online_orders 1 ---- many online_order_items many ---- 1 menu_items
   (customer_id)            (order_id)                (order_id, item_id)              (item_id)
```

- A customer can place many orders, so customers and orders are two tables, linked by `customer_id`.
- One order can have many items, so every item in an order gets its own row in a third table, `online_order_items`.
- Each of those rows points to the `menu_items` table you already have, so the price list lives in one place.
- Three new tables, and every link is a foreign key.

First look at the menu:

```sql
SELECT item_id, name, price
FROM menu_items
ORDER BY item_id;
```

You should see 12 rows. The ones this build uses:

| item_id | name | price |
|---|---|---|
| 2 | Cold Coffee | 80 |
| 6 | Maggi | 60 |
| 7 | Masala Chai | 30 |
| 8 | Samosa | 25 |

### Stage 2 · Create the tables, with rules

```sql
CREATE TABLE online_customers (
  customer_id int PRIMARY KEY,
  name        varchar(40) NOT NULL,
  phone       varchar(15) NOT NULL UNIQUE,
  joined_on   date NOT NULL DEFAULT CURRENT_DATE
);
```

The name can never be empty, and the phone must be unique: one phone means one person. `joined_on` defaults to today's date.

```sql
CREATE TABLE online_orders (
  order_id    int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES online_customers (customer_id),
  status      varchar(20) NOT NULL DEFAULT 'placed'
              CHECK (status IN ('placed', 'preparing', 'delivered', 'cancelled')),
  placed_at   timestamp NOT NULL DEFAULT now(),
  total       numeric(8,2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);
```

The customer must be real. The status must be one of four words, and every new order starts as `placed`. The total starts at 0 and can never go below 0.

```sql
CREATE TABLE online_order_items (
  order_id int REFERENCES online_orders (order_id) ON DELETE CASCADE,
  item_id  int REFERENCES menu_items (item_id),
  qty      int NOT NULL CHECK (qty > 0),
  price    numeric(6,2) NOT NULL CHECK (price >= 0),
  PRIMARY KEY (order_id, item_id)
);
```

The quantity must be more than 0. `ON DELETE CASCADE`: delete an order, and its items go with it. The primary key is two columns together: one row per item per order.

Each statement shows `Updated Rows 0`. That is normal: `CREATE TABLE` makes a table, not rows.

### Stage 3 · Load some data

Give only the ID, the name and the phone:

```sql
INSERT INTO online_customers (customer_id, name, phone)
VALUES (1, 'Meera', '90000 11111'),
       (2, 'Arjun', '90000 22222'),
       (3, 'Sana',  '90000 33333');
```

You should see: `Updated Rows 3`.

```sql
SELECT * FROM online_customers;
```

| customer_id | name | phone | joined_on |
|---|---|---|---|
| 1 | Meera | 90000 11111 | 2026-11-14 |
| 2 | Arjun | 90000 22222 | 2026-11-14 |
| 3 | Sana | 90000 33333 | 2026-11-14 |

`joined_on` was filled in by the default: your own run shows the day you run it.

### Stage 4 · The first order, in a transaction

Meera, the owner, tests it herself: two Masala Chai and one Samosa. It touches two tables, so wrap it in a transaction.

```sql
BEGIN;
INSERT INTO online_orders (order_id, customer_id) VALUES (1, 1);
INSERT INTO online_order_items (order_id, item_id, qty, price)
VALUES (1, 7, 2, 30), (1, 8, 1, 25);
UPDATE online_orders
SET total = (SELECT SUM(qty * price) FROM online_order_items WHERE order_id = 1)
WHERE order_id = 1;
COMMIT;
```

1. The order row: order 1 for customer 1. The status and the time come from the defaults (1 row).
2. The two item rows (`Updated Rows 2`).
3. The total: the sum of quantity × price for the items of order 1 (1 row).
4. `COMMIT` saves everything together.

The receipt joins all four tables:

```sql
SELECT o.order_id, c.name AS customer, m.name AS item,
       i.qty, i.price, o.total, o.status
FROM online_orders o
JOIN online_customers c   ON c.customer_id = o.customer_id
JOIN online_order_items i ON i.order_id = o.order_id
JOIN menu_items m         ON m.item_id = i.item_id
WHERE o.order_id = 1;
```

| order_id | customer | item | qty | price | total | status |
|---|---|---|---|---|---|---|
| 1 | Meera | Masala Chai | 2 | 30.00 | 85.00 | placed |
| 1 | Meera | Samosa | 1 | 25.00 | 85.00 | placed |

2 × 30 + 1 × 25 = ₹85.

### Stage 5 · When something goes wrong in the middle

Arjun orders, but one item has a quantity of 0 by mistake:

```sql
BEGIN;
INSERT INTO online_orders (order_id, customer_id) VALUES (2, 2);
INSERT INTO online_order_items (order_id, item_id, qty, price)
VALUES (2, 2, 1, 80), (2, 6, 0, 60);
```

The order row goes in, then:

```text
ERROR: new row for relation "online_order_items" violates check constraint "online_order_items_qty_check"   (SQLSTATE 23514)
  Detail: Failing row contains (2, 6, 0, 60.00).
```

Roll back. The order row you already added is undone too:

```sql
ROLLBACK;
SELECT order_id, customer_id, total FROM online_orders;
```

| order_id | customer_id | total |
|---|---|---|
| 1 | 1 | 85.00 |

Only order 1 is there. No half order is left behind.

## Check your work

Place order 2 for Arjun, the right way: one Cold Coffee and one Maggi. What is the total? (The video's task. Try it before you read on.)

```sql
BEGIN;
INSERT INTO online_orders (order_id, customer_id) VALUES (2, 2);
INSERT INTO online_order_items (order_id, item_id, qty, price)
VALUES (2, 2, 1, 80), (2, 6, 1, 60);
UPDATE online_orders
SET total = (SELECT SUM(qty * price) FROM online_order_items WHERE order_id = 2)
WHERE order_id = 2;
COMMIT;
```

Run as one script in DBeaver: `Queries 5`, `Updated Rows 4`. Then:

```sql
SELECT o.order_id, c.name AS customer, o.total, o.status
FROM online_orders o
JOIN online_customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;
```

| order_id | customer | total | status |
|---|---|---|---|
| 1 | Meera | 85.00 | placed |
| 2 | Arjun | 140.00 | placed |

The total is **₹140** (80 + 60). Your database now holds 3 online customers, 2 online orders and 4 order items.

## Common mistakes

The rules you put inside the tables catch all three. Each was run for real in the video.

1. **A status that is not in the list.**

   ```sql
   UPDATE online_orders SET status = 'done' WHERE order_id = 1;
   ```

   ```text
   ERROR: new row for relation "online_orders" violates check constraint "online_orders_status_check"   (SQLSTATE 23514)
   ```

   Use one of the four allowed words.

2. **A new customer with a phone that is already used.**

   ```sql
   INSERT INTO online_customers (customer_id, name, phone)
   VALUES (4, 'Tanvi', '90000 11111');
   ```

   ```text
   ERROR: duplicate key value violates unique constraint "online_customers_phone_key"   (SQLSTATE 23505)
     Detail: Key (phone)=(90000 11111) already exists.
   ```

3. **Deleting a customer who has placed an order.**

   ```sql
   DELETE FROM online_customers WHERE customer_id = 1;
   ```

   ```text
   ERROR: update or delete on table "online_customers" violates foreign key constraint "online_orders_customer_id_fkey" on table "online_orders"   (SQLSTATE 23503)
   ```

   Remove that order first, or simply keep the customer.

Also remember: an order that touches several tables belongs in one transaction. Without `BEGIN`, the failed order 2 would have left an order row with no items.

## Next

[M14-L01 · WITH: Naming a Step of Your Query](../../m14-ctes/m14-l01-with-naming-a-step-of-your-query/)
