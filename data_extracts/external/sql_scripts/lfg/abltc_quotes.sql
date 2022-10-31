SELECT ms.DateCreated,
       ms.BirthDate,
       ms.FaceAmount,
       ms.State,
       ms.Gender,
       'Morgan Stanley' AS [Firm],
       ms.FirstName AS Client_First_Name,
       ms.LastName AS Client_Last_Name
FROM dbo.MorganStanleyQuote ms
WHERE ms.OneClickTypeID IN ( 42, 35, 43, 46, 57 )
      AND ms.DateCreated >= '2022-01-01'
UNION
SELECT ql.CreatedDate AS [DateCreated],
       CAST(COALESCE(
                        JSON_VALUE(ql.Request, '$.BirthDate'),
                        JSON_VALUE(ql.Request, '$.Birthdate'),
                        JSON_VALUE(ql.Request, '$.Birthday')
                    ) AS DATE) AS BirthDate,
       TRY_CONVERT(DECIMAL(18, 2), COALESCE(
                                               JSON_VALUE(ql.Request, '$.FaceAmount'),
                                               JSON_VALUE(ql.Request, '$.CoverageAmount'),
                                               JSON_VALUE(ql.Request, '$.Premium'),
                                               JSON_VALUE(ql.Request, '$.SelectedPremium')
                                           )) AS FaceAmount,
       JSON_VALUE(ql.Request, '$.State') AS [State],
       COALESCE(JSON_VALUE(ql.Request, '$.Gender'), JSON_VALUE(ql.Request, '$.Sex')) AS Gender,
       oca.AccountName AS [Firm],
       '' AS Client_First_Name,
       '' AS Client_Last_Name
FROM dbo.QuoteLogs ql
    JOIN dbo.OneClickAccount oca
        ON oca.OneClickAccountID = ql.OneClickAccountID
WHERE ql.OneClickTypeID IN ( 42, 35, 43, 46, 57 )
      AND oca.AccountName <> 'Morgan Stanley'
      AND ql.CreatedDate >= DATEADD(yy, DATEDIFF(yy,0,GETDATE()), 0)
ORDER BY 1 DESC;


