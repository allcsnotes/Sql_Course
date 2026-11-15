-- M12-L03 setup: the changes this lesson (and its task) makes to feedback.
-- Only needed if you skipped the lesson. Safe to run more than once.

DELETE FROM feedback WHERE feedback_id = 6;

ALTER TABLE feedback ADD COLUMN IF NOT EXISTS hidden boolean NOT NULL DEFAULT false;

-- Row 3 was hidden and brought back; row 5 is hidden (the task)
UPDATE feedback SET hidden = (feedback_id = 5);
