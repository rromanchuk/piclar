import urllib
import json
import logging

log = logging.getLogger('web.poi.provider.instagram')

class Client(object):

    PROVIDER = 'instagram'
    TIMEOUT = 1
    STEP = 0.001

    def __init__(self):
        self.geo_url = 'https://api.instagram.com/v1/locations/search?distance=100&lat=%s&lng=%s&access_token=879325.1fb234f.719cf5db47b14051a6761fd0e75959cb'
        self.fsq_url = 'https://api.instagram.com/v1/locations/search?distance=100&foursquare_v2_id=%s&access_token=879325.1fb234f.719cf5db47b14051a6761fd0e75959cb'
        self.media_url = 'https://api.instagram.com/v1/locations/%s/media/recent?access_token=879325.1fb234f.719cf5db47b14051a6761fd0e75959cb'

    # TODO: extract this method for all clients
    def _fetch(self, url):
        retry = 3
        while retry > 0:
            try:
                uopen = urllib.urlopen(url)
                data = json.load(uopen.fp)
            except ValueError as e:
                log.exception(e)
                return []
            except IOError as e:
                log.exception(e)
                retry -= 1
            else:
                break

        if data['meta']['code'] != 200:
            log.info('instagram api error: %s' % data['meta'])
            return []
        data = data['data']
        return data

    def get_photos(self, place=None, f_place=None):
        if f_place:
            url = self.fsq_url % (f_place.external_id)
            place = self._fetch(url)
            if len(place) > 0:
                place_url = self.media_url % place[0]['id']
                return self._fetch(place_url)
        return {}

    def store(self, result):
        for item in result:
            print item['name']


    def download(self, box):
        lat = (box['upper_left_lat'] + box['lower_right_lat']) / 2
        lng = (box['upper_left_lng'] + box['lower_right_lng']) / 2

        url = self.geo_url % (lat, lng)

        return self._fetch(url)
