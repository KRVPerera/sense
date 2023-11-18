from aiocoap import *

class BasicResource(resource.Resource):
    async def render_get(self, request):
        return Response(payload=b"Hello, CoAP!")

def main():
    root = resource.Site()
    root.add_resource(['hello'], BasicResource())
    asyncio.Task(Context.create_server_context(root))
    asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
   main()
