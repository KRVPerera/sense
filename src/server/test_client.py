import requests

url = "http://your-ec2-public-ip/post"
data = {"key": "value"}

response = requests.post(url, json=data)

print(response.text)