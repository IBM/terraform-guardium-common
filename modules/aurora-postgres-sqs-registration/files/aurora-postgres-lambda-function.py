import boto3
import json
import os
import time
from datetime import datetime, timedelta

def lambda_handler(event, context):
    # Get environment variables
    log_group = os.environ['GROUP_NAME']
    queue_url = os.environ['QUEUE_NAME']
    
    # Initialize AWS clients
    logs_client = boto3.client('logs')
    sqs_client = boto3.client('sqs')
    
    # Calculate time range (last 2 minutes)
    end_time = int(time.time() * 1000)
    start_time = end_time - (2 * 60 * 1000)
    
    try:
        # Get log events from CloudWatch
        response = logs_client.filter_log_events(
            logGroupName=log_group,
            startTime=start_time,
            endTime=end_time,
            limit=10000
        )
        
        # Process and send events to SQS
        for event in response.get('events', []):
            try:
                # Parse the message
                message = event['message']
                
                # Send to SQS
                sqs_client.send_message(
                    QueueUrl=queue_url,
                    MessageBody=message
                )
            except Exception as e:
                print(f"Error processing event: {str(e)}")
                continue
        
        # Handle pagination if there are more events
        while 'nextToken' in response:
            response = logs_client.filter_log_events(
                logGroupName=log_group,
                startTime=start_time,
                endTime=end_time,
                nextToken=response['nextToken'],
                limit=10000
            )
            
            for event in response.get('events', []):
                try:
                    message = event['message']
                    sqs_client.send_message(
                        QueueUrl=queue_url,
                        MessageBody=message
                    )
                except Exception as e:
                    print(f"Error processing event: {str(e)}")
                    continue
        
        return {
            'statusCode': 200,
            'body': json.dumps('Successfully processed CloudWatch logs to SQS')
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
