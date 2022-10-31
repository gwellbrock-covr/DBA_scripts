WITH cteMinAppTakenDate
AS (SELECT fcsh.ConciergeCaseID,
           fcsh.StatusUpdatedDate
    FROM powerbi.FulfillmentCaseStatusHistories fcsh
        INNER JOIN
        (
            SELECT ConciergeCaseID,
                   MIN(StatusUpdatedDate) [MinDate]
            FROM powerbi.FulfillmentCaseStatusHistories
            WHERE ConciergeCaseStatusDescription = 'App Taken'
            GROUP BY ConciergeCaseID
        ) t1
            ON t1.ConciergeCaseID = fcsh.ConciergeCaseID
               AND fcsh.StatusUpdatedDate = t1.MinDate),
     cteCycleTimeCompletedtoSubmitted
AS (SELECT fc.CaseId,
           fa.Channel,
           fc.CaseManagerName,
           fssh.StatusUpdatedDate AS [AppTakenDate],
           fc.CaseCreatedDate AS [LifeCaseCreatedDate],
           DATEDIFF(DAY, fssh.StatusUpdatedDate, fc.CaseCreatedDate) AS [CycleTimeDays]
    FROM powerbi.FulfillmentActivities fa
        INNER JOIN powerbi.FormalCases fc
            ON fc.ConciergeCaseId = fa.ConciergeCaseId
        INNER JOIN cteMinAppTakenDate fssh
            ON fssh.ConciergeCaseID = fa.ConciergeCaseId
    WHERE fssh.StatusUpdatedDate >= '2021-01-01'
          AND
          (
              fc.is1035 <> 1
              OR fc.CaseExternalStatus <> 'Case is on hold'
              OR fa.ConciergeCaseExternalStatus NOT IN ( 'Application is on hold',
                                                         'Application is on hold, related case',
                                                         'Application is on hold, unable to reach'
                                                       )
          )
    GROUP BY fc.CaseId,
             fa.Channel,
             fc.CaseManagerName,
             fssh.StatusUpdatedDate,
             fc.CaseCreatedDate)
SELECT DISTINCT
       cteCycleTimeCompletedtoSubmitted.CaseManagerName,
       DATEPART(YEAR, cteCycleTimeCompletedtoSubmitted.AppTakenDate) [Year],
       DATEPART(MONTH, cteCycleTimeCompletedtoSubmitted.AppTakenDate) [Month],
       MIN(cteCycleTimeCompletedtoSubmitted.CycleTimeDays) [MinCycleTime],
       MAX(cteCycleTimeCompletedtoSubmitted.CycleTimeDays) [MaxCycleTime],
       AVG(cteCycleTimeCompletedtoSubmitted.CycleTimeDays) [AVGCycleTime]
FROM cteCycleTimeCompletedtoSubmitted
--WHERE cteCycleTimeCompletedtoSubmitted.Channel = 'ADVISOR'
--   AND cteCycleTimeCompletedtoSubmitted.AgencyName IS NOT NULL
GROUP BY cteCycleTimeCompletedtoSubmitted.CaseManagerName,
         DATEPART(YEAR, cteCycleTimeCompletedtoSubmitted.AppTakenDate),
         DATEPART(MONTH, cteCycleTimeCompletedtoSubmitted.AppTakenDate)
ORDER BY 2 DESC,
         3 DESC,
         1 ASC;