-- Module 11, Lesson 3: Foreign keys and ON DELETE
-- Database: chai_corner (needs the suppliers table from Lesson 1)

-- Step 1: each restock must come from a real supplier
CREATE TABLE restocks (
  restock_id  int PRIMARY KEY,
  supplier_id int NOT NULL REFERENCES suppliers (supplier_id),
  item        varchar(40),
  qty         int
);
-- Updated Rows 0

-- Step 2: two restocks from real suppliers (2 and 1)
INSERT INTO restocks VALUES
  (1, 2, 'milk', 30),
  (2, 1, 'tea leaves', 8);
-- Updated Rows 2

-- Step 3: supplier 9 does not exist, the foreign key stops it
INSERT INTO restocks VALUES (3, 9, 'sugar', 5);
-- ERROR 23503: insert or update on table "restocks" violates foreign key constraint "restocks_supplier_id_fkey"
--              Key (supplier_id)=(9) is not present in table "suppliers".

-- Step 4: remove Pune Dairy? Restock 1 still points to it: blocked
DELETE FROM suppliers WHERE supplier_id = 2;
-- ERROR 23503: update or delete on table "suppliers" violates foreign key constraint "restocks_supplier_id_fkey" on table "restocks"
--              Key (supplier_id)=(2) is still referenced from table "restocks".

-- Step 5: contacts belong to a supplier, delete them with it
CREATE TABLE supplier_contacts (
  contact_id  int PRIMARY KEY,
  supplier_id int REFERENCES suppliers (supplier_id) ON DELETE CASCADE,
  person      varchar(40),
  job         varchar(30)
);
-- Updated Rows 0

-- Step 6: a new supplier, and some contacts (run both together as a script)
INSERT INTO suppliers VALUES
  (4, 'Konkan Spices', 'Ratnagiri', 'spices', '2022-01-10', 4.0);

INSERT INTO supplier_contacts VALUES
  (1, 1, 'Ravi',  'sales'),
  (2, 2, 'Meena', 'delivery'),
  (3, 4, 'Sana',  'sales'),
  (4, 4, 'Imran', 'delivery');
-- Queries 2, Updated Rows 5

-- Step 7: before, four contacts
SELECT * FROM supplier_contacts;
-- 4 rows: 1 Ravi (1), 2 Meena (2), 3 Sana (4), 4 Imran (4)

-- Step 8: Meera stops buying from Konkan Spices
DELETE FROM suppliers WHERE supplier_id = 4;
-- Updated Rows 1

-- Step 9: after, Sana and Imran went with it
SELECT * FROM supplier_contacts;
-- 2 rows: 1 | 1 | Ravi | sales,  2 | 2 | Meena | delivery

-- The three mistakes from the video are in README.md.

-- Your task: delete Nilgiri Tea Co (supplier 1). What happens, and why?
-- (answer in README.md)
