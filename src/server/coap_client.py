import logging
import asyncio
import json
from aiocoap import *
import aiocoap
from random import randint
import time

logging.basicConfig(level=logging.INFO)

async def main():
    protocol = await Context.create_client_context()
    count =0
    while (count < 200):
        payload = json.dumps({'temperature': "5,34,1,35,0"}).encode("utf-8")
        request = Message(code=aiocoap.POST, payload=payload, uri='coap://[2a05:d016:1bb:3e00:2fbe:1fb4:63f9:eb4b]:5683/temp')
        try:
            response = await protocol.request(request).response
        except Exception as e:
            print('Failed to fetch resource:')
            print(e)
        else:
            print('Result: %s\n%r'%(response.code, response.payload))
        time.sleep(1)
        
if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
