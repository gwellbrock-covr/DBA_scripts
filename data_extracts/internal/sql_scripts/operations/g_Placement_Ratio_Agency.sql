WITH cteAgencySubmitsYTD
AS (SELECT AgencyName,
           Channel,
           COUNT(1) [Submits]
    FROM powerbi.FormalCases
    WHERE CaseCreatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
    GROUP BY AgencyName,
             Channel),
     cteAgencyPaidYTD
AS (SELECT AgencyName,
           Channel,
           COUNT(1) [Paid]
    FROM powerbi.FormalCases
    WHERE CaseFirstPaidDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
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
     cteAgencyPaidMTD
AS (SELECT AgencyName,
           Channel,
           COUNT(1) [Paid]
    FROM powerbi.FormalCases
    WHERE CaseFirstPaidDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    GROUP BY AgencyName,
             Channel),
     ctefinal
AS (SELECT REPLACE(cteAgencySubmitsYTD.AgencyName, ',', '') AgencyName,
           cteAgencySubmitsYTD.Channel,
           cteAgencySubmitsYTD.Submits submitYTD,
           cteAgencyPaidYTD.Paid paidYTD,
           cteAgencySubmitsMTD.Submits submitMTD,
           cteAgencyPaidMTD.Paid paidMTD
    FROM cteAgencySubmitsYTD
        LEFT JOIN cteAgencyPaidYTD
            ON cteAgencyPaidYTD.AgencyName = cteAgencySubmitsYTD.AgencyName
        LEFT JOIN cteAgencySubmitsMTD
            ON cteAgencySubmitsMTD.AgencyName = cteAgencyPaidYTD.AgencyName
        LEFT JOIN cteAgencyPaidMTD
            ON cteAgencyPaidMTD.AgencyName = cteAgencyPaidYTD.AgencyName)
SELECT *
FROM ctefinal
ORDER BY 1 ASC;

