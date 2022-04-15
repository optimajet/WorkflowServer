/* From 17/03/21 */
/* Adding a column */
ALTER TABLE "WorkflowServerProcessLogs" ADD COLUMN "CreatedOn" timestamp NOT NULL DEFAULT localtimestamp;
/* Updating the creation date of old records */
UPDATE "WorkflowServerProcessLogs" SET "CreatedOn" ="Timestamp" WHERE "Timestamp" < '2021-03-22 10:41:42.493342' AND "Timestamp" != "CreatedOn";
/* Adding an index */
CREATE index IF NOT EXISTS "WorkflowServerProcessLogs_CreatedOn_idx" ON "WorkflowServerProcessLogs" USING btree ("CreatedOn");