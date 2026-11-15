# M08-L06 · Drawing an ER Diagram

> Video: Module 8, Lesson 6. Watch it first, then follow along here.

## What you'll learn

- What an **ER diagram** is: a map of your tables (E for entity, which means a table; R for relationship)
- How to draw one on paper: a box per table, the key on top, a line per foreign key
- How to read the line ends: a single bar means one, a **crow's foot** means many
- How DBeaver draws the real diagram from your keys
- How to follow a path across four tables to answer a question

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). You need update 4 from [M08-L03](../m08-l03-foreign-keys-linking-tables-together/): the database then has six tables.
- DBeaver connected to `chai_corner`. Paper and a pen for steps 1 and 2.
- Most of this lesson happens in DBeaver. `check_links.sql` is an extra SQL check, not shown in the video.

## Files in this folder

| File | What it is |
|---|---|
| `check_links.sql` | Extra: list the tables and the foreign keys in SQL, to check the diagram |

## Follow along

### 1. On paper: a box for each table

Each table becomes a box. The table name goes on top, the columns go inside, one per line. Then mark the primary key, so anyone can see which column is the ID: here `branch_id` and `order_id`.

```text
+----------------+        +------------------+
| branches       |        | orders           |
+----------------+        +------------------+
| * branch_id    |        | * order_id       |
|   city         |        |   customer_id    |
|   opened_on    |        |   branch_id      |
+----------------+        |   ordered_at     |
                          +------------------+
```

On paper, names are enough. Types and data can wait.

### 2. On paper: lines for links

Draw a line for every foreign key. `orders` has a `branch_id`, so a line joins `orders` to `branches`. The ends of the line show the kind of link: a single bar means **one**, a crow's foot (like three little toes) means **many**.

```text
branches  -|---------<  orders
  (one)                 (many)
```

This reads: one branch, many orders. The crow's foot always sits on the side with the foreign key.

### 3. In DBeaver: open the schema

1. In the Connections panel, open your connection (`postgres`) > Databases > `chai_corner` > Schemas.
2. Double-click the schema called `public`. An editor tab named `public` opens on its **Properties** tab.
3. DBeaver lists our six tables: `branches`, `customers`, `menu_items`, `order_items`, `orders`, `sales`.

### 4. In DBeaver: the Diagram tab

1. Click the **Diagram** tab next to Properties. DBeaver draws the map for you, from the real keys.
2. If a table is cut off at the bottom, zoom out (the video uses 90%, in the zoom box at the bottom).

You should see six boxes. `orders` links to `branches` and `customers`. `order_items` links to `orders` and `menu_items`. Each dot at the end of a line marks the side with the foreign key. Key columns are shown in bold at the top of each box.

### 5. Reading the map

Which items did Kabir buy? Follow the lines:

```text
customers  ->  orders  ->  order_items  ->  menu_items
(Kabir)        (his orders)  (the items)     (each item's name)
```

Four tables, one path. In Module 9, joins walk this path for you.

### 6. Extra: check the diagram in SQL

```sql
SELECT conrelid::regclass AS from_table,
       confrelid::regclass AS points_to
FROM pg_constraint
WHERE contype = 'f'
ORDER BY 1, 2;
```

You should see the four lines of the diagram:

| from_table | points_to |
|---|---|
| orders | branches |
| orders | customers |
| order_items | menu_items |
| order_items | orders |

## Common mistakes

- Drawing a line for something that is not a foreign key. Lines come from real keys only.
- Putting the crow's foot on the wrong end. It sits on the table that holds the foreign key (the many side).
- Expecting the diagram to update by itself after you add a table. Click Refresh at the bottom of the Diagram tab.

## Try it yourself

1. Open the diagram. Which table has no lines at all, and why? Guess first, then check.
2. On paper, draw the path from a branch to the menu items it sold.
3. Which tables would you visit to find the city where order 1 was made?

## Next

[M09-L01 · INNER JOIN: Pairing Matching Rows](../../m09-joins/m09-l01-inner-join-pairing-matching-rows/)

## Answers

1. `sales`. It has no foreign keys: it is the old copied report table from Build 1, with names and prices typed in instead of IDs, so nothing links it to the other tables.
2. `branches` -> `orders` (by `branch_id`) -> `order_items` (by `order_id`) -> `menu_items` (by `item_id`).
3. `orders` (its `branch_id`) and then `branches` (the city).
