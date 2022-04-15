/*
Company: OptimaJet
Project: WorkflowServer Provider for PostgreSQL
Version: 3.0
File: update_wfs_3_0.sql
*/

CREATE TABLE IF NOT EXISTS "WorkflowServerProcessLogs"
(
    "Id"         uuid                    NOT NULL PRIMARY KEY,
    "ProcessId"  uuid                    NOT NULL,
    "CreatedOn"  timestamp               NOT NULL DEFAULT localtimestamp,
    "Timestamp"  timestamp               NOT NULL DEFAULT localtimestamp,
    "SchemeCode" character varying(256)  NULL,
    "Message"    text                    NOT NULL DEFAULT '',
    "Properties" text                    NOT NULL DEFAULT '',
    "Exception"  text                    NOT NULL DEFAULT '',
    "TenantId"   character varying(1024) NULL
    );
CREATE index IF NOT EXISTS "WorkflowServerProcessLogs_ProcessId_idx" ON "WorkflowServerProcessLogs" USING btree ("ProcessId");
CREATE index IF NOT EXISTS "WorkflowServerProcessLogs_Timestamp_idx" ON "WorkflowServerProcessLogs" USING btree ("Timestamp");
CREATE index IF NOT EXISTS "WorkflowServerProcessLogs_CreatedOn_idx" ON "WorkflowServerProcessLogs" USING btree ("CreatedOn");