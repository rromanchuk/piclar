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
        self.radius = 100
        # lat,lon
        # radius
        self.url_pattern = 'https://api.foursquare.com/v2/venues/search?ll=%s,%s&limit=50&radius=%s&client_id=%s&client_secret=%s&v=%s'


    def _get_url(self, lat, lng, radius=35):
        return self.url_pattern % (
            lat, lng, radius, self.client_id, self.client_secret, self.client_v
        )

    def store(self, result):
        saved_cnt = 0
        exists_cnt = 0
        for item in result:
            try:
                FoursquarePlace.objects.get(external_id=item['id'])
                exists_cnt += 1
                continue
            except FoursquarePlace.DoesNotExist:
                pass

            if len(item['categories']):
                category =  item['categories'][0].get('name')
            else:
                category = ''

            place_proto = {
                'external_data': json.dumps(item),
                'external_id': item['id'],
                'title': item['name'],
                'phone': item['contact'].get('formattedPhone'),
                'type': category,
                'checkins': item['stats'].get('checkinsCount', 0),
                'users': item['stats'].get('usersCount', 0),
                'tips': item['stats'].get('tips', 0),
                'address': item['location'].get('address'),
                'crossing': item['location'].get('crossStreet'),
                'position': 'POINT(%s %s)' % (item['location']['lng'], item['location']['lat']),
            }
            place = FoursquarePlace(**place_proto)
            place.save()
            saved_cnt +=1

        log.info('fousquare lazy download - %s saved, %s duplacated' % (saved_cnt, exists_cnt))

    def search(self, lat, lng):
        data = urllib.urlopen(self._get_url(lat, lng))
        try:
            data = json.load(data.fp)
        except ValueError as e:
            log.exception(e)
            return []
        data = data['response']['venues']
        log.info('found %s venues from foursquare' % len(data))
        return data