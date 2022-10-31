WITH cteAgencySubmitsYTD
AS (SELECT CaseManagerName,
           Channel,
           COUNT(1) [Submits]
    FROM powerbi.FormalCases
    WHERE CaseCreatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
    GROUP BY CaseManagerName,
             Channel),
     cteAgencyPaidYTD
AS (SELECT CaseManagerName,
           Channel,
           COUNT(1) [Paid]
    FROM powerbi.FormalCases
    WHERE CaseFirstPaidDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
    GROUP BY CaseManagerName,
             Channel),
     cteAgencySubmitsMTD
AS (SELECT CaseManagerName,
           Channel,
           COUNT(1) [Submits]
    FROM powerbi.FormalCases
    WHERE CaseCreatedDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    GROUP BY CaseManagerName,
             Channel),
     cteAgencyPaidMTD
AS (SELECT CaseManagerName,
           Channel,
           COUNT(1) [Paid]
    FROM powerbi.FormalCases
    WHERE CaseFirstPaidDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
    GROUP BY CaseManagerName,
             Channel),
     ctefinal
AS (SELECT REPLACE(cteAgencySubmitsYTD.CaseManagerName, ',', '') CaseManagerName,
           cteAgencySubmitsYTD.Channel,
           cteAgencySubmitsYTD.Submits submitYTD,
           cteAgencyPaidYTD.Paid paidYTD,
           cteAgencySubmitsMTD.Submits submitMTD,
           cteAgencyPaidMTD.Paid paidMTD
    FROM cteAgencySubmitsYTD
        LEFT JOIN cteAgencyPaidYTD
            ON cteAgencyPaidYTD.CaseManagerName = cteAgencySubmitsYTD.CaseManagerName
        LEFT JOIN cteAgencySubmitsMTD
            ON cteAgencySubmitsMTD.CaseManagerName = cteAgencyPaidYTD.CaseManagerName
        LEFT JOIN cteAgencyPaidMTD
            ON cteAgencyPaidMTD.CaseManagerName = cteAgencyPaidYTD.CaseManagerName)
SELECT *
FROM ctefinal
ORDER BY 1 ASC;

