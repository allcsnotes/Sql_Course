import getpass
import psycopg

print("psycopg", psycopg.__version__)
password = getpass.getpass("Database password: ")

with psycopg.connect(host="localhost", dbname="chai_corner",
                     user="postgres", password=password) as conn:
    with conn.cursor() as cur:

        print("\n--- 1. top 3 by price ---")
        cur.execute("SELECT name, price FROM menu_items ORDER BY price DESC LIMIT 3")
        for row in cur.fetchall():
            print(row)

        print("\n--- 2. safe: %s placeholder ---")
        for item in ["Samosa", "x' OR '1'='1"]:
            cur.execute("SELECT name, price FROM menu_items WHERE name = %s", (item,))
            rows = cur.fetchall()
            print(repr(item), "->", len(rows), "row(s)", rows)

        print("\n--- 3. unsafe: f-string ---")
        item = "x' OR '1'='1"
        cur.execute(f"SELECT name, price FROM menu_items WHERE name = '{item}'")
        print(repr(item), "->", len(cur.fetchall()), "row(s)")

        print("\n--- 4. mistake: quotes around %s ---")
        try:
            cur.execute("SELECT name FROM menu_items WHERE name = '%s'", ("Samosa",))
            print(cur.fetchall())
        except Exception as e:
            print(type(e).__name__ + ":", e)
