﻿/*
Company: OptimaJet
Project: WorkflowServer Provider for PostgreSQL
Version: 2.6
File: update_wfs_2_6.sql
*/

ALTER TABLE "WorkflowProcessInstanceStatus" ADD COLUMN "RuntimeId" character varying(450) NULL;

UPDATE "WorkflowProcessInstanceStatus" SET "RuntimeId" = '00000000-0000-0000-0000-000000000000';

ALTER TABLE "WorkflowProcessInstanceStatus" ALTER COLUMN "RuntimeId" SET NOT NULL;

CREATE INDEX IF NOT EXISTS "WorkflowProcessInstanceStatus_Status_Runtime_ix"
    ON public."WorkflowProcessInstanceStatus" USING btree
    ("Status" ASC NULLS LAST, "RuntimeId" ASC NULLS LAST)
;

ALTER TABLE "WorkflowProcessInstanceStatus" ADD COLUMN "SetTime" timestamp NULL;

UPDATE "WorkflowProcessInstanceStatus" SET "SetTime" = now()::timestamp;

ALTER TABLE "WorkflowProcessInstanceStatus" ALTER COLUMN "SetTime" SET NOT NULL;

CREATE TABLE IF NOT EXISTS "WorkflowRuntime" (
  "RuntimeId" character varying(450),
  "Lock" uuid NOT NULL,
  "Status" smallint NOT NULL,
  "RestorerId" character varying(450) NULL,
  "NextTimerTime" timestamp NULL,
  "NextServiceTimerTime" timestamp NULL,
  "LastAliveSignal" timestamp NULL,
  CONSTRAINT "WorkflowRuntime_pkey" PRIMARY KEY ("RuntimeId")
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

INSERT INTO "WorkflowRuntime" ("RuntimeId","Lock","Status") VALUES ('00000000-0000-0000-0000-000000000000',uuid_generate_v4(),100);

CREATE TABLE IF NOT EXISTS "WorkflowSync" (
  "Name" character varying(450),
  "Lock" uuid NOT NULL,
  CONSTRAINT "WorkflowSync_pkey" PRIMARY KEY ("Name")
);

INSERT INTO "WorkflowSync"("Name","Lock") VALUES ('Timer', uuid_generate_v4()) 
	ON CONFLICT ("Name") DO NOTHING;

INSERT INTO "WorkflowSync"("Name","Lock") VALUES ('ServiceTimer', uuid_generate_v4()) 
	ON CONFLICT ("Name") DO NOTHING;

ALTER TABLE "WorkflowProcessTimer" ADD COLUMN "RootProcessId" uuid NULL;

UPDATE "WorkflowProcessTimer" SET "RootProcessId" = (SELECT "RootProcessId" FROM "WorkflowProcessInstance" wpi WHERE wpi."Id" = "ProcessId");

ALTER TABLE "WorkflowProcessTimer" ALTER COLUMN "RootProcessId" SET NOT NULL;

--WorkflowApprovalHistory
CREATE TABLE IF NOT EXISTS "WorkflowApprovalHistory" (
  "Id" uuid NOT NULL,
  "ProcessId" uuid NOT NULL,
  "IdentityId" character varying(1024) NULL,
  "AllowedTo" text NULL,
  "TransitionTime" timestamp NULL,
  "Sort" bigint NULL,
	"InitialState" character varying(1024) NOT NULL,
	"DestinationState" character varying(1024) NOT NULL,
	"TriggerName" character varying(1024) NULL,
	"Commentary" text NULL,
  CONSTRAINT "WorkflowApprovalHistory_pkey" PRIMARY KEY ("Id")
);
CREATE INDEX IF NOT EXISTS "WorkflowApprovalHistory_ProcessId_idx"  ON "WorkflowApprovalHistory" USING btree ("ProcessId");

CREATE INDEX IF NOT EXISTS "WorkflowProcessInstance_RootProcessId_idx"  ON "WorkflowProcessInstance" USING btree ("RootProcessId");

ALTER TABLE "WorkflowProcessInstance" ADD COLUMN "StartingTransition" text NULL;

UPDATE "WorkflowProcessInstance" SET "StartingTransition" = (SELECT "StartingTransition" FROM "WorkflowProcessScheme" wps WHERE wps."Id" = "SchemeId");

ALTER TABLE "WorkflowScheme" ADD COLUMN IF NOT EXISTS "AutoStart" BIT NOT NULL DEFAULT(0::bit);
ALTER TABLE "WorkflowScheme" ADD COLUMN IF NOT EXISTS "DefaultForm" character varying(1024) NULL;

CREATE TABLE IF NOT EXISTS "WorkflowServerLogs" (
  "Id" uuid NOT NULL,
  "Message" text NOT NULL,
  "MessageTemplate" text NOT NULL,
  "Timestamp" timestamp NOT NULL,
  "Exception" text NULL,
  "PropertiesJson" text NULL,
  "Level" smallint NOT NULL,
  "RuntimeId" character varying(450),
  CONSTRAINT "WorkflowServerLogs_pkey" PRIMARY KEY ("Id")
);
CREATE index IF NOT EXISTS "WorkflowServerLogs_Timestamp_idx"  ON "WorkflowServerLogs" USING btree ("Timestamp");
CREATE index IF NOT EXISTS "WorkflowServerLogs_Level_idx"  ON "WorkflowServerLogs" USING btree ("Level");
CREATE index IF NOT EXISTS "WorkflowServerLogs_RuntimeId_idx"  ON "WorkflowServerLogs" USING btree ("RuntimeId");