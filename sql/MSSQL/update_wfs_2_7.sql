/*
Company: OptimaJet
Project: WorkflowServer Provider for MS SQL
Version: 2.7
File: update_wfs_2_7.sql
*/

IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE [TABLE_NAME] = N'WorkflowServerUser')
BEGIN
	CREATE TABLE [WorkflowServerUser](
		[Id] [uniqueidentifier] NOT NULL,
		[Name] [nvarchar](256) NOT NULL,
		[Email] [nvarchar](256) NULL,
		[Phone] [nvarchar](256) NULL,
		[ExternalId] [nvarchar](1024) NULL,
		[Lock] [uniqueidentifier] NOT NULL,
		[TenantId] [nvarchar](1024) NULL,
		[IsLocked] [bit] NOT NULL,
		[Roles] [nvarchar](max) NULL,
		[Extensions] [nvarchar](max) NULL,
	 CONSTRAINT [PK_WorkflowServerUser] PRIMARY KEY CLUSTERED
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

END
GO

IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[TABLES] WHERE [TABLE_NAME] = N'WorkflowServerUserCredential')
BEGIN
	CREATE TABLE [dbo].[WorkflowServerUserCredential](
		[Id] [uniqueidentifier] NOT NULL,
		[UserId] [uniqueidentifier] NOT NULL,
		[TenantId] [nvarchar](1024) NULL,
		[Login] [nvarchar](256) NOT NULL,
		[AuthType] [tinyint] NOT NULL,
		[PasswordSalt] [nvarchar](128) NULL,
		[PasswordHash] [nvarchar](128) NULL,
		[ExternalProviderName] [nvarchar](256) NULL,
	 CONSTRAINT [PK_WorkflowServerUserCredential] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	

	ALTER TABLE [dbo].[WorkflowServerUserCredential] WITH CHECK ADD CONSTRAINT [FK_WorkflowServerUserCredential_WorkflowServerUser] FOREIGN KEY([UserId])
	REFERENCES [dbo].[WorkflowServerUser] ([Id])
	ON UPDATE CASCADE
	ON DELETE CASCADE

	ALTER TABLE [dbo].[WorkflowServerUserCredential] CHECK CONSTRAINT [FK_WorkflowServerUserCredential_WorkflowServerUser]


END
GO

IF NOT EXISTS (SELECT 1 FROM [INFORMATION_SCHEMA].[COLUMNS] WHERE [TABLE_NAME] = N'WorkflowProcessInstance' 
AND [COLUMN_NAME] = N'SubprocessName')
BEGIN
	ALTER TABLE WorkflowProcessInstance ADD SubprocessName nvarchar (max) NULL
	PRINT 'ADD WorkflowProcessInstance.SubprocessName type nvarchar(max) NULL'
END
GO

UPDATE WorkflowProcessInstance SET SubprocessName = StartingTransition
GO
