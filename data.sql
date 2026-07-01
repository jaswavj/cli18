/*
SQLyog Community v13.3.1 (64 bit)
MySQL - 8.4.7 : Database - moulana
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`moulana` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `moulana`;

/*Table structure for table `agent_account` */

DROP TABLE IF EXISTS `agent_account`;

CREATE TABLE `agent_account` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `agent_id` int NOT NULL,
  `advance` decimal(10,2) DEFAULT '0.00',
  `due` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `agent_account` */

insert  into `agent_account`(`id`,`agent_id`,`advance`,`due`) values 
(1,1,0.00,1000.00),
(2,10,1000.00,0.00);

/*Table structure for table `company_details` */

DROP TABLE IF EXISTS `company_details`;

CREATE TABLE `company_details` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `address` text,
  `gstin` varchar(255) DEFAULT NULL,
  `print_type` int NOT NULL DEFAULT '0',
  `printer_name` varchar(255) DEFAULT NULL,
  `bank_details` varchar(255) DEFAULT NULL,
  `barcode_printer` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `company_details` */

insert  into `company_details`(`id`,`shop_name`,`address`,`gstin`,`print_type`,`printer_name`,`bank_details`,`barcode_printer`) values 
(2,'MOULANA AIR TRAVELS','No.6. UPPER FLOOR,TOWN PANCHAYAT COMMERCIAL COMPLEX,NEAR TOWN PANCHAYAT OFFICE. \r\nORATHANADU-614625\r\nPh No: 9788188469','',2,'','','AP4909');

/*Table structure for table `customers` */

DROP TABLE IF EXISTS `customers`;

CREATE TABLE `customers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  `is_eligible_for_commission` tinyint DEFAULT '1',
  `is_active` int DEFAULT '1',
  `gstin` varchar(255) DEFAULT NULL,
  `is_gst` int DEFAULT '0',
  `salesman` int DEFAULT NULL,
  `area` int DEFAULT NULL,
  `credit_limit` double(10,2) NOT NULL DEFAULT '0.00',
  `local` int DEFAULT '1',
  `exchange_point` double(10,3) DEFAULT '0.000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `customers` */

insert  into `customers`(`id`,`name`,`phone_number`,`address`,`date`,`time`,`is_eligible_for_commission`,`is_active`,`gstin`,`is_gst`,`salesman`,`area`,`credit_limit`,`local`,`exchange_point`) values 
(1,'Walk-in Customer','','','2026-05-14','16:06:39',0,1,'',0,NULL,NULL,0.00,1,0.000),
(2,'cus','9595959595','','2026-05-14','16:52:46',0,1,'',0,NULL,NULL,0.00,1,0.000),
(3,'jas','8888888888','','2026-05-14','16:59:07',0,1,'',0,NULL,NULL,0.00,1,0.000);

/*Table structure for table `expense_entry` */

DROP TABLE IF EXISTS `expense_entry`;

CREATE TABLE `expense_entry` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `exp_type` int NOT NULL,
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `exc_date_time` datetime DEFAULT NULL,
  `entry_date_time` datetime DEFAULT NULL,
  `is_active` int DEFAULT '1',
  `uid` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type` (`exp_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `expense_entry` */

insert  into `expense_entry`(`id`,`exp_type`,`content`,`amount`,`description`,`exc_date_time`,`entry_date_time`,`is_active`,`uid`) values 
(1,1,'8',13000.00,'','2026-06-01 10:39:00','2026-06-01 10:39:53',1,25);

/*Table structure for table `expense_type` */

DROP TABLE IF EXISTS `expense_type`;

CREATE TABLE `expense_type` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `expense_type` */

insert  into `expense_type`(`id`,`type`,`is_active`) values 
(1,'THARIK SALARY',1),
(2,'OFFICE EXPENSIVE',1);

/*Table structure for table `heading` */

DROP TABLE IF EXISTS `heading`;

CREATE TABLE `heading` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `head1` varchar(255) DEFAULT NULL,
  `head2` varchar(255) DEFAULT NULL,
  `head3` varchar(255) DEFAULT NULL,
  `active` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `heading` */

insert  into `heading`(`id`,`head1`,`head2`,`head3`,`active`) values 
(1,'Category','Brand','Product',200);

/*Table structure for table `service_bill` */

DROP TABLE IF EXISTS `service_bill`;

CREATE TABLE `service_bill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bill_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bill_date` date NOT NULL,
  `customer_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `subtotal` decimal(10,2) DEFAULT '0.00',
  `discount` decimal(10,2) DEFAULT '0.00',
  `total_amount` decimal(10,2) DEFAULT '0.00',
  `paid_amount` decimal(10,2) DEFAULT '0.00',
  `balance` decimal(10,2) DEFAULT '0.00',
  `pay_mode_id` int DEFAULT NULL,
  `pay_mode_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `DESCRIPTION` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bill_no` (`bill_no`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `service_bill` */

insert  into `service_bill`(`id`,`bill_no`,`bill_date`,`customer_name`,`phone`,`subtotal`,`discount`,`total_amount`,`paid_amount`,`balance`,`pay_mode_id`,`pay_mode_name`,`DESCRIPTION`,`created_by`,`created_at`) values 
(2,'26-1','2026-06-01','BALAMURUGAN PITCHAIKKANNU','9786057464',15000.00,0.00,15000.00,15000.00,0.00,1,'CASH PAYMENT','B',25,'2026-06-01 12:07:03'),
(3,'26-2','2026-06-16','sda','3333',1000.00,0.00,1000.00,700.00,300.00,1,'CASH PAYMENT','sasa',1,'2026-06-16 14:25:11');

/*Table structure for table `service_bill_balance_collection` */

DROP TABLE IF EXISTS `service_bill_balance_collection`;

CREATE TABLE `service_bill_balance_collection` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bill_id` int NOT NULL,
  `collection_date` date NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `pay_mode_id` int DEFAULT NULL,
  `pay_mode_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sb_collect_bill_id` (`bill_id`),
  KEY `idx_sb_collect_date` (`collection_date`),
  CONSTRAINT `fk_sb_collect_bill` FOREIGN KEY (`bill_id`) REFERENCES `service_bill` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `service_bill_balance_collection` */

insert  into `service_bill_balance_collection`(`id`,`bill_id`,`collection_date`,`amount`,`pay_mode_id`,`pay_mode_name`,`remarks`,`created_by`,`created_at`) values 
(1,3,'2026-06-16',200.00,1,'CASH PAYMENT','x',1,'2026-06-16 14:34:15');

/*Table structure for table `service_bill_items` */

DROP TABLE IF EXISTS `service_bill_items`;

CREATE TABLE `service_bill_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bill_id` int NOT NULL,
  `service_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cost` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `bill_id` (`bill_id`),
  CONSTRAINT `service_bill_items_ibfk_1` FOREIGN KEY (`bill_id`) REFERENCES `service_bill` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `service_bill_items` */

insert  into `service_bill_items`(`id`,`bill_id`,`service_name`,`cost`) values 
(1,2,'DUBAI VISA',15000.00),
(2,3,'sssss',1000.00);

/*Table structure for table `ticket_agent` */

DROP TABLE IF EXISTS `ticket_agent`;

CREATE TABLE `ticket_agent` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_agent` */

insert  into `ticket_agent`(`id`,`name`,`is_active`) values 
(1,'AKBAR TRAVELS',1),
(2,'NAVEEN AIR TRAVELS',1),
(3,'SHREE AIR TRAVELS',1),
(4,'JAFARULLA AIR TRAVELS',1),
(5,'WASEEMA AIR TRAVELS (SHAUL)',1),
(6,'MARVEL AIR TRAVELS',1),
(7,'SMART(AMEEN) AIR TRAVELS',1),
(8,'SHREYAA AIR TRAVELS',1),
(9,'PRAVEEN AIR TRAVELS',1),
(10,'ALHIIND AIR TRAVELS',1),
(11,'RIYA AIR TRAVELS',1),
(12,'BHARATH AIR TRAVELS',1),
(13,'SENGUTTUVAN',1);

/*Table structure for table `ticket_airline` */

DROP TABLE IF EXISTS `ticket_airline`;

CREATE TABLE `ticket_airline` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_airline_value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_airline` */

insert  into `ticket_airline`(`id`,`value`) values 
(10,'Air Arabia'),
(1,'Air India'),
(14,'AIR INDIA EXPRESS (IX)'),
(6,'AirAsia India'),
(7,'Blue Dart Aviation'),
(8,'Emirates'),
(11,'flydubai'),
(21,'FLYNAS (XY)'),
(5,'GoAir'),
(2,'IndiGo'),
(12,'Oman Air'),
(9,'Qatar Airways'),
(15,'SCOOT (TR)'),
(18,'SINGAPORE AIRLINES (SQ)'),
(3,'SpiceJet'),
(13,'SriLankan Airlines'),
(22,'SRILANKAN AIRLINES (UL)'),
(4,'Vistara');

/*Table structure for table `ticket_booking` */

DROP TABLE IF EXISTS `ticket_booking`;

CREATE TABLE `ticket_booking` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `pnr` varchar(100) DEFAULT NULL,
  `ticket_no` varchar(20) DEFAULT NULL,
  `booking_date` date NOT NULL,
  `oneway_travel_date` date DEFAULT NULL,
  `oneway_travel_time` time DEFAULT NULL,
  `oneway_from_id` int unsigned DEFAULT NULL,
  `oneway_to_id` int unsigned DEFAULT NULL,
  `oneway_flight_no` varchar(100) DEFAULT NULL,
  `oneway_airlines` varchar(255) DEFAULT NULL,
  `return_travel_date` date DEFAULT NULL,
  `return_travel_time` time DEFAULT NULL,
  `return_from_id` int unsigned DEFAULT NULL,
  `return_to_id` int unsigned DEFAULT NULL,
  `return_flight_no` varchar(100) DEFAULT NULL,
  `return_airlines` varchar(255) DEFAULT NULL,
  `no_of_seats` int NOT NULL DEFAULT '1',
  `phone` varchar(20) DEFAULT NULL,
  `buy_agent_id` int unsigned DEFAULT NULL,
  `buy_amount` decimal(10,2) DEFAULT NULL,
  `buy_paid_amount` decimal(10,2) DEFAULT NULL,
  `buy_payment_mode_id` int unsigned DEFAULT NULL,
  `sell_agent_id` int unsigned DEFAULT NULL,
  `sell_amount` decimal(10,2) DEFAULT NULL,
  `sell_paid_amount` decimal(10,2) DEFAULT NULL,
  `sell_payment_mode_id` int unsigned DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `customer_amount` decimal(10,2) DEFAULT NULL,
  `cust_paid_amount` decimal(10,2) DEFAULT NULL,
  `is_cancelled` tinyint(1) NOT NULL DEFAULT '0',
  `customer_payment_mode_id` int unsigned DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `buy_date_change_amt` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Total date-change charges paid to buy agent',
  `buy_date_change_paid` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Amount paid for buy-side date-change',
  `sell_date_change_amt` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Total date-change charges charged on sell side',
  `sell_date_change_paid` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Amount paid for sell-side date-change',
  `cancel_charge_buy` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Cancel fee charged by buy agent',
  `refund_received_buy` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Amount refunded back by buy agent after cancel',
  `cancel_charge_sell` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Cancel fee charged to customer / sell agent',
  `refund_to_sell` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Amount returned to customer / sell agent',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking` */

insert  into `ticket_booking`(`id`,`pnr`,`ticket_no`,`booking_date`,`oneway_travel_date`,`oneway_travel_time`,`oneway_from_id`,`oneway_to_id`,`oneway_flight_no`,`oneway_airlines`,`return_travel_date`,`return_travel_time`,`return_from_id`,`return_to_id`,`return_flight_no`,`return_airlines`,`no_of_seats`,`phone`,`buy_agent_id`,`buy_amount`,`buy_paid_amount`,`buy_payment_mode_id`,`sell_agent_id`,`sell_amount`,`sell_paid_amount`,`sell_payment_mode_id`,`customer_name`,`customer_amount`,`cust_paid_amount`,`is_cancelled`,`customer_payment_mode_id`,`created_by`,`created_at`,`buy_date_change_amt`,`buy_date_change_paid`,`sell_date_change_amt`,`sell_date_change_paid`,`cancel_charge_buy`,`refund_received_buy`,`cancel_charge_sell`,`refund_to_sell`) values 
(1,'1','TKT-001','2026-07-01','2026-07-02','14:20:00',6,5,'1','Air Arabia',NULL,NULL,NULL,NULL,NULL,NULL,1,'1234567890',1,10000.00,5000.00,1,10,20000.00,10000.00,1,NULL,NULL,0.00,0,NULL,1,'2026-07-01 14:20:35',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00);

/*Table structure for table `ticket_booking_log` */

DROP TABLE IF EXISTS `ticket_booking_log`;

CREATE TABLE `ticket_booking_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `ticket_no` varchar(50) DEFAULT NULL,
  `pnr` varchar(100) DEFAULT NULL,
  `action_type` varchar(10) NOT NULL COMMENT 'EDIT or CANCEL',
  `changed_by` int NOT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `change_date` date NOT NULL,
  `change_time` time NOT NULL,
  `remarks` text,
  `DESCRIPTION` text,
  PRIMARY KEY (`id`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_change_date` (`change_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking_log` */

/*Table structure for table `ticket_city` */

DROP TABLE IF EXISTS `ticket_city`;

CREATE TABLE `ticket_city` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_city` */

insert  into `ticket_city`(`id`,`name`,`is_active`) values 
(1,'SHARJAH (SHJ)',1),
(2,'THIRUVANANTHAPURAM (TRV)',1),
(3,'SINGAPORE (SIN)',1),
(4,'TIRUCHIRAPPALLI (TRZ)',1),
(5,'COLOMBO (CMB)',1),
(6,'CHENNAI (MAA)',1),
(7,'DUBAI (DXB)',1),
(8,'LONDON (LHR)',1),
(9,'RIYADH (RUH)',1),
(10,'DELHI (DEL)',1),
(11,'SYDNEY (SYD)',1),
(12,'KUALA LUMPUR (KUL)',1),
(13,'MUMBAI (BOM)',1),
(14,'DAMMAM (DMM)',1),
(15,'LONDON (LHR)',1),
(16,'NORTH KOREA (FNJ)',1);

/*Table structure for table `ticket_delete_log` */

DROP TABLE IF EXISTS `ticket_delete_log`;

CREATE TABLE `ticket_delete_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `ticket_no` varchar(50) DEFAULT NULL,
  `pnr` varchar(50) DEFAULT NULL,
  `booking_date` date DEFAULT NULL,
  `oneway_from` varchar(100) DEFAULT NULL,
  `oneway_to` varchar(100) DEFAULT NULL,
  `oneway_travel_date` date DEFAULT NULL,
  `passenger_names` text,
  `buy_agent` varchar(100) DEFAULT NULL,
  `buy_amount` decimal(10,2) DEFAULT NULL,
  `sell_agent` varchar(100) DEFAULT NULL,
  `sell_amount` decimal(10,2) DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `customer_amount` decimal(10,2) DEFAULT NULL,
  `no_of_seats` int DEFAULT NULL,
  `deleted_by` int unsigned DEFAULT NULL,
  `deleted_by_name` varchar(100) DEFAULT NULL,
  `deleted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tdl_booking` (`booking_id`),
  KEY `idx_tdl_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_delete_log` */

/*Table structure for table `ticket_flightno` */

DROP TABLE IF EXISTS `ticket_flightno`;

CREATE TABLE `ticket_flightno` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_flightno_value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_flightno` */

insert  into `ticket_flightno`(`id`,`value`) values 
(26,'1'),
(27,'12'),
(4,'132'),
(9,'134'),
(11,'252'),
(28,'32'),
(8,'321'),
(5,'529'),
(7,'609'),
(17,'682'),
(3,'689'),
(1,'690'),
(22,'6E 1007'),
(15,'758'),
(13,'759'),
(20,'766'),
(2,'767'),
(24,'C6E 1008');

/*Table structure for table `ticket_ledger` */

DROP TABLE IF EXISTS `ticket_ledger`;

CREATE TABLE `ticket_ledger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `party_type` varchar(20) NOT NULL DEFAULT 'AGENT',
  `party_name` varchar(255) DEFAULT NULL,
  `agent_id` int unsigned DEFAULT NULL,
  `bill_amount` decimal(10,2) DEFAULT NULL,
  `transaction_type` varchar(5) NOT NULL COMMENT 'DR = agent owes us | CR = we owe agent',
  `amount` decimal(10,2) DEFAULT NULL,
  `payment_mode_id` int unsigned DEFAULT NULL,
  `transaction_no` varchar(100) DEFAULT NULL,
  `remarks` varchar(500) DEFAULT NULL,
  `transaction_date` date NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `charge_type` varchar(20) NOT NULL DEFAULT 'ORIGINAL',
  `created_by` int unsigned DEFAULT NULL,
  `cancel_charge` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_ledger_agent` (`agent_id`),
  KEY `idx_ticket_ledger_booking` (`booking_id`),
  KEY `fk_tl_created_by` (`created_by`),
  CONSTRAINT `fk_tl_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_ledger` */

insert  into `ticket_ledger`(`id`,`booking_id`,`party_type`,`party_name`,`agent_id`,`bill_amount`,`transaction_type`,`amount`,`payment_mode_id`,`transaction_no`,`remarks`,`transaction_date`,`created_at`,`charge_type`,`created_by`,`cancel_charge`) values 
(1,1,'BUY_AGENT',NULL,1,10000.00,'CR',5000.00,1,NULL,'Buy ticket | PNR: 1','2026-07-01','2026-07-01 14:20:35','ORIGINAL',NULL,NULL),
(2,1,'SELL_AGENT',NULL,10,20000.00,'DR',10000.00,1,NULL,'Sell ticket | PNR: 1','2026-07-01','2026-07-01 14:20:35','ORIGINAL',NULL,NULL),
(3,0,'AGENT_ACCOUNT',NULL,1,0.00,'CR',5000.00,2,'1232','Pay balance | sssddsds','2026-07-01','2026-07-01 14:55:34','BALANCE_PAY',1,NULL),
(4,0,'AGENT_ACCOUNT',NULL,1,0.00,'DR',1000.00,2,'1232','Advance paid | sssddsds','2026-07-01','2026-07-01 14:55:34','ADVANCE_PAID',1,NULL),
(5,0,'AGENT_ACCOUNT',NULL,10,0.00,'DR',5000.00,1,NULL,'Balance collection | s','2026-07-01','2026-07-01 14:57:11','BALANCE_COLLECT',1,NULL),
(6,0,'AGENT_ACCOUNT',NULL,10,0.00,'DR',5000.00,1,NULL,'Balance collection | xxxx','2026-07-01','2026-07-01 15:00:07','BALANCE_COLLECT',1,NULL),
(7,0,'AGENT_ACCOUNT',NULL,10,0.00,'CR',4000.00,1,NULL,'Advance credit | aa','2026-07-01','2026-07-01 15:03:44','ADVANCE_CREDIT',1,NULL),
(8,0,'AGENT_ACCOUNT',NULL,10,0.00,'CR',4000.00,1,NULL,'Pay balance | s','2026-07-01','2026-07-01 15:04:31','BALANCE_PAY',1,NULL),
(9,0,'AGENT_ACCOUNT',NULL,10,0.00,'DR',1000.00,1,NULL,'Advance paid | s','2026-07-01','2026-07-01 15:04:31','ADVANCE_PAID',1,NULL),
(10,0,'AGENT_ACCOUNT',NULL,10,0.00,'DR',1000.00,2,'s','Balance collection | s','2026-07-01','2026-07-01 15:04:43','BALANCE_COLLECT',1,NULL),
(11,0,'AGENT_ACCOUNT',NULL,10,0.00,'CR',1000.00,2,'s','Advance credit | s','2026-07-01','2026-07-01 15:04:44','ADVANCE_CREDIT',1,NULL);

/*Table structure for table `ticket_passenger` */

DROP TABLE IF EXISTS `ticket_passenger`;

CREATE TABLE `ticket_passenger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `seat_no` int DEFAULT NULL,
  `passenger_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_passenger_booking` (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_passenger` */

insert  into `ticket_passenger`(`id`,`booking_id`,`seat_no`,`passenger_name`) values 
(1,1,1,'has');

/*Table structure for table `ticket_payment_mode` */

DROP TABLE IF EXISTS `ticket_payment_mode`;

CREATE TABLE `ticket_payment_mode` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `modes` varchar(255) DEFAULT NULL,
  `is_active` int DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_payment_mode` */

insert  into `ticket_payment_mode`(`id`,`modes`,`is_active`) values 
(1,'CASH PAYMENT',1),
(2,'UPI PAYMENT',1);

/*Table structure for table `user_modules` */

DROP TABLE IF EXISTS `user_modules`;

CREATE TABLE `user_modules` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `module_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

/*Data for the table `user_modules` */

insert  into `user_modules`(`id`,`module_name`) values 
(1,'Ticket'),
(2,'Master'),
(3,'User management'),
(4,'Admin'),
(5,'Reports'),
(6,'Edit/Cancel'),
(7,'Expense'),
(8,'Service bill');

/*Table structure for table `user_permission` */

DROP TABLE IF EXISTS `user_permission`;

CREATE TABLE `user_permission` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int NOT NULL,
  `uid` int NOT NULL,
  `date` date DEFAULT NULL,
  `time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mod` (`module_id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=latin1;

/*Data for the table `user_permission` */

insert  into `user_permission`(`id`,`module_id`,`uid`,`date`,`time`) values 
(142,1,1,'2026-05-25','23:11:28'),
(143,2,1,'2026-05-25','23:11:28'),
(144,3,1,'2026-05-25','23:11:28'),
(145,4,1,'2026-05-25','23:11:28'),
(146,5,1,'2026-05-25','23:11:28'),
(147,6,1,'2026-05-25','23:11:28'),
(148,7,1,'2026-05-25','23:11:28'),
(149,8,1,'2026-05-25','23:11:28'),
(150,1,25,'2026-05-25','23:11:33'),
(151,2,25,'2026-05-25','23:11:33'),
(152,3,25,'2026-05-25','23:11:33'),
(153,4,25,'2026-05-25','23:11:33'),
(154,5,25,'2026-05-25','23:11:33'),
(155,6,25,'2026-05-25','23:11:33'),
(156,7,25,'2026-05-25','23:11:33'),
(157,8,25,'2026-05-25','23:11:33');

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `is_active` int DEFAULT '1',
  `fullName` varchar(255) DEFAULT NULL,
  `disc_per` int DEFAULT '100',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;

/*Data for the table `users` */

insert  into `users`(`id`,`user_name`,`password`,`is_active`,`fullName`,`disc_per`) values 
(1,'admin','aecbf9a63cec1e93327dfc212f31acdb31c4f5d10bedccf8fbb8b042a6f0f39155797bdd04517905ae5d98b69fdc452cdb61b018e10939740ec96f36e133d639',1,'admin',50),
(25,'moulana','7f79508b2a02ed50f3ba563ab44d58d8aaf38c834900f5b1c0f50aaaf5123a223b58aa27dadb98d1acc5de986e6427478b698988e1f3c458c0dafc7eb666e6e5',1,'moulana',100);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
