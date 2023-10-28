import os
import sys
import requests
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Check if IP is passed as an argument to the script
if len(sys.argv) > 1:
    ip = sys.argv[1]
else:
    # Check if STATIC_IP environment variable exists and is not empty
    static_ip = os.getenv('STATIC_IP')
    if static_ip:
        ip = static_ip
    else:
        response = requests.get('https://ip.me')
        ip = response.text.strip()

token = os.getenv('DO_TOKEN')
domain = os.getenv('DO_DOMAIN')
record_id = os.getenv('DO_RECORD_ID')

# print the domain value
print("Domain: {}".format(domain))

headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer {0}'.format(token),
}

data = '{"data":"%s"}' % ip

print ("Starting")
response = requests.put('https://api.digitalocean.com/v2/domains/{0}/records/{1}'.format(domain, record_id), headers=headers, data=data)
print ("Done")

ip = response.json()['domain_record']['data']

print("Updated to {}".format(ip))
