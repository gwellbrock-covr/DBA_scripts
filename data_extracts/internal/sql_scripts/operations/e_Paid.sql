--# of app paid*

WITH cteAppsPaid
AS (SELECT DATEPART(YEAR, fa.CaseFirstPaidDate) AS [StatusYear],
           DATEPART(MONTH, fa.CaseFirstPaidDate) AS [StatusMonth],
           DATEPART(DAY, fa.CaseFirstPaidDate) AS [StatusDay],
           fa.Channel,
           COUNT(fa.CaseId) [DailyCount]
    FROM powerbi.FormalCases fa
    WHERE fa.CaseCreatedDate >= '2021-01-01'
    GROUP BY DATEPART(YEAR, fa.CaseFirstPaidDate),
             DATEPART(MONTH, fa.CaseFirstPaidDate),
             DATEPART(DAY, fa.CaseFirstPaidDate),
           fa.Channel)
SELECT *
FROM cteAppsPaid --WHERE cteAppsPaid.Channel = 'ADVISOR'
ORDER BY 1 DESC,
         2 DESC,
         3 DESC;


