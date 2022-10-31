const AWS = require('aws-sdk');
AWS.config.region = process.env.AWS_REGION || 'us-west-2';
const eventbridge = new AWS.EventBridge();

exports.handler = async (event) => {
  console.log(JSON.stringify(event, 0, null));
  let payload = { Entries: [] };
  event.Records.forEach((item) => {
    const newImage = item.dynamodb.NewImage;
    const data = {
      "covr_id": newImage.pk.S,
      "carrier": newImage.carriername.S,
      "casestatus": newImage.current_case_status.S,
      "agencyid": newImage.agencyid.S,
      "agencyname": newImage.agencyname.S,
      "channel": newImage.agencyname.S
    };
    
    payload.Entries.push({
      // Event envelope fields
      Source: 'MyDynamoStream',
      EventBusName: 'MyEventBus',
      DetailType: 'transaction',
      Time: new Date(),

      // Main event body      
      Detail: JSON.stringify(data)
    });
  });
  console.log("Payload to Event Bridge");
  console.log(payload);
  const result = await eventbridge.putEvents(payload).promise();
  console.log('EventBridge result');
  console.log(result);
}