-- M19-L03 Backups and restore: pg_dump and pg_restore
-- In the video both the backup and the restore run from DBeaver:
--   Database > Tools > Create new task. DBeaver runs the real pg_dump / pg_restore
--   that came with PostgreSQL, using its saved connection (no password typed).
-- The SQL below runs in DBeaver's SQL editor. The terminal commands are in the README.

-- Step 1: how big is the database?
SELECT pg_size_pretty(pg_database_size('chai_corner')) AS database_size;
-- video: 129 MB

-- Step 2: BACKUP (DBeaver task "PostgreSQL dump", database chai_corner,
--   Complete backup, Format: Custom, file chai_corner.dump in a folder of your choice).
--   The same thing in a terminal (it asks for the password you chose when installing):
--     pg_dump -U postgres -Fc -d chai_corner -f ~/chai_backups/chai_corner.dump
--   video: done in 3.043 s, a 14 MB file (13,992,660 bytes)

-- Step 3: look inside the file (reads only, changes nothing), in a terminal:
--     pg_restore --list ~/chai_backups/chai_corner.dump

-- Step 4: TEST THE RESTORE, first an empty database
CREATE DATABASE chai_restore;

-- Step 5: RESTORE (DBeaver task "PostgreSQL restore", target chai_restore,
--   Format Custom, backup file chai_corner.dump). DBeaver asks you to confirm.
--   The same thing in a terminal:
--     pg_restore -U postgres -d chai_restore ~/chai_backups/chai_corner.dump
--   video: done in about 1.5 s

-- Step 6: count the rows in both (run once connected to each database)
SELECT current_database(),
  (SELECT count(*) FROM menu_items) AS menu_items,
  (SELECT count(*) FROM tune_orders) AS tune_orders;
-- chai_corner : 12 | 1000000
-- chai_restore: 12 | 1000000

-- Step 7: clean up the test copy (run while connected to chai_corner or postgres)
DROP DATABASE chai_restore WITH (FORCE);
