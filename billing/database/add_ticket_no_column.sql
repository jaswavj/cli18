-- Add ticket_no column to ticket_booking table
-- Run this once on the moulana database

ALTER TABLE ticket_booking
  ADD COLUMN ticket_no VARCHAR(20) DEFAULT NULL AFTER pnr;

-- Optional: update existing rows with sequential numbers
SET @row := 0;
UPDATE ticket_booking
  SET ticket_no = CONCAT('TKT-', LPAD(@row := @row + 1, 3, '0'))
  ORDER BY id ASC;
