DECLARE @FirstCallDate DATETIME = '2022-01-01';

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
     cteCountOnePhoneCall
AS (SELECT COUNT(cte.ConciergeCaseID) [CountOneCall]
    FROM powerbi.FulfillmentActivities fa
        INNER JOIN cteMinAppTakenDate cte
            ON cte.ConciergeCaseID = fa.ConciergeCaseId
    WHERE fa.PhoneCallsMade = 1
          AND fa.CreatedDate >= @FirstCallDate),
     cteAppsTaken
AS (SELECT COUNT(cte.ConciergeCaseID) [CountTaken]
    FROM powerbi.FulfillmentActivities fa
        INNER JOIN cteMinAppTakenDate cte
            ON cte.ConciergeCaseID = fa.ConciergeCaseId
    WHERE fa.CreatedDate >= @FirstCallDate)
SELECT @FirstCallDate [StarteDate],cteCountOnePhoneCall.CountOneCall,
       cteAppsTaken.CountTaken
	
FROM cteCountOnePhoneCall
    OUTER APPLY cteAppsTaken;

	   	 