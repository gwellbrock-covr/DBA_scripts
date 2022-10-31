--# of apps taken ADVISOR

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
     cteAppsTaken
AS (SELECT DATEPART(YEAR, fssh.StatusUpdatedDate) AS [StatusYear],
           DATEPART(MONTH, fssh.StatusUpdatedDate) AS [StatusMonth],
           DATEPART(DAY, fssh.StatusUpdatedDate) [StatusDay],
            fa.Channel,
           COUNT(DISTINCT fssh.ConciergeCaseID) [DailyCount]
    FROM powerbi.FulfillmentActivities fa
        INNER JOIN cteMinAppTakenDate fssh
            ON fssh.ConciergeCaseID = fa.ConciergeCaseId
    WHERE fssh.StatusUpdatedDate >= '2021-01-01'
    GROUP BY DATEPART(YEAR, fssh.StatusUpdatedDate),
             DATEPART(MONTH, fssh.StatusUpdatedDate),
             DATEPART(DAY, fssh.StatusUpdatedDate),
              fa.Channel
     --ORDER BY 1 DESC, 2 ASC, 3 asc
     )
SELECT *
FROM cteAppsTaken -- WHERE cteAppsTaken.Channel = 'ADVISOR'
ORDER BY 1 DESC,
         2 ASC,
         3 ASC;
