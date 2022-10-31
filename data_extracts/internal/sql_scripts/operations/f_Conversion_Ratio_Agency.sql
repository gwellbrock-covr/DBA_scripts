WITH cteAgencyRequestsYTD
AS (SELECT AgencyName,
           Channel,
           COUNT(1) [Requests]
    FROM powerbi.FulfillmentActivities
    WHERE CreatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
    GROUP BY AgencyName,
             Channel),
     cteAgencySubmitsYTD
AS (SELECT AgencyName,
           Channel,
           COUNT(1) [Submits]
    FROM powerbi.FormalCases
    WHERE CaseCreatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
    GROUP BY AgencyName,
             Channel),
     cteAgencyRequestsMTD
AS (SELECT AgencyName,
           Channel,
           COUNT(1) [Requests]
    FROM powerbi.FulfillmentActivities
    WHERE CreatedDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    GROUP BY AgencyName,
             Channel),
     cteAgencySubmitsMTD
AS (SELECT AgencyName,
           Channel,
           COUNT(1) [Submits]
    FROM powerbi.FormalCases
    WHERE CaseCreatedDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    GROUP BY AgencyName,
             Channel),
     ctefinal
AS (SELECT REPLACE(cteAgencyRequestsYTD.AgencyName, ',', '') Agency,
           cteAgencyRequestsYTD.Channel,
           cteAgencyRequestsYTD.Requests requestsYTD,
           cteAgencySubmitsYTD.Submits submitsYTD,
           cteAgencyRequestsMTD.Requests requestsMTD,
           cteAgencySubmitsMTD.Submits submitsMTD
    FROM cteAgencyRequestsYTD
        LEFT JOIN cteAgencySubmitsYTD
            ON cteAgencySubmitsYTD.AgencyName = cteAgencyRequestsYTD.AgencyName
        LEFT JOIN cteAgencyRequestsMTD
            ON cteAgencyRequestsMTD.AgencyName = cteAgencyRequestsYTD.AgencyName
        LEFT JOIN cteAgencySubmitsMTD
            ON cteAgencySubmitsMTD.AgencyName = cteAgencyRequestsMTD.AgencyName)
SELECT *
FROM ctefinal
ORDER BY 1 ASC;

