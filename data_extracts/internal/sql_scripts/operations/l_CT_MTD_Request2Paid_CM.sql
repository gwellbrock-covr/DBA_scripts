
--Cycle time:  app request to app paid* 
WITH cteCycleTimeRequestToPaid
AS (SELECT fc.CaseId,
           fc.Channel,
           fc.CaseManagerName,
           COALESCE(fa.CreatedDate, fc.CaseCreatedDate) AS AppRequestDate,
           fc.CaseFirstPaidDate AS PaidDate,
           DATEDIFF(DAY, COALESCE(fa.CreatedDate, fc.CaseCreatedDate), fc.CaseFirstPaidDate) AS [CycleTimeDays]
    FROM powerbi.FormalCases fc
        LEFT JOIN powerbi.FulfillmentActivities fa
            ON fa.ConciergeCaseId = fc.ConciergeCaseId
    WHERE COALESCE(fa.CreatedDate, fc.CaseCreatedDate) IS NOT NULL
          AND fc.CaseFirstPaidDate IS NOT NULL
          AND COALESCE(fa.CreatedDate, fc.CaseCreatedDate) >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
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
             fc.Channel,
             fc.CaseManagerName,
             fa.CreatedDate,
             fc.CaseCreatedDate,
             fc.CaseFirstPaidDate)
SELECT DISTINCT
       cteCycleTimeRequestToPaid.CaseManagerName,
       MAX(cteCycleTimeRequestToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeRequestToPaid.CaseManagerName) AS maxcycle,
       MIN(cteCycleTimeRequestToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeRequestToPaid.CaseManagerName) AS mincycle,
       AVG(cteCycleTimeRequestToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeRequestToPaid.CaseManagerName) AS average,
       PERCENTILE_CONT(0.5)WITHIN GROUP(ORDER BY cteCycleTimeRequestToPaid.CycleTimeDays) OVER (PARTITION BY cteCycleTimeRequestToPaid.CaseManagerName) AS Median
FROM cteCycleTimeRequestToPaid
WHERE cteCycleTimeRequestToPaid.CaseManagerName IS NOT NULL; --AND cteCycleTimeRequestToPaid.Channel ='ADVISOR';

