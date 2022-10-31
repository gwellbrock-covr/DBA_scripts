SELECT PolicyNumber [Policy Number],
       CarrierName [Carrier Name],
       PlanName [Product Name],
       CasePlacedDate [Place Date],
       AgentFirstName + ' ' + AgentLastName AS [AgentName],
       AgencyName AS [Broker Dealer],
       CaseFirstName [Customer First Name],
       CaseLastName [Customer Last Name],
       '' AS [Customer Suffix],
       CaseFirstName [Owner First Name],
       CaseLastName [Owner Last Name],
'James Gothers' [WholeSale Agent],
       'COVR Financial' [AgencyName],
       
       'Commissions@covrtech.com' [Agency Email]
FROM powerbi.FormalCases
WHERE (
          ProductSubCategory IN ( 'Variable Life' )
          OR PlanType IN ( 'VULHybrid' )
      )
      AND CasePlacedDate
      BETWEEN DATEADD(WEEK, DATEDIFF(WEEK, 2, GETDATE()) - 1, 2) AND DATEADD(wk, DATEDIFF(wk, 0, GETDATE()), 2)
ORDER BY 2 DESC;



