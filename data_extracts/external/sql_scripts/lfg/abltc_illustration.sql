
WITH cteOneClickRequestStatuses AS (SELECT 1 AS OneClickRequestStatusID
                                          ,'New Request' AS OneClickRequestStatus
                                    UNION ALL
                                    SELECT 2
                                          ,'In Progress'
                                    UNION ALL
                                    SELECT 3
                                          ,'On Hold'
                                    UNION ALL
                                    SELECT 4
                                          ,'Canceled'
                                    UNION ALL
                                    SELECT 5
                                          ,'Complete')
    ,cteAgents AS (SELECT a.AgentID
                         ,COALESCE(NULLIF(TRIM(SUBSTRING(a.FirstName, 1, (CHARINDEX(' ', a.FirstName, 1)))), ''), a.FirstName) FirstName
                         ,COALESCE(NULLIF(TRIM(SUBSTRING(a.LastName, 1, (CHARINDEX(' ', a.LastName, 1)))), ''), a.LastName) LastName
                         ,NULLIF(a.Email, '') AS Email
                         ,NULLIF(a.WorkPhone, '') AS WorkPhone
                         ,a.MobilePhone
                         ,a.AgencyID
                         ,a.UserID
                         ,a.State
                   FROM dbo.Agent a)
    ,cteOneClickLeads AS (SELECT ocl.OneClickLeadID
                                ,ocl.OneClickAccountID
                                ,NULLIF(ocl.FirstName, '') AS FirstName
                                ,NULLIF(ocl.LastName, '') AS LastName
                                ,NULLIF(ocl.PrimaryPhone, '') AS PrimaryPhone
                                ,NULLIF(ocl.EmailAddress, '') AS EmailAddress
                                ,CAST(ocl.BirthDate AS DATE) AS BirthDate
                                ,ocl.Gender
                                ,ocl.UseTobacco
                                ,ocl.State
                                ,NULLIF(COALESCE(NULLIF(TRIM(SUBSTRING(ocl.RepFirstName, 1, (CHARINDEX(' ', ocl.RepFirstName, 1)))), ''), ocl.RepFirstName), '') AS RepFirstName
                                ,NULLIF(COALESCE(NULLIF(TRIM(SUBSTRING(ocl.RepLastName, 1, (CHARINDEX(' ', ocl.RepLastName, 1)))), ''), ocl.RepLastName), '') AS RepLastName
                                ,NULLIF(ocl.RepPhone, '') AS RepPhone
                                ,NULLIF(ocl.RepEmail, '') AS RepEmail
                                ,NULLIF(ocl.RepState, '') AS RepState
                                ,ocl.HealthClassCode
                                ,ocl.FaceAmount
                                ,ocl.AnnualPremium
                                ,ocl.OneClickTypeID
                          FROM dbo.OneClickLead ocl)
SELECT oceu.AgentID AS AgentId
      ,a.FirstName AS AgentFirstName
      ,a.LastName AS AgentLastName
    --  ,a.AgencyID
      ,ag.AgencyName
      ,a.State AS AgentState
      ,NULLIF(a.WorkPhone, '') AS AgentWorkPhone
      ,a.Email AS AgentEmail
      ,msq.FirstName + ' ' + msq.LastName AS ClientName
      ,CAST(msq.BirthDate AS DATE) AS ClientDOB
      ,msq.Gender AS ClientGender
      ,msq.State AS ClientState
      ,msq.OneClickTypeID
      ,oct.Name OneClickTypeName
      ,oct.ProductDisplayName AS ProductName
      ,msq.PremiumAmount AS Premium
     -- ,msq.HealthClassCode
      ,msq.Tobacco AS TobaccoUser
      ,msq.FaceAmount
      ,msqir.RequestedDate AS RequestedDate
    --  ,msqir.FulfilledDate
    --  ,s.OneClickRequestStatus
     -- ,a.UserID AS ISCRepUserId
      ,u.FirstName + ' ' + u.LastName AS ISCRepUserName
FROM dbo.MorganStanleyQuoteIllustrationRequest msqir
    JOIN cteOneClickRequestStatuses s ON msqir.OneClickRequestStatusID = s.OneClickRequestStatusID
    JOIN dbo.MorganStanleyQuote msq ON msqir.MorganStanleyQuoteID = msq.MorganStanleyQuoteID
    JOIN dbo.OneClickType oct ON msq.OneClickTypeID = oct.OneClickTypeID
    JOIN dbo.OneClickExternalUsers oceu ON msq.ExternalUserID = oceu.ExternalUserID
    JOIN dbo.Agent a ON oceu.AgentID = a.AgentID
    LEFT JOIN dbo.Agency ag ON a.AgencyID = ag.AgencyID
    LEFT JOIN dbo.[User] u ON a.UserID = u.UserID

	WHERE msq.QuoteType = 'LTC'
	AND msqir.RequestedDate >= '2022-01-01'

UNION
SELECT am.AgentID AS AgentId
      ,ocl.RepFirstName AS AgentFirstName
      ,ocl.RepLastName AS AgentLastName
      --,am.AgencyID
      ,ag.AgencyName
      ,NULLIF(COALESCE(ocl.RepState, am.State), '') AS AgentState
      ,NULLIF(ocl.RepPhone, '') AS AgentWorkPhone
      ,NULLIF(COALESCE(ocl.RepEmail, am.Email), '') AS AgentEmail
      ,TRIM(ocl.FirstName) + ' ' + TRIM(ocl.LastName) AS ClientName
      ,CAST(ocl.BirthDate AS DATE) AS ClientDOB
      ,NULLIF(ocl.Gender, '') AS ClientGender
      ,NULLIF(ocl.State, '') AS ClientState
      ,ocl.OneClickTypeID
      ,oct.Name AS OneClickTypeName
      ,oct.ProductDisplayName AS ProductName
      ,ocl.AnnualPremium
      --,ocl.HealthClassCode
      ,ocl.UseTobacco AS TobaccoUser
      ,ocl.FaceAmount
      ,ocr.CreatedDate AS RequestedDate
     -- ,CASE WHEN rs.OneClickRequestStatus = 'Complete' THEN ocr.StatusUpdateDate
          --  ELSE NULL
     --  END AS FulfilledDate
     -- ,rs.OneClickRequestStatus
     -- ,am.UserID AS ISCRepUserId
      ,iu.FirstName + ' ' + iu.LastName AS ISCRepName
FROM dbo.OneClickRequest ocr
    JOIN cteOneClickRequestStatuses rs ON ocr.OneClickRequestStatusID = rs.OneClickRequestStatusID
    JOIN dbo.OneClickRequestType ocrt ON ocr.OneClickRequestTypeID = ocrt.OneClickRequestTypeID
    JOIN cteOneClickLeads ocl ON ocr.OneClickLeadID = ocl.OneClickLeadID
    JOIN dbo.OneClickAccount oca ON ocl.OneClickAccountID = oca.OneClickAccountID
    LEFT JOIN dbo.OneClickType oct ON ocl.OneClickTypeID = oct.OneClickTypeID
    OUTER APPLY (SELECT a.AgentID
                       ,a.FirstName
                       ,a.LastName
                       ,a.Email
                       ,a.WorkPhone
                       ,a.MobilePhone
                       ,a.AgencyID
                       ,a.UserID
                       ,a.State
                 FROM dbo.Agent a
                 WHERE (ocl.RepFirstName = a.FirstName
                        AND ocl.RepLastName = a.LastName
                        AND ocl.RepEmail = a.Email)
                       OR (ocl.RepFirstName = a.FirstName
                           AND ocl.RepLastName = a.LastName
                           AND ocl.RepPhone = a.WorkPhone)
                       OR (ocl.RepFirstName = a.FirstName
                           AND ocl.RepLastName = a.LastName
                           AND ocl.RepPhone = a.MobilePhone)) am
    LEFT JOIN dbo.Agency ag ON am.AgencyID = ag.AgencyID
    LEFT JOIN dbo.[User] iu ON am.UserID = iu.UserID
    LEFT JOIN dbo.Agent ar ON oca.AgentID = ar.AgentID
    LEFT JOIN dbo.[User] aru ON ar.UserID = aru.UserID

	WHERE ocl.OneClickTypeID IN  ( 42, 35, 43, 46, 57 )
	AND ocr.CreatedDate >= DATEADD(yy, DATEDIFF(yy,0,GETDATE()), 0)
GO


