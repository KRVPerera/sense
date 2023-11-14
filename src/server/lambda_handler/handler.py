import json

def lambda_handler(event, context):
    print(event)
    records = event['Records']

    for record in records:
        print(record['body'])