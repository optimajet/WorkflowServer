-- Use this parameter to specify the last transition date until which process instances will be deleted
declare @lastTransitionDate datetime = '2023-04-01';

-- Use this parameter to specify the statuses in which process instances will be deleted
-- Initialized (0), Running (1), Idled (2), Finalized (3), Terminated (4), Error (5)
declare @statuses table (status tinyint);
insert @statuses(status) values(3);

declare @id uniqueidentifier;
declare @schemeId uniqueidentifier;
declare @code NVARCHAR(256);

DECLARE db_cursor CURSOR FOR
SELECT 
    WPI.Id AS Id,
    WPI.SchemeId AS SchemeId,
    WPS.SchemeCode AS Code
FROM dbo.WorkflowProcessInstance AS WPI
LEFT JOIN dbo.WorkflowProcessInstanceStatus AS WPIS ON WPI.Id = WPIS.Id
LEFT JOIN dbo.WorkflowProcessScheme AS WPS ON WPI.SchemeId = WPS.Id
WHERE WPI.LastTransitionDate < @lastTransitionDate
    AND WPIS.Status IN (SELECT status FROM @statuses)

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @id, @schemeId, @code

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRANSACTION
        
    INSERT INTO [backup].WorkflowProcessInstance
    SELECT *
    FROM dbo.WorkflowProcessInstance
    WHERE Id = @id

    INSERT INTO [backup].WorkflowProcessInstanceStatus
    SELECT *
    FROM dbo.WorkflowProcessInstanceStatus
    WHERE Id = @id

    INSERT INTO [backup].WorkflowProcessInstancePersistence
    SELECT *
    FROM dbo.WorkflowProcessInstancePersistence
    WHERE ProcessId = @id

    INSERT INTO [backup].WorkflowProcessTransitionHistory
    SELECT *
    FROM dbo.WorkflowProcessTransitionHistory
    WHERE ProcessId = @id

    INSERT INTO [backup].WorkflowProcessTimer
    SELECT *
    FROM dbo.WorkflowProcessTimer
    WHERE ProcessId = @id

    INSERT INTO [backup].WorkflowInbox
    SELECT *
    FROM dbo.WorkflowInbox
    WHERE ProcessId = @id

    INSERT INTO [backup].WorkflowApprovalHistory
    SELECT *
    FROM dbo.WorkflowApprovalHistory
    WHERE ProcessId = @id

    INSERT INTO [backup].WorkflowProcessAssignment
    SELECT *
    FROM dbo.WorkflowProcessAssignment
    WHERE ProcessId = @id

    IF NOT EXISTS (
        SELECT 1
        FROM [backup].WorkflowProcessScheme
        WHERE Id = @schemeId
    )
    BEGIN
        INSERT INTO [backup].WorkflowProcessScheme
        SELECT *
        FROM dbo.WorkflowProcessScheme
        WHERE Id = @schemeId
    END

    IF NOT EXISTS (
        SELECT 1
        FROM [backup].WorkflowScheme
        WHERE Code = @code
    )
    BEGIN
        INSERT INTO [backup].WorkflowScheme
        SELECT
            Code,
            Scheme,
            CanBeInlined,
            InlinedSchemes,
            Tags
        FROM dbo.WorkflowScheme
        WHERE Code = @code
    END

    DELETE FROM dbo.WorkflowProcessInstance
    WHERE Id = @id

    DELETE FROM  dbo.WorkflowProcessInstanceStatus
    WHERE Id = @id

    DELETE FROM  dbo.WorkflowProcessInstancePersistence
    WHERE ProcessId = @id

    DELETE FROM  dbo.WorkflowProcessTransitionHistory
    WHERE ProcessId = @id

    DELETE FROM  dbo.WorkflowProcessTimer
    WHERE ProcessId = @id

    DELETE FROM  dbo.WorkflowInbox
    WHERE ProcessId = @id

    DELETE FROM  dbo.WorkflowApprovalHistory
    WHERE ProcessId = @id

    DELETE FROM  dbo.WorkflowProcessAssignment
    WHERE ProcessId = @id

    COMMIT TRANSACTION
    
    FETCH NEXT FROM db_cursor INTO @id, @schemeId, @code
END

CLOSE db_cursor
DEALLOCATE db_cursor

EXEC dbo.DropUnusedWorkflowProcessScheme