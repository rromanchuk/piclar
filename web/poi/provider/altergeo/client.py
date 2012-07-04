from urllib import urlencode
from urllib2 import Request, HTTPHandler
import json
import logging

from models import AltergeoPlace

log = logging.getLogger('web.poi.provider.foursquare')

class Client(object):
    URL = 'http://altergeo.ru/openapi/v1/places/search/'

    def __init__(self):
        pass

    def search(self, lat, lng):
        raise NotImplemented

    def download(self, box):
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
            log.info('error due fetching Altergeo: %s' % result['error'] )
            return {'count': 0}

        log.info('Altergeo: %s fetched' % result['places']['count'])
        return result['places']

    def store(self, data):
        count = int(data['count'])
        saved_cnt = 0
        exists_cnt = 0
        for i in range(count):
            item = data[str(i)]['place']

            try:
                AltergeoPlace.objects.get(external_id = item['id'])
                exists_cnt +=1
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
                saved_cnt +=1

        log.info('altergeo download - %s saved, %s duplacated' % (saved_cnt, exists_cnt))

