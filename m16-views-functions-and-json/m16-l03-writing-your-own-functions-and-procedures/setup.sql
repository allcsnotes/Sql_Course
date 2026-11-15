-- M16-L03 setup: what this lesson leaves in the Chai Corner database.
-- Functions cups_for(text) and item_cups(text), procedure add_signup(text),
-- and Neha's newsletter sign-up (added by CALL add_signup).
-- Needs M16-L02 setup first. Re-runnable.
CREATE OR REPLACE FUNCTION cups_for(b text) RETURNS bigint LANGUAGE sql AS $$
  SELECT SUM(qty) FROM sales WHERE branch = b;
$$;

CREATE OR REPLACE PROCEDURE add_signup(e text) LANGUAGE sql AS $$
  INSERT INTO newsletter (email, joined_on) VALUES (e, '2026-03-12');
$$;

CREATE OR REPLACE FUNCTION item_cups(i text) RETURNS bigint LANGUAGE sql AS $$
  SELECT SUM(qty) FROM sales WHERE item = i;
$$;

-- The lesson ran CALL add_signup('neha@mail.com') once; only add her if she is missing.
INSERT INTO newsletter (email, joined_on)
SELECT 'neha@mail.com', '2026-03-12'
WHERE NOT EXISTS (SELECT 1 FROM newsletter WHERE email = 'neha@mail.com');

-- Check: cups_for('Pune') 3827, item_cups('Masala Chai') 1382, newsletter 6 rows
SELECT cups_for('Pune') AS pune, item_cups('Masala Chai') AS masala;
SELECT COUNT(*) AS people FROM newsletter;
