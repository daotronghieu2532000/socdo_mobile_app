-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 26, 2025 at 05:29 PM
-- Server version: 8.0.30
-- PHP Version: 8.2.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `socmoi`
--

-- --------------------------------------------------------

--
-- Table structure for table `sanpham`
--

CREATE TABLE `sanpham` (
  `id` int NOT NULL,
  `ma_sanpham` text NOT NULL,
  `tieu_de` varchar(255) NOT NULL,
  `minh_hoa` varchar(255) NOT NULL,
  `link` varchar(255) NOT NULL,
  `cat` varchar(255) NOT NULL,
  `gia_cu` int NOT NULL,
  `gia_moi` int NOT NULL,
  `gia_drop` int NOT NULL,
  `drop_min` int NOT NULL,
  `gia_ctv` int NOT NULL,
  `ctv_min` int NOT NULL,
  `noi_ban` varchar(160) NOT NULL,
  `noi_bat` text NOT NULL,
  `noi_dung` longtext NOT NULL,
  `mau` varchar(160) NOT NULL,
  `thuong_hieu` varchar(160) NOT NULL,
  `size` varchar(255) NOT NULL,
  `thongtin` text NOT NULL,
  `can_nang` varchar(160) NOT NULL,
  `anh` text NOT NULL,
  `sale` int NOT NULL,
  `kho` int NOT NULL,
  `kho_hcm` int NOT NULL,
  `ban` int NOT NULL,
  `box_banchay` int NOT NULL,
  `box_noibat` int NOT NULL,
  `cat_ma` int NOT NULL,
  `box_flash` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `view` int NOT NULL,
  `date_post` varchar(11) NOT NULL,
  `shop` int DEFAULT NULL,
  `status` int DEFAULT NULL,
  `kich_thuoc` varchar(255) NOT NULL,
  `can_nang_tinhship` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `sanpham`
--
ALTER TABLE `sanpham`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kho` (`kho`),
  ADD KEY `ban` (`ban`),
  ADD KEY `noi_ban` (`noi_ban`),
  ADD KEY `cat` (`cat`),
  ADD KEY `date_post` (`date_post`),
  ADD KEY `kho_hcm` (`kho_hcm`),
  ADD KEY `box_banchay` (`box_banchay`),
  ADD KEY `box_noibat` (`box_noibat`),
  ADD KEY `box_flash` (`box_flash`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `sanpham`
--
ALTER TABLE `sanpham`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
