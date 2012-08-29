import urllib
import json
import logging
from person.models import Person, SocialPerson

log = logging.getLogger('web.person.social.vkontakte')

# TODO: move access_token and user_id param to constructor

class VkontakteException(Exception):
    pass

class Client(object):

    URL = 'https://api.vk.com/method/%s'
    PERSON_FIELDS = 'first_name,last_name,bdate,photo,sex,counters,contacts,photo_medium,photo_big,photo_rec,education,city,country'
    PROVIDER = 'vkontakte'

    def _check_params(self, args, kwargs):
        if 'social_person' in kwargs:
            access_token = kwargs['social_person'].token
            user_id = kwargs['social_person'].external_id
        else:
            access_token = kwargs.get('access_token') or args[0]
            user_id = kwargs.get('user_id') or args[1]

        if not access_token or not user_id:
            raise TypeError('access_token and user_id or social_person are required params')

        return (access_token, user_id)

    def _fetch(self, method, params={}, return_one=False):
        url = self.URL % method
        for k, v in params.items():
            if isinstance(v, unicode):
                params[k] = v.encode('utf-8')
            else:
                params[k] = v
        url += '?' + urllib.urlencode(params)

        uopen = urllib.urlopen(url)
        data = json.load(uopen.fp)
        if 'error' in data:
            # important to raise exception here
            # if fetch_user returns None it means VK does not authorize us
            # we need to stop auth process because it can broke registration mechanics
            raise VkontakteException('vkontakte error [method=%s], [params=%s], [url=%s]:  %s,' % (method, params, url, data))

        if return_one:
            if len(data['response']) > 0:
                return data['response'][0]
            return {}
        else:
            return data['response']

    def fill_social_person(self, fetched_person, access_token=None):
        try:
            sp = SocialPerson.objects.get(provider=SocialPerson.PROVIDER_VKONTAKTE, external_id=fetched_person['uid'])
        except SocialPerson.DoesNotExist:
            sp = SocialPerson()
            # fill new token for not existent person because only mobile auth provide token with full rights
            # so, rewrite mobile token with limited desktop token is bad idea
            # updating desktop token by mobile is processed in person.backends.py
            sp.token = access_token

        sp.external_id = fetched_person['uid']
        sp.firstname = fetched_person['first_name']
        sp.lastname = fetched_person['last_name']
        sp.photo_url = fetched_person['photo_medium']
        sp.location = '%s, %s' % (fetched_person.get('country_rus'), fetched_person.get('city_rus'))

        if fetched_person['sex'] == 1:
            sp.sex = Person.PERSON_SEX_FEMALE
        elif fetched_person['sex'] == 2:
            sp.sex = Person.PERSON_SEX_MALE
        else:
            sp.sex = Person.PERSON_SEX_UNDEFINED

        #self.birthday = fetched_person.get('bdate')
        sp.provider = SocialPerson.PROVIDER_VKONTAKTE
        sp.data = json.dumps(fetched_person)
        return sp


    def fetch_friends(self,  *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)
        data = self._fetch('friends.get', {
            'access_token' : access_token,
            'uid' : user_id,
            'fields' : self.PERSON_FIELDS
        })
        if not data:
            return []
        result = []
        for fetched_person in data:
            result.append(self.fill_social_person(fetched_person))
        return result

    def fetch_user(self, *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)
        if not access_token or not user_id:
            raise TypeError('access_token and user_id or social_person are required params')

        fetched_person = self._fetch('users.get', {
           'access_token' : access_token,
           'uid' : user_id,
           'fields' : self.PERSON_FIELDS
        }, return_one=True)


        if int(fetched_person.get('city')):
            city_resp = self._fetch('places.getCityById', {
                'access_token' : access_token,
                'cids' : fetched_person.get('city'),
                }, return_one=True)
            fetched_person['city_rus'] = city_resp['name']
        if int(fetched_person.get('country')):
            country_resp = self._fetch('places.getCountryById', {
                'access_token' : access_token,
                'cids' : fetched_person.get('country'),
                } , return_one=True)
            fetched_person['country_rus'] = country_resp['name']

        return self.fill_social_person(fetched_person, access_token)

    def wall_post(self,  *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)

        message = kwargs.get('message')
        photo_url = kwargs['photo_url']
        link_url =  kwargs['link_url']
        lat =  kwargs.get('lat')
        lng =  kwargs.get('lng')

        # DEBUG VK WALL
        from django.conf import settings
        access_token = settings.DEBUG_VK_WALL_ACCESS_TOKEN
        user_id = settings.DEBUG_VK_WALL_USER_ID

        url = self._fetch('photos.getWallUploadServer', {
            'access_token' : access_token
        })['upload_url']


        import requests
        photo_resp = requests.get(photo_url)
        response = requests.post(url, files={'photo' : ('photo.jpeg', photo_resp.content)}).json

        photo_id_resp = self._fetch('photos.saveWallPhoto', {
            'access_token' : access_token,
            'server' : response['server'],
            'photo' : response['photo'],
            'hash' : response['hash'],
        })

        attachments = photo_id_resp[0]['id'] + ',' + link_url
        req_proto = {
            'access_token' : access_token,
            'message' : message,
            'attachments' : attachments,
            'friends_only' : 1,
            'lat' : lat,
            'long' : lng,
        }
        response = self._fetch('wall.post', req_proto)

    def get_settings(self,  *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)
        response = self._fetch('getUserSettings', {
            'access_token' : access_token,
            'uid' : user_id,
        })
        rights_list = (
            'notify',
            'friends',
            'photo',
            'audio',
            'video',
            'apps',
            'pr'
            'questions',
            'wiki',
            'left_menu',
            'quick_links',
            'status',
            'note',
            'messages',
            'wall',
            'ads',
            'docs',
            'groups',
            'notifications'
        )
        rights = []
        for right in rights_list:
            if response & 1 == 1:
                rights.append(right)
            response = response >> 1
        log.info('received settings for vk_id(%s) - %s' % (user_id, rights))
        return rights


def test():
    from person.social.vkontakte import Client
    c = Client()
    from poi.models import Checkin
    ch = Checkin.objects.get(id=724)
    c.wall_post(access_token=1, user_id=1, checkin=ch)


