-- Ensure ticket ledger notes can store longer balance collection remarks
ALTER TABLE ticket_ledger
    MODIFY COLUMN remarks VARCHAR(500) NULL;
