
--Cycle time: Submitted to app paid* 

WITH cteCycleTimeSubmittedToPaid
AS (SELECT fc.CaseId,
           fc.Channel,
           fc.CaseManagerName,
           fc.CaseCreatedDate AS AppSubmitDate,
           fc.CaseFirstPaidDate AS PaidDate,
           DATEDIFF(DAY, fc.CaseCreatedDate, fc.CaseFirstPaidDate) AS [CycleTimeDays]
    FROM powerbi.FormalCases fc
    WHERE fc.CaseFirstPaidDate IS NOT NULL
          AND fc.CaseCreatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
          AND fc.IsDirectToConsumer = 0
          AND
          (
              fc.is1035 <> 1
              OR fc.CaseExternalStatus <> 'Case is on hold'
          )
    GROUP BY fc.CaseId,
             fc.Channel,
             fc.CaseManagerName,
             fc.CaseCreatedDate,
             fc.CaseFirstPaidDate)
SELECT DISTINCT
       cteCycleTimeSubmittedToPaid.CaseManagerName,
       MAX(cteCycleTimeSubmittedToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeSubmittedToPaid.CaseManagerName) AS maxcycle,
       MIN(cteCycleTimeSubmittedToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeSubmittedToPaid.CaseManagerName) AS mincycle,
       AVG(cteCycleTimeSubmittedToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeSubmittedToPaid.CaseManagerName) AS average,
       PERCENTILE_CONT(0.5)WITHIN GROUP(ORDER BY cteCycleTimeSubmittedToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeSubmittedToPaid.CaseManagerName) AS Median
FROM cteCycleTimeSubmittedToPaid
WHERE cteCycleTimeSubmittedToPaid.CaseManagerName IS NOT NULL
   --   AND cteCycleTimeSubmittedToPaid.Channel = 'ADVISOR';

