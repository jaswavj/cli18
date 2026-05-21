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

/*Table structure for table `ticket_airline` */

DROP TABLE IF EXISTS `ticket_airline`;

CREATE TABLE `ticket_airline` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_airline_value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_airline` */

insert  into `ticket_airline`(`id`,`value`) values 
(10,'Air Arabia'),
(1,'Air India'),
(6,'AirAsia India'),
(7,'Blue Dart Aviation'),
(8,'Emirates'),
(11,'flydubai'),
(5,'GoAir'),
(2,'IndiGo'),
(16,'jas'),
(12,'Oman Air'),
(9,'Qatar Airways'),
(3,'SpiceJet'),
(13,'SriLankan Airlines'),
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking` */

insert  into `ticket_booking`(`id`,`pnr`,`ticket_no`,`booking_date`,`oneway_travel_date`,`oneway_travel_time`,`oneway_from_id`,`oneway_to_id`,`oneway_flight_no`,`oneway_airlines`,`return_travel_date`,`return_travel_time`,`return_from_id`,`return_to_id`,`return_flight_no`,`return_airlines`,`no_of_seats`,`phone`,`buy_agent_id`,`buy_amount`,`buy_paid_amount`,`buy_payment_mode_id`,`sell_agent_id`,`sell_amount`,`sell_paid_amount`,`sell_payment_mode_id`,`customer_name`,`customer_amount`,`cust_paid_amount`,`is_cancelled`,`customer_payment_mode_id`,`created_by`,`created_at`) values 
(1,'PNR1','TKT-001','2026-05-21','2026-05-23','15:36:00',10,2,'1','IndiGo',NULL,NULL,NULL,NULL,NULL,NULL,1,'9876543210',1,1000.00,0.00,NULL,NULL,NULL,0.00,NULL,'ref',2000.00,0.00,0,NULL,1,'2026-05-21 15:37:58'),
(2,'pnr2','TKT-002','2026-05-21','2026-05-28','17:52:00',7,4,'AY123','Blue Dart Aviation',NULL,NULL,NULL,NULL,NULL,NULL,1,'9876543211',10,1500.00,500.00,2,1,2000.00,500.00,2,NULL,NULL,0.00,0,NULL,1,'2026-05-21 15:54:09'),
(3,'pnr3','TKT-003','2026-05-21','2026-05-29','16:30:00',8,7,'fl1','jas',NULL,NULL,NULL,NULL,NULL,NULL,1,'9876543211',4,2000.00,1200.00,2,NULL,NULL,0.00,NULL,'aaaaa',2500.00,2200.00,0,2,1,'2026-05-21 16:32:00'),
(4,'pnr4','TKT-004','2026-05-21','2026-05-21','16:46:00',10,2,'FL1','JAS',NULL,NULL,NULL,NULL,NULL,NULL,1,'9876543211',5,500.00,100.00,2,NULL,NULL,0.00,NULL,'sasas',1000.00,200.00,0,2,1,'2026-05-21 16:47:18'),
(5,'pnr5','TKT-005','2026-05-21','2026-06-04','16:02:00',3,1,'FL1','jas',NULL,NULL,NULL,NULL,NULL,NULL,1,'9876543210',5,1000.00,1000.00,2,NULL,NULL,0.00,NULL,'ass',2000.00,2000.00,0,2,1,'2026-05-21 16:59:43'),
(6,'PNR6','TKT-006','2026-05-21','2026-05-31','17:33:00',8,7,'FL3','Air India','2026-06-05','17:33:00',7,8,'FL3','Air India',1,'1234567890',2,2000.00,500.00,2,NULL,NULL,0.00,NULL,'AY',1500.00,200.00,1,2,1,'2026-05-21 17:36:10'),
(7,'PNR7','TKT-007','2026-05-20','2026-05-21','17:57:00',7,6,'1234','Air India',NULL,NULL,NULL,NULL,NULL,NULL,2,'9876543210',8,200.00,50.00,2,3,300.00,100.00,2,NULL,NULL,0.00,0,NULL,1,'2026-05-21 17:58:35');

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
  `description` text,
  PRIMARY KEY (`id`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_change_date` (`change_date`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking_log` */

insert  into `ticket_booking_log`(`id`,`booking_id`,`ticket_no`,`pnr`,`action_type`,`changed_by`,`user_name`,`change_date`,`change_time`,`remarks`,`description`) values 
(1,6,'TKT-006','PNR6','EDIT',1,'admin','2026-05-21','17:38:11','',NULL),
(2,6,'TKT-006','PNR6','CANCEL',1,'admin','2026-05-21','17:43:30','asasd',NULL),
(3,7,'TKT-007','PNR7','EDIT',1,'admin','2026-05-21','17:59:41','','Booking Date: 2026-05-21 → 2026-05-20\nTravel Date: 2026-05-22 → 2026-05-21\nFrom: CHENNAI (MAA) → DUBAI (DXB)\nTo: DUBAI (DXB) → CHENNAI (MAA)\nFlight No: 123 → 1234\nAirlines: Air Arabia → Air India\nBuy Agent: WASEEMA AIR TRAVELS (SHAUL) → SHREYAA AIR TRAVELS\nBuy Amt: 100.00 → 200.00\nSell Agent: SMART(AMEEN) AIR TRAVELS → SHREE AIR TRAVELS\nSell Amt: 200.00 → 300.00');

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

/*Table structure for table `ticket_flightno` */

DROP TABLE IF EXISTS `ticket_flightno`;

CREATE TABLE `ticket_flightno` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_flightno_value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_flightno` */

insert  into `ticket_flightno`(`id`,`value`) values 
(10,'123'),
(11,'1234'),
(5,'FL1'),
(6,'FL2'),
(8,'FL3');

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
  PRIMARY KEY (`id`),
  KEY `idx_ticket_ledger_agent` (`agent_id`),
  KEY `idx_ticket_ledger_booking` (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_ledger` */

insert  into `ticket_ledger`(`id`,`booking_id`,`party_type`,`party_name`,`agent_id`,`bill_amount`,`transaction_type`,`amount`,`payment_mode_id`,`transaction_no`,`remarks`,`transaction_date`,`created_at`) values 
(1,1,'BUY_AGENT',NULL,1,1000.00,'CR',0.00,NULL,NULL,'Buy ticket | PNR: PNR1','2026-05-21','2026-05-21 15:37:58'),
(2,1,'CUSTOMER','ref',NULL,2000.00,'DR',0.00,NULL,NULL,'Customer payment | PNR: PNR1','2026-05-21','2026-05-21 15:37:58'),
(3,1,'CUSTOMER','ref',NULL,0.00,'DR',1000.00,2,NULL,'Balance collection','2026-05-21','2026-05-21 15:40:56'),
(4,1,'CUSTOMER','ref',NULL,0.00,'DR',500.00,2,NULL,'Balance collection','2026-05-21','2026-05-21 15:52:09'),
(5,2,'BUY_AGENT',NULL,10,1500.00,'CR',500.00,2,NULL,'Buy ticket | PNR: pnr2','2026-05-21','2026-05-21 15:54:09'),
(6,2,'SELL_AGENT',NULL,1,2000.00,'DR',500.00,2,NULL,'Sell ticket | PNR: pnr2','2026-05-21','2026-05-21 15:54:09'),
(7,2,'SELL_AGENT',NULL,1,0.00,'DR',200.00,2,NULL,'Balance collection','2026-05-21','2026-05-21 15:54:56'),
(8,1,'BUY_AGENT',NULL,1,0.00,'CR',250.00,2,NULL,'Balance collection','2026-05-21','2026-05-21 15:56:23'),
(9,3,'BUY_AGENT',NULL,4,2000.00,'CR',1200.00,2,'123','Buy ticket | PNR: pnr3','2026-05-21','2026-05-21 16:32:00'),
(10,3,'CUSTOMER','aaaaa',NULL,2500.00,'DR',2200.00,2,'1234','Customer payment | PNR: pnr3','2026-05-21','2026-05-21 16:32:00'),
(11,3,'CUSTOMER','aaaaa',NULL,0.00,'DR',100.00,2,'4321','Balance collection','2026-05-21','2026-05-21 16:35:10'),
(12,4,'BUY_AGENT',NULL,5,500.00,'CR',100.00,2,'1212','Buy ticket | PNR: pnr4','2026-05-21','2026-05-21 16:47:18'),
(13,4,'CUSTOMER','sasas',NULL,1000.00,'DR',200.00,2,'2121','Customer payment | PNR: pnr4','2026-05-21','2026-05-21 16:47:18'),
(14,5,'BUY_AGENT',NULL,5,1000.00,'CR',1000.00,2,'222','Buy ticket | PNR: pnr5','2026-05-21','2026-05-21 16:59:43'),
(15,5,'CUSTOMER','ass',NULL,2000.00,'DR',2000.00,2,'222','Customer payment | PNR: pnr5','2026-05-21','2026-05-21 16:59:43'),
(16,6,'BUY_AGENT',NULL,2,2000.00,'CR',500.00,2,'12345','Buy ticket | PNR: PNR6','2026-05-20','2026-05-21 17:36:10'),
(17,6,'CUSTOMER','AY',NULL,1500.00,'DR',200.00,2,'54321','Customer payment | PNR: PNR6','2026-05-20','2026-05-21 17:36:10'),
(18,7,'BUY_AGENT',NULL,5,200.00,'CR',50.00,2,'12312','Buy ticket | PNR: PNR7','2026-05-21','2026-05-21 17:58:35'),
(19,7,'SELL_AGENT',NULL,7,300.00,'DR',100.00,2,'1','Sell ticket | PNR: PNR7','2026-05-21','2026-05-21 17:58:35');

/*Table structure for table `ticket_passenger` */

DROP TABLE IF EXISTS `ticket_passenger`;

CREATE TABLE `ticket_passenger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `seat_no` int DEFAULT NULL,
  `passenger_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_passenger_booking` (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_passenger` */

insert  into `ticket_passenger`(`id`,`booking_id`,`seat_no`,`passenger_name`) values 
(1,1,1,'jaswavj'),
(2,2,1,'sdsddsds'),
(3,3,1,'aaaaaaa'),
(4,4,1,'sss'),
(5,5,1,'dddd'),
(7,6,1,'AYY'),
(10,7,1,'ass'),
(11,7,2,'arr');

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
(2,'ONLINE PAYMENT',1);

/*Table structure for table `user_modules` */

DROP TABLE IF EXISTS `user_modules`;

CREATE TABLE `user_modules` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `module_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

/*Data for the table `user_modules` */

insert  into `user_modules`(`id`,`module_name`) values 
(1,'Ticket'),
(2,'Master'),
(3,'User management'),
(4,'Admin'),
(5,'Report'),
(6,'Edit/Cancel');

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
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=latin1;

/*Data for the table `user_permission` */

insert  into `user_permission`(`id`,`module_id`,`uid`,`date`,`time`) values 
(70,1,1,'2025-09-19','11:43:23'),
(71,2,1,'2025-09-19','11:43:23'),
(72,3,1,'2025-09-19','11:43:23'),
(73,4,1,'2025-09-19','11:43:23'),
(120,1,25,'2026-05-20','16:26:19'),
(121,2,25,'2026-05-20','16:26:19'),
(122,3,25,'2026-05-20','16:26:19'),
(123,4,25,'2026-05-20','16:26:19'),
(124,5,1,'2026-05-20','16:26:19'),
(125,5,25,'2026-05-20','16:26:19'),
(126,6,1,'2026-05-20','16:26:19');

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
