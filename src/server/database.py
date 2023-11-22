#import os
from influxdb import InfluxDBClient

from configuration import HOST, PORT, USERNAME, PASSWORD, DATABASE, TEMPERATURE
import random

def client():
    # InfluxDB client setup
    client = InfluxDBClient(host=HOST, port=int(PORT), username=USERNAME, password=PASSWORD)

    # client.get_list_database()

    client.create_database(DATABASE)
    client.switch_database(DATABASE)
    
    # client.get_list_measurements()

    return client


def getInfluxDB(query, measurement=TEMPERATURE):
    db_client = client()
    result = db_client.query(query=query)
    output = []
    for key, value in enumerate(result):
        output.append(value)  
    return output


def sendInfluxdb(decodedValues):
    db_client = client()
    tags        = { "place": "node" + str(random.randint(1, 100))}
    for data in decodedValues:
        fields      = { "value" : data }
        save(db_client, TEMPERATURE, fields, tags=tags)    


def save(db_client, measurement, fields, tags=None):
    json_body = [{'measurement': measurement, 'tags': tags, 'fields': fields}]

    # write / save into a row
    db_client.write_points(json_body)

