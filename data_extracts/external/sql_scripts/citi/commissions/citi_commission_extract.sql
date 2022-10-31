WITH final
AS (SELECT c.CustomerClientAccountNumber AS [BrokerageAccount],
           oclcd.[Value] AS [CitiRepCode],
           fc.CaseFirstName + ' ' + fc.CaseLastName [Owner Name],
           fc.PolicyNumber AS [PolicyNumber],
           fc.CaseFirstPaidDate AS [Trade_Date],
           fc.State AS [State],
           fc.CarrierName AS [Carrier_Name],
           fc.ProductSubCategory AS Product_Category,
           NULL AS [CUSIP_Number],
           fc.PlanName AS Product_Name,
           fc.PremiumMode,
           fc.AdjustedBasePremium,
           '--INSERT Excess_Premium_Amount---' AS Excess_Premium_Amount,
           '--INSERT COMMISION PAYMENT TYPE HERE---' AS [Commission_Payment_Type],
           '--INSERT[PaymentAmount] HERE---' AS [PaymentAmount]
    FROM powerbi.FormalCases fc
        LEFT JOIN dbo.ConciergeCase cc
            ON fc.ConciergeCaseId = cc.ConciergeCaseID
        LEFT JOIN dbo.Client c
            ON COALESCE(cc.OwnerClientID, cc.ProposedInsuredClientID) = c.ClientID
        LEFT JOIN dbo.OneClickLead ocl
            ON ocl.ExportDestinationID = cc.ConciergeCaseID
        LEFT JOIN dbo.OneClickLeadCustomData oclcd
            ON oclcd.OneClickLeadID = ocl.OneClickLeadID
               AND oclcd.Label = 'RepCode'
    WHERE fc.AgencyId = 4916
          AND fc.CaseFirstPaidDate IS NOT NULL)
SELECT *
FROM final
WHERE [Owner Name] NOT LIKE 'Test%';

