-- M05-L02 · Text: char, varchar, text
-- Run each query on its own (DBeaver: cursor on the line, Ctrl+Enter).

-- Step 1: char(10) is a box with exactly ten places. Short text is padded with spaces.
-- The square brackets from format('[%s]', ...) show the edges.
SELECT format('[%s]', 'Chai'::char(10)) AS char_10_with_padding;
-- [Chai      ]   (Chai, then six spaces)

-- Step 2: varchar(10) keeps only what you type, up to ten letters.
SELECT format('[%s]', 'Chai'::varchar(10)) AS varchar_10_no_padding;
-- [Chai]

-- Step 3: Our menu names use varchar. character varying is its full name.
SELECT name, pg_typeof(name) AS its_type FROM menu_items LIMIT 1;
-- 1 row: Bun Maska, character varying   (the column is varchar(40))

-- Step 4: Changing a value with :: cuts text that is too long, with no warning.
SELECT 'Masala Chai'::varchar(5) AS cut_to_five;
-- Masal

-- Step 5: text has no limit. 'Chai ' (5 letters) repeated 1000 times.
SELECT length(repeat('Chai ', 1000)) AS text_length;
-- 5000

-- Step 6: length counts the letters. The space counts too.
SELECT name, length(name) AS letters FROM menu_items ORDER BY name;
-- 10 rows: Bun Maska 9, Cold Coffee 11, Cutting Chai 12, Filter Coffee 13, Ginger Chai 11,
--          Maggi 5, Masala Chai 11, Samosa 6, Vada Pav 8, Veg Sandwich 12
