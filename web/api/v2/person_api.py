# coding=utf-8
from django.contrib.auth import authenticate, login, logout

from feed.models import FeedItem

from person.models import Person, PersonSetting
from person.exceptions import *

from poi.models import Place

from feed_api import feeditemcomment_to_dict

from base import *
from logging import getLogger

log = getLogger('web.api.person')

from utils import model_to_dict, filter_fields, AuthTokenMixin, doesnotexist_to_404

class PersonApiMethod(ApiMethod):
    def refine(self, obj):
        if isinstance(obj, Person):
            return obj.serialize()

        return obj

class PersonCreate(PersonApiMethod):

    def post(self):
            # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email', 'password'
            )

        social_fields = (
            'user_id', 'access_token', #provider
        )

        # TODO: correct validation processing
        try:
            social_data = filter_fields(self.request.POST, social_fields)
            simple_data = filter_fields(self.request.POST, simple_fields)
            if simple_data:
                person = Person.objects.register_simple(**simple_data)
            elif social_data:
                import person.social
                social_client = person.social.provider(self.request.POST.get('provider', 'vkontakte'))
                person = Person.objects.register_provider(provider=social_client, good_token=True, **social_data)
            else:
                return self.error(message='Registration with args [%s] not implemented' %
                     (', ').join(self.request.POST.keys())
                )
        except AlreadyRegistered as e:
            person = e.get_person()

        except RegistrationException as e:
            return self.error(message='registration error')

        login(self.request, person.user)
        data = person.serialize()
        data['token'] = person.token
        return data

class PersonUpdate(PersonApiMethod, AuthTokenMixin):
    def post(self):
        non_empty_fields = {
            'email', 'firstname', 'lastname'
        }
        for field in non_empty_fields:
            if field in self.request.POST and not self.request.POST.get(field):
                return self.error(message='field %s must be not empty' % field)

        person = self.request.user.get_profile()
        if self.request.POST.get('email'):
            person.change_email(self.request.POST.get('email'))

        profile = {
            'firstname' : self.request.POST.get('firstname') or person.firstname,
            'lastname' : self.request.POST.get('lastname') or person.lastname,
        }

        for field in ['location', 'birthday']:
            if self.request.POST.get(field):
                profile[field] = self.request.POST.get(field)

        person.change_profile(**profile)
        return person

class PersonGet(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        person = Person.objects.get(id=pk)
        return person

class PersonLogin(PersonApiMethod):
    is_auth_required = False
    def post(self):
        username = self.request.POST.get('username')
        password = self.request.POST.get('password')
        user = authenticate(username=username, password=password)
        if user is not None:
            if user.is_active:
                login(self.request, user)
                data = user.get_profile().serialize()
                data['token'] = user.get_profile().token
                return data

        return self.error(message='unauthorized', status_code=401)

class PersonLogout(PersonApiMethod, AuthTokenMixin):
    def get(self):
        logout(self.request)

    def post(self):
        logout(self.request)

class PersonUpdateSocial(PersonApiMethod, AuthTokenMixin):
    def post(self):
        provider_name = self.request.POST.get('provider')
        token = self.request.POST.get('token')
        self.request.user.get_profile().update_social_token(provider_name, token)


class PersonLogged(PersonApiMethod, AuthTokenMixin):
    def get(self):
        person = self.request.user.get_profile()
        return person

class PersonFeed(PersonApiMethod, AuthTokenMixin):

    def get(self):
        if settings.API_DEBUG_FEED_EMPTY and settings.DEBUG:
            return []
        feed =  FeedItem.objects.feed_for_person(self.request.user.get_profile())[:20]
        return [ item.item.serialize(self.request) for item in feed ]

class PersonFeedOwned(PersonFeed):
    @doesnotexist_to_404
    def get(self, pk):
        if settings.API_DEBUG_FEED_EMPTY and settings.DEBUG:
            return []
        person = Person.objects.get(id=pk)
        feed =  FeedItem.objects.feed_for_person_owner(person)[:20]
        return [ item.item.serialize(self.request) for item in feed ]


class PersonFollowers(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        if pk == 'logged':
            person = self.request.user.get_profile()
        else:
            person = Person.objects.get(id=pk)
        return Person.objects.get_followers(person)


class PersonFollowing(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        if pk == 'logged':
            person = self.request.user.get_profile()
        else:
            person = Person.objects.get(id=pk)
        return Person.objects.get_following(person)

class PersonFollowUnfollow(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def post(self, pk, action):
        person = self.request.user.get_profile()
        friend = Person.objects.get(id=pk)
        if action == 'unfollow' :
            person.unfollow(friend)
        elif action == 'follow':
            person.follow(friend)
        return person

class PersonSettingApi(PersonApiMethod, AuthTokenMixin):
    def post(self):
        proto = {}
        for key in PersonSetting.SETTINGS_MAP.keys():
            proto[key] = self.request.POST.get(key)

        self.request.user.get_profile().set_settings(proto)
        return {}

    def get(self):
        return self.request.user.get_profile().get_settings()