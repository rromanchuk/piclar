# coding=utf-8
import urllib
from StringIO import StringIO
import logging
import ijson
from gzip import GzipFile

from models import OtaPlace

log = logging.getLogger('web.poi.provider.ota')

class Client(object):

    HOTELS_URL = 'http://affiliate.ostrovok.ru/api/v1/hotels.json.gz?_auth=1%3Af7868331c5b25bab69eb13dad38e15bab9f1b56c'

    PROVIDER = 'ota'
    STEP = 0.0


    def store(self, result):
        cnt = 0
        for item in result:
            proto = {
                'title' : item['name'],
                'external_id' : item['id'],
                'address' : item['address'],
                'url' : item['url'],
                'position' : 'POINT(%s %s)' % (item['longitude'], item['latitude'])
            }
            if item['images'] and len(item['images']) > 0:
                proto['photo'] =item['images'][0]['url']
            try:
                place = OtaPlace.objects.get(external_id=item['id'])
            except OtaPlace.DoesNotExist:
                place = OtaPlace()
            for k,v in proto.items():
                setattr(place, k, v)
            place.save()
            cnt += 1
            if cnt % 100 == 0:
                log.info('%s items were processed' % cnt)

    def download(self, box):
        url_f = urllib.urlopen(self.HOTELS_URL)
        log.info('reading OTA hotels file...')
        buff = StringIO(url_f.read())
        log.info('unpacking...')
        gzfile = GzipFile(fileobj=buff)

        log.info('processing OTA items:')
        return ijson.items(gzfile, 'item')


