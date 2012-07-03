# coding=utf-8
import urllib
import json
import logging
from models import FoursquarePlace

log = logging.getLogger('web.poi.provider.foursquare')

class Client(object):

    def __init__(self):
        self.client_id = 'ZXLGEGRBY5AQT2Z1C4MG2DIWAVENEDTDJGMSOVQB4FK3U121'
        self.client_secret = 'MA2V2Z1KXR1KUQAVNPRZWZQYFYORCREJVG3YRSRAA3OLTSUK'
        self.client_v = '20120627'
        self.radius = 35
        # lat,lon
        # radius
        self.url_pattern = 'https://api.foursquare.com/v2/venues/search?ll=%s,%s&limit=50&radius=%s&client_id=%s&client_secret=%s&v=%s'


    def _get_url(self, lat, lng, radius=35):
        return self.url_pattern % (
            lat, lng, radius, self.client_id, self.client_secret, self.client_v
        )

    def store(self, result):
        for item in result:

            place = FoursquarePlace()


    def search(self, lat, lng):
        data = urllib.urlopen(self._get_url(lat, lng))
        try:
            data = json.load(data.fp)
        except ValueError as e:
            log.exception(e)
            return []

        return  data['response']['venues']