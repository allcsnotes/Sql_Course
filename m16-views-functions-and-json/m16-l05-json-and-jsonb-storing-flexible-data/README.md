# M16-L05 · JSON and JSONB: Storing Flexible Data

> Video: Module 16, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- What **JSON** is: text made of keys and values, where each row can have different keys
- Why PostgreSQL's **JSONB** (a smart binary form) is the one to use
- How to store JSON in a `jsonb` column and read it back
- How to pull a value out with `->>`, cast it for maths, and search with `@>` (contains)
- Three mistakes: one arrow with maths, keys without quotes, and the wrong key case

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson **creates a table**, `app_orders`, with 3 orders. `setup.sql` builds the same table.

## Files in this folder

| File | What it is |
|---|---|
| `json_jsonb.sql` | Every statement from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | What this lesson leaves in the database: the `app_orders` table with its 3 rows. Safe to run again |

## Follow along

Some data does not fit neat columns. One order has extras, another has none. Keep each order as a little bundle of keys and values, all in one column.

```text
{"item": "Masala Chai", "qty": 2, "extras": ["ginger"]}
  item -> Masala Chai,  qty -> 2,  extras -> a list: ginger
```

A normal row needs the same columns every time; a JSON column can hold different keys in each row. JSONB saves it in a binary form that is faster to search, so use JSONB.

### 1. Create the table and insert three orders

```sql
CREATE TABLE app_orders (
  order_no int,
  details jsonb
);

INSERT INTO app_orders VALUES
(1, '{"item": "Masala Chai", "qty": 2, "extras": ["ginger"]}'),
(2, '{"item": "Cold Coffee", "qty": 1}'),
(3, '{"item": "Samosa", "qty": 3, "extras": ["chutney", "onion"]}');
```

Each JSON value sits inside single quotes, and every key has double quotes.

### 2. Look at them

```sql
SELECT order_no, details
FROM app_orders;
```

You should see:

| order_no | details |
|---|---|
| 1 | `{"qty": 2, "item": "Masala Chai", "extras": ["ginger"]}` |
| 2 | `{"qty": 1, "item": "Cold Coffee"}` |
| 3 | `{"qty": 3, "item": "Samosa", "extras": ["chutney", "onion"]}` |

Notice JSONB moved `qty` to the front. It sorts the keys its own way.

### 3. Get a value out

The double arrow `->>` pulls a key out as text: `details ->> 'item'` gives the item name. The quantity comes out as text too, so add `::int` to turn it into a number.

```sql
SELECT order_no,
  details ->> 'item' AS item,
  (details ->> 'qty')::int AS qty
FROM app_orders;
```

| order_no | item | qty |
|---|---|---|
| 1 | Masala Chai | 2 |
| 2 | Cold Coffee | 1 |
| 3 | Samosa | 3 |

Now it looks like normal columns.

### 4. Search inside: contains

`@>` means **contains**. Find the orders whose details contain item Samosa:

```sql
SELECT order_no, details ->> 'item' AS item
FROM app_orders
WHERE details @> '{"item": "Samosa"}';
```

You should see one row: `3 | Samosa`.

### 5. JSON next to JSONB

```sql
SELECT
  '{"qty": 2, "item": "Tea", "qty": 5}'::json  AS as_json,
  '{"qty": 2, "item": "Tea", "qty": 5}'::jsonb AS as_jsonb;
```

| as_json | as_jsonb |
|---|---|
| `{"qty": 2, "item": "Tea", "qty": 5}` | `{"qty": 5, "item": "Tea"}` |

JSON keeps the text exactly, even a repeated key. JSONB keeps only the last `qty`, 5.

## Common mistakes

All three were run for real in the video.

1. **One arrow, then maths.** One arrow `->` gives JSON, not a number:

   ```sql
   SELECT (details -> 'qty') + 1 AS one_more FROM app_orders;
   ```

   ```text
   ERROR: operator does not exist: jsonb + integer   (SQLSTATE 42883)
   ```

   Fix: two arrows, then cast: `(details ->> 'qty')::int + 1`.

2. **Keys without double quotes.**

   ```sql
   INSERT INTO app_orders VALUES (4, '{item: "Vada Pav", qty: 2}');
   ```

   ```text
   ERROR: invalid input syntax for type json   (SQLSTATE 22P02)
   DETAIL: Token "item" is invalid.
   ```

   Fix: in JSON, every key needs double quotes: `'{"item": "Vada Pav", ...}'`.

3. **The wrong key case.**

   ```sql
   SELECT order_no, details ->> 'Item' AS item
   FROM app_orders;
   ```

   No error, but every row comes back NULL: capital `Item` does not exist. Keys must match exactly (`'item'`).

## Try it yourself

1. Add up the quantity across all three orders. (The video's task.)
2. Find the orders that have an `extras` key (hint: `details ? 'extras'`).
3. Show each order's first extra with `details -> 'extras' ->> 0`.

## Answers

1. ```sql
   SELECT SUM((details ->> 'qty')::int) AS total_qty FROM app_orders;
   ```

   `total_qty` = 6.

2. `SELECT order_no FROM app_orders WHERE details ? 'extras';` gives orders 1 and 3.

3. Order 1 `ginger`, order 2 NULL (no extras), order 3 `chutney`.

## Next

[M16-B04 · The Business Dashboard](../m16-b04-the-business-dashboard/)
