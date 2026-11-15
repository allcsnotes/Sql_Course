# M02-L01 · Installing PostgreSQL 18 on Windows and Mac

> Video: Module 2, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What a database **server** is, and what a **port** and the **postgres** account are
- Where to download PostgreSQL 18 (the free installer made by EDB)
- Every screen of the setup wizard, and which options to keep or untick
- How to prove the server is running with `psql --version` and `pg_isready`
- What to do when the Terminal says `command not found`

## Before you start

- A Windows or Mac computer where you can install programs (you may be asked for your computer's password or to allow changes).
- About ten minutes, and a few hundred megabytes of free download (the Mac installer the video used was about 370 MB).
- No earlier lesson is needed. Module 1 explains what a database is.

## Files in this folder

There are no files for this lesson: everything happens in your browser, the installer and your terminal. Every step below is done in those apps, exactly as in the video.

## Follow along

### 1. What you are installing

**PostgreSQL** is a database **server**: think of a kitchen that stays open in the background, waiting for orders.

- Your **queries** are the orders.
- A tool like **psql** or **DBeaver** is the waiter: it carries your order to the kitchen and brings back the answer.
- The kitchen has a door number, called a **port**. For PostgreSQL it is **5432**.
- The kitchen has a manager account called **postgres**. You choose its password during the install.

### 2. Download the installer

1. Open your browser and go to **postgresql.org**.
2. Click the **Download** button.
3. Pick your computer: **macOS** or **Windows**.
4. Both pages look the same. Click **Download the installer**. This installer is made by **EDB**, a company that packages PostgreSQL for free.
5. On the EDB page a cookie box may pop up. Click **Required only**.
6. Find version **18.7**, the newest one in the video, and click the icon under **Mac OS X** or under **Windows**. If a newer 18.x is listed, take that one.
7. The file is a few hundred megabytes, so give it a minute.

### 3. Run the setup wizard

Open the file you downloaded:

- **Mac:** double-click the `.dmg` file. A window opens with the installer inside. Double-click it, and type your Mac password if it asks.
- **Windows:** double-click the `.exe` file. When Windows asks if this app can make changes, click **Yes**.

The setup wizard looks the same on both. Click **Next**, then:

| Screen | What to do |
|---|---|
| Installation Directory | the folder where PostgreSQL itself lives. Keep the default, click **Next** |
| Select Components | keep **PostgreSQL Server** and **Command Line Tools**. Untick **pgAdmin** and **Stack Builder** (we use DBeaver instead, in the next lesson). Click **Next** |
| Data Directory | the folder where your actual data is kept. Keep the default, click **Next** |
| Password | the password for the **postgres** account. Type it, then type it again to confirm. **Write it down somewhere safe**: you need it every time you connect, and you cannot see it again later |
| Port | keep **5432**, click **Next** |
| Locale | keep **Default**, click **Next** |
| Summary | shows everything you chose. Click **Next** |
| Ready to Install | click **Next** and wait |
| Installing | "Initialising the database cluster" means PostgreSQL is creating the data folder with everything it needs. It can take a few minutes |
| Completing the PostgreSQL Setup Wizard | click **Finish** |

PostgreSQL is now installed, and it is already running.

### 4. Prove it works (Mac)

Open the **Terminal** app and ask psql for its version:

```bash
psql --version
```

You may see:

```text
zsh: command not found: psql
```

Do not worry. PostgreSQL is installed; the installer just does not tell your Terminal where it lives. Use the full path instead (this is the installer's default folder):

```bash
/Library/PostgreSQL/18/bin/psql --version
```

You should see:

```text
psql (PostgreSQL) 18.7
```

To make plain `psql` work, add that folder to your **PATH**, the list of folders your Terminal searches for programs:

```bash
export PATH="/Library/PostgreSQL/18/bin:$PATH"
psql --version
```

```text
psql (PostgreSQL) 18.7
```

This fixes it for this Terminal window only. [M02-L03](../m02-l03-psql-the-database-in-a-terminal/) makes it permanent.

Finally, ask the server if it is running:

```bash
pg_isready
```

You should see:

```text
/tmp:5432 - accepting connections
```

**Accepting connections**: the kitchen is open, on port 5432.

### 5. Prove it works (Windows)

Open the **Start** menu and search for **SQL Shell (psql)**. That is psql, ready to go. You will use it in [M02-L03](../m02-l03-psql-the-database-in-a-terminal/).

## Common mistakes

- **Forgetting the password.** Write it down the moment you choose it. Without it you cannot connect.
- **A different port, like 5433.** That means another PostgreSQL is already installed. Note the number the installer shows, and use it whenever you connect.
- **Panicking at `command not found`.** PostgreSQL is installed. Your Terminal just does not know where to look: use the full path, or add the folder to PATH.
- **Installing pgAdmin and Stack Builder "just in case".** They are not needed for this course; DBeaver is the tool we use.

## Try it yourself

1. The video's task: install PostgreSQL 18 and run `pg_isready`. Keep your password safe: you need it in the next lesson.
2. Open a **new** Terminal window and run `psql --version` again. Does it work? Why or why not?
3. Which number would you write down if the Port screen showed 5433?

## Answers

1. `pg_isready` should print `... 5432 - accepting connections`.
2. On a Mac it says `command not found` again, because `export PATH=...` only lasts for the window you typed it in. M02-L03 makes it permanent.
3. 5433. Use that port wherever the course says 5432.

## Next

[M02-L02 · Installing DBeaver and Connecting to Your Database](../m02-l02-installing-dbeaver-and-connecting-to-your-database/)
