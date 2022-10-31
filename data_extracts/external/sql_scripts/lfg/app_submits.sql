SELECT 
       *
FROM powerbi.FormalCases
WHERE CarrierName in ('Lincoln Financial Group','Lincoln National Life Insurance Company')
      AND caseCreatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
ORDER BY caseCreatedDate DESC;