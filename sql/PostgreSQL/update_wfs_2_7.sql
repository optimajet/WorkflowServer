/*
Company: OptimaJet
Project: WorkflowServer Provider for PostgreSQL
Version: 2.7
File: update_wfs_2_7.sql
*/

CREATE TABLE IF NOT EXISTS "WorkflowServerUser"(
	"Id" uuid NOT NULL PRIMARY KEY,
	"Name" varchar(256) NOT NULL,
	"Email" varchar(256) NULL,
        "Phone" varchar(256) NULL,
	"IsLocked" boolean NOT NULL DEFAULT 0::boolean,
	"ExternalId" varchar(1024) NULL,
	"Lock" uuid NOT NULL,
	"TenantId" varchar(1024) NULL,
	"Roles" text NULL,
	"Extensions" text NULL
);

CREATE TABLE IF NOT EXISTS "WorkflowServerUserCredential"(
	"Id" uuid NOT NULL PRIMARY KEY,
	"PasswordHash" varchar(128) NULL,
	"PasswordSalt" varchar(128) NULL,
	"UserId" uuid NOT NULL REFERENCES "WorkflowServerUser" ON DELETE CASCADE,
	"Login" varchar(256) NOT NULL,
	"AuthType" smallint NOT NULL,
	"TenantId" varchar(1024) NULL,
    "ExternalProviderName" varchar(256) NULL
);

ALTER TABLE "WorkflowProcessInstance" ADD COLUMN "SubprocessName" text NULL;

UPDATE "WorkflowProcessInstance" SET "SubprocessName" = "StartingTransition";
