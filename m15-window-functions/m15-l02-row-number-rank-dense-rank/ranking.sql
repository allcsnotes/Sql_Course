-- M15-L02 ROW_NUMBER, RANK, DENSE_RANK (chai_corner)
-- Runs on the Chai Corner database (menu_items: 12 items). Run one query at a time.

-- Step 1: number the items from most to least expensive
SELECT name, price,
  ROW_NUMBER() OVER (ORDER BY price DESC) AS rn
FROM menu_items;
-- 12 rows: Paneer Roll 1, Cold Coffee 2 ... Filter Coffee 5, Kulhad Chai 6, Bun Maska 7 ... Cutting Chai 12

-- Step 2: RANK: ties share a number, then it skips
SELECT name, price,
  RANK() OVER (ORDER BY price DESC) AS rnk
FROM menu_items;
-- Filter Coffee 5, Kulhad Chai 5, Bun Maska 7 (6 is skipped)

-- Step 3: DENSE_RANK: ties share a number, no gaps
SELECT name, price,
  DENSE_RANK() OVER (ORDER BY price DESC) AS drnk
FROM menu_items;
-- Filter Coffee 5, Kulhad Chai 5, Bun Maska 6 (no gap)

-- Step 4: all three side by side
SELECT name, price,
  ROW_NUMBER() OVER (ORDER BY price DESC) AS rn,
  RANK()       OVER (ORDER BY price DESC) AS rnk,
  DENSE_RANK() OVER (ORDER BY price DESC) AS drnk
FROM menu_items;
-- 12 rows: the 40 rows are 5/6, 5/5, 5/5; Bun Maska is 7, 7, 6

-- Mistake 2 fixed: top 3, number first in a CTE, then filter
WITH ranked AS (
  SELECT name, price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS rn
  FROM menu_items
)
SELECT * FROM ranked WHERE rn <= 3;
-- 3 rows: Paneer Roll 90 1, Cold Coffee 80 2, Veg Sandwich 70 3

-- Your task: which items are in the top 5 price levels?
WITH ranked AS (
  SELECT name, price,
    DENSE_RANK() OVER (ORDER BY price DESC) AS drnk
  FROM menu_items
)
SELECT * FROM ranked WHERE drnk <= 5;
-- 6 rows: Paneer Roll 1, Cold Coffee 2, Veg Sandwich 3, Maggi 4, Filter Coffee 5, Kulhad Chai 5
