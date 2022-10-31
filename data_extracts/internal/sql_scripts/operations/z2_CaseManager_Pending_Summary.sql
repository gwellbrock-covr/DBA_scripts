WITH age
AS (SELECT CaseID,
           DATEDIFF(DAY, CreatedDate, GETDATE()) PendingDays
    FROM dbo.[Case]),
     cteAging
AS (SELECT fc.CaseId,
           age.PendingDays,
           fc.CaseManagerName,
           fc.CarrierName,
           fc.CaseFirstName,
           fc.CaseLastName,
           CASE
               WHEN age.PendingDays
                    BETWEEN 0 AND 45 THEN
                   '0-45'
               WHEN age.PendingDays
                    BETWEEN 46 AND 60 THEN
                   '46-60'
               WHEN age.PendingDays
                    BETWEEN 61 AND 90 THEN
                   '60-90'
               WHEN age.PendingDays
                    BETWEEN 91 AND 120 THEN
                   '91-120'
               WHEN age.PendingDays > 120 THEN
                   '>120'
           END AS [AgeGroup]
    FROM powerbi.FormalCases fc
        LEFT JOIN age
            ON age.CaseID = fc.CaseId
    WHERE fc.CaseStatusCategory = 'Pending')
SELECT cteAging.CaseManagerName,
       cteAging.AgeGroup,
       COUNT(CaseId) [COUNTPENDING]
FROM cteAging
GROUP BY cteAging.CaseManagerName,
         cteAging.AgeGroup
ORDER BY 1 ASC, 2 ASC;


