/*
Navicat MySQL Data Transfer

Source Server         : 10.10.0.169(高埗)
Source Server Version : 50626
Source Host           : 10.10.0.169:3306
Source Database       : airctrlmanager

Target Server Type    : MYSQL
Target Server Version : 50626
File Encoding         : 65001

Date: 2019-01-30 10:55:29
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `t_account_cas`
-- ----------------------------
DROP TABLE IF EXISTS `t_account_cas`;
CREATE TABLE `t_account_cas` (
  `name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `salt` varchar(255) NOT NULL,
  `status` int(50) NOT NULL,
  `depetIds` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of t_account_cas
-- ----------------------------
INSERT INTO `t_account_cas` VALUES ('admin', '60ffd0f610f76dbbfc787f0b4049b10d', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('dggb', '70446d04a37abd9389fe2a3e9506a24c', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('gbgc', '33db9677e1f69fffb8d10d4e1a601d19', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('haide', 'b55068f24c35f5eae15cf036ddb345b9', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('manager', '4fa5fd0ea7e0574e62617f33987f7a13', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('YZ-chenhh', '090b7bb07bd6df5eb49145722f868900', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('YZ-lyx', '46af888e52c27ce3d80050b9d850aa2a', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('YZ-renyun', '586eaca015849d53aa48ac3425893236', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
INSERT INTO `t_account_cas` VALUES ('YZ-xinjh', '794645f4d4bb3952f55604c6f46283f6', 'e843e2d04d58ae1f4ab13d39be660833', '1', '3');
