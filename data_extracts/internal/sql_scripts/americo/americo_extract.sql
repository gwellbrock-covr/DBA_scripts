SELECT *
FROM powerbi.covr_journey
WHERE CaseType = 'LifeCase'
      AND OneClickAccountID IN (   1309, --LifeStrategies
                                   1308, --Alliance
                                   1306, --Intelliquote
                                   1301  --Americo		
                               )
ORDER BY LifeCaseCreatedDate DESC;