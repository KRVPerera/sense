import asyncio
from aiocoap import *

async def main():
    protocol = await Context.create_client_context()

    request = Message(code=GET, uri='coap://86.50.252.174/hello')
    
    try:
        response = await protocol.request(request).response
    except Exception as e:
        print('Failed to fetch resource:')
        print(e)
    else:
        print('Result: %s\n%r'%(response.code, response.payload))

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(main())

