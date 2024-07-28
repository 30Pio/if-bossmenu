CREATE TABLE IF NOT EXISTS `bossmenu_application` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`job` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`citizenid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`gender` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`date` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`reason` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	INDEX `id` (`id`) USING BTREE
)COLLATE='utf8mb3_general_ci' ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `bossmenu_bills` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`job` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`rcdate` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`untildate` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`amount` INT(11) NULL DEFAULT NULL,
	`toname` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`tocitizenid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`fromname` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`fromcitizenid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	INDEX `id` (`id`) USING BTREE
) COLLATE='utf8mb3_general_ci' ENGINE=InnoDB;