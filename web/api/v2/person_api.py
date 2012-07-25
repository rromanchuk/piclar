# coding=utf-8
from django.contrib.auth import authenticate, login, logout

from feed.models import FeedItem

from person.models import Person
from person.exceptions import *

from poi.models import Place
from poi.provider import get_poi_client

from place_api import refine_place

from base import *
from logging import getLogger

log = getLogger('web.api.person')

from utils import model_to_dict, filter_fields, AuthTokenMixin, doesnotexist_to_404

def person_to_dict(person):
    person_fields = (
        'id', 'firstname', 'lastname', 'email', 'photo_url'
    )
    data = model_to_dict(person, person_fields)
    data['social_profile_urls'] = person.social_profile_urls
    return data


class PersonApiMethod(ApiMethod):
    def refine(self, obj):
        if isinstance(obj, Person):
            return person_to_dict(obj)

        return obj

class PersonCreate(PersonApiMethod):

    def post(self):
            # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email', 'password'
            )

        vk_fields = (
            'user_id', 'access_token', #'email'
            )

        # TODO: correct validation processing
        try:
            vk_data = filter_fields(self.request.POST, vk_fields)
            simple_data = filter_fields(self.request.POST, simple_fields)
            if simple_data:
                person = Person.objects.register_simple(**simple_data)
            elif vk_data:
                provider = get_poi_client('vkontakte')
                person = Person.objects.register_provider(provider=provider, **vk_data)
            else:
                return self.error(message='Registration with args [%s] not implemented' %
                     (', ').join(self.request.POST.keys())
                )
        except AlreadyRegistered as e:
            person = e.get_person()

        except RegistrationException as e:
            return self.error(message='registration error')

        login(self.request, person.user)
        data = person_to_dict(person)
        data['token'] = person.token
        return data

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
                data = person_to_dict(user.get_profile())
                data['token'] = user.get_profile().token
                return data

        return self.error(message='unauthorized', status_code=401)

class PersonLogout(PersonApiMethod, AuthTokenMixin):
    def get(self):
        logout(self.request)

    def post(self):
        logout(self.request)

class PersonLogged(PersonApiMethod, AuthTokenMixin):
    def get(self):
        person = self.request.user.get_profile()
        return person

class PersonFeed(PersonApiMethod, AuthTokenMixin):
    def refine(self, obj):
        if isinstance(obj, Place):
            return refine_place(obj)

        return super(PersonFeed, self).refine(obj)
    def get(self):
        person_feeds = FeedItem.objects.feed_for_person(self.request.user.get_profile())[:20]
        feed_list = []
        for pitem in person_feeds:
            item = {
                'creator' : pitem.creator,
                'type' : pitem.item.type,
                'data' : pitem.item.get_data(),
            }
            feed_list.append(item)

        return feed_list