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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_agent` */

insert  into `ticket_agent`(`id`,`name`,`is_active`) values 
(1,'AOS',1),
(2,'FOY',1);

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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_booking` */

insert  into `ticket_booking`(`id`,`pnr`,`ticket_no`,`booking_date`,`oneway_travel_date`,`oneway_travel_time`,`oneway_from_id`,`oneway_to_id`,`oneway_flight_no`,`oneway_airlines`,`return_travel_date`,`return_travel_time`,`return_from_id`,`return_to_id`,`return_flight_no`,`return_airlines`,`no_of_seats`,`phone`,`buy_agent_id`,`buy_amount`,`buy_paid_amount`,`buy_payment_mode_id`,`sell_agent_id`,`sell_amount`,`sell_paid_amount`,`sell_payment_mode_id`,`customer_name`,`customer_amount`,`cust_paid_amount`,`customer_payment_mode_id`,`created_by`,`created_at`) values 
(1,'PNR1','TKT-001','2026-05-19','2026-05-23','22:31:00',4,3,'1','Indigo',NULL,NULL,NULL,NULL,NULL,NULL,1,'9876543210',1,1000.00,200.00,2,NULL,NULL,NULL,NULL,'JAS',2000.00,1200.00,2,1,'2026-05-19 22:32:13'),
(2,'PNR2','TKT-002','2026-05-19','2026-05-28','22:34:00',2,3,'2','Indigo',NULL,NULL,NULL,NULL,NULL,NULL,1,'9876543210',NULL,NULL,NULL,NULL,1,5000.00,2000.00,2,NULL,NULL,NULL,NULL,1,'2026-05-19 22:35:15'),
(3,'pnr3','TKT-003','2026-05-19','2026-05-23','22:54:00',3,2,'3','Indigo','2026-05-30','22:59:00',2,3,'3','Indigo',1,'15156156516',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ass',1000.00,1000.00,2,1,'2026-05-19 22:55:08');

/*Table structure for table `ticket_city` */

DROP TABLE IF EXISTS `ticket_city`;

CREATE TABLE `ticket_city` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_active` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_city` */

insert  into `ticket_city`(`id`,`name`,`is_active`) values 
(1,'nagercoil city',1),
(2,'Thiruvananthapuram',1),
(3,'Delhi',1),
(4,'Nagercoil',1);

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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_ledger` */

insert  into `ticket_ledger`(`id`,`booking_id`,`party_type`,`party_name`,`agent_id`,`bill_amount`,`transaction_type`,`amount`,`payment_mode_id`,`remarks`,`transaction_date`,`created_at`) values 
(1,1,'BUY_AGENT',NULL,1,1000.00,'CR',200.00,2,'Buy ticket | PNR: PNR1','2026-05-19','2026-05-19 22:32:13'),
(2,1,'CUSTOMER','JAS',NULL,2000.00,'DR',1200.00,2,'Customer payment | PNR: PNR1','2026-05-19','2026-05-19 22:32:13'),
(3,1,'BUY_AGENT',NULL,1,0.00,'CR',500.00,2,'Balance collection','2026-05-19','2026-05-19 22:32:43'),
(4,2,'SELL_AGENT',NULL,1,5000.00,'DR',2000.00,2,'Sell ticket | PNR: PNR2','2026-05-19','2026-05-19 22:35:15'),
(5,3,'CUSTOMER','ass',NULL,1000.00,'DR',1000.00,2,'Customer payment | PNR: pnr3','2026-05-19','2026-05-19 22:55:08');

/*Table structure for table `ticket_passenger` */

DROP TABLE IF EXISTS `ticket_passenger`;

CREATE TABLE `ticket_passenger` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` int unsigned NOT NULL,
  `seat_no` int DEFAULT NULL,
  `passenger_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_passenger_booking` (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `ticket_passenger` */

insert  into `ticket_passenger`(`id`,`booking_id`,`seat_no`,`passenger_name`) values 
(1,1,1,'Jaswa Vijay'),
(2,2,1,'ASSSS'),
(3,3,1,'ass');

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
(1,'CASH',1),
(2,'UPI',1),
(3,'DEBIT CARD',1),
(4,'CREDIT CARD',1),
(5,'NEFT',1),
(6,'IMPS',1);

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
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=latin1;

/*Data for the table `user_permission` */

insert  into `user_permission`(`id`,`module_id`,`uid`,`date`,`time`) values 
(70,1,1,'2025-09-19','11:43:23'),
(71,2,1,'2025-09-19','11:43:23'),
(72,3,1,'2025-09-19','11:43:23'),
(73,4,1,'2025-09-19','11:43:23');

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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;

/*Data for the table `users` */

insert  into `users`(`id`,`user_name`,`password`,`is_active`,`fullName`,`disc_per`) values 
(1,'admin','aecbf9a63cec1e93327dfc212f31acdb31c4f5d10bedccf8fbb8b042a6f0f39155797bdd04517905ae5d98b69fdc452cdb61b018e10939740ec96f36e133d639',1,'admin',50);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
