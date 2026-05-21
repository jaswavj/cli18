-- =========================================================
-- ADD transaction_no COLUMN TO ticket_ledger
-- Run this ONCE on your database before deploying the update
-- =========================================================

ALTER TABLE ticket_ledger
  ADD COLUMN transaction_no VARCHAR(100) DEFAULT NULL
  AFTER payment_mode_id;

-- Verify:
-- SELECT id, party_type, payment_mode_id, transaction_no, amount FROM ticket_ledger LIMIT 10;
