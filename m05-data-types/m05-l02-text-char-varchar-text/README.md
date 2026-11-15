# M05-L02 · Text: char, varchar, text

> Video: Module 5, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- `char(n)` is a box of fixed size: short text is padded with spaces
- `varchar(n)` keeps only what you type, up to a limit (our menu names are `varchar(40)`)
- `text` has no limit, and in PostgreSQL it is just as fast as varchar
- `length` counts the letters, and a space counts too
- Three beginner mistakes: text too long, an apostrophe inside text, and double quotes

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database (the one `INSERT` fails on purpose).

## Files in this folder

| File | What it is |
|------|------------|
| `text_types.sql` | The six queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes and their fixes |

## Follow along

Every name, city and email in a database is text. Masala Chai, Pune and an email address are all text. Pick the wrong text type and your words get padded with spaces, cut short, or rejected.

### 1. char: a box of fixed size

`char(10)` is a box with exactly ten places. Store the word Chai (four letters) and the other six places are filled with blank spaces. The `format('[%s]', ...)` function wraps the value in square brackets so you can see the edges:

```sql
SELECT format('[%s]', 'Chai'::char(10)) AS char_10_with_padding;
```

You should see:

```text
[Chai      ]
```

Chai, then six spaces, then the closing bracket. Today `char` is rarely used, except for codes that always have the same length, like a two-letter country code.

### 2. varchar: a box with a limit

`varchar(10)` also holds up to ten letters, but it keeps only what you type, with no extra spaces:

```sql
SELECT format('[%s]', 'Chai'::varchar(10)) AS varchar_10_no_padding;
```

You should see `[Chai]`. Chai stays just four letters.

Our menu names use this type:

```sql
SELECT name, pg_typeof(name) AS its_type FROM menu_items LIMIT 1;
```

You should see:

| name | its_type |
|------|----------|
| Bun Maska | character varying |

`character varying` is the full name of varchar. The table was made with `varchar(40)`, so a name can have up to forty letters.

But be careful. When you change a value with two colons (`::`), a value that is too long gets cut, with no warning:

```sql
SELECT 'Masala Chai'::varchar(5) AS cut_to_five;
```

You should see `Masal`: only the first five letters.

### 3. text: no limit at all

`text` holds words of any length. Here the word Chai with a space is repeated one thousand times:

```sql
SELECT length(repeat('Chai ', 1000)) AS text_length;
```

You should see `5000`. Five thousand letters, and text is happy.

The `length` function counts the letters:

```sql
SELECT name, length(name) AS letters FROM menu_items ORDER BY name;
```

You should see:

| name | letters |
|------|--------:|
| Bun Maska | 9 |
| Cold Coffee | 11 |
| Cutting Chai | 12 |
| Filter Coffee | 13 |
| Ginger Chai | 11 |
| Maggi | 5 |
| Masala Chai | 11 |
| Samosa | 6 |
| Vada Pav | 8 |
| Veg Sandwich | 12 |

Bun Maska has nine, because the space counts too.

In PostgreSQL, text and varchar are equally fast. Use `text` when there is no real limit. Use `varchar` with a number when there is a rule, like a name of at most forty letters.

| Type | Size | Short text |
|------|------|------------|
| `char(10)` | always 10 | padded with spaces |
| `varchar(10)` | up to 10 | kept as typed |
| `text` | no limit | kept as typed |

## Common mistakes

The queries are in `mistakes.sql`.

**1. Text that is too long.** Put a 48-letter name into a `varchar(40)` column:

```sql
INSERT INTO menu_items (item_id, name, price) VALUES (11, 'Special Kashmiri Kahwa with Saffron and Almonds', 90);
```

```text
SQL Error [22001]: ERROR: value too long for type character varying(40)
```

Nothing is saved. Shorten the text, or make the column bigger. (The price at the end of the line is off screen in the video; any number gives the same error.) Note the difference: an `INSERT` that is too long fails, but `::varchar(5)` cuts silently.

**2. An apostrophe inside text.** In `Asha's Chai`, the apostrophe closes the quotes too early:

```sql
SELECT 'Asha's Chai' AS shop_name;
```

```text
SQL Error [42601]: Unterminated string literal started at position 19 in SQL SELECT 'Asha's Chai' AS shop_name;. Expected  char
```

(`psql` words it as `syntax error at or near "Chai"`.) Write the apostrophe twice and it works:

```sql
SELECT 'Asha''s Chai' AS shop_name;
```

You should see `Asha's Chai`.

**3. Double quotes.** In SQL, double quotes mean a column name:

```sql
SELECT name FROM menu_items WHERE name = "Maggi";
```

```text
SQL Error [42703]: ERROR: column "Maggi" does not exist
```

Text always goes in single quotes: `WHERE name = 'Maggi'`.

## Try it yourself

1. What does `length` give for Chai stored as `char(10)`? Guess first, then run it.
2. Show `Lukas` as a `varchar(3)`.
3. Write a query that shows the text `Priya's order`.

## Answers

1. The task from the video:

   ```sql
   SELECT length('Chai'::char(10)) AS letters_counted;
   ```

   It gives `4`. PostgreSQL ignores the padding spaces of a `char` when it counts.
2. `SELECT 'Lukas'::varchar(3);` gives `Luk` (cut with no warning).
3. `SELECT 'Priya''s order';` (the apostrophe written twice).

## Next

[M05-L03 · Dates and Times](../m05-l03-dates-and-times/)
