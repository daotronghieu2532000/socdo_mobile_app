-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 19, 2024 at 12:00 PM
-- Server version: 10.1.48-MariaDB
-- PHP Version: 7.3.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `socdo`
--

-- --------------------------------------------------------

--
-- Table structure for table `notification_mobile`
--

CREATE TABLE `notification_mobile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(11) NOT NULL COMMENT 'ID người dùng nhận thông báo',
  `type` varchar(50) NOT NULL COMMENT 'Loại thông báo: order, affiliate_order, deposit, withdrawal, voucher_new, voucher_expiring',
  `title` varchar(255) NOT NULL COMMENT 'Tiêu đề thông báo',
  `content` text NOT NULL COMMENT 'Nội dung thông báo',
  `data` longtext DEFAULT NULL COMMENT 'Dữ liệu bổ sung (JSON string)',
  `related_id` int(11) DEFAULT NULL COMMENT 'ID liên quan (đơn hàng, voucher, etc.)',
  `related_type` varchar(50) DEFAULT NULL COMMENT 'Loại đối tượng liên quan: order, coupon, affiliate_order',
  `priority` enum('low','medium','high') DEFAULT 'medium' COMMENT 'Mức độ ưu tiên',
  `is_read` tinyint(1) DEFAULT 0 COMMENT '0: chưa đọc, 1: đã đọc',
  `read_at` int(11) DEFAULT NULL COMMENT 'Thời gian đọc (timestamp)',
  `created_at` int(11) NOT NULL COMMENT 'Thời gian tạo (timestamp)',
  `updated_at` int(11) DEFAULT NULL COMMENT 'Thời gian cập nhật (timestamp)',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `type` (`type`),
  KEY `is_read` (`is_read`),
  KEY `created_at` (`created_at`),
  KEY `related_id` (`related_id`),
  KEY `related_type` (`related_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Bảng thông báo cho mobile app';

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `notification_mobile`
--
ALTER TABLE `notification_mobile`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `notification_mobile`
--
ALTER TABLE `notification_mobile`
  ADD CONSTRAINT `fk_notification_mobile_user` FOREIGN KEY (`user_id`) REFERENCES `user_info` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
