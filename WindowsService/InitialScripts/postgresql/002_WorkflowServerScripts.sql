/*
Company: OptimaJet
Project: WorkflowServer PostgreSQL
Version: 2
File: WorkflowServerScripts.sql
*/

CREATE TABLE IF NOT EXISTS "WorkflowServerStats" (
                                                     "Id" uuid NOT NULL,
                                                     "Type" character varying(256) NOT NULL,
    "DateFrom" timestamp NOT NULL,
    "DateTo" timestamp NOT NULL,
    "Duration" int NOT NULL,
    "IsSuccess" bit NOT NULL,
    "ProcessId" uuid NULL,
    CONSTRAINT "WorkflowServerStats_pkey" PRIMARY KEY ("Id")
    );
CREATE index IF NOT EXISTS "WorkflowServerStats_ProcessId_idx"  ON "WorkflowServerStats" USING btree ("ProcessId");

CREATE TABLE IF NOT EXISTS "WorkflowServerProcessHistory" (
                                                              "Id" uuid NOT NULL,
                                                              "ProcessId" uuid NOT NULL,
                                                              "IdentityId" character varying(256) NULL,
    "AllowedToEmployeeNames" text NULL,
    "TransitionTime" timestamp NULL,
    "Order" bigserial not null,
    "InitialState" character varying(1024) NOT NULL,
    "DestinationState" character varying(1024) NOT NULL,
    "Command" character varying(1024) NOT NULL,
    CONSTRAINT "WorkflowServerProcessHistory_pkey" PRIMARY KEY ("Id")
    );
CREATE index IF NOT EXISTS "WorkflowServerProcessHistory_ProcessId_idx"  ON "WorkflowServerProcessHistory" USING btree ("ProcessId");


ALTER TABLE "WorkflowInbox" ALTER COLUMN "IdentityId" TYPE character varying(1024);

CREATE OR REPLACE FUNCTION "WorkflowReportBySchemes"() 
RETURNS TABLE ("Code" character varying(1024), "ProcessCount" bigint, "TransitionCount" bigint) 
as $$
begin
RETURN QUERY SELECT
		ws."Code",
		(SELECT COUNT(inst."Id") FROM "WorkflowProcessInstance" inst
			LEFT JOIN "WorkflowProcessScheme" ps on ps."Id" = inst."SchemeId"
			WHERE coalesce(ps."RootSchemeCode", ps."SchemeCode") = ws."Code") as "ProcessCount",
		(SELECT COUNT(history."Id") FROM "WorkflowProcessTransitionHistory" history
		LEFT JOIN "WorkflowProcessInstance" inst on history."ProcessId" = inst."Id"
		LEFT JOIN "WorkflowProcessScheme" ps on ps."Id" = inst."SchemeId"
		WHERE coalesce(ps."RootSchemeCode", ps."SchemeCode") = ws."Code") as "TransitionCount"
	FROM "WorkflowScheme" ws;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "WorkflowReportByTransitions"(datefrom timestamp, dateto timestamp, period int)
RETURNS TABLE ("Date" timestamp, "SchemeCode" character varying(1024), "Count" bigint) 
as $$
DECLARE
curdate timestamp;
   dateend timestamp;
BEGIN

DROP TABLE IF EXISTS report_trans_table;
create temporary table report_trans_table (df timestamp NOT NULL, de timestamp NOT NULL)
	ON COMMIT PRESERVE ROWS;

	IF datefrom > dateto THEN
		RETURN;
END IF;

	curdate := make_date(
			CAST(date_part('year', datefrom) as int), 
			CAST(date_part('month', datefrom) as int), 
			1);
	if period >= 1 then 
		curdate := curdate + interval '1 day' * (date_part('day', datefrom) - 1);
end if;
	if period >= 2 then 
		curdate := curdate + interval '1 hour' * date_part('hour', datefrom);
end if;
	if period >= 3 then 
		curdate := curdate + interval '1 minute' * date_part('minute', datefrom);
end if;
	if period >= 4 then 
		curdate := curdate + interval '1 second' * date_part('second', datefrom);
end if;

	WHILE curdate <= dateto LOOP
		dateend := CASE 
			WHEN period = 0 then curdate + interval '1 month'
			WHEN period = 1 THEN curdate + interval '1 day'
			WHEN period = 2 THEN curdate + interval '1 hour'
			WHEN period = 3 THEN curdate + interval '1 minute'
			WHEN period = 4 THEN curdate + interval '1 second'
end;

INSERT INTO report_trans_table (df, de) SELECT curdate, dateend;
curdate := dateend;
END LOOP;

RETURN QUERY SELECT 
		p.df as "Date",
		scheme."Code" as "SchemeCode",
		coalesce(COUNT(history."Id"), 0::bigint) as "Count"
	FROM report_trans_table p
	LEFT JOIN "WorkflowScheme" scheme on 1=1
	LEFT JOIN "WorkflowProcessScheme" ps on scheme."Code" = coalesce(ps."RootSchemeCode", ps."SchemeCode")
	LEFT JOIN "WorkflowProcessInstance" inst on ps."Id" = inst."SchemeId"
	LEFT JOIN "WorkflowProcessTransitionHistory" history on history."ProcessId" = inst."Id" AND history."TransitionTime" >= p.df AND history."TransitionTime" < p.de
	GROUP BY p.df, scheme."Code"
	ORDER BY p.df, scheme."Code";

end;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "WorkflowReportByStats"(datefrom timestamp, dateto timestamp, period int)
RETURNS TABLE ( "Date" timestamp, 
				"SchemeCode" character varying(1024), 
				"Type" character varying(1024), 
				"IsSuccess" bit,
				"Count" bigint,
				"DurationAVG" bigint,
				"DurationMIN" bigint,
				"DurationMAX" bigint) 
as $$
DECLARE
curdate timestamp;
   dateend timestamp;
BEGIN

DROP TABLE IF EXISTS report_stats_table;
create temporary table report_stats_table (df timestamp NOT NULL, de timestamp NOT NULL)
	ON COMMIT PRESERVE ROWS;

	IF datefrom > dateto THEN
		RETURN;
END IF;

	curdate := make_date(
			CAST(date_part('year', datefrom) as int), 
			CAST(date_part('month', datefrom) as int), 
			1);
	if period >= 1 then 
		curdate := curdate + interval '1 day' * (date_part('day', datefrom) - 1);
end if;
	if period >= 2 then 
		curdate := curdate + interval '1 hour' * date_part('hour', datefrom);
end if;
	if period >= 3 then 
		curdate := curdate + interval '1 minute' * date_part('minute', datefrom);
end if;
	if period >= 4 then 
		curdate := curdate + interval '1 second' * date_part('second', datefrom);
end if;

	WHILE curdate <= dateto LOOP
		dateend := CASE 
			WHEN period = 0 then curdate + interval '1 month'
			WHEN period = 1 THEN curdate + interval '1 day'
			WHEN period = 2 THEN curdate + interval '1 hour'
			WHEN period = 3 THEN curdate + interval '1 minute'
			WHEN period = 4 THEN curdate + interval '1 second'
end;

INSERT INTO report_stats_table (df, de) SELECT curdate, dateend;
curdate := dateend;
END LOOP;

DROP TABLE IF EXISTS report_stats_schemes;
create temporary table report_stats_schemes ("Code" character varying(1024))
	ON COMMIT PRESERVE ROWS;

insert into report_stats_schemes ("Code")
SELECT DISTINCT coalesce(ps."RootSchemeCode", ps."SchemeCode") FROM "WorkflowServerStats" stats
                                                                        LEFT JOIN "WorkflowProcessInstance" inst on inst."Id" = stats."ProcessId"
                                                                        LEFT JOIN "WorkflowProcessScheme" ps on inst."SchemeId" = ps."Id"
WHERE "DateFrom" >= datefrom AND "DateFrom" < dateto;

DROP TABLE IF EXISTS report_stats_types;
create temporary table report_stats_types ("Code" character varying(1024))
	ON COMMIT PRESERVE ROWS;

insert into report_stats_types ("Code")
SELECT DISTINCT stats."Type" FROM "WorkflowServerStats" stats
WHERE stats."DateFrom" >= datefrom AND stats."DateFrom" < dateto;

DROP TABLE IF EXISTS report_stats_success;
create temporary table report_stats_success (value bit)
	ON COMMIT PRESERVE ROWS;

insert into report_stats_success (value)  values(0::bit);
insert into report_stats_success (value)  values(1::bit);

RETURN QUERY SELECT 
		p.df as "Date",
		scheme."Code" as "SchemeCode",
		types."Code" as "OperationType",
		success.value as "IsSuccess",
		coalesce(CAST(COUNT(stats."Id") as bigint), 0::bigint) as "Count",
		coalesce(CAST(AVG(stats."Duration") as bigint), 0::bigint) as "DurationAVG",
		coalesce(CAST(MIN(stats."Duration") as bigint), 0::bigint) as "DurationMIN",
		coalesce(CAST(MAX(stats."Duration") as bigint), 0::bigint) as "DurationMAX"
	FROM report_stats_table p
	LEFT JOIN report_stats_schemes scheme on 1=1
	LEFT JOIN report_stats_types types on 1=1
	LEFT JOIN report_stats_success success on 1=1
	LEFT JOIN "WorkflowServerStats" stats on stats."Type" = types."Code" AND stats."IsSuccess" = success.value AND stats."DateFrom" >= p.df AND stats."DateFrom" < p.de
	LEFT JOIN "WorkflowProcessInstance" inst on stats."ProcessId" = inst."Id"
	LEFT JOIN "WorkflowProcessScheme" ps on ps."Id" = inst."SchemeId" AND scheme."Code" = coalesce(ps."RootSchemeCode", ps."SchemeCode")
	GROUP BY p.df, scheme."Code", types."Code", success.value
	ORDER BY p.df, scheme."Code", types."Code", success.value;

end;
$$ LANGUAGE plpgsql;

ALTER TABLE "WorkflowScheme" ADD COLUMN IF NOT EXISTS "DeleteFinalized" BIT NOT NULL DEFAULT(0::bit);

ALTER TABLE "WorkflowScheme" ADD COLUMN IF NOT EXISTS "DontFillIndox" BIT NOT NULL DEFAULT(0::bit);

ALTER TABLE "WorkflowScheme" ADD COLUMN IF NOT EXISTS "DontPreExecute" BIT NOT NULL DEFAULT(0::bit);

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