-- ─────────────────────────────────────────────────────────────────────────────
-- Booking Edit / Cancel feature
-- Run once against the moulana database
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Soft-cancel flag on ticket_booking
ALTER TABLE ticket_booking
    ADD COLUMN IF NOT EXISTS is_cancelled TINYINT(1) NOT NULL DEFAULT 0
    AFTER cust_paid_amount;

-- 2. Audit log table
CREATE TABLE IF NOT EXISTS ticket_booking_log (
    id          INT          NOT NULL AUTO_INCREMENT,
    booking_id  INT          NOT NULL,
    ticket_no   VARCHAR(50)  DEFAULT NULL,
    pnr         VARCHAR(100) DEFAULT NULL,
    action_type VARCHAR(10)  NOT NULL COMMENT 'EDIT or CANCEL',
    changed_by  INT          NOT NULL,
    user_name   VARCHAR(100) DEFAULT NULL,
    change_date DATE         NOT NULL,
    change_time TIME         NOT NULL,
    remarks     TEXT         DEFAULT NULL,
    PRIMARY KEY (id),
    KEY idx_booking_id (booking_id),
    KEY idx_change_date (change_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Register permission module 6  (Edit Booking)
INSERT IGNORE INTO user_modules (id, module_name) VALUES (6, 'Edit Booking');

-- 4. Change description column on audit log (run if table already exists)
ALTER TABLE ticket_booking_log
    ADD COLUMN IF NOT EXISTS description TEXT DEFAULT NULL AFTER remarks;
