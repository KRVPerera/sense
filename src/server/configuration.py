import os



# ------------------------------  from database.py file ------------------------------ # 
# InfluxDB credentials
#HOST      = os.environ.get('INFLUXDB_HOST', '192.168.1.172')
HOST     = os.environ.get('INFLUXDB_HOST', 'localhost')
PORT     = os.environ.get('INFLUXDB_PORT', 8086)
USERNAME = os.environ.get('INFLUXDB_USER', 'username')
PASSWORD = os.environ.get('INFLUXDB_USER_PASSWORD', 'password')
DATABASE = os.environ.get('INFLUXDB_DB', 'dht')

# measurements/tables
TEMPERATURE = 'temperature'
HUMIDITY    = 'humidity'

