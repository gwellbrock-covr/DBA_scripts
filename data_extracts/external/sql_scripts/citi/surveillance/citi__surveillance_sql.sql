SELECT fc.AgentFirstName,
       fc.AgentLastName,
       fc.CaseFirstName,
       fc.CaseLastName,
       Client.CustomerClientAccountNumber AS [BrokerageAccount],
       fc.PolicyNumber,
       fc.CarrierName,
       fc.ProductCategory,
       fc.PlanName [Product Name],
       fc.CaseFaceAmount [FaceAmount],
       fc.CaseFirstPaidDate [Date Purchased],
       fc.CaseId [COVR_ID],
       st.CreatedDate AS [CRU_Created_at],
       u.UserName AS [CRU_Name],
       fc.CaseManagerName,
       fc.CaseStatusCategory [CaseStatus]
FROM powerbi.FormalCases fc
    LEFT JOIN dbo.SupervisoryTicket st
        ON fc.CaseId = st.EntityId
    LEFT JOIN dbo.[User] u
        ON st.CreatedUser = u.UserID
    LEFT JOIN dbo.ConciergeCase cc
        ON fc.ConciergeCaseID = cc.ConciergeCaseID
    LEFT JOIN Client
        ON Client.ClientID = cc.OwnerClientID
WHERE fc.AgencyId = 4916
      AND fc.casefirstpaiddate IS NOT NULL
	  AND fc.CaseFirstName NOT LIKE 'TEST%'
	  AND fc.ProductCategory = 'Variable Life';

