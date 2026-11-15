# M05-L05 · CAST and ::

> Video: Module 5, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- Casting means changing a value from one type to another
- The two ways to cast: `CAST(value AS type)` and the shorter `value::type`
- Why the type matters: as text, `'10'` is smaller than `'9'`
- Useful casts: to `numeric` to keep the decimal part, to `text` to join with words, and the `->>` result to `integer` to do maths
- Three beginner mistakes: casting letters, casting `'3.7'` straight to integer, and forgetting `AS` inside `CAST`

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `cast.sql` | The six queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and the fix for mistake 2 |

## Follow along

Is 10 smaller than 9? Of course not. But ask PostgreSQL with quotes, and it says yes! The values were text, not numbers. Today you learn to change a value from one type to another. This is called **casting**.

### 1. Two ways to cast

The first way is the word `CAST`. Inside the brackets write the value, the word `AS`, and the new type. The second way is shorter: two colons after the value, then the type. It does exactly the same job:

```sql
SELECT CAST('42' AS integer) AS with_cast, '42'::integer AS with_colons;
```

You should see:

| with_cast | with_colons |
|----------:|------------:|
| 42 | 42 |

The text `'42'` became the number 42. Most people use the two colons.

### 2. Why the type matters

```sql
SELECT '10' < '9' AS compared_as_text, 10 < 9 AS compared_as_numbers;
```

You should see:

| compared_as_text | compared_as_numbers |
|------------------|---------------------|
| [v] (true) | [ ] (false) |

Text is compared letter by letter, like words in a dictionary. The first letter of `'10'` is `1`, and `1` comes before `9`. So as text, 10 is smaller than 9. As numbers, it is false.

Cast both values to integer and the answer is correct again:

```sql
SELECT '10'::integer < '9'::integer AS compared_after_cast;
```

You should see `false` (an empty box). Always compare numbers as numbers.

### 3. Useful casts

**Keep the decimal part.** `7 / 2` gives 3, because both are whole numbers. Cast 7 to numeric first:

```sql
SELECT 7 / 2 AS integer_division, 7::numeric / 2 AS numeric_division;
```

You should see:

| integer_division | numeric_division |
|-----------------:|-----------------:|
| 3 | 3.5000000000000000 |

**Join a number with words.** The two bars `||` join text together. Cast the price to text first:

```sql
SELECT name, price::text || ' rupees' AS price_label FROM menu_items ORDER BY price LIMIT 3;
```

You should see:

| name | price_label |
|------|-------------|
| Cutting Chai | 20 rupees |
| Samosa | 25 rupees |
| Ginger Chai | 30 rupees |

(Three items cost ₹30, so your third row may be a different one.)

**Do maths with a JSON value.** Remember, `->>` gives back text. Cast it to integer and you can do maths:

```sql
SELECT ('{"name": "Samosa", "price": 25}'::jsonb ->> 'price')::integer + 5 AS new_price;
```

You should see `30`: 25 plus 5.

## Common mistakes

The queries are in `mistakes.sql`.

**1. Text that is not a number cannot become a number:**

```sql
SELECT 'abc'::integer AS price;
```

```text
SQL Error [22P02]: ERROR: invalid input syntax for type integer: "abc"
```

**2. `'3.7'` also fails as an integer:**

```sql
SELECT '3.7'::integer AS whole_number;
```

```text
SQL Error [22P02]: ERROR: invalid input syntax for type integer: "3.7"
```

Cast it to numeric first, then to integer:

```sql
SELECT '3.7'::numeric::integer AS whole_number;
```

You should see `4`, because it rounds.

**3. Inside CAST, the word AS is required:**

```sql
SELECT CAST('42' integer) AS price;
```

```text
SQL Error [42601]: ERROR: syntax error at or near "integer"
```

Write `CAST('42' AS integer)`.

## Try it yourself

1. Cast 9.6 to integer. Does it cut to 9, or round to 10? Guess first, then run it.
2. Write `'5'` plus `'7'` so that the answer is the number 12.
3. Show each menu item as `Masala Chai costs 30` (name, the word costs, the price).

## Answers

1. The task from the video:

   ```sql
   SELECT 9.6::integer AS rounded;
   ```

   It gives `10`: casting to integer rounds, it does not cut.
2. `SELECT '5'::integer + '7'::integer;` gives `12`.
3. `SELECT name || ' costs ' || price::text FROM menu_items;`

## Next

[M06-L01 · Text Functions](../../m06-functions/m06-l01-text-functions/)
