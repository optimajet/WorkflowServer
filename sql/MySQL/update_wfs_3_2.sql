/*
Company: OptimaJet
Project: WorkflowServer Provider for MySQL
Version: 3.2
File: update_wfs_3_2.sql
*/

DROP PROCEDURE IF EXISTS WorkflowReportBySchemes;

delimiter //
CREATE PROCEDURE WorkflowReportBySchemes()
begin
SELECT
    ws.`Code`,
    (SELECT COUNT(inst.`Id`) FROM `workflowprocessinstance` inst
                                      LEFT JOIN `workflowprocessscheme` ps on ps.`Id` = inst.`SchemeId`
     WHERE coalesce(ps.`RootSchemeCode`, ps.`SchemeCode`) = ws.`Code`) as `ProcessCount`,
    (SELECT COUNT(history.`Id`) FROM `workflowprocesstransitionhistory` history
                                         LEFT JOIN `workflowprocessinstance` inst on history.`ProcessId` = inst.`Id`
                                         LEFT JOIN `workflowprocessscheme` ps on ps.`Id` = inst.`SchemeId`
     WHERE coalesce(ps.`RootSchemeCode`, ps.`SchemeCode`) = ws.`Code`) as `TransitionCount`
FROM `workflowscheme` AS ws;
end;//
delimiter ;