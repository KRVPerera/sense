import asyncio
from aiocoap import Context, Message
import boto3
import json

# CoAP Server
async def coap_server(request):
    # Process CoAP message
    # Send the message to SQS
    message = request.payload.decode('utf-8')
    print(message)
    send_to_sqs(message)
    return Message(payload=b"Message received successfully")

# SQS Sender
def send_to_sqs(message):
    sqs = boto3.resource('sqs')
    queue = sqs.get_queue_by_name(QueueName='sense_iot')

    response = queue.send_message(MessageBody=message)
    print(f"Message sent to SQS: {response['MessageId']}")

# Run CoAP server
async def main():
    context = await Context.create_server_context(coap_server)
    await context

if __name__ == "__main__":
    asyncio.run(main())
