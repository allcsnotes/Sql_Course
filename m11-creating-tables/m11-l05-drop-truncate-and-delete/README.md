# M11-L05 · DROP, TRUNCATE and DELETE

> Video: Module 11, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- The safety habit: practise on a copy made with `CREATE TABLE ... AS SELECT`
- `DELETE ... WHERE`: removes the rows you pick
- `TRUNCATE`: empties every row at once, but keeps the table
- `DROP TABLE`: throws away the whole table, columns and all
- How foreign keys stop you dropping or truncating a table others depend on

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `deliveries`, `suppliers` and `restocks` as they are after [M11-L04](../m11-l04-alter-table/).
- Nothing in this lesson changes the real tables: every remove runs on a copy, and the copies are dropped at the end. There is no `setup.sql`.

## Files in this folder

| File | What it is |
|---|---|
| `drop_truncate_delete.sql` | Every command from the video in order, with the real result or error as a comment |

## Follow along

Three ways to remove things. They sound alike but do very different jobs. Pick the wrong one, and the data is gone for good.

| Command | Removes | The table afterwards |
|---|---|---|
| `DELETE FROM t WHERE ...` | the rows you pick | still there |
| `TRUNCATE t` | every row, in one fast step | still there, empty |
| `DROP TABLE t` | the whole table, columns and all | gone |

### 1. A safety habit: practise on a copy

```sql
CREATE TABLE practice AS
  SELECT * FROM deliveries;
```

You should see: `Updated Rows 3`. Postgres copies all three rows into a new table. Now you can break the copy, and `deliveries` stays safe.

### 2. DELETE

The `WHERE` part picks the rows.

```sql
DELETE FROM practice
WHERE item = 'milk';
```

You should see: `Updated Rows 1`.

```sql
SELECT delivery_id, item, status
FROM practice;
```

| delivery_id | item | status |
|---|---|---|
| 2 | tea leaves | ordered |
| 3 | samosa | delivered |

Milk is gone. Tea leaves and samosa stay.

### 3. TRUNCATE

```sql
TRUNCATE practice;
```

You should see: `Updated Rows 0`. It empties the whole table in one fast step and does not even count the rows.

```sql
SELECT delivery_id, item, status
FROM practice;
```

You should see the three column headers and no rows. The table is still there, ready for new rows.

### 4. DROP

```sql
DROP TABLE practice;
```

DBeaver stops and asks: "Execute drop queries. Possible data loss. Are you sure?" Postgres itself never asks, so read this box with care. Click OK, and the table is gone (`Updated Rows 0`).

```sql
SELECT * FROM practice;
```

```text
ERROR: relation "practice" does not exist   (SQLSTATE 42P01)
```

The rows, the columns, the table: all removed.

## Common mistakes

All three were run for real in the video.

1. **`DELETE` with no `WHERE`.** Every row goes. On a fresh copy:

   ```sql
   CREATE TABLE practice AS SELECT * FROM deliveries;
   DELETE FROM practice;
   ```

   DBeaver warns you first ("Execute dangerous queries"). Click through, and you see `Updated Rows 3`. Always write the `WHERE`, and test it with a `SELECT` first. Then clean up: `DROP TABLE practice;`.

2. **Dropping a table that other tables point to.**

   ```sql
   DROP TABLE suppliers;
   ```

   ```text
   ERROR: cannot drop table suppliers because other objects depend on it   (SQLSTATE 2BP01)
     Detail: constraint restocks_supplier_id_fkey on table restocks depends on table suppliers
     constraint supplier_contacts_supplier_id_fkey on table supplier_contacts depends on table suppliers
     constraint deliveries_supplier_id_fkey on table deliveries depends on table suppliers
     Hint: Use DROP ... CASCADE to drop the dependent objects too.
   ```

   `restocks`, `supplier_contacts` and `deliveries` depend on `suppliers`.

3. **`TRUNCATE` on that same table.**

   ```sql
   TRUNCATE suppliers;
   ```

   ```text
   ERROR: cannot truncate a table referenced in a foreign key constraint   (SQLSTATE 0A000)
     Detail: Table "deliveries" references "suppliers".
     Hint: Truncate table "deliveries" at the same time, or use TRUNCATE ... CASCADE.
   ```

   Your foreign keys protect you. Do not add `CASCADE` to "fix" these: it would remove the other tables' data too.

## Try it yourself

1. Copy `restocks`, then truncate the copy. How many rows does `restocks` still have? (The video's task.)
2. On a new copy of `deliveries`, delete only the rows whose status is `'ordered'`. Check with a `SELECT` before and after.
3. Which command would you use to empty a log table you still need tomorrow?

## Answers

1. ```sql
   CREATE TABLE restocks_copy AS SELECT * FROM restocks;
   TRUNCATE restocks_copy;
   SELECT * FROM restocks;
   ```

   | restock_id | supplier_id | item | qty | received |
   |---|---|---|---|---|
   | 1 | 2 | milk | 30 | false |
   | 2 | 1 | tea leaves | 8 | false |

   `restocks` still has 2 rows: the copy is a separate table. Clean up afterwards with `DROP TABLE restocks_copy;`.

2. ```sql
   CREATE TABLE practice AS SELECT * FROM deliveries;
   SELECT * FROM practice WHERE status = 'ordered';   -- 2 rows: milk, tea leaves
   DELETE FROM practice WHERE status = 'ordered';     -- Updated Rows 2
   SELECT * FROM practice;                            -- 1 row: samosa
   DROP TABLE practice;
   ```

3. `TRUNCATE`: it empties the rows fast and keeps the table.

## Next

[M12-L01 · INSERT](../../m12-changing-data/m12-l01-insert/)
