import requests
import json
from requests.auth import HTTPBasicAuth
from django.conf import settings

PUSH_URL = 'https://go.urbanairship.com/api/push/'

def send_notification(alias, text, extra={}, badge="+1"):
    data = {
        'aps' : {
            'alert' : text,
            'badge' : badge,
        },
        'aliases' : [str(alias)],
        'sound': 'default',
    }
    if extra:
        data['extra'] = extra
    headers = {'content-type': 'application/json'}

    key = settings.UA_KEY
    secret = settings.UA_SECRET

    auth = HTTPBasicAuth(key, secret)
    req = requests.post(PUSH_URL, data=json.dumps(data), auth=auth, headers=headers)

