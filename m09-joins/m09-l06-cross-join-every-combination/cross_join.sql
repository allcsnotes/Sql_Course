-- M09-L06 CROSS JOIN: every combination (Chai Corner, fictional data)
-- Needs Chai Corner update 4 (orders, order_items) and update 5 (staff).

-- Step 1: every chai in every cup size (3 x 3 = 9 rows)
SELECT menu_items.name, sizes.size
FROM menu_items
CROSS JOIN (VALUES ('Small', 0), ('Regular', 10), ('Large', 20))
           AS sizes(size, extra)
WHERE menu_items.category = 'Chai'
ORDER BY menu_items.name, sizes.extra;
-- 9 rows: Cutting Chai Small/Regular/Large, Ginger Chai Small/Regular/Large, Masala Chai Small/Regular/Large

-- Step 2: a price list
SELECT menu_items.name, sizes.size,
       menu_items.price + sizes.extra AS price
FROM menu_items
CROSS JOIN (VALUES ('Small', 0), ('Regular', 10), ('Large', 20))
           AS sizes(size, extra)
WHERE menu_items.category = 'Chai'
ORDER BY menu_items.name, sizes.extra;
-- 9 rows: Cutting Chai 20 30 40, Ginger Chai 30 40 50, Masala Chai 30 40 50

-- Step 3: rows multiply: 10 branches x 10 items = 100
SELECT COUNT(*) AS combos FROM branches CROSS JOIN menu_items;
-- 1 row: 100

-- Step 4: careful: 3,000 orders x 5,530 order items = 16,590,000
SELECT COUNT(*) AS combos FROM orders CROSS JOIN order_items;
-- 1 row: 16590000

-- Mistake 1: a comma and no WHERE is a hidden cross join
SELECT COUNT(*) AS combos
FROM branches, menu_items;
-- 1 row: 100

-- Mistake 2: a normal JOIN with no ON. FAILS on purpose.
SELECT branches.city, menu_items.name
FROM branches
JOIN menu_items;
-- SQL Error [42601]: ERROR: syntax error at end of input  Position: 68

-- Mistake 3: a CROSS JOIN with an ON. FAILS on purpose.
SELECT branches.city, menu_items.name
FROM branches
CROSS JOIN menu_items ON menu_items.item_id = branches.branch_id;
-- SQL Error [42601]: ERROR: syntax error at or near "ON"  Position: 75

-- Your task: staff x chai items (answer: 30)
SELECT COUNT(*) AS combos
FROM staff
CROSS JOIN menu_items
WHERE menu_items.category = 'Chai';
-- 1 row: 30
