from django.conf import settings
from urllib import urlopen
import json


def region_by_coords(lat, lng):
    url = settings.GIS_HOST + '/api/region_by_coords/?lng=%s&lat=%s' % (lng, lat)
    response = urlopen(url).read()
    response = json.loads(response)
    if response.get('data'):
        return response['data']
    return {}
