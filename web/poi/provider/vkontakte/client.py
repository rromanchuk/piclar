import urllib
import json
import logging

log = logging.getLogger('web.poi.provider.vkontakte')

class Client(object):

    URL = 'https://api.vk.com/method/%s'

    def __init__(self):
        pass

    def download(self, box):
        pass

    def search(self, lat, lng):
        pass

    def fetch_user(self, access_token, user_id):
        url = self.URL % 'users.get'

        url += '?access_token=%s&uid=%s&%s' % (
            access_token, user_id, 'fields= first_name,last_name,bdate,photo,counters,contacts,photo_medium,photo_big,photo_rec,education'
        )
        uopen = urllib.urlopen(url)
        data = json.load(uopen.fp)
        if 'error' in data:
            log.error('Error due vkontakte registration: %s' % data)
            return None
        return data['response'][0]

    def fetch_user_friends(self, access_token=None, socialPerson=None):
        if not access_token:
            access_token = socialPerson.token
        pass
