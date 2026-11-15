# M06-L05 · COALESCE and NULLIF

> Video: Module 6, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- `COALESCE` gives back the first value that is not NULL, so you can fill in a missing value
- `NULLIF(a, b)` gives NULL when the two values are equal, and `a` otherwise
- Safe division: divide by `NULLIF(x, 0)` and you never divide by zero
- Three beginner mistakes: a backup of a different type, the backup first, and empty text that is not NULL

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). The `email` column comes from [M03-L06](../../m03-your-first-queries/m03-l06-null-the-unknown-value/): four customers have no email (NULL).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `coalesce_nullif.sql` | The five queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and the fix for mistake 1 |

## Follow along

Lukas has no email, so his row shows NULL. And in [M06-L02](../m06-l02-number-functions/), dividing by zero stopped the whole query. Today we fix both.

### 1. Fill the gaps with COALESCE

The `COALESCE` function gives back the first value that is not NULL:

```sql
SELECT name, email,
  COALESCE(email, 'no email') AS contact
FROM customers;
```

You should see 15 rows, starting:

| name | email | contact |
|------|-------|---------|
| Asha | asha@example.com | asha@example.com |
| Lukas | [NULL] | no email |
| Priya | priya@example.com | priya@example.com |
| Rahul | rahul@example.com | rahul@example.com |
| Kabir | [NULL] | no email |

Asha has an email, so we see her email. Lukas has none, so we see the backup: `no email`. Isha and Dev also get `no email`.

You can give it many values. It checks them from left to right:

```sql
SELECT COALESCE(NULL, NULL, 'third', 'fourth') AS first_found;
```

You should see `third`.

### 2. NULLIF does the opposite

`NULLIF` takes two values. If they are equal, it gives NULL. If they are different, it gives back the first one:

```sql
SELECT NULLIF(5, 5) AS same, NULLIF(5, 3) AS different;
```

You should see:

| same | different |
|------|----------:|
| [NULL] | 5 |

### 3. Safe division

Remember, `100 / 0` stops the whole query. Wrap the zero in `NULLIF`. Now it becomes NULL, and dividing by NULL simply gives NULL. No error:

```sql
SELECT 100 / NULLIF(0, 0) AS safe_divide;
```

You should see `[NULL]`.

Want a number instead? Wrap it all in `COALESCE`, with 0 as the backup:

```sql
SELECT COALESCE(100 / NULLIF(0, 0), 0) AS result;
```

You should see `0`.

In a real report the zero would be a column, for example `total / NULLIF(orders, 0)`.

## Common mistakes

The queries are in `mistakes.sql`.

**1. The backup has a different type.** `price` is a number, but `'free'` is text:

```sql
SELECT name, COALESCE(price, 'free') AS shown FROM menu_items;
```

```text
SQL Error [22P02]: ERROR: invalid input syntax for type integer: "free"
```

Cast the price to text first:

```sql
SELECT name, COALESCE(price::text, 'free') AS shown FROM menu_items;
```

Now it runs (every item has a price, so you see the prices as text).

**2. The backup comes first:**

```sql
SELECT name, COALESCE('no email', email) AS contact FROM customers;
```

`'no email'` is never NULL, so the function stops there and everyone gets `no email`. Put the real column first and the backup last.

**3. Empty text is not NULL:**

```sql
SELECT COALESCE('', 'no email') AS plain, COALESCE(NULLIF('', ''), 'no email') AS fixed;
```

| plain | fixed |
|-------|-------|
| (blank) | no email |

`COALESCE` keeps the empty text and shows a blank. Use `NULLIF` to turn empty text into NULL first.

## Try it yourself

1. Show each customer's email, or `ask at counter` when it is missing. How many customers get `ask at counter`? Guess first, then run it.
2. Show 100 divided by each menu item's price minus 30, without an error for the ₹30 items.
3. What does `SELECT COALESCE(NULL, NULL);` give?

## Answers

1. The task from the video:

   ```sql
   SELECT name, COALESCE(email, 'ask at counter') AS contact FROM customers;
   ```

   4 customers: Lukas, Kabir, Isha and Dev.
2. `SELECT name, 100 / NULLIF(price - 30, 0) AS share FROM menu_items;` (the ₹30 items show NULL).
3. NULL: there is no value that is not NULL to give back.

## Next

[M07-L01 · COUNT, SUM, AVG, MIN, MAX](../../m07-summarising-data/m07-l01-count-sum-avg-min-max/)
