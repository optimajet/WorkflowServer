/*From 17/03/21*/
/* Adding a column */
ALTER TABLE `workflowserverprocesslogs`
    ADD `CreatedOn` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6);
/* Updating the creation date of old records */
UPDATE `workflowserverprocesslogs` SET `CreatedOn` = `Timestamp` WHERE Timestamp < '2021-03-22 10:41:42.493342' AND `CreatedOn` != `Timestamp`;
/* Adding a default value */
ALTER TABLE `workflowserverprocesslogs`
    MODIFY `Timestamp` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6);
/* Adding an index */
CREATE INDEX `IX_WorkflowServerProcessLogs_CreatedOn` ON workflowserverprocesslogs (`CreatedOn`)
