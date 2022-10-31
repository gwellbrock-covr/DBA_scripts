WITH paramed
AS (SELECT CaseID
    FROM dbo.ParamedOrders),
     final
AS (SELECT -- CJ.[JourneyID]
        cj.[ConciergeCaseID],
        cj.[CaseID],
        cj.[OneClickAccountID] OneClickAccountID,
        cj.[AgencyID],
        cj.[CarrierName],
        cj.[CaseType],
        cj.[CaseStatusCategory],
        cj.[CaseStatus],
        cj.[CaseStatusDetail],
        cj.[AnnualPremium],
        cj.[FulfillmentCreatedDate],
        cj.[LifeCaseCreatedDate],
        cj.[UpdatedDate],
        cj.[CasePaidDate],
        c.PolicyDate AS PolicyDate,
        fc.BasePremium,
        fc.PremiumMode,
        fc.Premium AS ModalPremium,
        fc.CaseLastStatusChangeDate AS LastStatusUpdate,
        cj.[IsDirectToConsumer],
        cj.[COVR_User],
        cj.[COVR_UserId],
        cj.[ProductCategory],
        cj.[PlanType],
        cj.[PlanName],
        cj.[ClientFirstName],
        c.MiddleName AS ClientMiddleName,
        cj.[ClientLastName],
        cj.[ClientEmail],
        cj.[ClientPhone],
        cj.[ClientAddress],
        cj.[ClientCity],
        cj.[ClientState],
        cj.[ClientZip],
        cj.[ClientBirthDate],
        c.Address2 AS ClientAddress2,
        cj.[FaceAmount],
        cj.[QuotedTerm],
        cj.[QuotedHealthClass],
        cj.[QuotedProduct],
        cj.[QuotedCarrier],
        cj.[CaseSource],
        cj.[DataField1Name],
        cj.DataField1Value,
        cj.[PartnerReferralID],
        Carrier.ALIRT_Score,
        COALESCE(cc.Gender, c.Gender, JSON_VALUE(ql.Request, '$.Request.Gender'), JSON_VALUE(ql.Request, '$.Gender')) AS Gender,
        CASE
            WHEN cj.isDigital = 'TRUE' THEN
                1
            ELSE
                3
        END AS [Tier],
        CASE
            WHEN cj.isDigital = 'TRUE' THEN
                '80%'
            ELSE
                '40%'
        END AS [COMMSION_PERCENTAGE],
        fc.PolicyNumber,
        class.ClassName AS approvd_health_class,
        CASE
            WHEN p.CaseID IS NOT NULL THEN
                'TRUE'
            ELSE
                'FALSE'
        END AS medical_exam_required,
	fc.ProductSubCategory,
		fc.WorkPhone

    FROM powerbi.covr_journey cj
        LEFT JOIN [Case] c
            ON c.CaseID = cj.CaseID
        LEFT JOIN dbo.Carrier
            ON Carrier.CarrierID = c.CarrierID
        LEFT JOIN dbo.ConciergeCase cc
            ON cc.ConciergeCaseID = cj.ConciergeCaseID
        LEFT JOIN dbo.QuoteLogs ql
            ON ql.PartnerQuoteId = cj.PartnerReferralID
        LEFT JOIN powerbi.FormalCases fc
            ON fc.CaseId = cj.CaseID
        LEFT JOIN dbo.CasePremium cp
            ON cp.CaseID = c.CaseID
        LEFT JOIN dbo.Class class
            ON class.ClassID = cp.ClassID
        LEFT JOIN paramed p
            ON p.CaseID = c.CaseID
    WHERE cj.AgencyID = 4884)
SELECT *
FROM final

--AND COALESCE(cc.Gender,c.Gender,JSON_VALUE(ql.Request, '$.Request.Gender'), JSON_VALUE(ql.Request, '$.Gender')) IS null

;