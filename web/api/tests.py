"""
This file demonstrates writing tests using the unittest module. These will pass
when you run "manage.py test".

Replace this with more appropriate tests for your application.
"""

from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from person.models import Person
from api.views import PersonResource
from tastypie import http
import json

class SimpleTest(TestCase):

    def setUp(self):
        self.client = Client()
        self.person_url = reverse('api_dispatch_list',
            kwargs={
                'resource_name' : 'person',
               'api_name' : 'v1'
            }
        )
        self.person_data = {
            'email' : 'test1@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
        }
        self.person = Person.register_simple(**self.person_data)


    def tearDown(self):
        pass

    def _check_user(self, response):
        self.assertEquals(response.status_code, 200)

    def test_simple_register(self):
        data = {
            'email' : 'test@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
        }
        response = self.client.post(self.person_url, data=json.dumps(data), content_type='application/json')
        self.assertEquals(response.status_code, 201)

        user = self.client.get(response['Location'])
        self._check_user(user)

    def test_already_registred(self):
        # check duplicate registration
        response = self.client.post(self.person_url, data=json.dumps(self.person_data), content_type='application/json')

        # HttpConflict
        self.assertEquals(response.status_code, 409)

    def test_invalid_email(self):
        self.skipTest('not implemented')

    def test_login_logout(self):
        resource = PersonResource()
        uri = resource.get_resource_uri(self.person)

        # try not logined
        response = self.client.get(uri)
        self.assertEquals(response.status_code, 401)

        # do login
        login_data = {
            'login' : self.person_data['email'],
            'password' : self.person_data['password'],
        }
        response = self.client.post(self.person_url + 'login/', login_data )
        self.assertEquals(response.status_code, 302)

        user = self.client.get(response['Location'])
        self._check_user(user)

        # do logout
        response = self.client.get(self.person_url + 'logout/')

        # try not logined again
        response = self.client.get(uri)
        self.assertEquals(response.status_code, 401)

    def test_search(self):
        pass
