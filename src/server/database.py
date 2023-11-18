#import os
from influxdb import InfluxDBClient

from configuration import HOST, PORT, USERNAME, PASSWORD, DATABASE, TEMPERATURE

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


def sendInfluxdb(data, measurement=TEMPERATURE):
    db_client = client()
    if measurement == TEMPERATURE or measurement == 'humidity':
        tags        = { "place": "node1" }
        fields      = { "value" : data }
        save(db_client, measurement, fields, tags=tags)    
    else:
        print("Positional argument (measurement) required!")


def save(db_client, measurement, fields, tags=None):
    json_body = [{'measurement': measurement, 'tags': tags, 'fields': fields}]

    # write / save into a row
    db_client.write_points(json_body)

