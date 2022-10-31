SELECT a.AccountName,
       ca.EmailAddress,
       ca.Pin,
       'https://' + a.Domain + '/retrieveprogress?appId=' + LOWER(ConsumerApplicationId) AS [url],
       CASE
           WHEN JSON_VALUE(ca.UnderwritingResponse, '$.Decision') = '01' THEN
               'Approved'
           WHEN JSON_VALUE(ca.UnderwritingResponse, '$.Decision') = '06' THEN
               'Approved/Approved_modified'
           WHEN JSON_VALUE(ca.UnderwritingResponse, '$.Decision') = '03' THEN
               'Declined'
           WHEN JSON_VALUE(ca.UnderwritingResponse, '$.Decision') = '05' THEN
               'No Decision'
           ELSE
               'Not Submitted'
       END AS [Case_Status],
       ca.ConsumerApplicationId,
      -- ca.ApplicationData,
       COALESCE(
                   JSON_VALUE(ca.ApplicationData, '$.steps.personalInfo.firstName'),
                   JSON_VALUE(ca.ApplicationData, '$.steps.basicInfo.firstName')
               ) AS CaseFirstName,
       COALESCE(
                   JSON_VALUE(ca.ApplicationData, '$.steps.personalInfo.lastName'),
                   JSON_VALUE(ca.ApplicationData, '$.steps.basicInfo.lastName')
               ) AS CaseLastName,
       ca.CreatedDate,
       ca.UpdatedDate,
       ca.RetrieveProgressEmailSentDate,
       ca.ReferenceId AS PolicyNumber,
       --   ca.UnderwritingResponse,
       ca.DateOfConsent
FROM core.ConsumerApplications ca
    JOIN core.Accounts a
        ON a.AccountId = ca.AccountId
--IF UNDERWRITING REPSONSE IS NOT NULL THEN APP IS CLOSED 7 DAYS FROM UPDATEDDATE
WHERE ca.AccountId IN ( 69, 65, 64, 59, 62 )
      AND EmailAddress != ''
ORDER BY UpdatedDate DESC;
