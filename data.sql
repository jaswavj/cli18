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
(2,'MOULANA AIR TRAVELS','No 6, Orathanadu','',2,'','','AP4909');

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

/*Table structure for table `ticket_agent` */

DROP TABLE IF EXISTS `ticket_agent`;

CREATE TABLE `ticket_agent` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
(11,'RIYA AIR TRAVELS',1);

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
  `customer_payment_mode_id` int unsigned DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking` */

/*Table structure for table `ticket_city` */

DROP TABLE IF EXISTS `ticket_city`;

CREATE TABLE `ticket_city` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
(12,'KUALA LUMPUR (KUL)',1);

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
  `remarks` varchar(500) DEFAULT NULL,
  `transaction_date` date NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_ledger_agent` (`agent_id`),
  KEY `idx_ticket_ledger_booking` (`booking_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_ledger` */

/*Table structure for table `ticket_passenger` */

DROP TABLE IF EXISTS `ticket_passenger`;

CREATE TABLE `ticket_passenger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `seat_no` int DEFAULT NULL,
  `passenger_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_passenger_booking` (`booking_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_passenger` */

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
(4,'Admin');

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
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=latin1;

/*Data for the table `user_permission` */

insert  into `user_permission`(`id`,`module_id`,`uid`,`date`,`time`) values 
(70,1,1,'2025-09-19','11:43:23'),
(71,2,1,'2025-09-19','11:43:23'),
(72,3,1,'2025-09-19','11:43:23'),
(73,4,1,'2025-09-19','11:43:23'),
(120,1,25,'2026-05-20','16:26:19'),
(121,2,25,'2026-05-20','16:26:19'),
(122,3,25,'2026-05-20','16:26:19'),
(123,4,25,'2026-05-20','16:26:19');

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
