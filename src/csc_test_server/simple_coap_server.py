from aiocoap import *
import aiocoap.resource as resource
import asyncio
import logging
from aiocoap import CHANGED, POST, Message, Context


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("CoAPServer")

class MessageResource(resource.Resource):
    async def render_post(self, request):
        logger.info(f"Received POST request with payload: {request.payload.decode()}")
        return Message(code=CHANGED, payload=request.payload)

class BasicResource(resource.Resource):
    async def render_get(self, request):
        logger.info("Received a GET request")
        return Message(payload=b"Hello, CoAP!")

def main():
    root = resource.Site()
    root.add_resource(['hello'], BasicResource())
    root.add_resource(['message'], MessageResource())
    asyncio.Task(Context.create_server_context(root))
    logger.info("CoAP server started")
    asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
   main()


