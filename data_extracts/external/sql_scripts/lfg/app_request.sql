SELECT 
       *
FROM powerbi.FulfillmentActivities
WHERE QuotedCarrier in ('Lincoln Financial Group','Lincoln National Life Insurance Company')
      AND CreatedDate >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
ORDER BY CreatedDate DESC;


