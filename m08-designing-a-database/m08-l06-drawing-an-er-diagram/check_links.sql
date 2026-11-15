-- M08-L06 Drawing an ER diagram (Chai Corner, fictional data)
-- The video draws the diagram in DBeaver (no SQL). These two queries are an extra
-- way to check the same facts in SQL.

-- Extra 1: the six tables in the public schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
-- 6 rows: branches, customers, menu_items, order_items, orders, sales

-- Extra 2: every line on the diagram is one foreign key (same query as M08-L03)
SELECT conrelid::regclass AS from_table,
       confrelid::regclass AS points_to
FROM pg_constraint
WHERE contype = 'f'
ORDER BY 1, 2;
-- 4 rows: orders -> branches, orders -> customers, order_items -> menu_items, order_items -> orders
-- sales is in neither column: it has no foreign keys, so it has no lines on the diagram.
