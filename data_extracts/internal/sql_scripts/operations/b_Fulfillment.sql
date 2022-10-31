
---# of fulfillment requests ADVISOR

WITH cteFulfillmentRequests
AS (SELECT DATEPART(YEAR, fa.CreatedDate) AS [StatusYear],
           DATEPART(MONTH, fa.CreatedDate) AS [StatusMonth],
           DATEPART(DAY, fa.CreatedDate) AS [StatusDay],
           fa.Channel,
           COUNT(fa.ConciergeCaseId) [DailyCount]
    FROM powerbi.FulfillmentActivities fa
    WHERE fa.CreatedDate >= '2021-01-01'
          AND fa.IsDirectToConsumer = 0
    GROUP BY DATEPART(YEAR, fa.CreatedDate),
             DATEPART(MONTH, fa.CreatedDate),
             DATEPART(DAY, fa.CreatedDate),
             fa.Channel
--ORDER BY 1 DESC, 2 ASC, 3 asc
)
SELECT *
FROM cteFulfillmentRequests
--WHERE cteFulfillmentRequests.Channel = 'ADVISOR'
ORDER BY 1 DESC,
         2 ASC,
         3 ASC;

