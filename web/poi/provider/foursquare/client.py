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

        categories = {
            u'College & University': u'4d4b7105d754a06372d81259',
            u'Food': u'4d4b7105d754a06374d81259',
            #u'Residence': u'4e67e38e036454776db1fb3a',
            u'Travel & Transport': u'4d4b7105d754a06379d81259',
            u'Shop & Service': u'4d4b7105d754a06378d81259',
            u'Arts & Entertainment': u'4d4b7104d754a06370d81259',
            u'Great Outdoors': u'4d4b7105d754a06377d81259',
            u'Nightlife Spot': u'4d4b7105d754a06376d81259',
            u'Professional & Other Places': u'4d4b7105d754a06375d81259'
        }
        self.search_url_pattern = 'https://api.foursquare.com/v2/venues/search?ll=%s,%s&limit=50&radius=%s&client_id=%s&client_secret=%s&v=%s' + \
            'categories=' + ','.join(categories.values())

        self.download_url_pattern = 'https://api.foursquare.com/v2/venues/search?intent=browse&sw=%s,%s&ne=%s,%s&limit=50&&client_id=%s&client_secret=%s&v=%s' +\
            '&categories=' + ','.join(categories.values())



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

    def _fetch(self, url):
        data = urllib.urlopen(url)
        retry = 3
        while retry > 0:
            try:
                data = json.load(data.fp)
            except ValueError as e:
                log.exception(e)
                return []
            except IOError:
                log.exception(e)
                retry -= 1

        if data.has_key('meta') and 'errorType' in data['meta']:
            log.info('foursquare api error: %s' % data['meta']['errorDetail'])
            return []
        data = data['response']['venues']
        log.info('found %s venues from foursquare' % len(data))
        return data

    def download(self, box):
        # box keys:
        #'upper_left_lat'
        #'upper_left_lng'
        #'lower_right_lat'
        #'lower_right_lng'

        sw = (box['lower_right_lat'], box['upper_left_lng'])
        ne = (box['upper_left_lat'], box['lower_right_lng'])

        url = self.download_url_pattern % (
            sw[0], sw[1], ne[0], ne[1], self.client_id, self.client_secret, self.client_v
            )
        return self._fetch(url)


    def search(self, lat, lng):
        url = self.search_url_pattern % (
            lat, lng, self.radius, self.client_id, self.client_secret, self.client_v
            )
        return self._fetch(url)

