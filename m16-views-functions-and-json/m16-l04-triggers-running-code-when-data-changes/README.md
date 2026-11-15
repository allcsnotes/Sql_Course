# M16-L04 · Triggers: Running Code When Data Changes

> Video: Module 16, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- What a **trigger** is: code the database runs by itself when data changes
- How to write a trigger function in `plpgsql` with `RETURNS trigger`
- What `OLD` (the row before) and `NEW` (the row after) mean
- How to connect the function to a table with `CREATE TRIGGER`, and keep a price log
- Three mistakes: a normal function, logging changes that did nothing, and dropping the function first

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- This lesson works on `menu_items` (Masala Chai is item 7, ₹30).
- It **changes the database**: a `price_log` table, a trigger function `log_price()`, a trigger `price_change` on `menu_items`, and 3 log rows. Masala Chai ends back at ₹30.

## Files in this folder

| File | What it is |
|---|---|
| `triggers.sql` | Every statement from the video in order (mistakes included), with the real result as a comment |
| `setup.sql` | What this lesson leaves in the database: `price_log` with its 3 rows, `log_price()`, the final `price_change` trigger. Safe to run again |

## Follow along

Every time a price changes, you want a record: the old price, the new price and the date. The database should run some code and write a log row all by itself.

```text
UPDATE Masala Chai 30 -> 35
   -> trigger price_change (watching menu_items) fires right after
   -> adds a row to price_log: 7 | 30 | 35 | today
You never wrote that row. The trigger did.
```

### 1. The log table

`price_log` keeps the item id, the old price and the new price. The date fills itself with today.

```sql
CREATE TABLE price_log (
  item_id int,
  old_price numeric,
  new_price numeric,
  changed_on date DEFAULT CURRENT_DATE
);
```

### 2. The trigger function

It `RETURNS trigger`. `LANGUAGE plpgsql` lets it run steps between `BEGIN` and `END`. Its body inserts one row: `OLD` is the row before the change, `NEW` the row after. `RETURN NEW` finishes it.

```sql
CREATE FUNCTION log_price()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO price_log (item_id, old_price, new_price)
  VALUES (OLD.item_id, OLD.price, NEW.price);
  RETURN NEW;
END;
$$;
```

### 3. Connect it to the table

`AFTER UPDATE OF price ON menu_items` means right after someone changes a price. `FOR EACH ROW` runs it once for every changed row. `EXECUTE FUNCTION` names `log_price`.

```sql
CREATE TRIGGER price_change
AFTER UPDATE OF price ON menu_items
FOR EACH ROW
EXECUTE FUNCTION log_price();
```

DBeaver says **Updated Rows: 0**, but the trigger is now watching.

### 4. Watch it fire

Change only the menu:

```sql
UPDATE menu_items
SET price = 35
WHERE name = 'Masala Chai';

SELECT * FROM price_log;
```

You should see one row that you never inserted:

| item_id | old_price | new_price | changed_on |
|---|---|---|---|
| 7 | 30 | 35 | 2026-11-14 |

`changed_on` is the day you run it (the video was recorded on 14 November 2026).

## Common mistakes

All three were run for real in the video.

1. **Using a normal function.** `say_hi()` returns `text` (`triggers.sql` makes a tiny one to show this):

   ```sql
   CREATE TRIGGER price_change2
   AFTER UPDATE OF price ON menu_items
   FOR EACH ROW
   EXECUTE FUNCTION say_hi();
   ```

   ```text
   ERROR: function say_hi must return type trigger   (SQLSTATE 42P17)
   ```

   Fix: a trigger function must say `RETURNS trigger`.

2. **Logging changes that did not happen.** Set the same price again:

   ```sql
   UPDATE menu_items
   SET price = 35
   WHERE name = 'Masala Chai';
   ```

   `price_log` gets a second row, `7 | 35 | 35`. Fix: add `WHEN`, so it only logs a real change:

   ```sql
   CREATE OR REPLACE TRIGGER price_change
   AFTER UPDATE OF price ON menu_items
   FOR EACH ROW
   WHEN (OLD.price <> NEW.price)
   EXECUTE FUNCTION log_price();
   ```

3. **Dropping the function first.**

   ```sql
   DROP FUNCTION log_price();
   ```

   ```text
   ERROR: cannot drop function log_price() because other objects depend on it   (SQLSTATE 2BP01)
   DETAIL: trigger price_change on table menu_items depends on function log_price()
   ```

   Fix: remove the trigger first (`DROP TRIGGER price_change ON menu_items;`), then the function. Do not run that here: the course keeps the trigger.

## Try it yourself

1. Change Masala Chai back to ₹30, and check that `price_log` gets a new row. (The video's task.)
2. Run the same `UPDATE` to ₹30 again. Does a row appear now?
3. Change Samosa from ₹25 to ₹25 and then look at `price_log`. Why is there no row?

## Answers

1. ```sql
   UPDATE menu_items
   SET price = 30
   WHERE name = 'Masala Chai';

   SELECT * FROM price_log;
   ```

   | item_id | old_price | new_price | changed_on |
   |---|---|---|---|
   | 7 | 30 | 35 | 2026-11-14 |
   | 7 | 35 | 35 | 2026-11-14 |
   | 7 | 35 | 30 | 2026-11-14 |

2. No. The `WHEN (OLD.price <> NEW.price)` check skips it: still 3 rows (the video's proof).

3. The price did not really change, so `WHEN` stops the trigger. (Leave Samosa at ₹25.)

## Next

[M16-L05 · JSON and JSONB: Storing Flexible Data](../m16-l05-json-and-jsonb-storing-flexible-data/)
