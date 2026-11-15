-- M12-L04 setup: the promo codes this lesson (and its task) leaves in the table.
-- Only needed if you skipped the lesson. Safe to run more than once.

INSERT INTO promo_codes (code, discount, uses)
VALUES ('CHAI10', 12, 2),
       ('WELCOME15', 25, 0),
       ('MONSOON20', 20, 0)
ON CONFLICT (code)
DO UPDATE SET discount = EXCLUDED.discount, uses = EXCLUDED.uses;
