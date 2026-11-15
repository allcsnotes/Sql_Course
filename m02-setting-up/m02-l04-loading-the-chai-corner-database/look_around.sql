-- M02-L04 · Loading Chai Corner and taking a first look, in the order the video types it in psql.
-- Start psql in the folder that holds chai_corner.sql, then: psql -U postgres

-- Step 1: make an empty database
CREATE DATABASE chai_corner;
-- CREATE DATABASE

-- Step 2: move into it (the prompt changes from postgres=# to chai_corner=#)
\c chai_corner
-- You are now connected to database "chai_corner" as user "postgres".

-- Step 3: run every line of the file
\i chai_corner.sql
-- CREATE TABLE, INSERT 0 10 (branches), CREATE TABLE, INSERT 0 10 (menu_items), CREATE TABLE, INSERT 0 15 (customers)

-- Step 4: list the tables
\dt
-- 3 rows: branches, customers, menu_items

-- Step 5: describe one table
\d menu_items
-- item_id integer not null, name character varying(40) not null, price integer not null; "menu_items_pkey" PRIMARY KEY, btree (item_id)

-- Step 6: every branch
SELECT * FROM branches;
-- 10 rows: Pune (2019-04-12) ... Kochi (2024-01-29)

-- Step 7: the whole menu
SELECT * FROM menu_items;
-- 10 rows: Bun Maska 35 ... Veg Sandwich 70
