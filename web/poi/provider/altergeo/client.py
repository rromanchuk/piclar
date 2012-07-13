# coding=utf-8
from urllib import urlencode
from urllib2 import Request, HTTPHandler
import json
import logging

from models import AltergeoPlace

log = logging.getLogger('web.poi.provider.foursquare')

class Client(object):
    URL = 'http://altergeo.ru/openapi/v1/places/search/'
    PROVIDER = 'altergeo'
    TIMEOUT = 6
    STEP = 0.01

    def __init__(self):
        self.categories = {
            #'1' : 'Автомобили',
            '4' : 'Кафе, бары и рестораны',
            '6' : 'Магазины',
            '8' : 'Развлечения и отдых',
            '9' : 'Спорт',
            '22' : 'Религия',
            '23' : 'Гостиницы'
        }

    def search(self, lat, lng):
        raise NotImplemented

    def get_photos(self, place):
        pass

    def download(self, box):
        req_params = {
            'limit' : 1000,
            'place_types' : ','.join(self.categories.keys()),
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
                    'rating' : item['rating'],
                    'checkin_count' : item['checkin_count'],
                    'rating_vote_count' : item['rating_vote_count'],

                    }
                place = AltergeoPlace(**proto)
                place.save()
                saved_cnt +=1

        log.info('altergeo download - %s saved, %s duplacated' % (saved_cnt, exists_cnt))

