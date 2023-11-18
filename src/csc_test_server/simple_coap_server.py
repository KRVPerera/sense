from aiocoap import *
import aiocoap.resource as resource
import asyncio
import logging


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("CoAPServer")


class BasicResource(resource.Resource):
    async def render_get(self, request):
        logger.info("Received a GET request")
        return Message(payload=b"Hello, CoAP!")

def main():
    root = resource.Site()
    root.add_resource(['hello'], BasicResource())
    asyncio.Task(Context.create_server_context(root))
    logger.info("CoAP server started")
    asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
   main()
