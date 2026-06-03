-- ADD created_by COLUMN TO ticket_ledger
-- Tracks which user inserted the balance-collection entry
-- Run once on the database before deploying the updated collectBalance.jsp

ALTER TABLE ticket_ledger
    ADD COLUMN `created_by` INT UNSIGNED DEFAULT NULL AFTER `charge_type`,
    ADD CONSTRAINT `fk_tl_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL;

-- Verify
-- SELECT id, booking_id, amount, transaction_date, created_by FROM ticket_ledger LIMIT 10;
