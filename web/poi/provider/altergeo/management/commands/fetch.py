from django.core.management.base import BaseCommand, CommandError

from urllib import urlencode
from urllib2 import Request, HTTPHandler
from poi.provider.altergeo.models import AltergeoPlace
import json
import time

def pair_range(start, stop, step=1):
    x = start
    while x < stop:
        yield (x, min(x+step, stop))
        x += step


class Command(BaseCommand):

    URL = 'http://altergeo.ru/openapi/v1/places/search/'
    FETCH_BOX = {
        'upper_left_lat' : 55.769718,
        'upper_left_lng' : 37.596245,
        'lower_right_lat' : 55.736293,
        'lower_right_lng' : 37.646713,
    }
    STEP = 0.01

    def _fetch_box(self, box):
        req_params = {
            'limit' : 1000
        }

        req_params.update(box)
        data = urlencode(req_params.items())
        req = Request(self.URL, data=data)
        req.timeout = 1000
        req.add_header('Accept', 'application/json')
        req.add_header('Content-type', 'application/x-www-form-urlencoded')
        h = HTTPHandler()
        result = h.http_open(req)
        result = json.load(result.fp)
        if 'error' in result:
            return {'count': 0}
        return result['places']

    def handle(self, *args, **options):
        ids = set()
        for x in pair_range(self.FETCH_BOX['lower_right_lat'], self.FETCH_BOX['upper_left_lat'], self.STEP):
            for y in pair_range(self.FETCH_BOX['upper_left_lng'], self.FETCH_BOX['lower_right_lng'], self.STEP):
                print x, y
                box = {
                    'upper_left_lat' : x[0],
                    'lower_right_lat' : x[1],
                    'lower_right_lng' : y[0],
                    'upper_left_lng' : y[1],
                }
                data = self._fetch_box(box)
                count = int(data['count'])
                time.sleep(6)
                print count
                for i in range(count):
                    item = data[str(i)]['place']
                    ids.add(item['id'])

                    try:
                        AltergeoPlace.objects.get(external_id = item['id'])
                    except AltergeoPlace.DoesNotExist:
                        proto = {
                            'title' : item['title'],
                            'description' : item['about'],
                            'external_id' : item['id'],
                            'type' : item['type']['title'],
                            #place.external_data
                            'position' : 'POINT(%s %s)' % (item['lng'], item['lat']),
                            'address' : item['street'],
                            'country' : item['country'],
                            'city' : item['city'],
                        }
                        place = AltergeoPlace(**proto)
                        place.save()


        print len(ids)
