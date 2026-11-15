-- Chai Corner update 2 (Module 4, Lesson 3): menu items get a category.
-- Chai, Coffee or Snack. Many items share a category, so DISTINCT has repeats to remove.
-- Safe to run more than once.
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS category varchar(20);
UPDATE menu_items SET category = CASE WHEN name LIKE '%Chai' THEN 'Chai' WHEN name LIKE '%Coffee' THEN 'Coffee' ELSE 'Snack' END;
-- Keep the rows stored in item_id order, so SELECT * still lists items 1 to 10.
CLUSTER menu_items USING menu_items_pkey;
