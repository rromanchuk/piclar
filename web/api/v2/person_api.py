# coding=utf-8
from django.contrib.auth import authenticate, login, logout
from person.models import Person
from person.exceptions import *

from poi.provider import get_poi_client
from feed.models import FeedItem

from ..base import *
from logging import getLogger

log = getLogger('web.api.person')

def model_to_dict(model, fields):
    return dict([ (fname, str(getattr(model, fname))) for fname in fields ])

class PersonApiMethod(ApiMethod):
    is_auth_required = True
    return_fields = (
        'id', 'firstname', 'lastname', 'email', 'photo',
    )


class PersonCreate(PersonApiMethod):
    is_auth_required = False
    def filter_fields(self, data, required_fields):
        filtered = dict([ (k,v) for k,v in data.items() if k in required_fields])
        if set(filtered.keys()).issuperset(set(required_fields)):
            return filtered
        else:
            return {}

    def post(self):
            # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email', 'password'
            )

        vk_fields = (
            'user_id', 'access_token', 'email'
            )

        # TODO: correct validation processing
        try:
            vk_data = self.filter_fields(self.request.POST, vk_fields)
            simple_data = self.filter_fields(self.request.POST, simple_fields)
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

        return model_to_dict(person, self.return_fields)

class PersonGet(PersonApiMethod):
    def get(self, pk):
        try:
            person = Person.objects.get(id=pk)
        except Person.DoesNotExist:
            return self.error(message='person with id %s not found' % pk)

        return model_to_dict(person, self.return_fields)

class PersonLogin(PersonApiMethod):
    is_auth_required = False
    def post(self):
        username = self.request.POST.get('username')
        password = self.request.POST.get('password')
        user = authenticate(username=username, password=password)
        if user is not None:
            if user.is_active:
                login(self.request, user)
                return model_to_dict(user.get_profile(), self.return_fields)
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
        print person
        return model_to_dict(person, self.return_fields)

class PersonFeed(PersonApiMethod):
    def get(self):
        data = FeedItem.objects.feed_for_person(self.request.user.get_profile()).values('item__data')
        return {'data' : 'test'}