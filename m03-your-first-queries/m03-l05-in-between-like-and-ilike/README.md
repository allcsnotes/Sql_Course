# M03-L05 · IN, BETWEEN, LIKE and ILIKE

> Video: Module 3, Lesson 5. Watch it first, then follow along here.

## What you'll learn

- `IN` and `NOT IN`: check a value against a list
- `BETWEEN`: keep values inside a range, both ends included
- `LIKE` with `%` (any letters, or none) and `_` (exactly one letter)
- `ILIKE`: the same as LIKE, but it ignores capitals
- Three mistakes that give no error, just 0 rows

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- A DBeaver SQL editor on `chai_corner`, or psql with `\c chai_corner`.

## Files in this folder

| File | What it is |
|---|---|
| `queries.sql` | The nine queries from the video, in order, with the real results as comments |
| `mistakes.sql` | The three beginner mistakes (each returns 0 rows) |

## Follow along

Last lesson, to find a Samosa, a Maggi or a Vada Pav you wrote `name =` three times, joined with OR. It works, but it is long and easy to get wrong. Here are four shortcuts.

### 1. IN, for a list of values

The long way:

```sql
SELECT name, price FROM menu_items WHERE name = 'Samosa' OR name = 'Maggi' OR name = 'Vada Pav';
```

The short way: `IN`, then the list inside brackets, with commas between the values:

```sql
SELECT name, price FROM menu_items WHERE name IN ('Samosa', 'Maggi', 'Vada Pav');
```

Both give the same three rows:

| name | price |
|---|---|
| Maggi | 60 |
| Samosa | 25 |
| Vada Pav | 30 |

`IN` asks one question: is the value anywhere in this list? Want the opposite? Write `NOT IN`:

```sql
SELECT city FROM branches WHERE city NOT IN ('Pune', 'Mumbai', 'Delhi');
```

Seven branches come back, every city except those three: Bengaluru, Chennai, Hyderabad, Kolkata, Jaipur, Ahmedabad, Kochi.

### 2. BETWEEN, for a range

Last lesson's `price >= 30 AND price <= 40`, said shorter. The small number comes first, then the big number:

```sql
SELECT name, price FROM menu_items WHERE price BETWEEN 30 AND 40;
```

| name | price |
|---|---|
| Bun Maska | 35 |
| Filter Coffee | 40 |
| Ginger Chai | 30 |
| Masala Chai | 30 |
| Vada Pav | 30 |

Filter Coffee costs exactly 40, and the ₹30 items are here too: **BETWEEN includes both ends.**

### 3. LIKE, for patterns in text

Sometimes you only know part of the text: you want every chai. `LIKE` uses a special sign, the percent sign `%`, which means **any letters here, or none at all**.

Anything first, then Chai at the end:

```sql
SELECT name, price FROM menu_items WHERE name LIKE '%Chai';
```

| name | price |
|---|---|
| Cutting Chai | 20 |
| Ginger Chai | 30 |
| Masala Chai | 30 |

Move the `%` to the end and it means **starts with**:

```sql
SELECT name, price FROM menu_items WHERE name LIKE 'C%';
```

| name | price |
|---|---|
| Cold Coffee | 80 |
| Cutting Chai | 20 |

### 4. Exact letters, and ILIKE

The underscore `_` means **exactly one letter**. `'P___'` (P and three underscores) means P plus exactly three letters:

```sql
SELECT city FROM branches WHERE city LIKE 'P___';
```

Only **Pune** comes back.

A catch: LIKE cares about capitals.

```sql
SELECT name, price FROM menu_items WHERE name LIKE '%chai';
```

**0 rows**: the menu writes Chai with a capital C. The fix is `ILIKE`. The I means: ignore capitals.

```sql
SELECT name, price FROM menu_items WHERE name ILIKE '%chai';
```

Three rows again: Cutting Chai, Ginger Chai, Masala Chai.

| Pattern | Matches |
|---|---|
| `'%Chai'` | ends with Chai |
| `'C%'` | starts with C |
| `'%Coffee%'` | has Coffee anywhere |
| `'P___'` | P plus exactly three letters |

## Common mistakes

All three give **no error, but 0 rows**:

- **`BETWEEN 40 AND 30`.** BETWEEN needs the small number first: `BETWEEN 30 AND 40`.
- **Forgetting the percent sign** (`name LIKE 'Chai'`). It looks for a name that is exactly Chai. Write `'%Chai'`.
- **`=` with a percent sign** (`name = '%Chai'`). `=` does not understand `%`. Only LIKE does.

## Try it yourself

1. The video's task: show every item that has the word Coffee anywhere in its name. How many rows come back?
2. Show the branches in Pune, Kochi and Jaipur using IN.
3. Show the customers whose name ends with the letter a.

## Answers

1. ```sql
   SELECT name, price FROM menu_items WHERE name LIKE '%Coffee%';
   ```
   **2 rows**: Cold Coffee 80, Filter Coffee 40. One `%` on each side means "anything before, anything after".
2. ```sql
   SELECT * FROM branches WHERE city IN ('Pune', 'Kochi', 'Jaipur');
   ```
   3 rows: Pune, Jaipur, Kochi.
3. ```sql
   SELECT name FROM customers WHERE name LIKE '%a';
   ```
   **7 rows**: Asha, Priya, Ananya, Isha, Neha, Sara, Tara.

## Next

[M03-L06 · NULL: the Unknown Value](../m03-l06-null-the-unknown-value/)
