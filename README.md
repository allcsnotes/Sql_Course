# SQL Course: From Zero to Job Ready, with PostgreSQL

The companion repo for the **AllCsVideos SQL course**: 22 modules, 114 videos (108 lessons and 6 builds), one running story: **Chai Corner**, a fictional café chain with branches, a menu, customers, orders and staff. You start with your first `SELECT` and finish with window functions, indexes, query tuning, security, SQL from Python, data analysis and interview practice.

Every video has a folder here with its SQL files and a step-by-step guide, so you can repeat on your own laptop exactly what the video does.

---

## How to use this repo

1. **Clone it once:**
   ```bash
   git clone https://github.com/allcsnotes/Sql_Course.git
   cd Sql_Course
   ```
2. **Set up PostgreSQL 18 and DBeaver** with [M02-L01](m02-setting-up/m02-l01-installing-postgresql-18-on-windows-and-mac/) and [M02-L02](m02-setting-up/m02-l02-installing-dbeaver-and-connecting-to-your-database/).
3. **Load the Chai Corner database** with [M02-L04](m02-setting-up/m02-l04-loading-the-chai-corner-database/). As the course goes on, some lessons add tables or rows: each of those lessons has a `setup.sql`. The full list, in order, is in [database/README.md](database/README.md).
4. **Watch a lecture**, then open its folder (see the [lesson index](#lesson-index) below, or the **Resources** link on the lecture page) and follow its `README.md` top to bottom.
5. **Get updates** later with `git pull`.

Every lesson README has the same parts:

| Part | What it gives you |
|---|---|
| What you'll learn | the goal of the lecture in a few bullets |
| Before you start | what your database needs, and which earlier lesson to finish first |
| Files in this folder | what each file is for |
| Follow along | every query, in the order the video runs it, with the result you should see |
| Common mistakes | the traps the video warns about |
| Try it yourself | small tasks, with answers at the bottom |
| Next | a link to the next lecture |

---

## What you need

| Modules | Install | Notes |
|---|---|---|
| **M01-M19, M21-M22** | PostgreSQL **18** and **DBeaver** Community (both free) | M02 walks through both on Windows and Mac |
| **M20** | Python 3 (the video uses 3.15) with `psycopg` 3.3.9 and `SQLAlchemy` 2.1.8 | Versions are pinned in each lesson's `requirements.txt` |
| **M22-L01** | Optional: MySQL 8.4 and SQLite | To see what changes between databases |
| **M22-L02** | Optional: a free Google account | BigQuery sandbox, no card needed |

**Your numbers can differ a little.** Timings (`Execution Time: 0.519 ms`) depend on your laptop, and a few big tables are made with random values. Row counts and query results match the videos.

---

## Safety first

- **Your PostgreSQL password is the one you choose** when you install. It is never stored in this repo. Never paste a real password into a shared file.
- Demo roles and passwords in the security lessons are fake and labelled "demo value".
- Lessons that delete or change data say so first, and show how to undo it.

---

## Resources

- [SQL cheat sheet (PDF)](resources/SQL_Cheat_Sheet.pdf): the commands from the course in one printable PDF.

---

## Repo layout

Each module has a folder (`m09-joins/`); each video has a folder named after it (`m09-l01-inner-join-pairing-matching-rows/`). Builds (B01-B06) sit at the end of the module they follow. [`database/`](database/README.md) holds the base Chai Corner database and the order of every `setup.sql`.

---

## Lesson index

**M01 · Welcome to Databases** · folder [`m01-welcome-to-databases/`](m01-welcome-to-databases/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | What Data Is, and Why Spreadsheets Stop Working | Lesson | [m01-l01-what-data-is-and-why-spreadsheets-stop-working](m01-welcome-to-databases/m01-l01-what-data-is-and-why-spreadsheets-stop-working/) |
| L02 | What a Database Is | Lesson | [m01-l02-what-a-database-is](m01-welcome-to-databases/m01-l02-what-a-database-is/) |
| L03 | What SQL Is and What Happens When You Run a Query | Lesson | [m01-l03-what-sql-is-and-what-happens-when-you-run-a-query](m01-welcome-to-databases/m01-l03-what-sql-is-and-what-happens-when-you-run-a-query/) |
| L04 | One Language, Many Databases | Lesson | [m01-l04-one-language-many-databases](m01-welcome-to-databases/m01-l04-one-language-many-databases/) |
| L05 | The Course Map and the Chai Corner Database | Lesson | [m01-l05-the-course-map-and-the-chai-corner-database](m01-welcome-to-databases/m01-l05-the-course-map-and-the-chai-corner-database/) |

**M02 · Setting Up** · folder [`m02-setting-up/`](m02-setting-up/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Installing PostgreSQL 18 on Windows and Mac | Lesson | [m02-l01-installing-postgresql-18-on-windows-and-mac](m02-setting-up/m02-l01-installing-postgresql-18-on-windows-and-mac/) |
| L02 | Installing DBeaver and Connecting to Your Database | Lesson | [m02-l02-installing-dbeaver-and-connecting-to-your-database](m02-setting-up/m02-l02-installing-dbeaver-and-connecting-to-your-database/) |
| L03 | psql: the Database in a Terminal | Lesson | [m02-l03-psql-the-database-in-a-terminal](m02-setting-up/m02-l03-psql-the-database-in-a-terminal/) |
| L04 | Loading the Chai Corner Database | Lesson | [m02-l04-loading-the-chai-corner-database](m02-setting-up/m02-l04-loading-the-chai-corner-database/) |

**M03 · Your First Queries** · folder [`m03-your-first-queries/`](m03-your-first-queries/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | SELECT and FROM: Reading a Table | Lesson | [m03-l01-select-and-from-reading-a-table](m03-your-first-queries/m03-l01-select-and-from-reading-a-table/) |
| L02 | Choosing Columns, Maths and AS | Lesson | [m03-l02-choosing-columns-maths-and-as](m03-your-first-queries/m03-l02-choosing-columns-maths-and-as/) |
| L03 | WHERE: Keeping Only the Rows You Want | Lesson | [m03-l03-where-keeping-only-the-rows-you-want](m03-your-first-queries/m03-l03-where-keeping-only-the-rows-you-want/) |
| L04 | AND, OR, NOT and Brackets | Lesson | [m03-l04-and-or-not-and-brackets](m03-your-first-queries/m03-l04-and-or-not-and-brackets/) |
| L05 | IN, BETWEEN, LIKE and ILIKE | Lesson | [m03-l05-in-between-like-and-ilike](m03-your-first-queries/m03-l05-in-between-like-and-ilike/) |
| L06 | NULL: the Unknown Value | Lesson | [m03-l06-null-the-unknown-value](m03-your-first-queries/m03-l06-null-the-unknown-value/) |

**M04 · Sorting and Limiting** · folder [`m04-sorting-and-limiting/`](m04-sorting-and-limiting/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | ORDER BY: Sorting Rows | Lesson | [m04-l01-order-by-sorting-rows](m04-sorting-and-limiting/m04-l01-order-by-sorting-rows/) |
| L02 | LIMIT and OFFSET | Lesson | [m04-l02-limit-and-offset](m04-sorting-and-limiting/m04-l02-limit-and-offset/) |
| L03 | DISTINCT: Removing Repeated Rows | Lesson | [m04-l03-distinct-removing-repeated-rows](m04-sorting-and-limiting/m04-l03-distinct-removing-repeated-rows/) |

**M05 · Data Types** · folder [`m05-data-types/`](m05-data-types/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Numbers: Integer, Numeric, Float | Lesson | [m05-l01-numbers-integer-numeric-float](m05-data-types/m05-l01-numbers-integer-numeric-float/) |
| L02 | Text: char, varchar, text | Lesson | [m05-l02-text-char-varchar-text](m05-data-types/m05-l02-text-char-varchar-text/) |
| L03 | Dates and Times | Lesson | [m05-l03-dates-and-times](m05-data-types/m05-l03-dates-and-times/) |
| L04 | Boolean, UUID and JSON | Lesson | [m05-l04-boolean-uuid-and-json](m05-data-types/m05-l04-boolean-uuid-and-json/) |
| L05 | CAST and :: | Lesson | [m05-l05-cast-and-colons](m05-data-types/m05-l05-cast-and-colons/) |

**M06 · Functions** · folder [`m06-functions/`](m06-functions/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Text Functions | Lesson | [m06-l01-text-functions](m06-functions/m06-l01-text-functions/) |
| L02 | Number Functions | Lesson | [m06-l02-number-functions](m06-functions/m06-l02-number-functions/) |
| L03 | Date Functions | Lesson | [m06-l03-date-functions](m06-functions/m06-l03-date-functions/) |
| L04 | CASE WHEN | Lesson | [m06-l04-case-when](m06-functions/m06-l04-case-when/) |
| L05 | COALESCE and NULLIF | Lesson | [m06-l05-coalesce-and-nullif](m06-functions/m06-l05-coalesce-and-nullif/) |

**M07 · Summarising Data** · folder [`m07-summarising-data/`](m07-summarising-data/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | COUNT, SUM, AVG, MIN, MAX | Lesson | [m07-l01-count-sum-avg-min-max](m07-summarising-data/m07-l01-count-sum-avg-min-max/) |
| L02 | COUNT(*), COUNT(column) and COUNT(DISTINCT) | Lesson | [m07-l02-count-star-column-and-distinct](m07-summarising-data/m07-l02-count-star-column-and-distinct/) |
| L03 | GROUP BY: Making Piles | Lesson | [m07-l03-group-by-making-piles](m07-summarising-data/m07-l03-group-by-making-piles/) |
| L04 | HAVING vs WHERE | Lesson | [m07-l04-having-vs-where](m07-summarising-data/m07-l04-having-vs-where/) |
| L05 | The Order SQL Runs Your Query | Lesson | [m07-l05-the-order-sql-runs-your-query](m07-summarising-data/m07-l05-the-order-sql-runs-your-query/) |
| L06 | FILTER: Many Counts in One Query | Lesson | [m07-l06-filter-many-counts-in-one-query](m07-summarising-data/m07-l06-filter-many-counts-in-one-query/) |
| B01 | The Café Sales Report | Build | [m07-b01-the-cafe-sales-report](m07-summarising-data/m07-b01-the-cafe-sales-report/) |

**M08 · Designing a Database** · folder [`m08-designing-a-database/`](m08-designing-a-database/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Why We Split Data into Many Tables | Lesson | [m08-l01-why-we-split-data-into-many-tables](m08-designing-a-database/m08-l01-why-we-split-data-into-many-tables/) |
| L02 | Primary Keys: One Unique ID per Row | Lesson | [m08-l02-primary-keys-one-unique-id-per-row](m08-designing-a-database/m08-l02-primary-keys-one-unique-id-per-row/) |
| L03 | Foreign Keys: Linking Tables Together | Lesson | [m08-l03-foreign-keys-linking-tables-together](m08-designing-a-database/m08-l03-foreign-keys-linking-tables-together/) |
| L04 | Relationships: One to One, One to Many, Many to Many | Lesson | [m08-l04-relationships-one-to-one-one-to-many-many-to-many](m08-designing-a-database/m08-l04-relationships-one-to-one-one-to-many-many-to-many/) |
| L05 | Normalisation: 1NF, 2NF, 3NF | Lesson | [m08-l05-normalisation-1nf-2nf-3nf](m08-designing-a-database/m08-l05-normalisation-1nf-2nf-3nf/) |
| L06 | Drawing an ER Diagram | Lesson | [m08-l06-drawing-an-er-diagram](m08-designing-a-database/m08-l06-drawing-an-er-diagram/) |

**M09 · JOINs** · folder [`m09-joins/`](m09-joins/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | INNER JOIN: Pairing Matching Rows | Lesson | [m09-l01-inner-join-pairing-matching-rows](m09-joins/m09-l01-inner-join-pairing-matching-rows/) |
| L02 | LEFT JOIN and RIGHT JOIN: Keeping Rows With No Match | Lesson | [m09-l02-left-join-and-right-join-keeping-rows-with-no-match](m09-joins/m09-l02-left-join-and-right-join-keeping-rows-with-no-match/) |
| L03 | FULL OUTER JOIN: Everything From Both Sides | Lesson | [m09-l03-full-outer-join-everything-from-both-sides](m09-joins/m09-l03-full-outer-join-everything-from-both-sides/) |
| L04 | Joining Three or More Tables | Lesson | [m09-l04-joining-three-or-more-tables](m09-joins/m09-l04-joining-three-or-more-tables/) |
| L05 | Self Join: a Table Joined to Itself | Lesson | [m09-l05-self-join-a-table-joined-to-itself](m09-joins/m09-l05-self-join-a-table-joined-to-itself/) |
| L06 | CROSS JOIN: Every Combination | Lesson | [m09-l06-cross-join-every-combination](m09-joins/m09-l06-cross-join-every-combination/) |
| L07 | JOIN Mistakes: Duplicates, Wrong Totals, Forgotten ON | Lesson | [m09-l07-join-mistakes-duplicates-wrong-totals-forgotten-on](m09-joins/m09-l07-join-mistakes-duplicates-wrong-totals-forgotten-on/) |

**M10 · Subqueries and Set Operations** · folder [`m10-subqueries-and-set-operations/`](m10-subqueries-and-set-operations/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | A Query Inside a Query: Subquery in WHERE | Lesson | [m10-l01-a-query-inside-a-query-subquery-in-where](m10-subqueries-and-set-operations/m10-l01-a-query-inside-a-query-subquery-in-where/) |
| L02 | IN, EXISTS, NOT EXISTS and the NOT IN + NULL Trap | Lesson | [m10-l02-in-exists-not-exists-and-the-not-in-null-trap](m10-subqueries-and-set-operations/m10-l02-in-exists-not-exists-and-the-not-in-null-trap/) |
| L03 | Subqueries in SELECT and FROM: Derived Tables | Lesson | [m10-l03-subqueries-in-select-and-from-derived-tables](m10-subqueries-and-set-operations/m10-l03-subqueries-in-select-and-from-derived-tables/) |
| L04 | Correlated Subqueries: Once for Every Row | Lesson | [m10-l04-correlated-subqueries-once-for-every-row](m10-subqueries-and-set-operations/m10-l04-correlated-subqueries-once-for-every-row/) |
| L05 | UNION, INTERSECT and EXCEPT | Lesson | [m10-l05-union-intersect-and-except](m10-subqueries-and-set-operations/m10-l05-union-intersect-and-except/) |
| B02 | Customer Insights | Build | [m10-b02-customer-insights](m10-subqueries-and-set-operations/m10-b02-customer-insights/) |

**M11 · Creating Tables** · folder [`m11-creating-tables/`](m11-creating-tables/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | CREATE TABLE: Columns and Types | Lesson | [m11-l01-create-table-columns-and-types](m11-creating-tables/m11-l01-create-table-columns-and-types/) |
| L02 | Constraints | Lesson | [m11-l02-constraints](m11-creating-tables/m11-l02-constraints/) |
| L03 | Foreign Keys and ON DELETE | Lesson | [m11-l03-foreign-keys-and-on-delete](m11-creating-tables/m11-l03-foreign-keys-and-on-delete/) |
| L04 | ALTER TABLE | Lesson | [m11-l04-alter-table](m11-creating-tables/m11-l04-alter-table/) |
| L05 | DROP, TRUNCATE and DELETE | Lesson | [m11-l05-drop-truncate-and-delete](m11-creating-tables/m11-l05-drop-truncate-and-delete/) |

**M12 · Changing Data** · folder [`m12-changing-data/`](m12-changing-data/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | INSERT | Lesson | [m12-l01-insert](m12-changing-data/m12-l01-insert/) |
| L02 | UPDATE Safely | Lesson | [m12-l02-update-safely](m12-changing-data/m12-l02-update-safely/) |
| L03 | DELETE Safely, and Soft Delete | Lesson | [m12-l03-delete-safely-and-soft-delete](m12-changing-data/m12-l03-delete-safely-and-soft-delete/) |
| L04 | UPSERT: INSERT ... ON CONFLICT | Lesson | [m12-l04-upsert-insert-on-conflict](m12-changing-data/m12-l04-upsert-insert-on-conflict/) |
| L05 | Importing and Exporting CSV Files | Lesson | [m12-l05-importing-and-exporting-csv-files](m12-changing-data/m12-l05-importing-and-exporting-csv-files/) |

**M13 · Transactions** · folder [`m13-transactions/`](m13-transactions/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Transactions: All or Nothing | Lesson | [m13-l01-transactions-all-or-nothing](m13-transactions/m13-l01-transactions-all-or-nothing/) |
| L02 | BEGIN, COMMIT, ROLLBACK, SAVEPOINT | Lesson | [m13-l02-begin-commit-rollback-savepoint](m13-transactions/m13-l02-begin-commit-rollback-savepoint/) |
| L03 | ACID in Plain Words | Lesson | [m13-l03-acid-in-plain-words](m13-transactions/m13-l03-acid-in-plain-words/) |
| L04 | Isolation Levels, Locks and Deadlocks | Lesson | [m13-l04-isolation-levels-locks-and-deadlocks](m13-transactions/m13-l04-isolation-levels-locks-and-deadlocks/) |
| B03 | Chai Corner Online Orders | Build | [m13-b03-chai-corner-online-orders](m13-transactions/m13-b03-chai-corner-online-orders/) |

**M14 · CTEs** · folder [`m14-ctes/`](m14-ctes/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | WITH: Naming a Step of Your Query | Lesson | [m14-l01-with-naming-a-step-of-your-query](m14-ctes/m14-l01-with-naming-a-step-of-your-query/) |
| L02 | Many CTEs: Small, Readable Steps | Lesson | [m14-l02-many-ctes-small-readable-steps](m14-ctes/m14-l02-many-ctes-small-readable-steps/) |
| L03 | Recursive CTEs: Trees and Chains | Lesson | [m14-l03-recursive-ctes-trees-and-chains](m14-ctes/m14-l03-recursive-ctes-trees-and-chains/) |

**M15 · Window Functions** · folder [`m15-window-functions/`](m15-window-functions/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | What a Window Is | Lesson | [m15-l01-what-a-window-is](m15-window-functions/m15-l01-what-a-window-is/) |
| L02 | ROW_NUMBER, RANK, DENSE_RANK | Lesson | [m15-l02-row-number-rank-dense-rank](m15-window-functions/m15-l02-row-number-rank-dense-rank/) |
| L03 | PARTITION BY | Lesson | [m15-l03-partition-by](m15-window-functions/m15-l03-partition-by/) |
| L04 | Running Totals and Moving Averages | Lesson | [m15-l04-running-totals-and-moving-averages](m15-window-functions/m15-l04-running-totals-and-moving-averages/) |
| L05 | LAG and LEAD | Lesson | [m15-l05-lag-and-lead](m15-window-functions/m15-l05-lag-and-lead/) |
| L06 | FIRST_VALUE, LAST_VALUE and NTILE | Lesson | [m15-l06-first-value-last-value-and-ntile](m15-window-functions/m15-l06-first-value-last-value-and-ntile/) |
| L07 | Top N per Group, and Removing Duplicates | Lesson | [m15-l07-top-n-per-group-and-removing-duplicates](m15-window-functions/m15-l07-top-n-per-group-and-removing-duplicates/) |

**M16 · Views, Functions and JSON** · folder [`m16-views-functions-and-json/`](m16-views-functions-and-json/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Views: Saving a Query as a Virtual Table | Lesson | [m16-l01-views-saving-a-query-as-a-virtual-table](m16-views-functions-and-json/m16-l01-views-saving-a-query-as-a-virtual-table/) |
| L02 | Materialized Views: Saving the Result for Speed | Lesson | [m16-l02-materialized-views-saving-the-result-for-speed](m16-views-functions-and-json/m16-l02-materialized-views-saving-the-result-for-speed/) |
| L03 | Writing Your Own Functions and Procedures | Lesson | [m16-l03-writing-your-own-functions-and-procedures](m16-views-functions-and-json/m16-l03-writing-your-own-functions-and-procedures/) |
| L04 | Triggers: Running Code When Data Changes | Lesson | [m16-l04-triggers-running-code-when-data-changes](m16-views-functions-and-json/m16-l04-triggers-running-code-when-data-changes/) |
| L05 | JSON and JSONB: Storing Flexible Data | Lesson | [m16-l05-json-and-jsonb-storing-flexible-data](m16-views-functions-and-json/m16-l05-json-and-jsonb-storing-flexible-data/) |
| B04 | The Business Dashboard | Build | [m16-b04-the-business-dashboard](m16-views-functions-and-json/m16-b04-the-business-dashboard/) |

**M17 · Indexes** · folder [`m17-indexes/`](m17-indexes/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Full Scan vs Index: How a Database Finds a Row | Lesson | [m17-l01-full-scan-vs-index-how-a-database-finds-a-row](m17-indexes/m17-l01-full-scan-vs-index-how-a-database-finds-a-row/) |
| L02 | Creating an Index on 100,000 Orders | Lesson | [m17-l02-creating-an-index-on-100000-orders](m17-indexes/m17-l02-creating-an-index-on-100000-orders/) |
| L03 | Multi-Column Indexes: Why Column Order Matters | Lesson | [m17-l03-multi-column-indexes-why-column-order-matters](m17-indexes/m17-l03-multi-column-indexes-why-column-order-matters/) |
| L04 | EXPLAIN and EXPLAIN ANALYZE: Reading a Query Plan | Lesson | [m17-l04-explain-and-explain-analyze-reading-a-query-plan](m17-indexes/m17-l04-explain-and-explain-analyze-reading-a-query-plan/) |
| L05 | When Indexes Hurt: Writes, Unused Indexes, Low-Variety Columns | Lesson | [m17-l05-when-indexes-hurt-writes-unused-indexes-low-variety-columns](m17-indexes/m17-l05-when-indexes-hurt-writes-unused-indexes-low-variety-columns/) |

**M18 · Making Queries Fast** · folder [`m18-making-queries-fast/`](m18-making-queries-fast/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | The Usual Slow Patterns: SELECT *, Functions on Columns, Leading % in LIKE | Lesson | [m18-l01-the-usual-slow-patterns-select-star-functions-on-columns-leading-percent-in-like](m18-making-queries-fast/m18-l01-the-usual-slow-patterns-select-star-functions-on-columns-leading-percent-in-like/) |
| L02 | Faster Paging: Keyset Pagination Instead of a Big OFFSET | Lesson | [m18-l02-faster-paging-keyset-pagination-instead-of-big-offset](m18-making-queries-fast/m18-l02-faster-paging-keyset-pagination-instead-of-big-offset/) |
| L03 | How the Planner Decides: Statistics, ANALYZE and VACUUM | Lesson | [m18-l03-how-the-planner-decides-statistics-analyze-and-vacuum](m18-making-queries-fast/m18-l03-how-the-planner-decides-statistics-analyze-and-vacuum/) |
| L04 | A Full Tuning Walkthrough: From 3 Seconds to 1 Millisecond | Lesson | [m18-l04-a-full-tuning-walkthrough-from-3-seconds-to-1-millisecond](m18-making-queries-fast/m18-l04-a-full-tuning-walkthrough-from-3-seconds-to-1-millisecond/) |

**M19 · Users, Security and Backups** · folder [`m19-users-security-and-backups/`](m19-users-security-and-backups/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Users and Roles: GRANT, REVOKE and Least Privilege | Lesson | [m19-l01-users-and-roles-grant-and-revoke-least-privilege](m19-users-security-and-backups/m19-l01-users-and-roles-grant-and-revoke-least-privilege/) |
| L02 | SQL Injection, and How Parameterised Queries Stop It | Lesson | [m19-l02-sql-injection-and-how-parameterised-queries-stop-it](m19-users-security-and-backups/m19-l02-sql-injection-and-how-parameterised-queries-stop-it/) |
| L03 | Backups and Restore: pg_dump and pg_restore | Lesson | [m19-l03-backups-and-restore-pg-dump-and-pg-restore](m19-users-security-and-backups/m19-l03-backups-and-restore-pg-dump-and-pg-restore/) |
| L04 | Row-Level Security: Each Branch Sees Only Its Own Data | Lesson | [m19-l04-row-level-security-each-branch-sees-only-its-own-data](m19-users-security-and-backups/m19-l04-row-level-security-each-branch-sees-only-its-own-data/) |

**M20 · SQL from Code** · folder [`m20-sql-from-code/`](m20-sql-from-code/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Connecting from Python: psycopg and Safe Queries | Lesson | [m20-l01-connecting-from-python-psycopg-and-running-safe-queries](m20-sql-from-code/m20-l01-connecting-from-python-psycopg-and-running-safe-queries/) |
| L02 | What an ORM Is, and When Raw SQL Is Better | Lesson | [m20-l02-what-an-orm-is-and-when-raw-sql-is-better](m20-sql-from-code/m20-l02-what-an-orm-is-and-when-raw-sql-is-better/) |
| L03 | Migrations: Changing a Live Database Safely | Lesson | [m20-l03-migrations-changing-a-live-database-safely](m20-sql-from-code/m20-l03-migrations-changing-a-live-database-safely/) |

**M21 · SQL for Data Analysis** · folder [`m21-sql-for-data-analysis/`](m21-sql-for-data-analysis/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | Cleaning Messy Data: Duplicates, Extra Spaces, Wrong Formats | Lesson | [m21-l01-cleaning-messy-data-duplicates-extra-spaces-wrong-formats](m21-sql-for-data-analysis/m21-l01-cleaning-messy-data-duplicates-extra-spaces-wrong-formats/) |
| L02 | Date Reports: Filling Missing Days, Week and Month Buckets | Lesson | [m21-l02-date-reports-filling-missing-days-week-and-month-buckets](m21-sql-for-data-analysis/m21-l02-date-reports-filling-missing-days-week-and-month-buckets/) |
| L03 | Pivoting Rows into Columns | Lesson | [m21-l03-pivoting-rows-into-columns](m21-sql-for-data-analysis/m21-l03-pivoting-rows-into-columns/) |
| L04 | From SQL to a Chart: Exporting to Google Sheets | Lesson | [m21-l04-from-sql-to-a-chart-exporting-to-google-sheets](m21-sql-for-data-analysis/m21-l04-from-sql-to-a-chart-exporting-to-google-sheets/) |

**M22 · Other Databases and Interviews** · folder [`m22-other-databases-and-interviews/`](m22-other-databases-and-interviews/)

| # | Lesson | Type | Folder |
|---|---|---|---|
| L01 | MySQL and SQLite: What Changes, What Stays the Same | Lesson | [m22-l01-mysql-and-sqlite-what-changes-what-stays-the-same](m22-other-databases-and-interviews/m22-l01-mysql-and-sqlite-what-changes-what-stays-the-same/) |
| L02 | Cloud Warehouses (BigQuery, Snowflake) and When to Choose NoSQL | Lesson | [m22-l02-cloud-warehouses-bigquery-snowflake-and-when-to-choose-nosql](m22-other-databases-and-interviews/m22-l02-cloud-warehouses-bigquery-snowflake-and-when-to-choose-nosql/) |
| L03 | Classic Interview Problems 1: Second Highest Salary, Duplicates, Nth Row | Lesson | [m22-l03-classic-interview-problems-1-second-highest-salary-duplicates-nth-row](m22-other-databases-and-interviews/m22-l03-classic-interview-problems-1-second-highest-salary-duplicates-nth-row/) |
| L04 | Classic Interview Problems 2: Consecutive Days, Gaps and Islands, Streaks | Lesson | [m22-l04-classic-interview-problems-2-consecutive-days-gaps-and-islands-running-streaks](m22-other-databases-and-interviews/m22-l04-classic-interview-problems-2-consecutive-days-gaps-and-islands-running-streaks/) |
| L05 | Design Interview: the Database for a Food Delivery App | Lesson | [m22-l05-design-interview-the-database-for-a-food-delivery-app](m22-other-databases-and-interviews/m22-l05-design-interview-the-database-for-a-food-delivery-app/) |
| L06 | The Top 50 SQL Interview Questions, Answered | Lesson | [m22-l06-the-top-50-sql-interview-questions-answered](m22-other-databases-and-interviews/m22-l06-the-top-50-sql-interview-questions-answered/) |
| L07 | How to Keep Practising: Free Practice Sites and a 30-Day Plan | Lesson | [m22-l07-how-to-keep-practising-free-practice-sites-and-a-30-day-plan](m22-other-databases-and-interviews/m22-l07-how-to-keep-practising-free-practice-sites-and-a-30-day-plan/) |
| B05 | Interview Mock | Build | [m22-b05-interview-mock](m22-other-databases-and-interviews/m22-b05-interview-mock/) |
| B06 | Capstone: Raw CSV to a Final Report | Build | [m22-b06-capstone](m22-other-databases-and-interviews/m22-b06-capstone/) |
