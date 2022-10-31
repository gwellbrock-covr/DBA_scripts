SELECT *
FROM powerbi.covr_journey
WHERE IsDirectToConsumer = 1
      AND
      (
          FulfillmentCreatedDate >= '2021-01-01'
          OR LifeCaseCreatedDate >= '2021-01-01'
      );