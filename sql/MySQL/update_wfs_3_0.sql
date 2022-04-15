/*
Company: OptimaJet
Project: WorkflowServer Provider for MySQL
Version: 3.0
File: update_wfs_3_0.sql
*/

CREATE TABLE IF NOT EXISTS `workflowserverprocesslogs` (
    `Id`         binary(16)    NOT NULL,
    `ProcessId`  binary(16)    NOT NULL,
    `CreatedOn`  datetime(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `Timestamp`  datetime(6)   NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `SchemeCode` varchar(256)  NULL,
    `Message`    text          NOT NULL,
    `Properties` text          NOT NULL,
    `Exception`  text          NOT NULL,
    `TenantId`   varchar(1024) NULL,
    PRIMARY KEY (`Id`),
    INDEX `IX_WorkflowServerProcessLogs_ProcessId` (`ProcessId`),
    INDEX `IX_WorkflowServerProcessLogs_Timestamp` (`Timestamp`),
    INDEX `IX_WorkflowServerProcessLogs_CreatedOn` (`CreatedOn`)
);