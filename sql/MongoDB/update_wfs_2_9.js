db.WorkflowServerProcessLogs.createIndex({ProcessId: 1});
db.WorkflowServerProcessLogs.createIndex({Timestamp: -1});
db.WorkflowServerProcessLogs.createIndex({CreatedOn: -1});