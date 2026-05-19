-- ============================================================
-- Ticket Booking: Add Paid Amount + Ledger Party Support
-- Run this script on the moulana database
-- ============================================================

-- 1. Add paid amount columns to ticket_booking
ALTER TABLE ticket_booking
  ADD COLUMN buy_paid_amount  DECIMAL(10,2) DEFAULT NULL AFTER buy_amount,
  ADD COLUMN sell_paid_amount DECIMAL(10,2) DEFAULT NULL AFTER sell_amount,
  ADD COLUMN cust_paid_amount DECIMAL(10,2) DEFAULT NULL AFTER customer_amount;

-- 2. Update ticket_ledger to support all party types (agent + customer)
ALTER TABLE ticket_ledger
  MODIFY COLUMN agent_id int unsigned DEFAULT NULL,
  ADD COLUMN party_type  VARCHAR(20)   NOT NULL DEFAULT 'AGENT' AFTER booking_id,
  ADD COLUMN party_name  VARCHAR(255)  DEFAULT NULL             AFTER party_type,
  ADD COLUMN bill_amount DECIMAL(10,2) DEFAULT NULL             AFTER agent_id;

-- Note: existing `amount` column = paid amount per entry
-- Balance = SUM(bill_amount) - SUM(amount) per booking+party_type

-- 3. Backfill party_type for any pre-existing ledger entries
--    CR = bought from agent (BUY_AGENT), DR = sold to agent (SELL_AGENT)
UPDATE ticket_ledger
  SET party_type = IF(transaction_type = 'CR', 'BUY_AGENT', 'SELL_AGENT')
  WHERE party_type = 'AGENT';

-- 4. Backfill bill_amount = amount for pre-existing entries (paid in full assumed)
UPDATE ticket_ledger
  SET bill_amount = amount
  WHERE bill_amount IS NULL;
