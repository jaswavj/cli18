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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `service_bill` */

insert  into `service_bill`(`id`,`bill_no`,`bill_date`,`customer_name`,`phone`,`subtotal`,`discount`,`total_amount`,`paid_amount`,`balance`,`pay_mode_id`,`pay_mode_name`,`DESCRIPTION`,`created_by`,`created_at`) values 
(2,'26-1','2026-06-01','BALAMURUGAN PITCHAIKKANNU','9786057464',15000.00,0.00,15000.00,15000.00,0.00,1,'CASH PAYMENT','B',25,'2026-06-01 12:07:03');

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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `service_bill_items` */

insert  into `service_bill_items`(`id`,`bill_id`,`service_name`,`cost`) values 
(1,2,'DUBAI VISA',15000.00);

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
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking` */

insert  into `ticket_booking`(`id`,`pnr`,`ticket_no`,`booking_date`,`oneway_travel_date`,`oneway_travel_time`,`oneway_from_id`,`oneway_to_id`,`oneway_flight_no`,`oneway_airlines`,`return_travel_date`,`return_travel_time`,`return_from_id`,`return_to_id`,`return_flight_no`,`return_airlines`,`no_of_seats`,`phone`,`buy_agent_id`,`buy_amount`,`buy_paid_amount`,`buy_payment_mode_id`,`sell_agent_id`,`sell_amount`,`sell_paid_amount`,`sell_payment_mode_id`,`customer_name`,`customer_amount`,`cust_paid_amount`,`is_cancelled`,`customer_payment_mode_id`,`created_by`,`created_at`,`buy_date_change_amt`,`buy_date_change_paid`,`sell_date_change_amt`,`sell_date_change_paid`,`cancel_charge_buy`,`refund_received_buy`,`cancel_charge_sell`,`refund_to_sell`) values 
(1,'D879XZ','TKT-001','2026-04-08','2026-04-16','10:15:00',4,3,'132','SriLankan Airlines',NULL,NULL,NULL,NULL,NULL,NULL,1,'8531878715',1,38900.00,38900.00,2,NULL,NULL,0.00,NULL,NULL,40800.00,40800.00,0,1,25,'2026-05-29 12:30:47',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(2,'F827GJ','TKT-002','2026-04-06','2026-06-03','23:15:00',6,3,'529','SINGAPORE AIRLINES (SQ)',NULL,NULL,NULL,NULL,NULL,NULL,1,'+65 94475011',1,16000.00,16000.00,2,NULL,NULL,0.00,NULL,NULL,16900.00,16900.00,0,2,25,'2026-05-29 12:37:34',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(3,'MIGQEM','TKT-003','2026-05-27','2026-06-09','14:30:00',6,7,'609','Oman Air',NULL,NULL,NULL,NULL,NULL,NULL,1,'6385883628',1,17100.00,17100.00,2,NULL,NULL,0.00,NULL,NULL,17500.00,17000.00,0,1,25,'2026-05-29 15:14:15',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(4,'AGZ8JK','TKT-004','2026-05-28','2026-06-02','20:20:00',9,13,'321','FLYNAS (XY)',NULL,NULL,NULL,NULL,NULL,NULL,1,'8110981322',1,17770.00,17770.00,2,NULL,NULL,0.00,NULL,NULL,18800.00,18800.00,0,2,25,'2026-05-29 15:20:24',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(5,'8BFNHK','TKT-005','2026-05-28','2026-06-19','15:40:00',4,14,'134','SRILANKAN AIRLINES (UL)',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,1,29030.00,29030.00,2,NULL,NULL,0.00,NULL,NULL,29915.00,29915.00,0,2,25,'2026-05-29 18:17:25',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(6,'T7YT4G','TKT-006','2026-04-01','2026-04-16','03:30:00',4,3,'690','AIR INDIA EXPRESS (IX)',NULL,NULL,NULL,NULL,NULL,NULL,1,'6369727158',3,17500.00,17500.00,2,NULL,NULL,0.00,NULL,NULL,18500.00,18500.00,0,1,25,'2026-05-29 18:35:43',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(7,'CJXQCU','TKT-007','2026-04-01','2026-04-03','08:15:00',6,9,'252','Oman Air',NULL,NULL,NULL,NULL,NULL,NULL,1,'8072821579',10,33000.00,33000.00,2,NULL,NULL,0.00,NULL,NULL,33900.00,33900.00,0,1,25,'2026-05-29 18:43:25',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(8,'XZPKQB','TKT-008','2026-04-02','2026-04-05','03:30:00',4,3,'690','AIR INDIA EXPRESS (IX)',NULL,NULL,NULL,NULL,NULL,NULL,1,'9360538282',12,29000.00,29000.00,2,NULL,NULL,0.00,NULL,NULL,31000.00,31000.00,0,1,25,'2026-05-29 18:50:21',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(9,'X932RP','TKT-009','2026-05-28','2026-07-04','02:44:00',3,4,NULL,'IndiGo',NULL,NULL,NULL,NULL,NULL,NULL,1,'+65 84304930',10,23113.75,23113.75,2,NULL,NULL,0.00,NULL,NULL,24100.00,24100.00,0,2,25,'2026-05-29 19:58:43',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(10,'JB7MVJ','TKT-010','2026-05-29','2026-06-03',NULL,4,3,'759','SCOOT (TR)',NULL,NULL,NULL,NULL,NULL,NULL,1,'8122698123',2,37500.00,0.00,NULL,NULL,NULL,0.00,NULL,NULL,39500.00,5000.00,0,1,25,'2026-05-29 20:02:37',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(11,'C64ZQI','TKT-011','2026-05-29','2026-06-17',NULL,4,3,'759','SCOOT (TR)',NULL,NULL,NULL,NULL,NULL,NULL,1,'8015737941',2,24500.00,0.00,NULL,NULL,NULL,0.00,NULL,NULL,26000.00,26000.00,0,1,25,'2026-05-29 20:09:23',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(12,'OEIZFN','TKT-012','2026-04-02','2026-04-11','21:40:00',3,4,'758','SCOOT (TR)',NULL,NULL,NULL,NULL,NULL,NULL,1,'9715825688',8,18000.00,18000.00,2,NULL,NULL,0.00,NULL,NULL,20800.00,20800.00,0,1,25,'2026-06-01 12:17:02',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(13,'BB2S9H','TKT-013','2026-04-02','2026-05-06','03:30:00',4,3,'690','AIR INDIA EXPRESS (IX)',NULL,NULL,NULL,NULL,NULL,NULL,1,'9715825688',1,15896.00,15896.00,2,NULL,NULL,0.00,NULL,NULL,16800.00,16800.00,0,1,25,'2026-06-01 12:21:19',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(14,'F4BWJP','TKT-014','2026-04-02','2026-04-12','16:35:00',4,3,'682','AIR INDIA EXPRESS (IX)',NULL,NULL,NULL,NULL,NULL,NULL,1,'9566840346',1,19781.00,19781.00,2,NULL,NULL,0.00,NULL,NULL,20900.00,20900.00,0,1,25,'2026-06-02 11:06:48',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(15,'FZPDKL','TKT-015','2026-04-02','2026-04-07','03:30:00',4,3,'690','AIR INDIA EXPRESS (IX)',NULL,NULL,NULL,NULL,NULL,NULL,1,'+65 90364654',12,26000.00,26000.00,2,NULL,NULL,0.00,NULL,NULL,20000.00,27500.00,0,2,25,'2026-06-02 11:12:12',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(16,'W6S13V','TKT-016','2026-04-02','2026-04-05','22:55:00',3,4,'766','SCOOT (TR)',NULL,NULL,NULL,NULL,NULL,NULL,1,'9488415876',8,16000.00,16000.00,2,NULL,NULL,0.00,NULL,NULL,10000.00,10000.00,0,1,25,'2026-06-02 11:43:32',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(17,'XGZVGI','TKT-017','2026-05-26','2026-06-12','22:55:00',3,4,'766','SCOOT (TR)',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,8,38000.00,0.00,NULL,13,39500.00,0.00,NULL,NULL,NULL,0.00,0,NULL,25,'2026-06-02 12:21:21',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(18,'WFK9RX','TKT-018','2026-06-02','2026-06-16','18:45:00',4,3,'6E 1007','IndiGo',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,1,28142.00,28142.00,2,13,29200.00,0.00,NULL,NULL,NULL,0.00,0,NULL,25,'2026-06-02 12:28:18',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(19,'GE3QHN','TKT-019','2026-05-18','2026-06-16',NULL,3,4,'758','SCOOT (TR)',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,9,27500.00,0.00,NULL,13,28500.00,0.00,NULL,NULL,NULL,0.00,0,NULL,25,'2026-06-02 12:32:11',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(20,'N6E63C','TKT-020','2026-05-25','2026-07-02','02:45:00',3,4,'C6E 1008','IndiGo',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,1,19600.00,19600.00,2,13,20700.00,0.00,NULL,NULL,NULL,0.00,0,NULL,25,'2026-06-02 12:57:08',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(21,'D9MNHW','TKT-021','2026-05-26','2026-06-14',NULL,3,4,NULL,'IndiGo','2026-06-19',NULL,4,3,NULL,'IndiGo',1,NULL,1,63642.00,63642.00,2,13,65530.00,0.00,NULL,NULL,NULL,0.00,0,NULL,25,'2026-06-02 13:26:40',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00),
(22,'MHDF2R','TKT-022','2026-05-03','2026-05-09',NULL,3,4,NULL,'SCOOT (TR)',NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,8,28000.00,0.00,NULL,13,30000.00,0.00,NULL,NULL,NULL,0.00,0,NULL,25,'2026-06-02 13:37:26',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00);

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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking_log` */

insert  into `ticket_booking_log`(`id`,`booking_id`,`ticket_no`,`pnr`,`action_type`,`changed_by`,`user_name`,`change_date`,`change_time`,`remarks`,`DESCRIPTION`) values 
(1,2,'TKT-002','F827GJ','EDIT',25,'moulana','2026-05-29','12:41:16','','Booking Date: 2026-05-29 → 2026-04-06\nTravel Time:  → 23:15'),
(2,15,'TKT-015','FZPDKL','EDIT',25,'moulana','2026-06-02','11:15:26','','Cust Amt: 27500.00 → 20000.00');

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

/*Table structure for table `ticket_flightno` */

DROP TABLE IF EXISTS `ticket_flightno`;

CREATE TABLE `ticket_flightno` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_flightno_value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_flightno` */

insert  into `ticket_flightno`(`id`,`value`) values 
(4,'132'),
(9,'134'),
(11,'252'),
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
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_ledger` */

insert  into `ticket_ledger`(`id`,`booking_id`,`party_type`,`party_name`,`agent_id`,`bill_amount`,`transaction_type`,`amount`,`payment_mode_id`,`transaction_no`,`remarks`,`transaction_date`,`created_at`,`charge_type`,`created_by`,`cancel_charge`) values 
(1,1,'BUY_AGENT',NULL,1,38900.00,'CR',38900.00,2,'.','Buy ticket | PNR: D879XZ','2026-04-08','2026-05-29 12:30:47','ORIGINAL',25,NULL),
(2,1,'CUSTOMER','-',NULL,40800.00,'DR',40800.00,1,NULL,'Customer payment | PNR: D879XZ','2026-04-08','2026-05-29 12:30:47','ORIGINAL',25,NULL),
(3,2,'BUY_AGENT',NULL,1,16000.00,'CR',16000.00,2,'.','Buy ticket | PNR: F827GJ','2026-05-29','2026-05-29 12:37:34','ORIGINAL',25,NULL),
(4,2,'CUSTOMER','-',NULL,16900.00,'DR',16900.00,2,'.','Customer payment | PNR: F827GJ','2026-05-29','2026-05-29 12:37:34','ORIGINAL',25,NULL),
(5,3,'BUY_AGENT',NULL,1,17100.00,'CR',17100.00,2,'.','Buy ticket | PNR: MIGQEM','2026-05-27','2026-05-29 15:14:15','ORIGINAL',25,NULL),
(6,3,'CUSTOMER','-',NULL,17500.00,'DR',17000.00,1,NULL,'Customer payment | PNR: MIGQEM','2026-05-27','2026-05-29 15:14:15','ORIGINAL',25,NULL),
(7,4,'BUY_AGENT',NULL,1,17770.00,'CR',17770.00,2,'.','Buy ticket | PNR: AGZ8JK','2026-05-28','2026-05-29 15:20:24','ORIGINAL',25,NULL),
(8,4,'CUSTOMER','-',NULL,18800.00,'DR',18800.00,2,'.','Customer payment | PNR: AGZ8JK','2026-05-28','2026-05-29 15:20:24','ORIGINAL',25,NULL),
(9,5,'BUY_AGENT',NULL,1,29030.00,'CR',29030.00,2,'.','Buy ticket | PNR: 8BFNHK','2026-05-28','2026-05-29 18:17:25','ORIGINAL',25,NULL),
(10,5,'CUSTOMER','-',NULL,29915.00,'DR',29915.00,2,'.','Customer payment | PNR: 8BFNHK','2026-05-28','2026-05-29 18:17:25','ORIGINAL',25,NULL),
(11,6,'BUY_AGENT',NULL,3,17500.00,'CR',17500.00,2,'.','Buy ticket | PNR: T7YT4G','2026-04-01','2026-05-29 18:35:43','ORIGINAL',25,NULL),
(12,6,'CUSTOMER','-',NULL,18500.00,'DR',18500.00,1,NULL,'Customer payment | PNR: T7YT4G','2026-04-01','2026-05-29 18:35:43','ORIGINAL',25,NULL),
(13,7,'BUY_AGENT',NULL,10,33000.00,'CR',33000.00,2,'.','Buy ticket | PNR: CJXQCU','2026-04-01','2026-05-29 18:43:25','ORIGINAL',25,NULL),
(14,7,'CUSTOMER','-',NULL,33900.00,'DR',33900.00,1,NULL,'Customer payment | PNR: CJXQCU','2026-04-01','2026-05-29 18:43:25','ORIGINAL',25,NULL),
(15,8,'BUY_AGENT',NULL,12,29000.00,'CR',29000.00,2,',','Buy ticket | PNR: XZPKQB','2026-04-02','2026-05-29 18:50:21','ORIGINAL',25,NULL),
(16,8,'CUSTOMER','-',NULL,31000.00,'DR',31000.00,1,NULL,'Customer payment | PNR: XZPKQB','2026-04-02','2026-05-29 18:50:21','ORIGINAL',25,NULL),
(17,9,'BUY_AGENT',NULL,10,23113.75,'CR',23113.75,2,'0','Buy ticket | PNR: X932RP','2026-05-28','2026-05-29 19:58:43','ORIGINAL',25,NULL),
(18,9,'CUSTOMER','-',NULL,24100.00,'DR',24100.00,2,'PH PAY','Customer payment | PNR: X932RP','2026-05-28','2026-05-29 19:58:43','ORIGINAL',25,NULL),
(19,10,'BUY_AGENT',NULL,2,37500.00,'CR',0.00,NULL,NULL,'Buy ticket | PNR: JB7MVJ','2026-05-29','2026-05-29 20:02:37','ORIGINAL',25,NULL),
(20,10,'CUSTOMER','-',NULL,39500.00,'DR',5000.00,1,NULL,'Customer payment | PNR: JB7MVJ','2026-05-29','2026-05-29 20:02:37','ORIGINAL',25,NULL),
(21,10,'CUSTOMER','-',NULL,0.00,'DR',5000.00,2,'ICIC QR','Balance collection','2026-05-29','2026-05-29 20:03:22','ORIGINAL',25,NULL),
(22,11,'BUY_AGENT',NULL,2,24500.00,'CR',0.00,NULL,NULL,'Buy ticket | PNR: C64ZQI','2026-05-29','2026-05-29 20:09:23','ORIGINAL',25,NULL),
(23,11,'CUSTOMER','-',NULL,26000.00,'DR',26000.00,1,NULL,'Customer payment | PNR: C64ZQI','2026-05-29','2026-05-29 20:09:23','ORIGINAL',25,NULL),
(24,10,'CUSTOMER','-',NULL,0.00,'DR',29500.00,1,NULL,'Balance collection','2026-05-30','2026-05-30 11:54:12','ORIGINAL',25,NULL),
(25,12,'BUY_AGENT',NULL,8,18000.00,'CR',18000.00,2,'.','Buy ticket | PNR: OEIZFN','2026-04-02','2026-06-01 12:17:02','ORIGINAL',25,NULL),
(26,12,'CUSTOMER','-',NULL,20800.00,'DR',20800.00,1,NULL,'Customer payment | PNR: OEIZFN','2026-04-02','2026-06-01 12:17:02','ORIGINAL',25,NULL),
(27,13,'BUY_AGENT',NULL,1,15896.00,'CR',15896.00,2,'.','Buy ticket | PNR: BB2S9H','2026-04-02','2026-06-01 12:21:19','ORIGINAL',25,NULL),
(28,13,'CUSTOMER','-',NULL,16800.00,'DR',16800.00,1,NULL,'Customer payment | PNR: BB2S9H','2026-04-02','2026-06-01 12:21:19','ORIGINAL',25,NULL),
(29,14,'BUY_AGENT',NULL,1,19781.00,'CR',19781.00,2,'.','Buy ticket | PNR: F4BWJP','2026-04-02','2026-06-02 11:06:48','ORIGINAL',25,NULL),
(30,14,'CUSTOMER','-',NULL,20900.00,'DR',20900.00,1,NULL,'Customer payment | PNR: F4BWJP','2026-04-02','2026-06-02 11:06:48','ORIGINAL',25,NULL),
(31,15,'BUY_AGENT',NULL,12,26000.00,'CR',26000.00,2,'.','Buy ticket | PNR: FZPDKL','2026-04-02','2026-06-02 11:12:12','ORIGINAL',25,NULL),
(32,15,'CUSTOMER','-',NULL,20000.00,'DR',27500.00,2,'.','Customer payment | PNR: FZPDKL','2026-04-02','2026-06-02 11:12:12','ORIGINAL',25,NULL),
(34,3,'CUSTOMER','-',NULL,0.00,'DR',500.00,2,'.','Balance collection','2026-06-02','2026-06-02 11:19:31','ORIGINAL',25,NULL),
(36,16,'BUY_AGENT',NULL,8,16000.00,'CR',16000.00,2,'.','Buy ticket | PNR: W6S13V','2026-04-02','2026-06-02 11:43:32','ORIGINAL',25,NULL),
(37,16,'CUSTOMER','-',NULL,10000.00,'DR',10000.00,1,NULL,'Customer payment | PNR: W6S13V','2026-04-02','2026-06-02 11:43:32','ORIGINAL',25,NULL),
(38,15,'CUSTOMER','-',NULL,0.00,'CR',7500.00,2,'.','Balance collection','2026-06-02','2026-06-02 11:44:43','ORIGINAL',25,NULL),
(39,17,'BUY_AGENT',NULL,8,38000.00,'CR',0.00,NULL,NULL,'Buy ticket | PNR: XGZVGI','2026-05-26','2026-06-02 12:21:21','ORIGINAL',25,NULL),
(40,17,'SELL_AGENT',NULL,13,39500.00,'DR',0.00,NULL,NULL,'Sell ticket | PNR: XGZVGI','2026-05-26','2026-06-02 12:21:21','ORIGINAL',25,NULL),
(41,18,'BUY_AGENT',NULL,1,28142.00,'CR',28142.00,2,'I','Buy ticket | PNR: WFK9RX','2026-06-02','2026-06-02 12:28:18','ORIGINAL',25,NULL),
(42,18,'SELL_AGENT',NULL,13,29200.00,'DR',0.00,NULL,NULL,'Sell ticket | PNR: WFK9RX','2026-06-02','2026-06-02 12:28:18','ORIGINAL',25,NULL),
(43,19,'BUY_AGENT',NULL,9,27500.00,'CR',0.00,NULL,NULL,'Buy ticket | PNR: GE3QHN','2026-05-18','2026-06-02 12:32:11','ORIGINAL',25,NULL),
(44,19,'SELL_AGENT',NULL,13,28500.00,'DR',0.00,NULL,NULL,'Sell ticket | PNR: GE3QHN','2026-05-18','2026-06-02 12:32:11','ORIGINAL',25,NULL),
(45,20,'BUY_AGENT',NULL,1,19600.00,'CR',19600.00,2,'IC','Buy ticket | PNR: N6E63C','2026-05-25','2026-06-02 12:57:08','ORIGINAL',25,NULL),
(46,20,'SELL_AGENT',NULL,13,20700.00,'DR',0.00,NULL,NULL,'Sell ticket | PNR: N6E63C','2026-05-25','2026-06-02 12:57:08','ORIGINAL',25,NULL),
(47,20,'SELL_AGENT',NULL,13,0.00,'DR',20700.00,1,NULL,'Balance collection','2026-06-01','2026-06-02 12:58:16','ORIGINAL',25,NULL),
(49,21,'BUY_AGENT',NULL,1,63642.00,'CR',63642.00,2,'IC','Buy ticket | PNR: D9MNHW','2026-05-26','2026-06-02 13:26:40','ORIGINAL',25,NULL),
(50,21,'SELL_AGENT',NULL,13,65530.00,'DR',0.00,NULL,NULL,'Sell ticket | PNR: D9MNHW','2026-05-26','2026-06-02 13:26:40','ORIGINAL',25,NULL),
(51,22,'BUY_AGENT',NULL,8,28000.00,'CR',0.00,NULL,NULL,'Buy ticket | PNR: MHDF2R','2026-05-03','2026-06-02 13:37:26','ORIGINAL',25,NULL),
(52,22,'SELL_AGENT',NULL,13,30000.00,'DR',0.00,NULL,NULL,'Sell ticket | PNR: MHDF2R','2026-05-03','2026-06-02 13:37:26','ORIGINAL',25,NULL),
(53,22,'SELL_AGENT',NULL,13,0.00,'DR',30000.00,1,NULL,'Balance collection','2026-06-03','2026-06-03 15:07:48','ORIGINAL',1,NULL);

/*Table structure for table `ticket_passenger` */

DROP TABLE IF EXISTS `ticket_passenger`;

CREATE TABLE `ticket_passenger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `seat_no` int DEFAULT NULL,
  `passenger_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_passenger_booking` (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_passenger` */

insert  into `ticket_passenger`(`id`,`booking_id`,`seat_no`,`passenger_name`) values 
(1,1,1,'Mr. ENIYAVAN SEKAR'),
(3,2,1,'Mr.MURUGANANTHAM BALAJI'),
(4,3,1,'Mr. NASURDEEN ISMAYIL'),
(5,4,1,'Mr.IBRAHIM IDRIS KASAMBHAI SHEKH'),
(6,5,1,'Mr.MOHAMED SAMEER SIRAJUDEEN'),
(7,6,1,'RAJESHKANNAN / RAJASEKAR'),
(8,7,1,'MR . Nagoor Meera Mohamed Ibrahim'),
(9,8,1,'MR. MOHANRAJ ARUNACHALAM'),
(10,9,1,'MR. SUTHAKAR / GANESAN'),
(11,10,1,'MR. RISHIVARAN / NAGARAJAN'),
(12,11,1,'MR. DHARMALINGAM / UTHIRAPATHI'),
(13,12,1,'Mr. BALRASU TAMILARASAN'),
(14,13,1,'Mr. BALRASU TAMILARASAN'),
(15,14,1,'MR. VEERAMMAL / RAMESH'),
(17,15,1,'MR. KUMARESAN / MURUGAN'),
(18,16,1,'MR. SAMINATHAN / CHINNAKKANNU'),
(19,17,1,'Mr. DURAIRAJ  YOGANATHAN'),
(20,18,1,'Mr.YOGANATHAN DURAIRAJ'),
(21,19,1,'Mr. SELVARAJ SENGUTTUVAN'),
(22,20,1,'Mr. VENKATESAN MUTHU'),
(23,21,1,'Mr. RAMESH RAMACHANDRAN'),
(24,22,1,'MR . SABARINATHAN SHANMUGAVADIVEL');

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
