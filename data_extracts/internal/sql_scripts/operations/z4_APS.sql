SELECT DATEPART(YEAR, cs.RequirementCreatedDate) [RequirementCreatedYear],
       DATEPART(MONTH, cs.RequirementCreatedDate) [RequirementCreatedMonth],
       fc.Channel,
       fc.CarrierName,
       COUNT(DISTINCT fc.CaseId) [APSCount]
FROM powerbi.FormalCases fc
    LEFT JOIN dbo.CaseRequirement cs
        ON cs.CaseID = fc.CaseId
WHERE cs.RequirementCode = 'APS'
GROUP BY DATEPART(YEAR, cs.RequirementCreatedDate),
         DATEPART(MONTH, cs.RequirementCreatedDate),
         fc.Channel,
         fc.CarrierName
ORDER BY 1 DESC,
         2 DESC;



