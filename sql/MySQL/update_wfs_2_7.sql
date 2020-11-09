/*
Company: OptimaJet
Project: WorkflowServer Provider for MySQL
Version: 2.7
File: update_wfs_2_7.sql
*/

CREATE TABLE IF NOT EXISTS `workflowserveruser`
(
	`Id` binary(16) NOT NULL,
	`Name` varchar(256) NOT NULL,
	`Email` varchar(256) NULL,
        `Phone` varchar(256) NULL,
	`IsLocked` bit(1) NOT NULL DEFAULT 0,
	`ExternalId` varchar(1024) NULL,
	`Lock` binary(16) NOT NULL,
	`TenantId` varchar(1024) NULL,
	`Roles` text NULL,
	`Extensions` text NULL,
    PRIMARY KEY (`Id`)
);


CREATE TABLE IF NOT EXISTS `workflowserverusercredential`(
	`Id` binary(16) NOT NULL,
	`PasswordHash` varchar(128) NULL,
	`PasswordSalt` varchar(128) NULL,
	`UserId` binary(16) NOT NULL,
	`Login` varchar(256) NOT NULL,
	`AuthType` tinyint(4) NOT NULL,
	`TenantId` varchar(1024) NULL,
    `ExternalProviderName` varchar(256) NULL,
    PRIMARY KEY (`Id`),
    FOREIGN KEY (`UserId`) REFERENCES `workflowserveruser`(`Id`) ON DELETE CASCADE,
    INDEX `IX_workflowserverusercredential_UserId` (`UserId`),
    INDEX `IX_workflowserverusercredential_Login` (`Login`)
);

ALTER TABLE `WorkflowProcessInstance` ADD `SubprocessName`  longtext NULL;

UPDATE `WorkflowProcessInstance` SET  `SubprocessName` = `StartingTransition`;
