# M01-L01 · What Data Is, and Why Spreadsheets Stop Working

> Video: Module 1, Lesson 1. Watch it first, then follow along here.

## What you'll learn

- What **data** is (facts written down) and what **information** is (what you learn from them)
- Why a spreadsheet is a good first home for data, and the five ways it breaks as a business grows
- What a **database** is, and how it solves each of those five problems
- What **SQL** and a **query** are
- Three beginner mistakes about spreadsheets, databases and SQL

This is an idea lesson. There is nothing to install yet: PostgreSQL arrives in [Module 2](../../m02-setting-up/m02-l01-installing-postgresql-18-on-windows-and-mac/).

## Key ideas

### 1. Meera's question

Meera opened a small chai stall called Chai Corner. Every order went into a notebook: the date, the customer, the item, how many cups, and the price. Today Chai Corner has ten branches, and two years of orders would fill the notebook with **365,000 orders**.

Her question: *how many cups of Masala Chai did the Pune branch sell last Tuesday?* By hand, page by page, that takes hours, and you could still miscount.

In the video the same question is typed once, in SQL, into a database holding those orders:

```sql
SELECT SUM(qty) FROM orders
WHERE item = 'Masala Chai'
AND branch = 'Pune'
AND order_date = '2026-11-10';
```

```text
 sum
-----
  29
(1 row)

Time: 10.962 ms
```

**29 cups, in about 11 milliseconds** (about one hundredth of a second). Same orders, same question: the only difference is where the data lives. You do not need to understand the query yet. You will write queries like it from Module 3.

### 2. Data and information

- **Data** is facts that someone wrote down so they can be used later.
- One order: Priya bought 2 Masala Chai at the Pune branch, on 10 November, for ₹30 each. Each part is one small fact: who, what, how many, where, when, how much.
- One fact alone tells you very little. Thousands of facts together answer questions: which item sells the most, which branch is the busiest, which month was the best.
- The answer to such a question is **information**. Data is the raw facts; information is what you learn from them.

### 3. The spreadsheet

Meera moved every order into a spreadsheet: a grid where each **column** holds one kind of fact (date, branch, customer, phone, item) and each **row** holds one order.

Spreadsheets are genuinely useful. You can sort rows (for example by item), filter them (only Pune), and add up a column with a formula (total cups sold). For one small shop this works well, and many businesses start exactly like this.

### 4. Five ways the spreadsheet breaks

| Problem | What goes wrong at Chai Corner |
|---|---|
| 1 · Size | 10 branches × 2 years is already 365,000 rows: slow to open, every filter makes you wait. 50 branches × 5 years passes 4.5 million rows, but one Excel sheet holds only about 1 million rows |
| 2 · The same facts typed again and again | Priya orders almost every day, so her phone number is typed on every one of her rows. When it changes, miss one row and the sheet shows two numbers for Priya |
| 3 · Wrong data slips in | Someone types the word `two` instead of the number, leaves the price empty, or writes the date the other way round. The totals are wrong and nobody notices |
| 4 · Many people at once | Every branch manager edits their own copy: files called `final`, `final two`, `final real`. Which one has the true sales? |
| 5 · Hard questions | "Which customers ordered in October but not in November?" needs tricky formulas, helper columns and patience |

### 5. What a database is

A **database** is an organised store of data, looked after by a program called a **database system**. You never scroll through it yourself: you ask the database system a question, and it finds the answer.

| Problem | How a database solves it |
|---|---|
| Size | Millions, even billions of rows, still answered in milliseconds |
| Repeated facts | Priya's phone number is kept in one place only. Change it once, every order sees the new number |
| Wrong data | It checks the rules before saving anything |
| Many people | Hundreds of people and apps read and write at the same time, safely, in one single copy |
| Hard questions | You ask them in SQL, in a few lines |

The video tries to save the word `two` as a quantity, and the database refuses:

```text
ERROR:  invalid input syntax for type integer: "two"
```

And the hard October question takes just a few lines (shown only so you can see its size; `EXCEPT` comes much later in the course):

```sql
SELECT customer FROM orders
WHERE order_date BETWEEN '2026-10-01' AND '2026-10-31'
EXCEPT
SELECT customer FROM orders
WHERE order_date >= '2026-11-01';
```

**SQL** stands for **Structured Query Language**, a language made for asking questions about data. A **query** simply means a question.

### 6. You already use databases

A UPI payment is saved as a row in a database. Every WhatsApp message, food delivery order and Instagram like is a row somewhere. Data analysts, backend developers, product managers and marketers write SQL every day, which is why SQL is one of the most useful skills you can learn, whatever job you do.

### 7. Three beginner mistakes

1. **Thinking spreadsheets are bad.** They are not. For a small list a spreadsheet is perfect. A database wins when data grows, or when many people share it.
2. **Thinking a database is just a big spreadsheet.** It has rules, it links data together, and it answers questions for you.
3. **Thinking SQL is only for programmers.** Many people who use SQL never write any other code. If you can ask a clear question, you can learn SQL.

## Try it yourself

1. The video's task: pick one app you used today, and write down five facts it probably saved about you.
2. For one Chai Corner order, name the six small facts in it (who, what, how many, where, when, how much).
3. Which of the five spreadsheet problems does each of these describe? (a) Two different phone numbers for the same customer. (b) A file called `sales_final_real.xlsx`. (c) A quantity typed as `three`.

## Answers

1. Any five facts the app could store, for example for a food delivery app: your name, phone number, delivery address, the items you ordered, the time of the order, the amount paid. Each one would be a value in some table.
2. Who: Priya. What: Masala Chai. How many: 2. Where: Pune. When: 10 November. How much: ₹30 each.
3. (a) Problem 2, the same facts typed again and again. (b) Problem 4, many people at once. (c) Problem 3, wrong data slips in.

## Next

[M01-L02 · What a Database Is](../m01-l02-what-a-database-is/)
