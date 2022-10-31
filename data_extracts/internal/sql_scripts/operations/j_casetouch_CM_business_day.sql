WITH cteCaseNote AS
(SELECT caseid,MAX(CreatedDate) notecreateddate FROM dbo.CaseNote
WHERE createddate >= DATEADD(Day, Datediff(Day,0, GetDate() -1 ), 0)
GROUP BY CaseID),
 cteLastRequirmentUpdate
AS (SELECT CaseID,
           MAX(UpdatedDate) lastrequirementupdate
    FROM dbo.CaseRequirement
    WHERE RequirementDate >= DATEADD(Day, Datediff(Day,0, GetDate() -1 ), 0)  
    GROUP BY CaseID),
     cteMasterTask
AS (SELECT CaseID,
           MAX(UpdatedDate) lasttaskupdate
    FROM dbo.MasterTask
    WHERE CreatedDate >= DATEADD(Day, Datediff(Day,0, GetDate() -1 ), 0) 
    GROUP BY CaseID),
     cteFinal
AS (SELECT 
           fc.CaseId,
           fc.ConciergeCaseId,
		   fc.CaseFirstName,
		   fc.CaseLastName,
		   fc.CaseManagerName,
           cteLastRequirmentUpdate.lastrequirementupdate,
		   cteMasterTask.lasttaskupdate,
		   cteCaseNote.notecreateddate,
		   fc.CaseLastStatusChangeDate,
		   fc.Channel
    FROM powerbi.FormalCases fc
        LEFT JOIN cteLastRequirmentUpdate
            ON cteLastRequirmentUpdate.CaseID = fc.CaseId
		LEFT JOIN cteMasterTask ON cteMasterTask.CaseID = fc.CaseId	
		LEFT JOIN cteCaseNote ON cteCaseNote.CaseID = fc.CaseId
		WHERE fc.CaseCreatedDate > '2021-01-01'
		AND fc.DivisionId = 5
			)

     SELECT   cteFinal.CaseManagerName,COUNT(cteFinal.CaseId) AS [CaseManagerTouches]
FROM cteFinal where
(cteFinal.CaseLastStatusChangeDate) >= DATEADD(Day, Datediff(Day,0, GetDate() -1 ), 0)
      OR cteFinal.notecreateddate >= DATEADD(Day, Datediff(Day,0, GetDate() -1 ), 0)
      OR cteFinal.lasttaskupdate >= DATEADD(Day, Datediff(Day,0, GetDate() -1 ), 0)
      OR cteFinal.lastrequirementupdate >= DATEADD(Day, Datediff(Day,0, GetDate() -1 ), 0)
	--  AND cteFinal.Channel = 'ADVISOR'
	  GROUP BY cteFinal.CaseManagerName
ORDER BY cteFinal.CaseManagerName ASC

