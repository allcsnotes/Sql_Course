# M06-L02 · Number Functions

> Video: Module 6, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- `ROUND(x, 2)` keeps two places after the point and goes to the nearest; `ROUND(x)` gives a whole number
- `CEIL` always goes up, `FLOOR` always goes down
- Two whole numbers give a whole answer; `%` gives what is left over; a decimal point keeps the rest
- Three beginner mistakes: dividing by zero, hidden whole number division, and `ROUND` on double precision

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `number_functions.sql` | The four queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and the fix for mistake 3 |

## Follow along

A price with tax comes out as 26.2500. Seven cups need boxes that hold two each. And 10 divided by 3 gives just 3. Number functions handle all of this.

### 1. ROUND

The `ROUND` function makes a number shorter. The second value says how many places to keep after the point. With no second value, `ROUND` gives a whole number:

```sql
SELECT ROUND(42.567, 2) AS two_places, ROUND(42.567) AS whole, ROUND(42.5) AS half_up;
```

You should see:

| two_places | whole | half_up |
|-----------:|------:|--------:|
| 42.57 | 43 | 43 |

.5 or more goes up, so 42.5 becomes 43.

A real use: add 5 percent tax to each price, and round it to two places:

```sql
SELECT name, price, ROUND(price * 1.05, 2) AS with_tax FROM menu_items ORDER BY price LIMIT 3;
```

You should see:

| name | price | with_tax |
|------|------:|---------:|
| Cutting Chai | 20 | 21.00 |
| Samosa | 25 | 26.25 |
| Ginger Chai | 30 | 31.50 |

₹25 becomes ₹26.25. (Three items cost ₹30, so your third row may be another of them.)

### 2. Always up, or always down

`CEIL` (ceiling) always goes up to the next whole number. `FLOOR` always goes down:

```sql
SELECT CEIL(4.1) AS ceil_up, FLOOR(4.9) AS floor_down;
```

You should see:

| ceil_up | floor_down |
|--------:|-----------:|
| 5 | 4 |

`ROUND` picks the nearest, but `CEIL` and `FLOOR` pick one direction.

### 3. The division trap

```sql
SELECT 10 / 3 AS whole_part, 10 % 3 AS leftover, 10 / 3.0 AS exact;
```

You should see:

| whole_part | leftover | exact |
|-----------:|---------:|------:|
| 3 | 1 | 3.3333333333333333 |

10 divided by 3 gives 3: both numbers are whole, so the answer is whole too, and the rest is thrown away. The percent sign `%` (modulo) gives what is left over: 1. Write `3.0` and one side has a decimal point, so the answer is exact.

## Common mistakes

The queries are in `mistakes.sql`.

**1. You can never divide by zero:**

```sql
SELECT 100 / 0 AS per_order;
```

```text
SQL Error [22012]: ERROR: division by zero
```

The whole query stops. Check for zero first. [M06-L05](../m06-l05-coalesce-and-nullif/) shows a neat way to do that.

**2. Whole number division hides inside bigger sums:**

```sql
SELECT 5 / 2 * 2 AS back_again, 5.0 / 2 * 2 AS with_decimal;
```

| back_again | with_decimal |
|-----------:|-------------:|
| 4 | 5.0000000000000000 |

5 / 2 is 2, times 2 is 4, not 5. Add a decimal point and you get 5 again.

**3. ROUND with places needs a numeric value.** On a `double precision` (float) value:

```sql
SELECT ROUND(4.567::double precision, 2) AS rounded;
```

```text
SQL Error [42883]: ERROR: function round(double precision, integer) does not exist
```

Cast it to numeric first:

```sql
SELECT ROUND(4.567::double precision::numeric, 2) AS rounded;
```

You should see `4.57`.

## Try it yourself

1. Seven cups, and each box holds two. How many boxes do you need? Use `CEIL` on 7 divided by 2.0. Guess first, then run it.
2. Show every menu price with 18 percent tax, rounded to whole rupees.
3. 17 samosas are shared between 5 people. How many does each get, and how many are left?

## Answers

1. The task from the video:

   ```sql
   SELECT CEIL(7 / 2.0) AS boxes_needed;
   ```

   It gives `4` (3.5 goes up to 4).
2. `SELECT name, ROUND(price * 1.18) AS with_tax FROM menu_items;` (Cold Coffee: 94).
3. `SELECT 17 / 5 AS each_gets, 17 % 5 AS left_over;` gives 3 and 2.

## Next

[M06-L03 · Date Functions](../m06-l03-date-functions/)
