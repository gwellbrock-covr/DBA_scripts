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
    WHERE fssh.StatusUpdatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
          AND
          (
              fc.is1035 <> 1
              OR fc.CaseExternalStatus <> 'Case is on hold'
          )
    GROUP BY fc.CaseId,
             fa.Channel,
             fc.CaseManagerName,
             fssh.StatusUpdatedDate,
             fc.CaseCreatedDate)
SELECT DISTINCT
       cteCycleTimeCompletedtoSubmitted.CaseManagerName,
       MAX(cteCycleTimeCompletedtoSubmitted.CycleTimeDays) OVER (PARTITION BY cteCycleTimeCompletedtoSubmitted.CaseManagerName) AS maxcycle,
       MIN(cteCycleTimeCompletedtoSubmitted.CycleTimeDays) OVER (PARTITION BY cteCycleTimeCompletedtoSubmitted.CaseManagerName) AS mincycle,
       AVG(cteCycleTimeCompletedtoSubmitted.CycleTimeDays) OVER (PARTITION BY cteCycleTimeCompletedtoSubmitted.CaseManagerName) AS average,
       PERCENTILE_CONT(0.5)WITHIN GROUP(ORDER BY cteCycleTimeCompletedtoSubmitted.CycleTimeDays) OVER (PARTITION BY cteCycleTimeCompletedtoSubmitted.CaseManagerName) AS Median
FROM cteCycleTimeCompletedtoSubmitted
--WHERE cteCycleTimeCompletedtoSubmitted.Channel = 'ADVISOR'
--   AND cteCycleTimeCompletedtoSubmitted.CaseManagerName IS NOT NULL
ORDER BY 2 DESC,
         3 DESC,
         1 ASC;