/*
Company: OptimaJet
Project: WorkflowServer Provider for PostgreSQL
Version: 2.8
File: update_wfs_2_8.sql
*/

ALTER TABLE "WorkflowProcessInstance" ADD COLUMN "CreationDate" timestamp NOT NULL DEFAULT localtimestamp;
ALTER TABLE "WorkflowProcessInstance" ADD COLUMN "LastTransitionDate" timestamp NULL;

ALTER TABLE "WorkflowProcessTransitionHistory" ADD COLUMN "StartTransitionTime" timestamp;
ALTER TABLE "WorkflowProcessTransitionHistory" ADD COLUMN "TransitionDuration" bigint;

ALTER TABLE "WorkflowInbox" ADD COLUMN "AddingDate" timestamp NOT NULL  DEFAULT localtimestamp;
ALTER TABLE "WorkflowInbox" ADD COLUMN "AvailableCommands" character varying(1024) NOT NULL DEFAULT '';

CREATE INDEX IF NOT EXISTS "WorkflowApprovalHistory_IdentityId_idx" ON "WorkflowApprovalHistory" USING btree ("IdentityId");
