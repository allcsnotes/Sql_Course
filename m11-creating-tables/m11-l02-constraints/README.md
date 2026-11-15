# M11-L02 · Constraints

> Video: Module 11, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- What a **constraint** is: a rule on a column that Postgres checks for every new row
- `NOT NULL`, `UNIQUE`, `CHECK (...)` and `DEFAULT`, on Meera's new `deliveries` table
- What each rule's error looks like, and that a broken rule saves nothing
- Three traps: `CHECK` without brackets, typing `NULL` into a column with a default, and empty text

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- You need the `suppliers` table from [M11-L01](../m11-l01-create-table-columns-and-types/).
- This lesson creates two tables that later lessons use: `deliveries` and (in the task) `promo_codes`.

## Files in this folder

| File | What it is |
|---|---|
| `constraints.sql` | Every query from the video in order, with the real result or error as a comment |
| `setup.sql` | `deliveries` with its 3 rows and an empty `promo_codes`. Run it only if you skipped the lesson |

## Follow along

A table with no rules takes anything: a missing item, zero packets, or the same bill twice. Constraints are rules you add to columns. Postgres checks every new row against them and says no to bad data.

### 1. The four rules

Meera now logs every delivery from her suppliers in a new table, `deliveries`.

```sql
CREATE TABLE deliveries (
  delivery_id int PRIMARY KEY,
  supplier_id int NOT NULL,
  item        varchar(40) NOT NULL,
  qty         int CHECK (qty > 0),
  bill_no     varchar(20) UNIQUE,
  status      varchar(20) DEFAULT 'ordered'
);
```

| Rule | Meaning here |
|---|---|
| `NOT NULL` | the supplier and the item must always have a value |
| `CHECK (qty > 0)` | only values that pass the test in brackets: more than zero packets |
| `UNIQUE` | no two rows share a bill number |
| `DEFAULT 'ordered'` | the value used when you leave `status` out |

### 2. A good delivery

Supplier 2, milk, 40 packets, a new bill number. Every rule is kept.

```sql
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no)
VALUES (1, 2, 'milk', 40, 'PD-101');
```

You should see: `Updated Rows 1`. We never gave a status:

```sql
SELECT * FROM deliveries;
```

You should see:

| delivery_id | supplier_id | item | qty | bill_no | status |
|---|---|---|---|---|---|
| 1 | 2 | milk | 40 | PD-101 | ordered |

The default filled in `ordered` for us.

### 3. Try to break the rules

Each of these is stopped, and nothing is saved.

```sql
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no) VALUES (2, 1, NULL, 10, 'NT-201');
```

```text
ERROR: null value in column "item" of relation "deliveries" violates not-null constraint   (SQLSTATE 23502)
```

```sql
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no) VALUES (2, 1, 'tea leaves', 0, 'NT-201');
```

```text
ERROR: new row for relation "deliveries" violates check constraint "deliveries_qty_check"   (SQLSTATE 23514)
```

The error shows the name Postgres made for the rule: table, column, `check`.

```sql
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no) VALUES (2, 3, 'samosa', 50, 'PD-101');
```

```text
ERROR: duplicate key value violates unique constraint "deliveries_bill_no_key"   (SQLSTATE 23505)
  Detail: Key (bill_no)=(PD-101) already exists.
```

### 4. Fix the bad deliveries

A real item, a quantity of 10, and new bill numbers:

```sql
INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no, status)
VALUES (2, 1, 'tea leaves', 10, 'NT-201', 'ordered'),
       (3, 3, 'samosa', 50, 'SS-301', 'delivered');
```

You should see: `Updated Rows 2`.

```sql
SELECT * FROM deliveries;
```

You should see:

| delivery_id | supplier_id | item | qty | bill_no | status |
|---|---|---|---|---|---|
| 1 | 2 | milk | 40 | PD-101 | ordered |
| 2 | 1 | tea leaves | 10 | NT-201 | ordered |
| 3 | 3 | samosa | 50 | SS-301 | delivered |

Three deliveries, and each one follows every rule.

## Common mistakes

All three were run for real in the video.

1. **A `CHECK` with no brackets around the test.**

   ```sql
   CREATE TABLE stock (
     item varchar(40),
     qty  int CHECK qty > 0
   );
   ```

   ```text
   ERROR: syntax error at or near "qty"   (SQLSTATE 42601)
   ```

   Fix: `CHECK (qty > 0)`. The test always goes inside brackets.

2. **Typing `NULL` for a column with a default.** The default only fills a column you leave out.

   ```sql
   INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no, status)
   VALUES (4, 2, 'curd', 5, 'PD-102', NULL);
   ```

   It goes in, and the status stays empty (`[NULL]` in DBeaver). Fix: leave `status` out of the column list, or add `NOT NULL` to it.

3. **Empty text is not NULL.** An item of two quotes passes `NOT NULL`:

   ```sql
   INSERT INTO deliveries (delivery_id, supplier_id, item, qty, bill_no)
   VALUES (5, 2, '', 5, 'PD-103');
   ```

   It goes in. `SELECT * FROM deliveries;` now shows row 4 with status `[NULL]` and row 5 with an empty item. Fix: add a `CHECK (item <> '')` if blank text should be stopped too.

   These two demo rows were removed after the video. Remove them too, so your table matches later lessons:

   ```sql
   DELETE FROM deliveries WHERE delivery_id IN (4, 5);
   ```

## Try it yourself

1. Create a `promo_codes` table: a `code` that is unique and not null, a `discount` from 1 to 50, and `uses` that start at 0. Then try a discount of 60. (The video's task. Later lessons use this table, so do create it.)
2. Insert `('CHAI10', 10)` into `promo_codes`. What is in `uses`? (Then delete it again: `DELETE FROM promo_codes;`, because M12-L04 starts with an empty table.)
3. Which rule would stop two deliveries with the same `bill_no`, and what is its name?

## Answers

1. ```sql
   CREATE TABLE promo_codes (
     code     varchar(20) UNIQUE NOT NULL,
     discount int CHECK (discount BETWEEN 1 AND 50),
     uses     int DEFAULT 0
   );

   INSERT INTO promo_codes (code, discount)
   VALUES ('CHAI60', 60);
   ```

   ```text
   ERROR: new row for relation "promo_codes" violates check constraint "promo_codes_discount_check"   (SQLSTATE 23514)
     Detail: Failing row contains (CHAI60, 60, 0).
   ```

   The `CHECK` stops a 60 percent discount. Notice the failing row already has `uses` = 0 from the default.

2. `uses` is 0, filled by `DEFAULT 0`.
3. `UNIQUE` on `bill_no`, named `deliveries_bill_no_key`.

## Next

[M11-L03 · Foreign Keys and ON DELETE](../m11-l03-foreign-keys-and-on-delete/)
