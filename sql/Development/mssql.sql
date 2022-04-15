/* From 17/03/21 */
/* Adding a column */
IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[COLUMNS] WHERE [TABLE_NAME] = N'WorkflowServerProcessLogs'
AND [COLUMN_NAME] = N'CreatedOn')
BEGIN
	ALTER TABLE WorkflowServerProcessLogs ADD [CreatedOn] [datetime2](6) NOT NULL DEFAULT CURRENT_TIMESTAMP;
	PRINT 'ADD WorkflowServerProcessLogs.CreatedOn type [datetime2](6) NOT NULL DEFAULT CURRENT_TIMESTAMP';
	/* Updating the creation date of old records */
	UPDATE WorkflowServerProcessLogs SET CreatedOn = Timestamp WHERE Timestamp < '2021-03-22 10:41:42.493342' AND CreatedOn != Timestamp;
END
GO
/* Adding an index */
CREATE NONCLUSTERED INDEX [IX_WorkflowServerProcessLogs_CreatedOn_Id]
            ON [dbo].[WorkflowServerProcessLogs] ([CreatedOn] ASC, [Id] ASC)
GO