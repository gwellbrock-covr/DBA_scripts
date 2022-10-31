import boto3
import json
import os
#Import AWS Lambda Powertools
from aws_lambda_powertools import Tracer, Logger, Metrics

tracer = Tracer()
logger = Logger()
metrics = Metrics()

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')


# Get the table name from the Lambda Environment Variable
table_name = os.environ['TABLE_NAME']


# --------------- Main handler ------------------
@tracer.capture_lambda_handler
def lambda_handler(event, context):
  try:
        bucket = event['detail']['bucket']['name']
        json_file_name = event['detail']['object']['key']
        json_object = s3_client.get_object(Bucket=bucket, Key=json_file_name)
        jsonFileReader = json_object['Body'].read().decode("utf-8")
        #print(jsonFileReader)
        list = jsonFileReader.split("\n")
        for jsonObj in list:
          if jsonObj.lstrip().startswith('{'):
            jsonDict = json.loads(jsonObj)
            #print(jsonDict)
            table = dynamodb.Table(table_name)
            table.put_item(Item=jsonDict) 
            logger.structure_logs(append=True, log_data=jsonDict)
            logger.info("InsertingIntoDynamoDB",jsonDict)           
        return 'Success'

  except Exception as e:
        metrics.add_metric(name="dBInsertFailure", unit="Count",value=1)
        logger.exception("Received an exception")
        raise e
