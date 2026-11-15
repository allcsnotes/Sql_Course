# M05-L01 · Numbers: Integer, Numeric, Float

> Video: Module 5, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- `integer` is for whole numbers, and `pg_typeof` shows the type of any value
- Dividing two integers throws away the part after the point (`7 / 2` is `3`)
- `numeric` is exact: `0.1 + 0.2` is exactly `0.3`, and `numeric(6,2)` fixes the size for money
- `float` is fast but rough: `0.1 + 0.2` gives `0.30000000000000004`, so never use it for money
- Three beginner mistakes: integer out of range, numeric field overflow, and integer division

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `numbers.sql` | The seven queries from the video, in order, each with its real result |
| `mistakes.sql` | The three beginner mistakes (the first two fail on purpose) |

## Follow along

### 1. The puzzle

Ask a computer for 0.1 + 0.2. You expect 0.3, but some number types give you a tiny bit more, with a 4 far away at the end. Picking the right number type stops this. PostgreSQL has three kinds of numbers: **integer**, **numeric** and **float**.

### 2. Integer: whole numbers

An integer is a whole number with no decimal point, like 3 or 80. Our menu prices are integers. The `pg_typeof` function shows the type of any value:

```sql
SELECT name, price, pg_typeof(price) FROM menu_items LIMIT 3;
```

You should see:

| name | price | pg_typeof |
|------|------:|-----------|
| Bun Maska | 35 | integer |
| Cold Coffee | 80 | integer |
| Cutting Chai | 20 | integer |

Integers are great for counting. But watch out when you divide:

```sql
SELECT 7 / 2;
```

You should see `3`, not 3.5. **Integer division** keeps only the whole part and throws away the `.5`.

### 3. Numeric: exact decimals

Now put a decimal point on one side:

```sql
SELECT 7 / 2.0 AS divided_with_decimal;
```

You should see:

| divided_with_decimal |
|---------------------:|
| 3.5000000000000000 |

One side has a decimal point, so the answer is `numeric`: 3.5 with some extra zeros. Numeric is exact:

```sql
SELECT 0.1 + 0.2 AS total_using_numeric;
```

You should see exactly `0.3`.

| Expression | Result | Type |
|------------|-------:|------|
| `7 / 2` | 3 | integer |
| `7 / 2.0` | 3.5 | numeric |
| `0.1 + 0.2` | 0.3 | numeric |

Two colons and a type (`value::type`) tell SQL to treat a value as that type. You will learn this fully in [lesson 5](../m05-l05-cast-and-colons/).

You can also fix the size. `numeric(6,2)` means 6 digits in total, 2 of them after the point. Perfect for money:

```sql
SELECT 19.999::numeric(6,2) AS rounded_price;
```

You should see `20.00`. The value 19.999 is rounded to fit 2 places after the point.

### 4. Float: fast, but rough

Float stores numbers in **binary**, the zeros and ones inside a computer. Many decimals, like 0.1, cannot be stored exactly:

```sql
SELECT 0.1::float + 0.2::float AS total_using_float;
```

You should see:

| total_using_float |
|------------------:|
| 0.30000000000000004 |

So close, but not equal. Ask if it equals 0.3:

```sql
SELECT 0.1::float + 0.2::float = 0.3::float AS is_it_equal;
```

You should see `false`. In DBeaver false is an empty tick box; `psql` prints `f`.

Float is fine for science and measurements. For money, always use numeric.

## Common mistakes

The queries are in `mistakes.sql`.

**1. A number too big for integer.** An integer stops at about 2.1 billion (2147483647):

```sql
SELECT 2147483647 + 1;
```

```text
SQL Error [22003]: ERROR: integer out of range
```

For bigger numbers, use `bigint`.

**2. A numeric that is too small.** `numeric(6,2)` holds up to 9999.99:

```sql
SELECT 12345.67::numeric(6,2);
```

```text
SQL Error [22003]: ERROR: numeric field overflow
  Detail: A field with precision 6, scale 2 must round to an absolute value less than 10^4.
```

Make the type bigger, for example `numeric(10,2)`.

**3. Dividing whole numbers.** `7 / 2` is `3`. Write `2.0` to keep the part after the point: `7 / 2.0` gives `3.5000000000000000`.

## Try it yourself

1. What does 1.1 + 2.2 give, as a float? Guess first, then run it.
2. What type does `pg_typeof(7 / 2.0)` show?
3. What does `SELECT 99.995::numeric(6,2);` give?
4. Pick a type for a column that stores a menu price with paise, like ₹29.50.

## Answers

1. The task from the video:

   ```sql
   SELECT 1.1::float + 2.2::float AS total_using_float;
   ```

   It gives `3.3000000000000003`, not 3.3. Float strikes again.
2. `numeric`, because one side has a decimal point.
3. `100.00`: it is rounded to 2 places after the point, and 100.00 still fits in 6 digits.
4. `numeric(10,2)` (or another size of numeric). Never float for money.

## Next

[M05-L02 · Text: char, varchar, text](../m05-l02-text-char-varchar-text/)
