# M11-L04 · ALTER TABLE

> Video: Module 11, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- `ALTER TABLE` changes a table in place and keeps its rows
- `ADD COLUMN`: old rows get NULL, or the default if you give one
- `RENAME COLUMN` and `ALTER COLUMN ... TYPE`: the data stays
- Adding a rule later (a foreign key), and how Postgres checks the old rows first
- Three mistakes: `NOT NULL` with no default, text to number, a name that is taken

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need `deliveries` (3 rows) from [M11-L02](../m11-l02-constraints/) and `restocks` from [M11-L03](../m11-l03-foreign-keys-and-on-delete/).
- This lesson changes both tables, and later lessons expect the new shape.

## Files in this folder

| File | What it is |
|---|---|
| `alter_table.sql` | Every query from the video in order, with the real result or error as a comment |
| `setup.sql` | The same changes, safe to run more than once. Run it only if you skipped the lesson |

## Follow along

Meera wants more in `deliveries`: the day each delivery arrived, whether it is paid, and a full word, `quantity`, instead of the short column name. Drop the table and make it again? Every row would be lost. `ALTER TABLE` changes a table in place and keeps the rows.

### 1. Where we start

```sql
SELECT * FROM deliveries;
```

| delivery_id | supplier_id | item | qty | bill_no | status |
|---|---|---|---|---|---|
| 1 | 2 | milk | 40 | PD-101 | ordered |
| 2 | 1 | tea leaves | 10 | NT-201 | ordered |
| 3 | 3 | samosa | 50 | SS-301 | delivered |

### 2. Add a column

```sql
ALTER TABLE deliveries
  ADD COLUMN delivered_on date;

SELECT delivery_id, item, status, delivered_on
FROM deliveries;
```

You should see the same 3 rows with `delivered_on` = `[NULL]` in all three. Postgres adds the column at the end of the table. Nobody told it the dates, so every old row gets NULL: empty, unknown.

### 3. Add a column with a default

Want a real value instead of NULL? Give a default. `boolean` holds only true or false.

```sql
ALTER TABLE deliveries
  ADD COLUMN paid boolean NOT NULL DEFAULT false;

SELECT delivery_id, item, status, paid
FROM deliveries;
```

You should see:

| delivery_id | item | status | paid |
|---|---|---|---|
| 1 | milk | ordered | false |
| 2 | tea leaves | ordered | false |
| 3 | samosa | delivered | false |

DBeaver shows false as an empty check box. All three deliveries are not paid yet.

### 4. Rename and retype

```sql
ALTER TABLE deliveries
  RENAME COLUMN qty TO quantity;
```

Only the name changes; 40, 10 and 50 stay the same. Some new bill numbers will be longer, so make the column wider (it was `varchar(20)`):

```sql
ALTER TABLE deliveries
  ALTER COLUMN bill_no TYPE varchar(40);
```

Every old bill number still fits.

### 5. Add a rule later: a foreign key

In M11-L03, `deliveries` had a `supplier_id` but no foreign key. Add it now:

```sql
ALTER TABLE deliveries
  ADD FOREIGN KEY (supplier_id)
  REFERENCES suppliers (supplier_id);
```

Postgres checks the three old rows first. Suppliers 2, 1 and 3 are all real, so the rule goes in (its name is `deliveries_supplier_id_fkey`).

### 6. The table now

```sql
SELECT delivery_id, item, quantity, bill_no, paid
FROM deliveries;
```

You should see:

| delivery_id | item | quantity | bill_no | paid |
|---|---|---|---|---|
| 1 | milk | 40 | PD-101 | false |
| 2 | tea leaves | 10 | NT-201 | false |
| 3 | samosa | 50 | SS-301 | false |

Same three rows, nothing lost.

## Common mistakes

All three were run for real in the video.

1. **Adding a `NOT NULL` column with no default.** The old rows would get NULL.

   ```sql
   ALTER TABLE deliveries ADD COLUMN driver varchar(30) NOT NULL;
   ```

   ```text
   ERROR: column "driver" of relation "deliveries" contains null values   (SQLSTATE 23502)
   ```

   Fix: give it a default, like `paid` in step 3.

2. **Turning text into a number.** Milk is not a number.

   ```sql
   ALTER TABLE deliveries ALTER COLUMN item TYPE int;
   ```

   ```text
   ERROR: column "item" cannot be cast automatically to type integer   (SQLSTATE 42804)
     Hint: You might need to specify "USING item::integer".
   ```

   Fix: keep text as text.

3. **Renaming to a name that is taken.**

   ```sql
   ALTER TABLE deliveries RENAME COLUMN item TO status;
   ```

   ```text
   ERROR: column "status" of relation "deliveries" already exists   (SQLSTATE 42701)
   ```

   Fix: pick a free name.

## Try it yourself

1. Add a `received` column to `restocks`: true or false, default false. What do the two restocks show? (The video's task. Later lessons expect this column.)
2. Write the statement that would rename `restocks.qty` to `quantity`. (Do not run it: `restocks` keeps `qty` in this course.)
3. Why did step 5 succeed? What would happen if a delivery came from supplier 9?

## Answers

1. ```sql
   ALTER TABLE restocks
     ADD COLUMN received boolean NOT NULL DEFAULT false;
   SELECT * FROM restocks;
   ```

   | restock_id | supplier_id | item | qty | received |
   |---|---|---|---|---|
   | 1 | 2 | milk | 30 | false |
   | 2 | 1 | tea leaves | 8 | false |

   Both restocks show false, the default.

2. `ALTER TABLE restocks RENAME COLUMN qty TO quantity;`
3. Every `supplier_id` in `deliveries` (2, 1, 3) exists in `suppliers`. With a supplier 9 row, Postgres would refuse to add the foreign key with a 23503 error, because an old row breaks the new rule.

## Next

[M11-L05 · DROP, TRUNCATE and DELETE](../m11-l05-drop-truncate-and-delete/)
