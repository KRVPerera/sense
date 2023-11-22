FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY database.py .
COPY coap_server.py .
COPY configuration.py .
COPY decoder.py .

CMD ["python", "coap_server.py"]