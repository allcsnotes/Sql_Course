-- M19-L01 Users and roles: GRANT, REVOKE and least privilege
-- Run as postgres on the Chai Corner database.
-- The demo role "reporter" has no password and cannot log in; we act as it with SET ROLE.
-- Run one statement at a time.

-- Step 1: a role (a key card) and one grant (one room)
CREATE ROLE reporter;

GRANT SELECT ON menu_items TO reporter;

-- Step 2: check the grant
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'reporter';
-- 1 row: reporter | menu_items | SELECT

-- Step 3: act as reporter
SET ROLE reporter;

SELECT current_user, name, price
FROM menu_items
LIMIT 5;
-- 5 rows: reporter | Bun Maska 35, Cold Coffee 80, Cutting Chai 20, Filter Coffee 40, Ginger Chai 30

-- Step 4: not allowed (price = price changes nothing, even if it were allowed)
UPDATE menu_items
SET price = price
WHERE name = 'Samosa';
-- ERROR: permission denied for table menu_items (SQLSTATE 42501)

-- Step 5: not allowed either, reporter never got this room
SELECT *
FROM orders
LIMIT 5;
-- ERROR: permission denied for table orders (SQLSTATE 42501)

-- Step 6: back to postgres, then take the key back
RESET ROLE;

REVOKE SELECT ON menu_items FROM reporter;

-- Step 7: as reporter again
SET ROLE reporter;

SELECT name, price
FROM menu_items
LIMIT 5;
-- ERROR: permission denied for table menu_items (SQLSTATE 42501)

-- Step 8: back to postgres
RESET ROLE;
SELECT current_user;
-- postgres

-- A real login user is a role WITH LOGIN and a password, for example:
--   CREATE ROLE menu_app WITH LOGIN PASSWORD '...';   (not run in the video)

-- Your task: a dashboard role must read orders, but never change them
--   GRANT SELECT ON orders TO dashboard;
