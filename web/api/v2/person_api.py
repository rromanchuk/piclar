# coding=utf-8
from django.contrib.auth import authenticate, login, logout
from person.models import Person
from person.exceptions import *

from poi.provider import get_poi_client
from feed.models import FeedItem

from ..base import *
from logging import getLogger

log = getLogger('web.api.person')

from utils import model_to_dict, filter_fields

class PersonApiMethod(ApiMethod):
    is_auth_required = True
    person_fields = (
        'id', 'firstname', 'lastname', 'email', 'photo',
    )

class PersonCreate(PersonApiMethod):
    is_auth_required = False

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

        return model_to_dict(person, self.person_fields)

class PersonGet(PersonApiMethod):
    def get(self, pk):
        try:
            person = Person.objects.get(id=pk)
        except Person.DoesNotExist:
            return self.error(message='person with id %s not found' % pk)

        return model_to_dict(person, self.person_fields)

class PersonLogin(PersonApiMethod):
    is_auth_required = False
    def post(self):
        username = self.request.POST.get('username')
        password = self.request.POST.get('password')
        user = authenticate(username=username, password=password)
        if user is not None:
            if user.is_active:
                login(self.request, user)
                return model_to_dict(user.get_profile(), self.person_fields)
        return self.error(message='unauthorized', status_code=401)

class PersonLogout(PersonApiMethod):
    def get(self):
        logout(self.request)
    def post(self):
        logout(self.request)

class PersonLogged(PersonApiMethod):
    def get(self):
        if not self.request.user.is_authenticated():
            return self.error(message='unauthorized', status_code=401)

        person = self.request.user.get_profile()
        return model_to_dict(person, self.person_fields)

class PersonFeed(PersonApiMethod):
    def get(self):
        person_feeds = FeedItem.objects.feed_for_person(self.request.user.get_profile())[:20]
        feed = []
        for pitem in person_feeds:
            item = {
                'creator' : model_to_dict(pitem.creator, self.person_fields),
                'create_date' : pitem.item.create_date,
                'type' : pitem.item.type,
                'data' : pitem.item.data,
            }
            feed.append(item)

        return feed