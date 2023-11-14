import json

def lambda_handler(event, context):
    print("Event triggered", event)
    records = event['Records']

    for record in records:
        print(f"Received data: {record['body']}")