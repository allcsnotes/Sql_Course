# M20-L02 · What an ORM Is, and When Raw SQL Is Better

> Video: Module 20, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- What an **ORM** (object relational mapper) is: a table becomes a Python class, a row becomes an object
- Describing `menu_items` once as a SQLAlchemy class and asking for rows in Python
- Seeing the SQL the ORM writes for you, with a safe placeholder
- The **N+1 problem** (one query for the list, then one more for each row) and the one-line fix, `selectinload`
- When plain SQL is the better choice: reports, window functions and tuning, run with `text()`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). This lesson only reads `menu_items`, `orders` and `order_items`.
- The virtual environment from [M20-L01](../m20-l01-connecting-from-python-psycopg-and-running-safe-queries/) (or make a new one here with `python3 -m venv .venv`), and the password you chose when installing PostgreSQL.
- On Windows use `.venv\Scripts\python` instead of `.venv/bin/python`.

## Files in this folder

| File | What it is |
|------|------------|
| `orm_demo.py` | The script the video runs: the three classes, the ORM query, N+1, the `selectinload` fix and a raw SQL report |
| `requirements.txt` | The pinned versions from the video: `psycopg[binary]==3.3.9`, `SQLAlchemy==2.1.8` |

## Follow along

### 1. The picture

An ORM maps a table to a Python class. The `menu_items` table becomes a class called `MenuItem`, each column becomes an attribute (`item_id`, `name`, `price`), and each row comes back as an object. You write `item.name`, not `row[0]`.

### 2. Install SQLAlchemy and describe the table once

SQLAlchemy is the most used ORM in Python.

```bash
.venv/bin/python -m pip install sqlalchemy
```

You should see:

```text
Successfully installed sqlalchemy-2.1.8 typing-extensions-4.16.0
```

(Or `.venv/bin/python -m pip install -r requirements.txt` for the exact versions.)

The class in `orm_demo.py`:

```python
class MenuItem(Base):
    __tablename__ = "menu_items"
    item_id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]
    price: Mapped[int]
```

`orm_demo.py` also describes `Order` and `OrderItem` (with `items` as a relationship), asks for the password with `getpass`, and prints every SQL statement it sends (an event listener called `show_sql`), so slow queries cannot hide.

### 3. Ask in Python: items under 40, cheapest first

```python
stmt = select(MenuItem).where(MenuItem.price < 40).order_by(MenuItem.price)
for item in session.scalars(stmt):
    print(item.name, item.price)
```

Run it:

```bash
.venv/bin/python orm_demo.py
```

You should see (first part):

```text
--- 1. ORM: items under 40, cheapest first ---
   SQL > SELECT menu_items.item_id, menu_items.name, menu_items.price FROM menu_items WHERE menu_items.price < %(price_1)s::INTEGER ORDER BY menu_items.price {'price_1': 40}
Cutting Chai 20
Samosa 25
Ginger Chai 30
Vada Pav 30
Masala Chai 30
Bun Maska 35
```

SQLAlchemy wrote the SQL itself. The value 40 goes in on its own, through a placeholder, safely. Six items come back, cheapest first. (Items with the same price can come back in a different order on your computer.)

### 4. The N+1 problem

Load five orders, then in a loop print how many items each order has:

```python
orders = session.scalars(select(Order).order_by(Order.order_id).limit(5)).all()
for o in orders:
    print("order", o.order_id, "->", len(o.items), "item(s)")
print("queries sent:", len(sent))
```

You should see:

```text
--- 2. N+1: 5 orders, then each order's items ---
   SQL > SELECT orders.order_id, orders.branch_id FROM orders ORDER BY orders.order_id LIMIT %(param_1)s::INTEGER {'param_1': 5}
   SQL > SELECT order_items.order_id, order_items.item_id, order_items.qty FROM order_items WHERE %(param_1)s::INTEGER = order_items.order_id {'param_1': 1}
order 1 -> 1 item(s)
   SQL > ... WHERE %(param_1)s::INTEGER = order_items.order_id {'param_1': 2}
order 2 -> 3 item(s)
   SQL > ... {'param_1': 3}
order 3 -> 2 item(s)
   SQL > ... {'param_1': 4}
order 4 -> 1 item(s)
   SQL > ... {'param_1': 5}
order 5 -> 2 item(s)
queries sent: 6
```

Each time the loop touches `o.items`, the ORM quietly sends one more query: one for the orders, then one for each order. Six queries for five orders. With 500 orders it would be 501.

### 5. The fix: selectinload

```python
orders = session.scalars(select(Order).order_by(Order.order_id).limit(5)
                         .options(selectinload(Order.items))).all()
for o in orders:
    print("order", o.order_id, "->", len(o.items), "item(s)")
```

You should see:

```text
--- 3. fix: selectinload ---
   SQL > SELECT orders.order_id, orders.branch_id FROM orders ORDER BY orders.order_id LIMIT %(param_1)s::INTEGER {'param_1': 5}
   SQL > SELECT order_items.order_id, order_items.item_id, order_items.qty FROM order_items WHERE order_items.order_id IN (%(primary_keys_1)s::INTEGER, ... %(primary_keys_5)s::INTEGER) {'primary_keys_1': 1, ... 'primary_keys_5': 5}
order 1 -> 1 item(s)
order 2 -> 3 item(s)
order 3 -> 2 item(s)
order 4 -> 1 item(s)
order 5 -> 2 item(s)
queries sent: 2
```

The second query asks for all five order ids at once. The same answers, in just two queries.

### 6. A report in plain SQL

The top three items by quantity sold, with a rank, needs `SUM`, `GROUP BY` and a window function. Write it as plain SQL, wrap it in `text()`, and the ORM simply runs it:

```python
rows = session.execute(text("""
    SELECT m.name, SUM(oi.qty) AS cups,
           RANK() OVER (ORDER BY SUM(oi.qty) DESC) AS rnk
    FROM order_items oi JOIN menu_items m ON m.item_id = oi.item_id
    GROUP BY m.name
    ORDER BY rnk
    LIMIT 3"""))
for r in rows:
    print(r.rnk, r.name, r.cups)
```

You should see:

```text
1 Masala Chai 1704
2 Cutting Chai 1592
3 Vada Pav 1045
```

Use the ORM for everyday reads and saves. Use plain SQL for reports, window functions and tuning.

## Common mistakes

- **Never looking at the SQL.** Print the queries while you build (like `show_sql` here, or `echo=True` on the engine), so slow ones cannot hide.
- **Touching related data inside a loop.** That is N+1. Load it up front with `selectinload`.
- **Thinking the ORM means you do not need SQL.** When something is slow or wrong, you will read the SQL it wrote.

## Try it yourself

1. (The video's task.) Load 20 orders with `selectinload`, then read every order's items. How many queries?
2. Change the ORM query in step 3 to items under 40 with the dearest first.
3. Change the report in step 6 to the top 5 items.

## Answers

1. Two: one for the orders, and one for all their items (`WHERE order_items.order_id IN (...)` with 20 ids). Without `selectinload` it would be 21.
2. `.order_by(MenuItem.price.desc())`: Bun Maska 35 first, Cutting Chai 20 last.
3. Change `LIMIT 3` to `LIMIT 5` inside the `text()` string. The new rows are `4 Bun Maska 1008` and `5 Samosa 922`.

## Next

[M20-L03 · Migrations: Changing a Live Database Safely](../m20-l03-migrations-changing-a-live-database-safely/)
