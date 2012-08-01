import urllib
import json
import logging
from person.models import SocialPerson

log = logging.getLogger('web.poi.provider.vkontakte')

# TODO: move access_token and user_id param to constructor

class Client(object):

    URL = 'https://api.vk.com/method/%s'
    PERSON_FIELDS = 'first_name,last_name,bdate,photo,counters,contacts,photo_medium,photo_big,photo_rec,education'
    PROVIDER = 'vkontakte'

    def download(self, box):
        pass

    def search(self, lat, lng):
        pass

    def _check_params(self, args, kwargs):
        if 'social_person' in kwargs:
            access_token = kwargs['social_person'].token
            user_id = kwargs['social_person'].external_id
        else:
            access_token = args[0] or kwargs['access_token']
            user_id = args[1] or kwargs['user_id']

        if not access_token or not user_id:
            raise TypeError('access_token and user_id or social_person are required params')

        return (access_token, user_id)

    def _fetch(self, url, return_one=False):
        uopen = urllib.urlopen(url)
        data = json.load(uopen.fp)
        if 'error' in data:
            log.error('Error due vkontakte registration: %s' % data)
            return None
        if return_one:
            return data['response'][0]
        else:
            return data['response']

    def fill_social_person(self, fetched_person, access_token):
        try:
            sp = SocialPerson.objects.get(provider=SocialPerson.PROVIDER_VKONTAKTE, external_id=fetched_person['uid'])
        except SocialPerson.DoesNotExist:
            sp = SocialPerson()

        sp.external_id = fetched_person['uid']
        sp.firstname = fetched_person['first_name']
        sp.lastname = fetched_person['last_name']
        sp.photo_url = fetched_person['photo_big']
        #self.birthday = fetched_person.get('bdate')
        sp.provider = SocialPerson.PROVIDER_VKONTAKTE
        sp.token = access_token
        sp.data = json.dumps(fetched_person)
        return sp


    def fetch_friends(self,  *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)
        url = self.URL % 'friends.get'
        url += '?access_token=%s&uid=%s&%s' % (
            access_token, user_id, 'fields=' + self.PERSON_FIELDS
        )
        data = self._fetch(url)
        if not data:
            return []
        result = []
        for fetched_person in data:
            result.append(self.fill_social_person(fetched_person, access_token))
        return result

    def fetch_user(self, *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)
        if not access_token or not user_id:
            raise TypeError('access_token and user_id or social_person are required params')

        url = self.URL % 'users.get'
        url += '?access_token=%s&uid=%s&%s' % (
            access_token, user_id, 'fields='+ self.PERSON_FIELDS
        )
        fetched_person = self._fetch(url, return_one=True)
        if not fetched_person:
            return None
        return self.fill_social_person(fetched_person, access_token)

    def fetch_user_friends(self, access_token=None, socialPerson=None):
        if not access_token:
            access_token = socialPerson.token
        pass
