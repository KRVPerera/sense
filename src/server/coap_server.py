import datetime
import logging
import json
import boto3
import asyncio

import aiocoap.resource as resource
from aiocoap.numbers.contentformat import ContentFormat
import aiocoap


sqsClient = boto3.client('sqs', region_name='eu-north-1')
sqsUrl = "https://sqs.eu-north-1.amazonaws.com/293814872100/iot-queue"

# logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("coap-server").setLevel(logging.DEBUG)


class TimeResource(resource.ObservableResource):
    async def render_get(self, request):
        payload = datetime.datetime.now().\
                strftime("%Y-%m-%d %H:%M").encode('ascii')
        return aiocoap.Message(payload=payload)

class temperature(resource.Resource):
    async def render_post(self, request):
        payload = json.loads(request.payload.decode('utf8'))
        message = sqsClient.send_message(
            QueueUrl = sqsUrl,
            MessageBody = ("This was sent on: ")
        )
        return aiocoap.Message(content_format=0,
                payload=json.dumps({"status": 'ok'}).encode('utf8'))

async def main():
    # Resource tree creation
    root = resource.Site()

    root.add_resource(['.well-known', 'core'],
            resource.WKCResource(root.get_resources_as_linkheader))
    root.add_resource(['time'], TimeResource())
    root.add_resource(['temp'], temperature())

    await aiocoap.Context.create_server_context(root, bind=('0.0.0.0', 5683))

    # Run forever
    await asyncio.get_running_loop().create_future()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(f"Error: {e}")