-- Module 12, Lesson 4: UPSERT, INSERT ... ON CONFLICT
-- Chai Corner database (PostgreSQL 18). promo_codes was created empty in M11-L02.

-- Step 1: two promo codes to start with
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 10),
       ('WELCOME15', 15)
RETURNING code, discount, uses;
-- 2 rows: CHAI10 | 10 | 0,  WELCOME15 | 15 | 0

-- Step 2: CHAI10 now gives 12% off. A plain INSERT?
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 12);
-- ERROR 23505: duplicate key value violates unique constraint "promo_codes_code_key"
--              Key (code)=(CHAI10) already exists.

-- Step 3: option 1, if the code exists, skip it
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 12)
ON CONFLICT (code) DO NOTHING
RETURNING code, discount;
-- no error, 0 rows (the old discount stays at 10)

-- Step 4: option 2, if the code exists, update it instead
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 12)
ON CONFLICT (code)
DO UPDATE SET discount = EXCLUDED.discount
RETURNING code, discount, uses;
-- 1 row: CHAI10 | 12 | 0

-- Step 5: same command, new code: it simply inserts
INSERT INTO promo_codes (code, discount)
VALUES ('MONSOON20', 20)
ON CONFLICT (code)
DO UPDATE SET discount = EXCLUDED.discount
RETURNING code, discount, uses;
-- 1 row: MONSOON20 | 20 | 0

-- Step 6: a counter, someone used CHAI10, add one. Run it TWICE.
INSERT INTO promo_codes (code, discount, uses)
VALUES ('CHAI10', 12, 1)
ON CONFLICT (code)
DO UPDATE SET uses = promo_codes.uses + 1
RETURNING code, discount, uses;
-- 1st run: CHAI10 | 12 | 1
-- 2nd run: CHAI10 | 12 | 2

-- Mistake 1: a conflict column with no unique rule
INSERT INTO promo_codes (code, discount)
VALUES ('TEA5', 5)
ON CONFLICT (discount) DO NOTHING;
-- ERROR 42P10: there is no unique or exclusion constraint matching the ON CONFLICT specification

-- Mistake 2: forgetting EXCLUDED
INSERT INTO promo_codes (code, discount)
VALUES ('WELCOME15', 18)
ON CONFLICT (code)
DO UPDATE SET discount = discount;
-- ERROR 42702: column reference "discount" is ambiguous

-- Mistake 3: the same code twice in one command
INSERT INTO promo_codes (code, discount)
VALUES ('CHAI10', 14),
       ('CHAI10', 16)
ON CONFLICT (code)
DO UPDATE SET discount = EXCLUDED.discount;
-- ERROR 21000: ON CONFLICT DO UPDATE command cannot affect row a second time

-- Your task: WELCOME15 now gives 25% off (answer in README.md)
