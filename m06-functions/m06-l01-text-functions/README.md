# M06-L01 · Text Functions

> Video: Module 6, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- A function is a ready-made tool: you give it a value inside brackets and it gives back a new value
- `UPPER` and `LOWER` change the case of every letter
- `LENGTH` counts characters, and `TRIM` removes extra spaces at the ends
- `SUBSTRING(... FROM ... FOR ...)` cuts a piece; the two bars `||` and `CONCAT` join texts
- Three beginner mistakes: a text function on a number, joining with NULL, and starting positions at 0

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)). Step 4 needs the `category` column from [M04-L03](../../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `text_functions.sql` | The four queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and their fixes |

## Follow along

A customer typed their name with extra spaces. Another wrote it all in small letters. Your menu needs short codes for every item. Text functions fix all of this.

### 1. Change the case

`UPPER` turns every letter into a capital letter. `LOWER` turns every letter into a small letter:

```sql
SELECT name, UPPER(name) AS upper_name, LOWER(name) AS lower_name FROM menu_items ORDER BY price LIMIT 3;
```

You should see:

| name | upper_name | lower_name |
|------|------------|------------|
| Cutting Chai | CUTTING CHAI | cutting chai |
| Samosa | SAMOSA | samosa |
| Ginger Chai | GINGER CHAI | ginger chai |

The real name in the table does not change. Only the result does.

### 2. Clean and count

`LENGTH` counts the characters in a text, and spaces count too. `TRIM` removes the spaces from the start and the end:

```sql
SELECT LENGTH('  Chai  ') AS len_before, TRIM('  Chai  ') AS clean, LENGTH(TRIM('  Chai  ')) AS len_after;
```

You should see:

| len_before | clean | len_after |
|-----------:|-------|----------:|
| 8 | Chai | 4 |

Chai with two spaces on each side has a length of 8. After `TRIM` it has 4. Use `TRIM` to clean what people type.

### 3. Cut and join

`SUBSTRING` takes a piece of the text. `FROM 1` means start at the first letter, `FOR 3` means take three letters:

```sql
SELECT name, SUBSTRING(name FROM 1 FOR 3) AS short_code FROM menu_items ORDER BY price LIMIT 3;
```

You should see:

| name | short_code |
|------|------------|
| Cutting Chai | Cut |
| Samosa | Sam |
| Ginger Chai | Gin |

To join texts together, use the two bars `||`. Here the name, a bracket, the category and a closing bracket make one label:

```sql
SELECT name || ' (' || category || ')' AS label FROM menu_items ORDER BY price LIMIT 3;
```

You should see:

| label |
|-------|
| Cutting Chai (Chai) |
| Samosa (Snack) |
| Ginger Chai (Chai) |

## Common mistakes

The queries are in `mistakes.sql`.

**1. Text functions need text.** `UPPER` on the price, a number:

```sql
SELECT UPPER(price) AS loud_price FROM menu_items;
```

```text
SQL Error [42883]: ERROR: function upper(integer) does not exist
  Hint: No function matches the given name and argument types. You might need to add explicit type casts.
```

Cast the number to text first:

```sql
SELECT UPPER(price::text) AS loud_price FROM menu_items LIMIT 3;
```

You should see `35`, `80`, `20`.

**2. Joining with a NULL gives NULL.** The whole result is lost, and no error warns you:

```sql
SELECT 'Chai' || NULL AS with_bars, CONCAT('Chai', NULL) AS with_concat;
```

| with_bars | with_concat |
|-----------|-------------|
| [NULL] | Chai |

`CONCAT` skips the NULL, so Chai comes back safely.

**3. Positions start at 1, not 0:**

```sql
SELECT SUBSTRING('Masala' FROM 0 FOR 3) AS from_zero, SUBSTRING('Masala' FROM 1 FOR 3) AS from_one;
```

| from_zero | from_one |
|-----------|----------|
| Ma | Mas |

`FROM 0 FOR 3` gives only two letters. Start from 1 to get `Mas`.

## Try it yourself

1. Clean the name `'  samosa  '` (spaces around it) and make it all capitals. Use `TRIM` inside `UPPER`. Guess first, then run it.
2. Show each customer's name in small letters with its length.
3. Make a label like `Masala Chai - Chai` with `CONCAT`.

## Answers

1. The task from the video:

   ```sql
   SELECT UPPER(TRIM('  samosa  ')) AS clean_name;
   ```

   It gives `SAMOSA`.
2. `SELECT LOWER(name), LENGTH(name) FROM customers;` (Asha gives `asha` and 4).
3. `SELECT CONCAT(name, ' - ', category) FROM menu_items;`

## Next

[M06-L02 · Number Functions](../m06-l02-number-functions/)
