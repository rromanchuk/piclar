import urllib
import json
import logging
from django.conf import settings

from models import Person, SocialPerson

log = logging.getLogger('web.person.social.providers')

# TODO: move access_token and user_id param to constructor
class ProviderException(Exception):
    pass

class BasePersonResponse(object):

    def __init__(self, raw_response, access_token=None):
        self.raw_response = raw_response
        self.access_token = access_token

    def get_social_person(self):
        try:
            sp = SocialPerson.objects.get(provider=self.provider_name, external_id=self._get_external_id())
        except SocialPerson.DoesNotExist:
            sp = SocialPerson()

        # HACK here for facebook, we should check settings here and update token only if scopes for new token is better
        if not sp.token or sp.provider == SocialPerson.PROVIDER_FACEBOOK:
            # fill new token for not existent person because only mobile auth provide token with full rights
            # so, rewrite mobile token with limited desktop token is bad idea
            # updating desktop token by mobile is processed in person.backends.py
            sp.token = self.access_token

        self._map_response(sp, self.raw_response)

        sp.provider = self.provider_name
        return sp

    def _get_external_id(self):
        return self.raw_response[self.ID_FIELD]

    def _map_response(self, social_person, response):
        for k,v in self.FIELD_MAP.items():
            magic_mapper = '_map_%s' % k
            if hasattr(self, magic_mapper):
                setattr(social_person, k, getattr(self, magic_mapper)(response.get(v), response=response))
            else:
                setattr(social_person, k, response[v])
        social_person.data = json.dumps(response)
        return social_person


class VkontaktePersonResponse(BasePersonResponse):

    ID_FIELD = 'uid'
    FIELD_MAP = {
        'external_id' : 'uid',
        'firstname' : 'first_name',
        'lastname' : 'last_name',
        'photo_url' : 'photo_medium',

        # use magic here
        'sex' : 'gender',
        'location' : None,
        'profile_url' : 'uid',
    }

    provider_name = SocialPerson.PROVIDER_VKONTAKTE

    def _map_profile_url(self, value, response):
        return 'http://vk.com/id%s' % value

    def _map_sex(self, value, response):
        gender_map = {
            1 : Person.PERSON_SEX_FEMALE,
            2 : Person.PERSON_SEX_MALE
        }
        if value in gender_map:
            return gender_map[value]
        else:
            return Person.PERSON_SEX_UNDEFINED


    def _map_location(self, value, response):
        if 'country_rus' in response and 'city_rus' in response:
            return '%s, %s' % (response.get('country_rus'), response.get('city_rus'))
        return ''

class FacebookPersonResponse(BasePersonResponse):

    ID_FIELD = 'id'
    FIELD_MAP = {
        'external_id' : 'id',
        'firstname' : 'first_name',
        'lastname' : 'last_name',

        # use magic here
        'sex' : 'gender',
        'photo_url' : 'picture',
        'location' : 'location',
        'profile_url' : 'link',
    }
    provider_name = SocialPerson.PROVIDER_FACEBOOK

    def _map_sex(self, value, response):
        gender_map = {
            'female' : Person.PERSON_SEX_FEMALE,
            'male' : Person.PERSON_SEX_MALE
        }
        if value in gender_map:
            return gender_map[value]
        else:
            return Person.PERSON_SEX_UNDEFINED

    def _map_photo_url(self, value, response):
        if not value or value['data']['is_silhouette']:
            return
        return value['data']['url']

    def _map_location(self, value, response):
        if not value:
            return
        return value['name']


class BaseClient(object):
    def __init__(self):
        self.provider_name = 'base'
        self.url = ''

    def _check_params(self, args, kwargs):
        if 'social_person' in kwargs:
            access_token = kwargs['social_person'].token
            user_id = kwargs['social_person'].external_id
        else:
            access_token = kwargs.get('access_token') or args[0]
            user_id = kwargs.get('user_id') or args[1]

        if not access_token or not user_id:
            raise TypeError('Provider [%s] - access_token and user_id or social_person are required params' % self.provider_name)
        return (access_token, user_id)


    def _fetch(self, method, params={}):
        url = self.url % method

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
            raise ProviderException('provider[%s] error [method=%s], [params=%s], [url=%s]:  %s,' % (self.provider_name, method, params, url, data))
        return data


class Facebook(BaseClient):
    PERSON_FIELDS = 'id,picture.type(large),first_name,last_name,birthday,link,gender,education,work,location,email'

    def __init__(self):
        super(Facebook, self).__init__()
        self.url = 'https://graph.facebook.com/%s'
        self.provider_name = SocialPerson.PROVIDER_FACEBOOK
        self.person_response_cls = FacebookPersonResponse

    def _fetch(self, method, params={}, return_one=False):
        response = super(Facebook, self)._fetch(method, params)
        if 'data' in response:
            return response['data']
        return response


    def fetch_user(self, *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)

        response = self._fetch(user_id, {
            'access_token' : access_token,
            'fields' : self.PERSON_FIELDS
        })
        return self.person_response_cls(response, access_token)

    def fetch_friends(self, *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)

        response = self._fetch(str(user_id) + '/friends', {
            'access_token' : access_token,
            'fields' : self.PERSON_FIELDS
        })
        result = []
        for friend in response:
            result.append(self.person_response_cls(friend, access_token))
        return result

    def wall_post(self, *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)

        message = kwargs.get('message')
        photo_url = kwargs['photo_url']
        link_url =  kwargs['link_url']
        lat =  kwargs.get('lat')
        lng =  kwargs.get('lng')


    def get_settings(self, *args, **kwargs):
        raise ProviderException('not implemented')

class Vkontakte(BaseClient):

    PERSON_FIELDS = 'first_name,last_name,bdate,photo,sex,counters,contacts,photo_medium,photo_big,photo_rec,education,city,country'

    def __init__(self):
        super(Vkontakte, self).__init__()
        self.provider_name = SocialPerson.PROVIDER_VKONTAKTE
        self.url = 'https://api.vk.com/method/%s'
        self.person_response_cls = VkontaktePersonResponse

    def _fetch(self, method, params={}, return_one=False):
        response = super(Vkontakte, self)._fetch(method, params)
        if return_one:
            if len(response['response']) > 0:
                return response['response'][0]
            return {}
        else:
            return response['response']


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
            result.append(self.person_response_cls(fetched_person))
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
            fetched_person['city_rus'] = city_resp['name'] or ''
        if int(fetched_person.get('country')):
            country_resp = self._fetch('places.getCountryById', {
                'access_token' : access_token,
                'cids' : fetched_person.get('country'),
                } , return_one=True)
            fetched_person['country_rus'] = country_resp['name'] or ''

        response = self.person_response_cls(fetched_person, access_token)
        return response

    def wall_post(self,  *args, **kwargs):
        access_token, user_id = self._check_params(args, kwargs)

        message = kwargs.get('message')
        photo_url = kwargs['photo_url']
        link_url =  kwargs['link_url']
        lat =  kwargs.get('lat')
        lng =  kwargs.get('lng')

        # DEBUG VK WALL
        from django.conf import settings
        #access_token = settings.DEBUG_VK_WALL_ACCESS_TOKEN
        #user_id = settings.DEBUG_VK_WALL_USER_ID

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

        attachments = photo_id_resp[0]['id'] # + ',' + link_url
        req_proto = {
            'access_token' : access_token,
            'message' : message,
            'attachments' : attachments,
            #'friends_only' : 1,
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
    c = Facebook()
    token = 'AAACEdEose0cBAFbVkGLMLEq5b0EmSzZC0QofGZCTLe6g1WITdhPZBXrahZBbYlQVyWHHnJeSvvrc7zlmecIfZCFyiPwvIOyPHtRoqHZCZAPpWZBZCljiaTCOZA'
    print c.fetch_user(access_token=token, user_id=1189704961)
    #c = Vkontakte()
    #from poi.models import Checkin
    #ch = Checkin.objects.get(id=724)
    #c.wall_post(access_token=1, user_id=1, checkin=ch)



def provider(name):
    client_map = settings.SOCIAL_PROVIDER_CLIENTS
    class_path = client_map[name].split('.')
    class_name = class_path.pop()

    module = __import__('.'.join(class_path), fromlist='person')
    return getattr(module, class_name)()
