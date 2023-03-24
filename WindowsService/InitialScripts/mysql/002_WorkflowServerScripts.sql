/*
Company: OptimaJet
Project: WorkflowServer MySQL
Version: 2
File: WorkflowServerScripts.sql
*/

CREATE TABLE IF NOT EXISTS `workflowserverstats` (
    `Id` binary(16) NOT NULL,
    `Type` varchar(256) NOT NULL,
    `DateFrom` datetime NOT NULL,
    `DateTo` datetime NOT NULL,
    `Duration` int NOT NULL,
    `IsSuccess` bit(1) NOT NULL,
    `ProcessId` binary(16) NULL,
    PRIMARY KEY  (`Id`)
    );

CREATE TABLE IF NOT EXISTS `workflowserverprocesshistory` (
    `Id` binary(16) NOT NULL,
    `ProcessId` binary(16) NOT NULL,
    `IdentityId` varchar(256) NULL,
    `AllowedToEmployeeNames` longtext NULL,
    `TransitionTime` datetime NULL,
    `Order` serial,
    `InitialState` varchar(1024) NOT NULL,
    `DestinationState` varchar(1024) NOT NULL,
    `Command` varchar(1024) NOT NULL,
    PRIMARY KEY  (`Id`)
    );


DROP PROCEDURE IF EXISTS AddIndexTemp;

delimiter //
CREATE PROCEDURE AddIndexTemp(indexname varchar(128), tablename varchar(128))
BEGIN

	SET @statement = (SELECT IF(
	  (
		SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
		WHERE
		  (table_name = tablename)
		  AND (table_schema = DATABASE())
		  AND (index_name = indexname)
	  ) > 0,
	  "SELECT 1",
	  CONCAT("CREATE INDEX `", indexname, "` ON `", tablename, "` (`ProcessId`);")
	));

PREPARE prepared FROM @statement;
EXECUTE prepared;
DEALLOCATE PREPARE prepared;

END;//
delimiter ;


CALL AddIndexTemp("ix_workflowserverstats_processid", "workflowserverstats");
CALL AddIndexTemp("ix_workflowServerprocesshistory_processid", "workflowserverprocesshistory");

DROP PROCEDURE AddIndexTemp;


-- 1024 in Postgres ?
ALTER TABLE `workflowinbox` MODIFY `IdentityId` varchar(256);


DROP PROCEDURE IF EXISTS WorkflowReportBySchemes;

delimiter //
CREATE PROCEDURE WorkflowReportBySchemes()
begin
SELECT
    ws.`Code`,
    (SELECT COUNT(inst.`Id`) FROM `workflowprocessinstance` inst
                                      LEFT JOIN `workflowprocessscheme` ps on ps.`Id` = inst.`SchemeId`
     WHERE coalesce(ps.`RootSchemeCode`, ps.`SchemeCode`) = ws.`Code`) as `ProcessCount`,
    (SELECT COUNT(history.`Id`) FROM `workflowprocesstransitionhistory` history
                                         LEFT JOIN `workflowprocessinstance` inst on history.`ProcessId` = inst.`Id`
                                         LEFT JOIN `workflowprocessscheme` ps on ps.`Id` = inst.`SchemeId`
     WHERE coalesce(ps.`RootSchemeCode`, ps.`SchemeCode`) = ws.`Code`) as `TransitionCount`
FROM `workflowscheme` AS ws;
end;//
delimiter ;

DROP PROCEDURE IF EXISTS WorkflowReportByTransitions;

delimiter //
-- period: 0 - MONTH, 1 - DAY, 2 - HOUR, 3 - MINUTE, 4 - SECOND 
CREATE PROCEDURE WorkflowReportByTransitions(datefrom datetime, dateto datetime, period int)
    by_transitions:BEGIN

	DECLARE currentdate, dateend datetime;

	DROP TEMPORARY TABLE IF EXISTS report_trans_table;
	create temporary table report_trans_table (df datetime NOT NULL, de datetime NOT NULL);

	IF datefrom > dateto THEN
		LEAVE by_transitions;
END IF;

	SET currentdate = DATE_SUB(datefrom, INTERVAL DAYOFMONTH(datefrom)-1 DAY);
	
    
	if period >= 1 then 
		SET currentdate = currentdate + interval (day(datefrom) - 1) day;
end if;
	if period >= 2 then 
		SET currentdate = currentdate + interval hour(datefrom) hour;
end if;
	if period >= 3 then 
		SET currentdate = currentdate + interval minute(datefrom) minute;
end if;
	if period >= 4 then 
		SET currentdate = currentdate + interval second(datefrom) second;
end if;

	WHILE currentdate <= dateto DO
		SET dateend = CASE 
			WHEN period = 0 then currentdate + interval 1 month
			WHEN period = 1 THEN currentdate + interval 1 day
			WHEN period = 2 THEN currentdate + interval 1 hour
			WHEN period = 3 THEN currentdate + interval 1 minute
			WHEN period = 4 THEN currentdate + interval 1 second
end;

INSERT INTO report_trans_table (df, de) SELECT currentdate, dateend;
SET currentdate = dateend;
END WHILE;

SELECT
    p.df as `Date`,
    scheme.`Code` as `SchemeCode`,
    coalesce(COUNT(history.`Id`), 0) as `Count`
FROM report_trans_table p
         LEFT JOIN `workflowscheme` scheme on 1=1
         LEFT JOIN `workflowprocessscheme` ps on scheme.`Code` = coalesce(ps.`RootSchemeCode`, ps.`SchemeCode`)
         LEFT JOIN `workflowprocessinstance` inst on ps.`Id` = inst.`SchemeId`
         LEFT JOIN `workflowprocesstransitionhistory` history on history.`ProcessId` = inst.`Id` AND history.`TransitionTime` >= p.df AND history.`TransitionTime` < p.de
GROUP BY p.df, scheme.`Code`
ORDER BY p.df, scheme.`Code`;

end;//
delimiter ;

DROP PROCEDURE IF EXISTS WorkflowReportByStats;

delimiter //
CREATE PROCEDURE WorkflowReportByStats(datefrom datetime, dateto datetime, period int)
    by_stats:BEGIN
	DECLARE currentdate, dateend datetime;

	DROP TEMPORARY TABLE IF EXISTS report_stats_table;
	create temporary table report_stats_table (df datetime NOT NULL, de datetime NOT NULL);

	IF datefrom > dateto THEN
		LEAVE by_stats;
END IF;

	SET currentdate = DATE_SUB(datefrom, INTERVAL DAYOFMONTH(datefrom)-1 DAY);

	if period >= 1 then 
		SET currentdate = currentdate + interval (day(datefrom) - 1) day;
end if;
	if period >= 2 then 
		SET currentdate = currentdate + interval hour(datefrom) hour;
end if;
	if period >= 3 then 
		SET currentdate = currentdate + interval minute(datefrom) minute;
end if;
	if period >= 4 then 
		SET currentdate = currentdate + interval second(datefrom) second;
end if;

	WHILE currentdate <= dateto DO
		SET dateend = CASE 
			WHEN period = 0 then currentdate + interval 1 month
			WHEN period = 1 THEN currentdate + interval 1 day
			WHEN period = 2 THEN currentdate + interval 1 hour
			WHEN period = 3 THEN currentdate + interval 1 minute
			WHEN period = 4 THEN currentdate + interval 1 second
end;

INSERT INTO report_stats_table (df, de) SELECT currentdate, dateend;
SET currentdate = dateend;
END WHILE;

	DROP TEMPORARY TABLE IF EXISTS report_stats_schemes;
	create temporary table report_stats_schemes (`Code` varchar(1024));

insert into report_stats_schemes (`Code`)
SELECT DISTINCT coalesce(ps.`RootSchemeCode`, ps.`SchemeCode`)
FROM `workflowserverstats` stats
         LEFT JOIN `workflowprocessinstance` inst on inst.`Id` = stats.`ProcessId`
         LEFT JOIN `workflowprocessscheme` ps on inst.`SchemeId` = ps.`Id`
WHERE `DateFrom` >= datefrom AND `DateFrom` < dateto;

DROP TEMPORARY TABLE IF EXISTS report_stats_types;
	create temporary table report_stats_types (`Code` varchar(1024));

insert into report_stats_types (`Code`)
SELECT DISTINCT stats.`Type` FROM `workflowserverstats` stats
WHERE stats.`DateFrom` >= datefrom AND stats.`DateFrom` < dateto;

DROP TEMPORARY TABLE IF EXISTS report_stats_success;
	create temporary table report_stats_success (`Value` bit);

insert into report_stats_success (`Value`)  values(0);
insert into report_stats_success (`Value`)  values(1);

SELECT
    p.df as `Date`,
    scheme.`Code` as `SchemeCode`,
    types.`Code` as `OperationType`,
    success.`Value` as `IsSuccess`,
    coalesce(COUNT(stats.`Id`), 0) as `Count`,
    coalesce(AVG(stats.`Duration`), 0) as `DurationAVG`,
    coalesce(MIN(stats.`Duration`), 0) as `DurationMIN`,
    coalesce(MAX(stats.`Duration`), 0) as `DurationMAX`
FROM report_stats_table p
         LEFT JOIN report_stats_schemes scheme on 1=1
         LEFT JOIN report_stats_types types on 1=1
         LEFT JOIN report_stats_success success on 1=1
         LEFT JOIN `workflowserverstats` stats on stats.`Type` = types.`Code` AND stats.`IsSuccess` = success.`Value` AND stats.`DateFrom` >= p.df AND stats.`DateFrom` < p.de
         LEFT JOIN `workflowprocessinstance` inst on stats.`ProcessId` = inst.`Id`
         LEFT JOIN `workflowprocessscheme` ps on ps.`Id` = inst.`SchemeId` AND scheme.`Code` = coalesce(ps.`RootSchemeCode`, ps.`SchemeCode`)
GROUP BY p.df, scheme.`Code`, types.`Code`, success.`Value`
ORDER BY p.df, scheme.`Code`, types.`Code`, success.`Value`;

end;//
delimiter ;


DROP PROCEDURE IF EXISTS AddColumnTemp;

delimiter //
CREATE PROCEDURE AddColumnTemp(columnname varchar(128))
BEGIN

	SET @statement = (SELECT IF(
	  (
		SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
		WHERE
		  (table_name = "workflowscheme" )
		  AND (table_schema = DATABASE())
		  AND (column_name = columnname)
	  ) > 0,
	  "SELECT 1",
	  CONCAT("ALTER TABLE `workflowscheme` ADD `", columnname, "` BIT(1) NOT NULL DEFAULT 0;")
	));

PREPARE prepared FROM @statement;
EXECUTE prepared;
DEALLOCATE PREPARE prepared;

END;//
delimiter ;

CALL AddColumnTemp("DeleteFinalized");

CALL AddColumnTemp("DontFillIndox");

CALL AddColumnTemp("DontPreExecute");

CALL AddColumnTemp("AutoStart");

DROP PROCEDURE AddColumnTemp;

delimiter //
CREATE PROCEDURE AddColumnTemp(columnname varchar(128))
BEGIN

	SET @statement = (SELECT IF(
	  (
		SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
		WHERE
		  (table_name = "workflowscheme" )
		  AND (table_schema = DATABASE())
		  AND (column_name = columnname)
	  ) > 0,
	  "SELECT 1",
	  CONCAT("ALTER TABLE `workflowscheme` ADD `", columnname, "` varchar(1024) NULL;")
	));

PREPARE prepared FROM @statement;
EXECUTE prepared;
DEALLOCATE PREPARE prepared;

END;//
delimiter ;

CALL AddColumnTemp("DefaultForm");

DROP PROCEDURE AddColumnTemp;


CREATE TABLE IF NOT EXISTS `workflowserverlogs` (
    `Id` binary(16) NOT NULL,
    `Message` text NOT NULL,
    `MessageTemplate` text NOT NULL,
    `Timestamp` datetime NOT NULL,
    `Exception` text NULL,
    `PropertiesJson` text NULL,
    `Level` tinyint(4) not null,
    `RuntimeId` varchar(450) not null,
    PRIMARY KEY  (`Timestamp`, `Id`),
    INDEX `IX_WorkflowServerLogs_RuntimeId` (`RuntimeId`),
    INDEX `IX_WorkflowServerLogs_Level` (`Level`)
    );


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