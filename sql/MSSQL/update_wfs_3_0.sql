/*
Company: OptimaJet
Project: WorkflowServer Provider for MS SQL
Version: 3.0
File: update_wfs_3_0.sql
*/

IF NOT EXISTS(SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE [TABLE_NAME] = N'WorkflowServerProcessLogs')
    BEGIN
        CREATE TABLE [dbo].[WorkflowServerProcessLogs]
        (
            [Id]         [uniqueidentifier] NOT NULL,
            [ProcessId]  [uniqueidentifier] NOT NULL,
            [CreatedOn]  [datetime2](6)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
            [Timestamp]  [datetime2](6)     NOT NULL DEFAULT CURRENT_TIMESTAMP,
            [SchemeCode] [nvarchar](256)    NULL,
            [Message]    [nvarchar](max)    NOT NULL DEFAULT '',
            [Properties] [nvarchar](max)    NOT NULL DEFAULT '',
            [Exception]  [nvarchar](max)    NOT NULL DEFAULT '',
            [TenantId]   [nvarchar](1024)   NULL
                CONSTRAINT [PK_WorkflowServerProcessLogs] PRIMARY KEY NONCLUSTERED
                    ([Id] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
        ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

        CREATE CLUSTERED INDEX [IX_WorkflowServerProcessLogs_Timestamp_Id]
            ON [dbo].[WorkflowServerProcessLogs] ([Timestamp] ASC, [Id] ASC)

        CREATE NONCLUSTERED INDEX [IX_WorkflowServerProcessLogs_CreatedOn_Id]
            ON [dbo].[WorkflowServerProcessLogs] ([CreatedOn] ASC, [Id] ASC)

        CREATE NONCLUSTERED INDEX [IX_WorkflowServerProcessLogs_ProcessId] ON [dbo].[WorkflowServerProcessLogs]
            ([ProcessId] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

    END