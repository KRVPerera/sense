import datetime
import logging
import json
import asyncio

import aiocoap.resource as resource
from aiocoap.numbers.contentformat import ContentFormat
import aiocoap

from database import client, getInfluxDB, sendInfluxdb
from configuration import TEMPERATURE

from decoder import decodeTemperature

# logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("coap-server")
logger.setLevel(logging.DEBUG)


class TimeResource(resource.ObservableResource):
    async def render_get(self, request):
        payload = datetime.datetime.now().\
                strftime("%Y-%m-%d %H:%M").encode('ascii')
        return aiocoap.Message(payload=payload)

class temperature(resource.Resource):
    async def render_post(self, request):
        payload = request.payload.decode('utf8')
        logger.debug(f"Received message: {payload}")
        decodedValues = decodeTemperature(payload)
        logger.debug(f"Decoded values: {decodedValues}")
        sendInfluxdb(decodedValues)
        return aiocoap.Message(content_format=0,
                payload=json.dumps({"status": "ok"}).encode('utf8'))

async def main():
    # Resource tree creation
    root = resource.Site()

    root.add_resource(['.well-known', 'core'],
            resource.WKCResource(root.get_resources_as_linkheader))
    root.add_resource(['time'], TimeResource())
    root.add_resource(['temp'], temperature())

    await aiocoap.Context.create_server_context(root, bind=('::', 5683))

    # Run forever
    await asyncio.get_running_loop().create_future()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(f"Error: {e}")
