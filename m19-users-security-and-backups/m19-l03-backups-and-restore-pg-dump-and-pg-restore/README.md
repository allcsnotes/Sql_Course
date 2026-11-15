# M19-L03 · Backups and Restore: pg_dump and pg_restore

> Video: Module 19, Lesson 3. Watch it first, then follow along here.

## What you'll learn

- What `pg_dump` does (writes the whole database into one file) and what `pg_restore` does (builds it back)
- The two main backup formats: **plain** (a text file of SQL) and **custom** (packed and compressed)
- How to make a backup and a restore in DBeaver (Database > Tools > Create new task), and the same with terminal commands
- How to look inside a backup with `pg_restore --list`
- Why a backup only counts if you have **tested the restore**, into a new database

## Before you start

- Your Chai Corner database from [M02-L04](../../m02-setting-up/m02-l04-loading-the-chai-corner-database/) with every earlier lesson's `setup.sql` run (see [database/README.md](../../database/README.md)).
- DBeaver connected to `chai_corner` as `postgres`. `pg_dump` and `pg_restore` come with PostgreSQL (the video used version 18.7); DBeaver finds them by itself in the PostgreSQL folder.
- A folder for your backups. This README uses `~/chai_backups/` (a folder in your home folder); pick any folder you like, ideally not only on the same disk.
- This lesson creates a test database, `chai_restore`, and drops it again at the end. Your `chai_corner` database is not changed.
- In the video, the backup and the restore run **in DBeaver**, which uses its saved connection, so no password is typed. The terminal commands below do the same; they ask for the password you chose when installing.

## Files in this folder

| File | What it is |
|---|---|
| `backup_restore.sql` | The SQL from the video (size, create, count, drop) and the matching terminal commands as comments |

## Follow along

Someone runs one wrong command, and a table full of orders is gone. With a backup, that is a bad morning. Without one, the data is lost for good.

- `pg_dump` reads your database and writes everything into one file: the tables, the rows, and the functions. That file is your backup. Keep it somewhere safe.
- `pg_restore` reads the file and builds the database again, in an empty database you choose.

| Format | What it is | How you load it back |
|---|---|---|
| Plain | A text file full of SQL you can open and read | `psql` |
| Custom | Packed and compressed | `pg_restore`, and you can even pick just one table |

### 1. How big is the database?

```sql
SELECT pg_size_pretty(pg_database_size('chai_corner')) AS database_size;
```

In the video: `129 MB` (yours depends on which lessons you ran).

### 2. Make a backup in DBeaver

1. Menu **Database**, then **Tools**, then **Create new task**, then **PostgreSQL dump**.
2. Pick the `chai_corner` database.
3. On **Choose objects to export**, tick **Complete backup**, so every table goes in.
4. On **Backup settings**: **Format: Custom**. **Output folder**: your backup folder. **File name pattern**: `chai_corner.dump`.
5. Click **Proceed**.

In the video the notification says the dump task completed in **3.043 s**. The file is about **14 MB** (13,992,660 bytes) for a 129 MB database: it is compressed, and each index is saved as one short command, not as data.

The same backup from a terminal:

```bash
mkdir -p ~/chai_backups
pg_dump -U postgres -Fc -d chai_corner -f ~/chai_backups/chai_corner.dump
```

`-Fc` means custom format, `-d` the database, `-f` the output file.

### 3. Look inside the file

`pg_restore --list` reads the file without changing anything:

```bash
pg_restore --list ~/chai_backups/chai_corner.dump
```

The top of the output in the video:

```text
;
; Archive created at 2026-11-14 19:05:59 IST
;     dbname: chai_corner
;     TOC Entries: 120
;     Compression: gzip
;     Dump Version: 1.16-0
;     Format: CUSTOM
;     Integer: 4 bytes
;     Offset: 8 bytes
;     Dumped from database version: 18.7
;     Dumped by pg_dump version: 18.7
;
;
; Selected TOC Entries:
;
257; 1255 16731 PROCEDURE public add_signup(text) postgres
...
224; 1259 16393 TABLE public menu_items postgres
227; 1259 16421 TABLE public orders postgres
...
4045; 0 16393 TABLE DATA public menu_items postgres
4048; 0 16421 TABLE DATA public orders postgres
...
```

It was dumped from `chai_corner`, in custom format, by pg_dump 18.7. Then come the tables, and the data for each one (`TABLE DATA`): menu items, orders and the rest. The numbers and the date will be different for you.

### 4. Test the restore: an empty database first

A backup only counts if it restores. Never restore over the real database: make a new, empty one.

```sql
CREATE DATABASE chai_restore;
```

### 5. Restore in DBeaver

1. **Database**, **Tools**, **Create new task**, then **PostgreSQL restore**.
2. Target: the `chai_restore` database.
3. On **Restore settings**: **Format: Custom**, **Backup file**: your `chai_corner.dump`.
4. **Proceed**. DBeaver warns you ("It may corrupt your database. Are you sure?"). That is exactly why you restore into a new database: click **Yes**.

In the video it was done in about one and a half seconds. The same restore from a terminal:

```bash
pg_restore -U postgres -d chai_restore ~/chai_backups/chai_corner.dump
```

### 6. Count the rows in both

Run this once connected to `chai_corner`, and once connected to `chai_restore`:

```sql
SELECT current_database(),
  (SELECT count(*) FROM menu_items) AS menu_items,
  (SELECT count(*) FROM tune_orders) AS tune_orders;
```

You should see the same numbers in both:

| current_database | menu_items | tune_orders |
|---|---|---|
| chai_corner | 12 | 1000000 |
| chai_restore | 12 | 1000000 |

12 menu items and a million tune orders, in the original and in the restored copy.

### 7. Clean up the test copy

Connected to `chai_corner` (not to `chai_restore`):

```sql
DROP DATABASE chai_restore WITH (FORCE);
```

`WITH (FORCE)` closes any connection still open to that database first. Keep the backup file.

## Common mistakes

1. **Never testing the restore.** Restore into a test database, and count the rows.
2. **Keeping the only copy on the same computer.** If the disk dies, the backup dies too. Keep a copy somewhere else.
3. **Restoring over the live database.** Restore into a new one first, check it, then switch.

## Try it yourself

1. Someone dropped the `menu_items` table by mistake. You have last night's backup. What do you do? (The video's task.)
2. Make a **plain** backup (`-Fp`) of `chai_corner` into `~/chai_backups/chai_corner.sql` and open it in a text editor. What do you see?
3. Restore only `menu_items` from the custom backup into a new empty database.

## Answers

1. Restore the backup into a **new** database, check it (count the rows), then copy the table back. A custom backup lets `pg_restore` pick just that table with `-t menu_items`.
2. ```bash
   pg_dump -U postgres -Fp -d chai_corner -f ~/chai_backups/chai_corner.sql
   ```

   Plain SQL: `CREATE TABLE` statements, then `COPY ... FROM stdin` blocks with the rows. It is much bigger than the custom file, and you load it back with `psql`.
3. ```sql
   CREATE DATABASE menu_test;
   ```

   ```bash
   pg_restore -U postgres -d menu_test -t menu_items ~/chai_backups/chai_corner.dump
   ```

   `menu_test` now holds one table, `menu_items`, with 12 rows. Drop it afterwards with `DROP DATABASE menu_test;`.

## Next

[M19-L04 · Row-Level Security: Each Branch Sees Only Its Own Data](../m19-l04-row-level-security-each-branch-sees-only-its-own-data/)
