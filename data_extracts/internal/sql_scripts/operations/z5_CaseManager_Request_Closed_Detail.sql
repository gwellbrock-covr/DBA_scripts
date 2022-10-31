WITH onhold1035
AS (SELECT csh.CaseID,
           DATEDIFF(DAY, csh.UpdatedDate, csh2.UpdatedDate) [DaysonHold135]
    FROM dbo.CaseStatusHistory csh
        LEFT JOIN dbo.CaseStatusHistory csh2
            ON csh2.CaseID = csh.CaseID
               AND csh.NewCaseStatusID = csh2.CaseStatusID
        JOIN dbo.CaseStatus cs
            ON cs.CaseStatusID = csh.CaseStatusID
    WHERE csh.CaseStatusID IN ( 7, 8 )
          AND csh.CaseStatusID IS NOT NULL
          AND DATEDIFF(DAY, csh.UpdatedDate, csh2.UpdatedDate) > 0
          AND csh.UpdatedDate >= GETDATE() - 500),
     apshold
AS (SELECT csh.CaseID,
           DATEDIFF(DAY, csh.UpdatedDate, csh2.UpdatedDate) [Daysonaps]
    FROM dbo.CaseStatusHistory csh
        LEFT JOIN dbo.CaseStatusHistory csh2
            ON csh2.CaseID = csh.CaseID
               AND csh.NewCaseStatusID = csh2.CaseStatusID
        JOIN dbo.CaseStatus cs
            ON cs.CaseStatusID = csh.CaseStatusID
    WHERE csh.CaseStatusID IN ( 573, 700, 726, 746, 164 )
          AND csh.CaseStatusID IS NOT NULL
          AND DATEDIFF(DAY, csh.UpdatedDate, csh2.UpdatedDate) > 0
          AND csh.UpdatedDate >= GETDATE() - 500),
     age
AS (SELECT CaseId,
           DATEDIFF(DAY, COALESCE(FulfillmentCreatedDate, CaseCreatedDate), CaseLastStatusChangeDate) AS RequestToCloseDays
    FROM powerbi.FormalCases),
     cteAging
AS (SELECT fc.CaseId,
           fc.FulfillmentCreatedDate,
           fc.AppSubmitDate,
           fc.CaseLastStatusChangeDate,
           fc.CaseFirstPaidDate,
           age.RequestToCloseDays,
           fc.CaseManagerName,
           fc.CarrierName,
           fc.CaseFirstName,
           fc.CaseLastName,
           fc.AgencyName,
           fc.Channel,
           fc.CaseStatusDescription,
           fc.ProductCategory,
           fc.ProductSubCategory,
           onhold1035.DaysonHold135,
           apshold.Daysonaps [daysAwaitingAPS],
           -- fc.DaysInCurrentStatus,
           CASE
               WHEN age.RequestToCloseDays
                    BETWEEN 0 AND 45 THEN
                   '0-45'
               WHEN age.RequestToCloseDays
                    BETWEEN 46 AND 60 THEN
                   '46-60'
               WHEN age.RequestToCloseDays
                    BETWEEN 61 AND 90 THEN
                   '60-90'
               WHEN age.RequestToCloseDays
                    BETWEEN 91 AND 120 THEN
                   '91-120'
               WHEN age.RequestToCloseDays > 120 THEN
                   '>120'
           END AS [AgeGroup]
    FROM powerbi.FormalCases fc
        LEFT JOIN age
            ON age.CaseId = fc.CaseId
        LEFT JOIN onhold1035
            ON onhold1035.CaseID = fc.CaseId
        LEFT JOIN apshold
            ON apshold.CaseID = age.CaseId
    WHERE fc.CaseStatusCategory IN ( 'Closed', 'Paid' )
     --AND fc.CaseLastStatusChangeDate >= '2021-01-01'
     )
SELECT *
FROM cteAging
ORDER BY 2 DESC;


