# M05-L04 · Boolean, UUID and JSON

> Video: Module 5, Lesson 4. Watch it first, then follow along here.

## What you'll learn

- `boolean` is true or false, and every comparison gives one
- `uuid` is a long random ID that never repeats, made with `gen_random_uuid()`
- `jsonb` stores flexible data (names and values in curly brackets), and `->>` reads one value out
- Three beginner mistakes: unclear boolean words, a label that is not a UUID, and JSON names without double quotes

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` (or `psql`). This lesson changes nothing in the database.

## Files in this folder

| File | What it is |
|------|------------|
| `boolean_uuid_json.sql` | The five queries from the video, in order, with their real results |
| `mistakes.sql` | The three beginner mistakes |

## Follow along

Is this item cheap, yes or no? Which order is this, out of millions? And what if every item has different extra details? Three more types answer these: **boolean** for yes or no, **UUID** for an ID that never repeats, and **JSON** for flexible data.

### 1. Boolean: true or false

A boolean has only two values, true or false. Every comparison gives a boolean:

```sql
SELECT 5 > 3 AS is_5_bigger_than_3, 5 < 3 AS is_5_smaller_than_3;
```

You should see:

| is_5_bigger_than_3 | is_5_smaller_than_3 |
|--------------------|---------------------|
| [v] (true) | [ ] (false) |

DBeaver shows true as a ticked box and false as an empty box (`psql` prints `t` and `f`).

You can show a comparison as a column:

```sql
SELECT name, price, price < 30 AS is_cheap FROM menu_items ORDER BY price;
```

You should see:

| name | price | is_cheap |
|------|------:|----------|
| Cutting Chai | 20 | [v] |
| Samosa | 25 | [v] |
| Masala Chai | 30 | [ ] |
| Vada Pav | 30 | [ ] |
| Ginger Chai | 30 | [ ] |
| Bun Maska | 35 | [ ] |
| Filter Coffee | 40 | [ ] |
| Maggi | 60 | [ ] |
| Veg Sandwich | 70 | [ ] |
| Cold Coffee | 80 | [ ] |

Only Cutting Chai and Samosa get a tick. (The three items at ₹30 may come in a different order for you, because `ORDER BY price` does not say how to order ties.)

### 2. UUID: an ID that never repeats

A **UUID** is a long random code of letters and numbers, split by dashes. `gen_random_uuid()` makes a new one every time you call it:

```sql
SELECT gen_random_uuid() AS id_one, gen_random_uuid() AS id_two;
```

In the video:

| id_one | id_two |
|--------|--------|
| 5ba77508-84b9-4a4d-82e6-7f489fe7b1e7 | 7cc80b64-c5fd-4287-95b8-6a51ef3b560e |

Yours will be different, every time. The two are completely different. The chance of two ever matching is so tiny that we treat every UUID as unique. Many apps use them as order IDs.

### 3. JSON: flexible data

**JSON** stores data as names and values inside curly brackets. Here a menu item has a name, a price and a list of sizes. The type `jsonb` stores it in a fast, checked form:

```sql
SELECT '{"name": "Masala Chai", "price": 30, "sizes": ["small", "large"]}'::jsonb AS menu_item;
```

You should see:

```text
{"name": "Masala Chai", "price": 30, "sizes": ["small", "large"]}
```

To read one value out, write an arrow with two greater-than signs (`->>`), then the name:

```sql
SELECT '{"name": "Masala Chai", "price": 30}'::jsonb ->> 'name' AS item_name;
```

You should see `Masala Chai`.

JSON is great for extra details that change a lot. For normal data, columns are still best. Module 16 goes deeper into JSON.

## Common mistakes

The queries are in `mistakes.sql`.

**1. A boolean only takes clear values,** like true, false, yes or no:

```sql
SELECT 'maybe'::boolean AS is_open;
```

```text
SQL Error [22P02]: ERROR: invalid input syntax for type boolean: "maybe"
```

**2. A UUID must follow its exact pattern:**

```sql
SELECT 'order-42'::uuid AS order_id;
```

```text
SQL Error [22P02]: ERROR: invalid input syntax for type uuid: "order-42"
```

Let `gen_random_uuid()` make them for you.

**3. In JSON, every name needs double quotes:**

```sql
SELECT '{name: "Masala Chai"}'::jsonb AS menu_item;
```

```text
SQL Error [22P02]: ERROR: invalid input syntax for type json
  Detail: Token "name" is invalid.
```

Put double quotes around the name, inside the single quotes: `'{"name": "Masala Chai"}'`.

## Try it yourself

1. From a Samosa written as JSON, read the price. Do you get back a number, or text? Guess first, then run it.
2. Show every menu item with a column `is_coffee` that is true when the category is `'Coffee'`.
3. Read the `price` of Masala Chai from the JSON in step 3.

## Answers

1. The task from the video:

   ```sql
   SELECT '{"name": "Samosa", "price": 25}'::jsonb ->> 'price' AS item_price;
   ```

   You get `25`, but as **text**: DBeaver shows the column with the A-Z text icon and the value on the left. `->>` always gives back text. The next lesson casts it to a number.
2. `SELECT name, category = 'Coffee' AS is_coffee FROM menu_items;` (Cold Coffee and Filter Coffee get a tick).
3. `SELECT '{"name": "Masala Chai", "price": 30}'::jsonb ->> 'price';` gives `30` (text).

## Next

[M05-L05 · CAST and ::](../m05-l05-cast-and-colons/)
