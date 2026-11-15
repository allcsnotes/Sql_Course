CREATE TABLE branches (branch_id int PRIMARY KEY, city varchar(30) NOT NULL, opened_on date NOT NULL);
INSERT INTO branches VALUES (1,'Pune','2019-04-12'),(2,'Mumbai','2019-09-02'),(3,'Delhi','2020-01-20'),(4,'Bengaluru','2020-07-15'),(5,'Chennai','2021-02-08'),
 (6,'Hyderabad','2021-08-23'),(7,'Kolkata','2022-03-14'),(8,'Jaipur','2022-11-05'),(9,'Ahmedabad','2023-06-19'),(10,'Kochi','2024-01-29');
CREATE TABLE menu_items (item_id int PRIMARY KEY, name varchar(40) NOT NULL, price int NOT NULL);
INSERT INTO menu_items VALUES (1,'Bun Maska',35),(2,'Cold Coffee',80),(3,'Cutting Chai',20),(4,'Filter Coffee',40),(5,'Ginger Chai',30),(6,'Maggi',60),(7,'Masala Chai',30),(8,'Samosa',25),(9,'Vada Pav',30),(10,'Veg Sandwich',70);
CREATE TABLE customers (customer_id int PRIMARY KEY, name varchar(40) NOT NULL, joined_on date NOT NULL);
INSERT INTO customers VALUES (1,'Asha','2024-11-11'),(2,'Lukas','2024-11-14'),(3,'Priya','2024-12-02'),(4,'Rahul','2025-01-09'),(5,'Kabir','2025-01-21'),
 (6,'Ananya','2025-02-17'),(7,'Rohan','2025-03-05'),(8,'Isha','2025-04-12'),(9,'Vikram','2025-05-30'),(10,'Neha','2025-07-08'),
 (11,'Arjun','2025-08-19'),(12,'Sara','2025-10-02'),(13,'Dev','2026-01-15'),(14,'Tara','2026-03-27'),(15,'Kiran','2026-06-10');
