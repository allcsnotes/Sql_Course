-- M02-L03 · The psql session from the video, in order.
-- Type each line at the postgres=# prompt (or run the file with: psql -U postgres -f session.sql).
-- Lines starting with a backslash are psql commands, not SQL: they need no semicolon.

-- Step 1: the server version, as plain text
SELECT version();
-- 1 row: PostgreSQL 18.7 on ... (the rest names your computer)

-- Step 2: a tiny sum
SELECT 2 + 3;
-- 1 row: ?column? = 5

-- Step 3: the same query split over two lines (the prompt shows postgres-# until the semicolon)
SELECT 2 + 3
;
-- 1 row: 5

-- Step 4: who and where am I?
\conninfo
-- Database postgres, Client User postgres, Server Port 5432

-- Step 5: every database
\l
-- 3 rows: postgres, template0, template1

-- Step 6: tables in this database
\dt
-- Did not find any tables.

-- Step 7: quit
\q
