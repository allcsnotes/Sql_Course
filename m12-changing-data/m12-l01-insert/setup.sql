-- M12-L01 setup: the feedback rows this lesson adds (8 rows, including the task).
-- Only needed if you skipped the lesson. Safe to run more than once.

INSERT INTO feedback (feedback_id, customer_id, rating, comment, given_on)
VALUES (1, 4, 5, 'Best masala chai in Pune', '2026-04-20'),
       (2, 7, 4, 'Samosa was hot and fresh', '2026-04-21'),
       (3, 12, 3, 'Chai came a bit late', '2026-04-22'),
       (4, 16, 5, 'Loved the Kulhad Chai', '2026-04-23'),
       (5, 9, 4, 'Friendly staff', '2026-04-24'),
       (6, 2, 3, NULL, NULL),
       (7, 11, 5, 'Great tea', NULL),
       (8, 18, 4, 'Nice samosa', NULL)
ON CONFLICT (feedback_id) DO NOTHING;
