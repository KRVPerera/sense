import datetime
import logging
import json

import asyncio

import aiocoap.resource as resource
from aiocoap.numbers.contentformat import ContentFormat
import aiocoap

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
        return aiocoap.Message(content_format=0,
                payload=json.dumps({"status": payload['input']}).encode('utf8'))

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