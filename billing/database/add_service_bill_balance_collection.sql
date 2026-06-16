-- =========================================================
-- SERVICE BILL BALANCE COLLECTION TABLE
-- Run this once in the target database.
-- =========================================================

CREATE TABLE IF NOT EXISTS `service_bill_balance_collection` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `bill_id` INT NOT NULL,
  `collection_date` DATE NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `pay_mode_id` INT DEFAULT NULL,
  `pay_mode_name` VARCHAR(100) DEFAULT '',
  `remarks` TEXT,
  `created_by` INT NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sb_collect_bill_id` (`bill_id`),
  KEY `idx_sb_collect_date` (`collection_date`),
  CONSTRAINT `fk_sb_collect_bill` FOREIGN KEY (`bill_id`) REFERENCES `service_bill` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional view query for balance collection report:
-- SELECT c.id, sb.bill_no, DATE_FORMAT(c.collection_date,'%d-%m-%Y') AS collection_date,
--        sb.customer_name, c.amount, COALESCE(c.pay_mode_name,'') AS pay_mode,
--        COALESCE(c.remarks,'') AS remarks, c.created_at
-- FROM service_bill_balance_collection c
-- JOIN service_bill sb ON sb.id = c.bill_id
-- ORDER BY c.collection_date DESC, c.id DESC;
