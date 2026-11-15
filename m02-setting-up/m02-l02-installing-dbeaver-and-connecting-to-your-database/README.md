# M02-L02 · Installing DBeaver and Connecting to Your Database

> Video: Module 2, Lesson 2. Watch it first, then follow along here.

## What you'll learn

- Where to download **DBeaver Community**, the free database tool used in this course
- Which first-run options to choose (and which to untick)
- How to create a **connection** to your PostgreSQL server: host, port, database, username, password
- How to open a SQL editor and run your first query, `SELECT version();`
- The three errors beginners meet first, and what each one means

## Before you start

- PostgreSQL 18 installed and running, from [M02-L01](../m02-l01-installing-postgresql-18-on-windows-and-mac/). `pg_isready` should say `accepting connections`.
- The password you chose when installing PostgreSQL.

## Files in this folder

| File | What it is |
|---|---|
| `first_query.sql` | The one query from the video, `SELECT version();` |

Everything else in this lesson happens in your browser and in the DBeaver app.

## Follow along

### 1. Download DBeaver

PostgreSQL is running, but it has no window to type in. DBeaver is a free tool for Windows and Mac that shows every answer as a clear table.

1. Open your browser and go to **dbeaver.io**.
2. Click **Download** in the menu.
3. This page is for **DBeaver Community**, the free version. At the time of recording it is version **26.2.4** (a newer one is fine).
4. Scroll down to the boxes:
   - **Mac with an M chip** (M1, M4 and so on): click **DMG** under **Apple Silicon**.
   - **Older Intel Mac**: click **DMG** under **Intel**.
   - **Windows**: in the Windows box, click **EXE** under **x86**. That fits most Windows laptops.

### 2. Install and first start

- **Mac:** double-click the `.dmg` file. A window opens. Drag **DBeaver** into the **Applications** folder, then open it from Applications.
- **Windows:** double-click the `.exe` file and click **Yes**. Keep clicking **Next** until it finishes. Open DBeaver from the Start menu.

The first time it opens, it asks a few questions:

| Screen | Choice |
|---|---|
| Language | keep **English**, click **Next** |
| Appearance | **Dark** or **Light**, whichever you like. Keep **Full**, click **Next** |
| Features | untick **AI integration** (we write every query ourselves), click **Next** |
| Data collection | choose **Do not share**, click **Next** |
| Final steps | untick **Create sample database** (we have our own data) and **Tip of the day**, then click **Apply** |

### 3. Connect to your PostgreSQL server

1. Click the **plug icon** at the top left: **New Database Connection**.
2. A list of databases appears. Click **PostgreSQL** (the blue elephant) and click **Next**.
3. If DBeaver asks for a driver, keep **PostgreSQL standard driver** and click **Next**. A **driver** is the small program DBeaver uses to talk to PostgreSQL.
4. Fill in the settings:

   | Field | Value | Why |
   |---|---|---|
   | Host | `localhost` | this computer, your own |
   | Port | `5432` | the door number from M02-L01 |
   | Database | `postgres` | the database every install comes with |
   | Username | `postgres` | the manager account |
   | Password | the password you chose when installing | |
   | Save password | keep it **ticked** | so you type it only once |

5. Click **Test Connection**. The first time, DBeaver may ask to download driver files: click **Download** and wait until it says **Connected**.
6. Click **Finish**. Your connection appears on the left: **postgres**, at **localhost**, port **5432**.

### 4. Your first query

1. Click **postgres** on the left.
2. Open the **SQL Editor** menu and click **New SQL script**. An empty editor opens.
3. Type this query. It asks the server one question: which version are you?

   ```sql
   SELECT version();
   ```

4. Click the orange **play** button on the left to run it.

You should see a table with one row, starting with:

```text
version
PostgreSQL 18.7 on ...
```

The rest of the text names your computer and the compiler, so it will differ from the video. At the bottom DBeaver says **1 row(s) fetched** in a tiny fraction of a second (0.002s in the video). You just ran your first query on your own database.

## Common mistakes

These are the real messages, from the video's terminal runs:

- **A wrong password.** The server says:
  ```text
  FATAL:  password authentication failed for user "postgres"
  ```
  Type the exact password you chose, capital letters included.
- **Connection refused.** Nothing is answering at that door, for example port 5433 when the server is on 5432:
  ```text
  connection to server at "localhost" (::1), port 5433 failed: Connection refused
  	Is the server running on that host and accepting TCP/IP connections?
  ```
  Check the port, and run `pg_isready` to check the server is running.
- **Typing a query and waiting.** Typing does nothing on its own. Click the play button; only then does the server answer.

## Try it yourself

1. The video's task: connect DBeaver to your database and run `SELECT version();`. Check that it shows PostgreSQL, version 18.
2. In the same editor, run `SELECT 7 / 2;` from [M01-L04](../../m01-welcome-to-databases/m01-l04-one-language-many-databases/). What do you get?
3. Change the port of your connection to 5433 (Edit Connection), click Test Connection, read the error, then set it back to 5432.

## Answers

1. One row starting `PostgreSQL 18.` (18.7 in the video).
2. `3`: PostgreSQL divides whole numbers as whole numbers.
3. DBeaver shows a "Connection refused" error, because nothing listens on 5433. With 5432 it connects again.

## Next

[M02-L03 · psql: the Database in a Terminal](../m02-l03-psql-the-database-in-a-terminal/)
