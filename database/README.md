# The Chai Corner database

Every lesson in this course runs on one database, **chai_corner**: a fictional café chain with branches, a menu, customers, orders and staff. It starts small and grows: some lessons add a table, a column or rows. Each of those lessons has a `setup.sql` in its folder.

## Start: load the base database

Follow [M02-L04](../m02-setting-up/m02-l04-loading-the-chai-corner-database/). It creates the database and loads [`chai_corner.sql`](chai_corner.sql): 3 tables (`branches`, `menu_items`, `customers`).

## Catching up to any lesson

Watching the course in order? Run each lesson's `setup.sql` when you reach that lesson (the README says so in **Before you start**).

Jumping ahead? Run every `setup.sql` above your lesson, in this order:

| # | Video | Title | File |
|---|---|---|---|
| 1 | M03-L06 | NULL: the Unknown Value | [m03-your-first-queries/m03-l06-null-the-unknown-value/setup.sql](../m03-your-first-queries/m03-l06-null-the-unknown-value/setup.sql) |
| 2 | M04-L03 | DISTINCT: Removing Repeated Rows | [m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/setup.sql](../m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/setup.sql) |
| 3 | M07-B01 | The Café Sales Report | [m07-summarising-data/m07-b01-the-cafe-sales-report/setup.sql](../m07-summarising-data/m07-b01-the-cafe-sales-report/setup.sql) |
| 4 | M08-L03 | Foreign Keys: Linking Tables Together | [m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/setup.sql](../m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/setup.sql) |
| 5 | M09-L03 | FULL OUTER JOIN: Everything From Both Sides | [m09-joins/m09-l03-full-outer-join-everything-from-both-sides/setup.sql](../m09-joins/m09-l03-full-outer-join-everything-from-both-sides/setup.sql) |
| 6 | M10-B02 | Customer Insights | [m10-subqueries-and-set-operations/m10-b02-customer-insights/setup.sql](../m10-subqueries-and-set-operations/m10-b02-customer-insights/setup.sql) |
| 7 | M11-L01 | CREATE TABLE: Columns and Types | [m11-creating-tables/m11-l01-create-table-columns-and-types/setup.sql](../m11-creating-tables/m11-l01-create-table-columns-and-types/setup.sql) |
| 8 | M11-L02 | Constraints | [m11-creating-tables/m11-l02-constraints/setup.sql](../m11-creating-tables/m11-l02-constraints/setup.sql) |
| 9 | M11-L03 | Foreign Keys and ON DELETE | [m11-creating-tables/m11-l03-foreign-keys-and-on-delete/setup.sql](../m11-creating-tables/m11-l03-foreign-keys-and-on-delete/setup.sql) |
| 10 | M11-L04 | ALTER TABLE | [m11-creating-tables/m11-l04-alter-table/setup.sql](../m11-creating-tables/m11-l04-alter-table/setup.sql) |
| 11 | M12-L01 | INSERT | [m12-changing-data/m12-l01-insert/setup.sql](../m12-changing-data/m12-l01-insert/setup.sql) |
| 12 | M12-L02 | UPDATE Safely | [m12-changing-data/m12-l02-update-safely/setup.sql](../m12-changing-data/m12-l02-update-safely/setup.sql) |
| 13 | M12-L03 | DELETE Safely, and Soft Delete | [m12-changing-data/m12-l03-delete-safely-and-soft-delete/setup.sql](../m12-changing-data/m12-l03-delete-safely-and-soft-delete/setup.sql) |
| 14 | M12-L04 | UPSERT: INSERT ... ON CONFLICT | [m12-changing-data/m12-l04-upsert-insert-on-conflict/setup.sql](../m12-changing-data/m12-l04-upsert-insert-on-conflict/setup.sql) |
| 15 | M12-L05 | Importing and Exporting CSV Files | [m12-changing-data/m12-l05-importing-and-exporting-csv-files/setup.sql](../m12-changing-data/m12-l05-importing-and-exporting-csv-files/setup.sql) |
| 16 | M13-L01 | Transactions: All or Nothing | [m13-transactions/m13-l01-transactions-all-or-nothing/setup.sql](../m13-transactions/m13-l01-transactions-all-or-nothing/setup.sql) |
| 17 | M13-L02 | BEGIN, COMMIT, ROLLBACK, SAVEPOINT | [m13-transactions/m13-l02-begin-commit-rollback-savepoint/setup.sql](../m13-transactions/m13-l02-begin-commit-rollback-savepoint/setup.sql) |
| 18 | M13-L03 | ACID in Plain Words | [m13-transactions/m13-l03-acid-in-plain-words/setup.sql](../m13-transactions/m13-l03-acid-in-plain-words/setup.sql) |
| 19 | M13-B03 | Chai Corner Online Orders | [m13-transactions/m13-b03-chai-corner-online-orders/setup.sql](../m13-transactions/m13-b03-chai-corner-online-orders/setup.sql) |
| 20 | M15-L06 | FIRST_VALUE, LAST_VALUE and NTILE | [m15-window-functions/m15-l06-first-value-last-value-and-ntile/setup.sql](../m15-window-functions/m15-l06-first-value-last-value-and-ntile/setup.sql) |
| 21 | M15-L07 | Top N per Group, and Removing Duplicates | [m15-window-functions/m15-l07-top-n-per-group-and-removing-duplicates/setup.sql](../m15-window-functions/m15-l07-top-n-per-group-and-removing-duplicates/setup.sql) |
| 22 | M16-L01 | Views: Saving a Query as a Virtual Table | [m16-views-functions-and-json/m16-l01-views-saving-a-query-as-a-virtual-table/setup.sql](../m16-views-functions-and-json/m16-l01-views-saving-a-query-as-a-virtual-table/setup.sql) |
| 23 | M16-L02 | Materialized Views: Saving the Result for Speed | [m16-views-functions-and-json/m16-l02-materialized-views-saving-the-result-for-speed/setup.sql](../m16-views-functions-and-json/m16-l02-materialized-views-saving-the-result-for-speed/setup.sql) |
| 24 | M16-L03 | Writing Your Own Functions and Procedures | [m16-views-functions-and-json/m16-l03-writing-your-own-functions-and-procedures/setup.sql](../m16-views-functions-and-json/m16-l03-writing-your-own-functions-and-procedures/setup.sql) |
| 25 | M16-L04 | Triggers: Running Code When Data Changes | [m16-views-functions-and-json/m16-l04-triggers-running-code-when-data-changes/setup.sql](../m16-views-functions-and-json/m16-l04-triggers-running-code-when-data-changes/setup.sql) |
| 26 | M16-L05 | JSON and JSONB: Storing Flexible Data | [m16-views-functions-and-json/m16-l05-json-and-jsonb-storing-flexible-data/setup.sql](../m16-views-functions-and-json/m16-l05-json-and-jsonb-storing-flexible-data/setup.sql) |
| 27 | M16-B04 | The Business Dashboard | [m16-views-functions-and-json/m16-b04-the-business-dashboard/setup.sql](../m16-views-functions-and-json/m16-b04-the-business-dashboard/setup.sql) |
| 28 | M17-L02 | Creating an Index on 100,000 Orders | [m17-indexes/m17-l02-creating-an-index-on-100000-orders/setup.sql](../m17-indexes/m17-l02-creating-an-index-on-100000-orders/setup.sql) |
| 29 | M17-L03 | Multi-Column Indexes: Why Column Order Matters | [m17-indexes/m17-l03-multi-column-indexes-why-column-order-matters/setup.sql](../m17-indexes/m17-l03-multi-column-indexes-why-column-order-matters/setup.sql) |
| 30 | M17-L04 | EXPLAIN and EXPLAIN ANALYZE: Reading a Query Plan | [m17-indexes/m17-l04-explain-and-explain-analyze-reading-a-query-plan/setup.sql](../m17-indexes/m17-l04-explain-and-explain-analyze-reading-a-query-plan/setup.sql) |
| 31 | M17-L05 | When Indexes Hurt: Writes, Unused Indexes, Low-Variety Columns | [m17-indexes/m17-l05-when-indexes-hurt-writes-unused-indexes-low-variety-columns/setup.sql](../m17-indexes/m17-l05-when-indexes-hurt-writes-unused-indexes-low-variety-columns/setup.sql) |
| 32 | M18-L01 | The Usual Slow Patterns: SELECT *, Functions on Columns, Leading % in LIKE | [m18-making-queries-fast/m18-l01-the-usual-slow-patterns-select-star-functions-on-columns-leading-percent-in-like/setup.sql](../m18-making-queries-fast/m18-l01-the-usual-slow-patterns-select-star-functions-on-columns-leading-percent-in-like/setup.sql) |
| 33 | M18-L02 | Faster Paging: Keyset Pagination Instead of a Big OFFSET | [m18-making-queries-fast/m18-l02-faster-paging-keyset-pagination-instead-of-big-offset/setup.sql](../m18-making-queries-fast/m18-l02-faster-paging-keyset-pagination-instead-of-big-offset/setup.sql) |
| 34 | M18-L03 | How the Planner Decides: Statistics, ANALYZE and VACUUM | [m18-making-queries-fast/m18-l03-how-the-planner-decides-statistics-analyze-and-vacuum/setup.sql](../m18-making-queries-fast/m18-l03-how-the-planner-decides-statistics-analyze-and-vacuum/setup.sql) |
| 35 | M18-L04 | A Full Tuning Walkthrough: From 3 Seconds to 1 Millisecond | [m18-making-queries-fast/m18-l04-a-full-tuning-walkthrough-from-3-seconds-to-1-millisecond/setup.sql](../m18-making-queries-fast/m18-l04-a-full-tuning-walkthrough-from-3-seconds-to-1-millisecond/setup.sql) |
| 36 | M19-L01 | Users and Roles: GRANT, REVOKE and Least Privilege | [m19-users-security-and-backups/m19-l01-users-and-roles-grant-and-revoke-least-privilege/setup.sql](../m19-users-security-and-backups/m19-l01-users-and-roles-grant-and-revoke-least-privilege/setup.sql) |
| 37 | M19-L04 | Row-Level Security: Each Branch Sees Only Its Own Data | [m19-users-security-and-backups/m19-l04-row-level-security-each-branch-sees-only-its-own-data/setup.sql](../m19-users-security-and-backups/m19-l04-row-level-security-each-branch-sees-only-its-own-data/setup.sql) |
| 38 | M20-L03 | Migrations: Changing a Live Database Safely | [m20-sql-from-code/m20-l03-migrations-changing-a-live-database-safely/setup.sql](../m20-sql-from-code/m20-l03-migrations-changing-a-live-database-safely/setup.sql) |
| 39 | M21-L01 | Cleaning Messy Data: Duplicates, Extra Spaces, Wrong Formats | [m21-sql-for-data-analysis/m21-l01-cleaning-messy-data-duplicates-extra-spaces-wrong-formats/setup.sql](../m21-sql-for-data-analysis/m21-l01-cleaning-messy-data-duplicates-extra-spaces-wrong-formats/setup.sql) |
| 40 | M21-L02 | Date Reports: Filling Missing Days, Week and Month Buckets | [m21-sql-for-data-analysis/m21-l02-date-reports-filling-missing-days-week-and-month-buckets/setup.sql](../m21-sql-for-data-analysis/m21-l02-date-reports-filling-missing-days-week-and-month-buckets/setup.sql) |
| 41 | M22-L03 | Classic Interview Problems 1: Second Highest Salary, Duplicates, Nth Row | [m22-other-databases-and-interviews/m22-l03-classic-interview-problems-1-second-highest-salary-duplicates-nth-row/setup.sql](../m22-other-databases-and-interviews/m22-l03-classic-interview-problems-1-second-highest-salary-duplicates-nth-row/setup.sql) |
| 42 | M22-L04 | Classic Interview Problems 2: Consecutive Days, Gaps and Islands, Streaks | [m22-other-databases-and-interviews/m22-l04-classic-interview-problems-2-consecutive-days-gaps-and-islands-running-streaks/setup.sql](../m22-other-databases-and-interviews/m22-l04-classic-interview-problems-2-consecutive-days-gaps-and-islands-running-streaks/setup.sql) |
| 43 | M22-L05 | Design Interview: the Database for a Food Delivery App | [m22-other-databases-and-interviews/m22-l05-design-interview-the-database-for-a-food-delivery-app/setup.sql](../m22-other-databases-and-interviews/m22-l05-design-interview-the-database-for-a-food-delivery-app/setup.sql) |
| 44 | M22-B06 | Capstone: Raw CSV to a Final Report | [m22-other-databases-and-interviews/m22-b06-capstone/setup.sql](../m22-other-databases-and-interviews/m22-b06-capstone/setup.sql) |

## Rebuild everything in one go (psql)

From this `database/` folder, in a terminal:

```bash
./rebuild.sh
```

It asks for your PostgreSQL password (the one you chose when installing), drops and recreates `chai_corner`, loads the base file, then runs every `setup.sql` above in order, each from its own folder (so the CSV files the capstone loads are found). It stops at the first error. The script uses `psql`, user `postgres` and `localhost`; change the variables at the top if yours differ.

> [!WARNING]
> `rebuild.sh` deletes your `chai_corner` database first. Anything you added yourself is lost.

## Good to know

- **Big tables use random values** (Module 17 and 18: 100,000 and 1,000,000 rows). The scripts fix the random seed, so you always get the same rows, but they are not the exact rows from the video: counts per customer and timings differ a little.
- **Some files run as a superuser** (M19 creates roles `reporter`, `pune` and `delhi`). Roles belong to the whole server, so running those files twice says "role already exists": that is fine.
- **Files with `VACUUM`** (M18) must not run inside a transaction. `rebuild.sh` runs each file normally, so this is handled.
- **Run once:** the files for M08-L03, M09-L03 and M10-B02 are the exact update files from the videos and add rows; run them only once (the rebuild script starts from an empty database, so it is safe).
