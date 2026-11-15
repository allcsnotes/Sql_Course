# M11-L03 · Foreign Keys and ON DELETE

> Video: Module 11, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What a **foreign key** is: a column whose values must already exist in another table
- How `REFERENCES` stops a link to a supplier that does not exist
- Why Postgres blocks deleting a row that other rows still point to (the default)
- `ON DELETE CASCADE` (delete the linked rows too) and `ON DELETE SET NULL` (keep them, empty the link)
- Three mistakes when you write a foreign key

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need the `suppliers` table (3 rows) from [M11-L01](../m11-l01-create-table-columns-and-types/).
- This lesson creates two tables that later lessons use: `restocks` and `supplier_contacts`.

## Files in this folder

| File | What it is |
|---|---|
| `foreign_keys.sql` | Every query from the video in order, with the real result or error as a comment |
| `setup.sql` | `restocks` (2 rows) and `supplier_contacts` (2 rows). Run it only if you skipped the lesson |

## Follow along

Meera wants to log every restock, and each one says which supplier it came from, by number. What stops someone typing supplier 9, when there is no supplier 9? Or deleting a supplier that restocks still point to? A foreign key does.

### 1. Make the link

`restocks` has its own key, `restock_id`. Its `supplier_id` column says `REFERENCES suppliers (supplier_id)`. That makes it a **foreign key**: a key that comes from another table. Every value in it must already exist in `suppliers`.

```sql
CREATE TABLE restocks (
  restock_id  int PRIMARY KEY,
  supplier_id int NOT NULL REFERENCES suppliers (supplier_id),
  item        varchar(40),
  qty         int
);

INSERT INTO restocks VALUES
  (1, 2, 'milk', 30),
  (2, 1, 'tea leaves', 8);
```

You should see: `Updated Rows 2`. Suppliers 2 and 1 are real.

### 2. A bad link

Restock 3 comes from supplier 9, but there is no supplier 9:

```sql
INSERT INTO restocks VALUES (3, 9, 'sugar', 5);
```

```text
ERROR: insert or update on table "restocks" violates foreign key constraint "restocks_supplier_id_fkey"   (SQLSTATE 23503)
  Detail: Key (supplier_id)=(9) is not present in table "suppliers".
```

A restock can never point to a supplier that does not exist.

### 3. Deleting a supplier that is still used

`DELETE` removes rows (Module 12 explains it fully). Try to remove Pune Dairy, supplier 2:

```sql
DELETE FROM suppliers WHERE supplier_id = 2;
```

```text
ERROR: update or delete on table "suppliers" violates foreign key constraint "restocks_supplier_id_fkey" on table "restocks"   (SQLSTATE 23503)
  Detail: Key (supplier_id)=(2) is still referenced from table "restocks".
```

This is the default: Postgres blocks the delete, so no restock is left pointing at nothing.

### 4. ON DELETE CASCADE

Sometimes you want the linked rows to go too. Supplier contacts belong to a supplier, so this foreign key adds `ON DELETE CASCADE`:

```sql
CREATE TABLE supplier_contacts (
  contact_id  int PRIMARY KEY,
  supplier_id int REFERENCES suppliers (supplier_id) ON DELETE CASCADE,
  person      varchar(40),
  job         varchar(30)
);
```

Meera adds Konkan Spices as supplier 4, with two contacts, Sana and Imran. Run both statements together as a script:

```sql
INSERT INTO suppliers VALUES
  (4, 'Konkan Spices', 'Ratnagiri', 'spices', '2022-01-10', 4.0);

INSERT INTO supplier_contacts VALUES
  (1, 1, 'Ravi',  'sales'),
  (2, 2, 'Meena', 'delivery'),
  (3, 4, 'Sana',  'sales'),
  (4, 4, 'Imran', 'delivery');
```

You should see: `Queries 2`, `Updated Rows 5`. Now there are four contacts:

```sql
SELECT * FROM supplier_contacts;
```

| contact_id | supplier_id | person | job |
|---|---|---|---|
| 1 | 1 | Ravi | sales |
| 2 | 2 | Meena | delivery |
| 3 | 4 | Sana | sales |
| 4 | 4 | Imran | delivery |

Meera stops buying from Konkan Spices:

```sql
DELETE FROM suppliers WHERE supplier_id = 4;
```

You should see: `Updated Rows 1`. Select the contacts again:

```sql
SELECT * FROM supplier_contacts;
```

| contact_id | supplier_id | person | job |
|---|---|---|---|
| 1 | 1 | Ravi | sales |
| 2 | 2 | Meena | delivery |

Sana and Imran are gone too. The delete flowed down to them, like water down steps.

### 5. One more choice: SET NULL

`ON DELETE SET NULL` keeps the linked row and only empties its `supplier_id`. The three choices:

| Written on the foreign key | Delete the supplier, and the linked rows... |
|---|---|
| nothing (default) | block the delete |
| `ON DELETE CASCADE` | are deleted too |
| `ON DELETE SET NULL` | stay, with `supplier_id` set to NULL |

## Common mistakes

All three were run for real in the video, each on a test table `payments`.

1. **A wrong table name**, like `supplier` without the s.

   ```sql
   CREATE TABLE payments (
     payment_id  int PRIMARY KEY,
     supplier_id int REFERENCES supplier (supplier_id)
   );
   ```

   ```text
   ERROR: relation "supplier" does not exist   (SQLSTATE 42P01)
   ```

2. **Types that do not match.** A text column cannot point to a number column.

   ```sql
   CREATE TABLE payments (
     payment_id  int PRIMARY KEY,
     supplier_id varchar(10) REFERENCES suppliers (supplier_id)
   );
   ```

   ```text
   ERROR: foreign key constraint "payments_supplier_id_fkey" cannot be implemented   (SQLSTATE 42804)
     Detail: Key columns "supplier_id" of the referencing table and "supplier_id" of the referenced table are of incompatible types: character varying and integer.
   ```

3. **Pointing at a column that is not unique**, like `city`. Two suppliers are in Pune.

   ```sql
   CREATE TABLE payments (
     payment_id int PRIMARY KEY,
     city       varchar(30) REFERENCES suppliers (city)
   );
   ```

   ```text
   ERROR: there is no unique constraint matching given keys for referenced table "suppliers"   (SQLSTATE 42830)
   ```

   A foreign key must point at a primary key or a `UNIQUE` column.

## Try it yourself

1. Try to delete supplier 1, Nilgiri Tea. What happens, and why? (The video's task.)
2. Can you delete supplier 3, Sahyadri Snacks? Think first, then check with `SELECT * FROM restocks;` (do not actually delete it; later lessons need it).
3. Which `ON DELETE` choice would you pick for an `orders` table that points at `customers`, if old orders must be kept?

## Answers

1. ```sql
   DELETE FROM suppliers WHERE supplier_id = 1;
   ```

   ```text
   ERROR: update or delete on table "suppliers" violates foreign key constraint "restocks_supplier_id_fkey" on table "restocks"   (SQLSTATE 23503)
     Detail: Key (supplier_id)=(1) is still referenced from table "restocks".
   ```

   It is blocked: restock 2 (tea leaves) still points to supplier 1, and `restocks` uses the default rule. Ravi's contact row would have cascaded, but the block stops the whole delete.

2. No restock points to supplier 3 and no contact either, so nothing would block it. (Later, M11-L04 adds a foreign key from `deliveries`, and delivery 3 comes from supplier 3.)
3. The default (block) or `ON DELETE SET NULL`: both keep the old orders. `CASCADE` would delete them.

## Next

[M11-L04 · ALTER TABLE](../m11-l04-alter-table/)
