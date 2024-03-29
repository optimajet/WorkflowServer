/*From 17/03/21*/
/* Adding a column */
ALTER TABLE WORKFLOWSERVERPROCESSLOGS ADD
(
	CREATEDON TIMESTAMP default current_timestamp NOT NULL
);
/* Updating the creation date of old records */
UPDATE WORKFLOWSERVERPROCESSLOGS SET CREATEDON = TIMESTAMP WHERE TIMESTAMP < TIMESTAMP'2021-03-22 08:56:22.100178' AND CREATEDON != TIMESTAMP;
/* Adding an index */
CREATE INDEX IDX_WORKFLOWSERVERPROCESSLOGS_CREATEDON ON WORKFLOWSERVERPROCESSLOGS (CREATEDON);

