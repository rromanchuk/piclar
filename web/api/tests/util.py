from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse

from person.models import Person, SocialPerson
import urllib

class BaseTest(TestCase):
    def setUp(self):
        self.client = Client()

    def _prep_param(self, url, data=None):
        params = {
            'content_type': 'application/x-www-form-urlencoded',
            'HTTP_ACCEPT': 'application/json',
            }
        if data:
            params['data'] = urllib.urlencode(data)
        return params

    def perform_post(self, url, data=None):
        params = self._prep_param(url, data)
        return self.client.post(url, **params)

    def perform_get(self, url, data=None):
        params = self._prep_param(url, data)
        return self.client.get(url, **params)

    def register_person(self, person_data=None):
        if not person_data:
            person_data = {
                'email' : 'test1@gmail.com',
                'firstname': 'test',
                'lastname' : 'test',
                'password' : 'test',
                }
        return Person.objects.register_simple(**person_data)

    def login_person(self):
        url = reverse('api_person_login', args=('json',))
        login_data = {
            'username' : 'test1@gmail.com',
            'password' :'test',
            }
        self.perform_post(url, login_data)