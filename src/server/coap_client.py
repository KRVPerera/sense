import logging
import asyncio
import json
from aiocoap import *
import aiocoap
from random import randint
import time
import random
import struct

logging.basicConfig(level=logging.INFO)

async def main():
    protocol = await Context.create_client_context()
    count =0
    while (count < 200):
        randString = ",".join([setParity(random.randint(3500, 3900)) for i in range(5)])
        payload = (randString+',').encode("utf-8")
        request = Message(code=aiocoap.POST, payload=payload , uri='coap://[2a05:d016:1bb:3e00:2fbe:1fb4:63f9:eb4b]:5683/temp')
        try:
            response = await protocol.request(request).response
        except Exception as e:
            print('Failed to fetch resource:')
            print(e)
        else:
            print('Result: %s\n%r'%(response.code, response.payload))
        time.sleep(1)
       
def setParity(value):
    ones_count = bin(value).count('1')
    if ones_count % 2 == 1:
        return ",".join([str(value), '0'])
    else:
        return ",".join([str(value), '1'])

if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
