"""
This file demonstrates writing tests using the unittest module. These will pass
when you run "manage.py test".

Replace this with more appropriate tests for your application.
"""
import json

from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from tastypie import http

from poi.provider.vkontakte.client import Client as VKClient
from person.models import Person, SocialPerson
from api.views.person_api import PersonResource

from util import BaseTest

import urllib

class DummyVkClient(VKClient):

    def fetch_user(self, *args, **kwargs):
        sp = self.fill_social_person({
            'uid' : '123123',
            'first_name' : 'test',
            'last_name' : 'test',
        }, 'asdasd')
        return sp

    def fetch_friends(self,  *args, **kwargs):
        sp = self.fill_social_person({
            'uid' : '123124',
            'first_name' : 'test',
            'last_name' : 'test',
            }, 'asdasd')
        return [sp]

@override_settings(POI_PROVIDER_CLIENTS={'vkontakte':'api.tests.DummyVkClient'})
class PersonTest(BaseTest):

    def setUp(self):
        super(PersonTest, self).setUp()

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
        self.person = self.register_person(self.person_data)



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
        response = self.perform_post(self.person_url, data)
        self.assertEquals(response.status_code, 201)

        user = self.perform_get(response['Location'])
        self._check_user(user)

    def test_already_registred(self):
        # check duplicate registration
        response = self.perform_post(self.person_url, self.person_data)
        self.assertEquals(response.status_code, 302)
        user = self.perform_get(response['Location'])
        self._check_user(user)

    def test_already_registred_vk(self):
        vk_data = {
            'access_token' : 'asdasd',
            'user_id' : '123123'
        }
        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 201)

        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 302)
        user = self.perform_get(response['Location'])
        self._check_user(user)

    def test_register_existent_social_person(self):
        # register person with friends
        vk_data = {
            'access_token' : 'asdasd',
            'user_id' : '123123'
        }
        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 201)

        # try to register this friend
        vk_data = {
            'access_token' : 'asdasd',
            'user_id' : '123124'
        }
        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 302)


    def test_invalid_email(self):
        data = {
            'email' : 'invalid_email_here',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
            }
        response = self.perform_post(self.person_url, data)
        self.assertNotEquals(response.status_code, 201)


    def test_login_logout(self):
        resource = PersonResource()
        uri = resource.get_resource_uri(self.person)

        # try not logined
        response = self.perform_get(uri)
        self.assertEquals(response.status_code, 401)

        # do login
        login_data = {
            'login' : self.person_data['email'],
            'password' : self.person_data['password'],
        }
        response = self.perform_post(self.person_url + 'login/', login_data)
        self.assertEquals(response.status_code, 302)

        user = self.perform_get(response['Location'])
        self._check_user(user)

        # do logout
        response = self.perform_post(self.person_url + 'logout/')

        # try not logined again
        response = self.perform_get(uri)
        self.assertEquals(response.status_code, 401)