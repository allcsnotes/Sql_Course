# M22-L02 · Cloud Warehouses (BigQuery, Snowflake) and When to Choose NoSQL

> Video: Module 22, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- What a **cloud data warehouse** is, and why it stores data by column instead of by row
- How to run real queries on Google's public datasets in the free **BigQuery sandbox**
- How BigQuery charges: you pay for the data a query reads, so `SELECT *` costs more and `LIMIT` does not help
- How **Snowflake** is different: you pay for the time your warehouse runs
- The four kinds of **NoSQL** database, and when (rarely) to choose one instead of PostgreSQL

## Before you start

- A Google account and a web browser. The BigQuery sandbox is free and does not need a card. Everything in this lesson happens in the BigQuery web page, not in DBeaver or your Chai Corner database.
- Nothing here touches your Chai Corner database.

## Files in this folder

| File | What it is |
|---|---|
| `bigquery_queries.sql` | Every BigQuery query from the video in order, with the real estimate, time and result as comments |

## Key ideas

### 1. What is a warehouse?

So far our biggest table had one million rows (`tune_orders` in M18-L04). Big companies have billions, and keep years of history.

| | Your app's database (PostgreSQL) | A warehouse (BigQuery, Snowflake) |
|---|---|---|
| Job | many small jobs all day: add one order, change one price | a few huge questions: total sales for every month of the last five years |
| Stores data | by row | by column |
| To add up one column | reads whole rows | reads only that column, skips the rest |

### 2. BigQuery: you pay for the data a query reads

| Query | Estimate before Run | Notes |
|---|---|---|
| Top 5 baby names of 2020 (3 columns) | 143.71 MB | ran in 247 ms |
| `SELECT *` on the same table | 185.85 MB | more columns means more data |
| `SELECT *` on Stack Overflow questions | 37.17 GB | do not run |
| `SELECT title` on the same table | 1.21 GB | about 30 times less |
| `SELECT * ... LIMIT 10` | 37.17 GB | LIMIT does not reduce the bytes read |
| `COUNT(*)` on Stack Overflow questions | 0 B | the row count is kept ready |
| Questions per year | 175.63 MB | ran in 522 ms |

Your first terabyte (1 TB) of data read each month is free. Still, never use `SELECT *` here, and check the estimate before you click Run. (Free limits change: check Google's current BigQuery pricing page.)

### 3. Snowflake: you pay for the time you use

The SQL looks almost the same. The big difference is how you pay. In Snowflake you start a **warehouse**, which is a group of computers, and you pay for every second it runs. When it is idle it can pause itself (auto-suspend). So BigQuery charges for the **data you read**, Snowflake charges for the **time you use**. Amazon Redshift and Databricks are other warehouses you will hear about.

### 4. NoSQL: no tables with fixed columns

| Kind | Example | Good for |
|---|---|---|
| Document | MongoDB | one order as one document: the customer, the items and the address together |
| Key value | Redis | finding one value by its key, very fast: logins, caches |
| Wide column | Cassandra | huge numbers of writes |
| Graph | Neo4j | friends of friends |

Choose NoSQL only when your data truly does not fit in tables. For most apps, start with PostgreSQL. It can even store JSON (`jsonb`, from [M16-L05](../../m16-views-functions-and-json/m16-l05-json-and-jsonb-storing-flexible-data/)).

## Follow along in BigQuery

These steps happen in the BigQuery web page. Bytes and results are from the video; timings will differ for you.

### 1. Open the sandbox

1. Open `console.cloud.google.com/bigquery` and sign in with your Google account.
2. If Google asks, create a project (the sandbox makes a free one for you). No card is needed.
3. Click the **+** tab (or **Compose new query**) to open an empty query editor.

### 2. Top 5 baby names of 2020

Google shares public tables. This one has every baby name in the United States since 1910. Type:

```sql
SELECT name, SUM(number) AS babies
FROM `bigquery-public-data.usa_names.usa_1910_current`
WHERE year = 2020
GROUP BY name
ORDER BY babies DESC
LIMIT 5;
```

Before you run anything, look under the editor: `This query will process 143.71 MB when run.` Click **Run**. You should see:

| name | babies |
|---|---|
| Liam | 19777 |
| Noah | 18630 |
| Olivia | 17641 |
| Emma | 15661 |
| Oliver | 14234 |

Open **Job information** under Query results: about 247 ms, and the same 143.71 MB.

Note the back-ticks around the table name: BigQuery names are `project.dataset.table`.

### 3. More columns, more data

Change the first line to `SELECT *` (and remove the GROUP BY, ORDER BY and LIMIT lines). Do not run it: just read the estimate, `185.85 MB`.

### 4. A bigger table: Stack Overflow questions

Type each of these and read only the estimate. **Do not click Run:**

```sql
SELECT *     FROM `bigquery-public-data.stackoverflow.posts_questions`;
SELECT title FROM `bigquery-public-data.stackoverflow.posts_questions`;
```

`SELECT *` will process 37.17 GB. Only the title column: 1.21 GB, about 30 times less.

### 5. How big is that table?

```sql
SELECT COUNT(*) AS questions
FROM `bigquery-public-data.stackoverflow.posts_questions`;
```

The estimate says 0 B, because BigQuery keeps the row count ready. Run it: `23020127` (23 million questions).

### 6. A real report: questions per year

```sql
SELECT EXTRACT(YEAR FROM creation_date) AS year,
COUNT(*) AS questions
FROM `bigquery-public-data.stackoverflow.posts_questions`
GROUP BY year
ORDER BY questions DESC
LIMIT 5;
```

Estimate 175.63 MB (only the `creation_date` column is read). You should see:

| year | questions |
|---|---|
| 2016 | 2200802 |
| 2015 | 2196676 |
| 2014 | 2137435 |
| 2017 | 2116212 |
| 2013 | 2033690 |

2016 had the most, 2.2 million. It took about half a second (522 ms) across all 23 million rows, because the work is split across many machines.

## Common mistakes

- Running `SELECT *` on a big warehouse table: you pay for every column it reads.
- Thinking `LIMIT 10` makes a query cheaper in BigQuery: it still reads every row of the columns you chose.
- Clicking Run before reading the estimate under the editor.
- Choosing NoSQL because it sounds modern: if your data fits in tables, PostgreSQL is the safer start.
- Leaving a Snowflake warehouse running with auto-suspend off: you pay for every second.

## Try it yourself

1. `SELECT *` on Stack Overflow questions reads 37.17 GB. Does adding `LIMIT 10` make it read less?
2. Which costs less in BigQuery: `SELECT title` or `SELECT *`, and roughly by how much on the Stack Overflow table?
3. A food delivery app needs a cache for logged-in sessions. Which kind of NoSQL database fits?

## Answers

1. No. It still reads 37.17 GB. Only fewer columns help.
2. `SELECT title`: 1.21 GB instead of 37.17 GB, about 30 times less.
3. A key value store such as Redis: it finds one value by its key, very fast.

## Next

[M22-L03 · Classic Interview Problems 1: Second Highest Salary, Duplicates, Nth Row](../m22-l03-classic-interview-problems-1-second-highest-salary-duplicates-nth-row/)
