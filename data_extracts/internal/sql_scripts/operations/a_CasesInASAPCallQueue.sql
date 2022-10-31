
--Status for no date & time selected App Requests = Continuing to Contact, Calls 1, 2 & 3 with time stamp 5:01pm MT or later previous business day
SELECT ConciergeCaseId,
       replace(AgencyName,',','') AgencyName,
       AgentName,
	   Channel,
       CustomerFirstName,
       CustomerLastName,
       COALESCE(CustomerHomePhone, CustomerMobilePhone, CustomerWorkPhone) [phone],
       LastStatusUpdateDate
FROM powerbi.FulfillmentActivities
WHERE (
          ConciergeCaseStatusDescription = 'Continuing to Contact / No Response Yet'
          AND PhoneCallsMade = 0
          --AND Channel = 'ADVISOR'
      )
      OR
      (
          ConciergeCaseStatusDescription = 'Continuing to Contact / No Response Yet'
          AND PhoneCallsMade > 0
          AND NextCallSpecificAppointment = 0
         -- AND Channel = 'ADVISOR'
      )
ORDER BY LastStatusUpdateDate ASC;