
--# of app submitted*


WITH cteAppsSubmitted
AS (SELECT DATEPART(YEAR, fa.CaseCreatedDate) AS [StatusYear],
           DATEPART(MONTH, fa.CaseCreatedDate) AS [StatusMonth],
           DATEPART(DAY, fa.CaseCreatedDate) AS [StatusDay],
            fa.Channel,
           COUNT(fa.CaseId) [DailyCount]
    FROM powerbi.FormalCases fa
    WHERE fa.CaseCreatedDate >= '2021-01-01'
    GROUP BY DATEPART(YEAR, fa.CaseCreatedDate),
             DATEPART(MONTH, fa.CaseCreatedDate),
             DATEPART(DAY, fa.CaseCreatedDate),
              fa.Channel)
SELECT *
FROM cteAppsSubmitted --WHERE cteAppsSubmitted.Channel = 'ADVISOR'
ORDER BY 1 DESC,
         2 ASC,
         3 ASC;
