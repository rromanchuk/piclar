import json

from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from tastypie import http

from poi.provider.vkontakte.client import Client as VKClient
from person.models import Person, SocialPerson
#from api.v1.person_api import PersonResource

from util import BaseTest

import urllib

class DummyVkClient(VKClient):

    def fetch_user(self, *args, **kwargs):
        sp = self.fill_social_person({
            'uid' : '123123',
            'first_name' : 'test',
            'last_name' : 'test',
            'photo_medium' : 'http://img.yandex.net/i/www/logo.png',
            'sex' : 1,
        }, 'asdasd')
        return sp

    def fetch_friends(self,  *args, **kwargs):
        sp = self.fill_social_person({
            'uid' : '123124',
            'first_name' : 'test',
            'last_name' : 'test',
            'photo_medium' : 'http://img.yandex.net/i/www/logo.png',
            'sex' : 2,
            }, 'asdasd')
        return [sp]

@override_settings(POI_PROVIDER_CLIENTS={'vkontakte':'api.tests.DummyVkClient'})
class PersonTest(BaseTest):

    def setUp(self):
        super(PersonTest, self).setUp()

        self.person_url = reverse('api_person', args=('json',))
        self.person_get_url = reverse('api_person_get', kwargs={'content_type' : 'json', 'pk' : 1})
        self.person_login_url = reverse('api_person_login', args=('json',))
        self.person_logout_url = reverse('api_person_logout', args=('json',))
        self.person_feed_url = reverse('api_person_logged_feed', args=('json',))

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
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertTrue('email' in data)

    def test_simple_register(self):
        data = {
            'email' : 'test@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
        }
        response = self.perform_post(self.person_url, data)
        self.assertEquals(response.status_code, 200)
        self._check_user(response)

    def test_already_registred(self):
        # check duplicate registration
        response = self.perform_post(self.person_url, self.person_data)
        self.assertEquals(response.status_code, 200)
        self._check_user(response)

    def test_already_registred_vk(self):
        vk_data = {
            'access_token' : 'asdasd',
            'user_id' : '123123',
            'email' : 'test@asd.ru'
        }
        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 200)

        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 200)
        self._check_user(response)

    def test_register_existent_social_person(self):
        # register person with friends
        vk_data = {
            'access_token' : 'asdasd',
            'user_id' : '123123',
            'email' : 'test@asd.ru'
        }
        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 200)

        # try to register this friend
        vk_data = {
            'access_token' : 'asdasd',
            'user_id' : '123124',
            'email' : 'test1@asd.ru'
        }
        response = self.perform_post(self.person_url, data=vk_data)
        self.assertEquals(response.status_code, 200)


    def test_invalid_email(self):
        data = {
            'email' : 'invalid_email_here',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
            }
        response = self.perform_post(self.person_url, data)
        self.assertNotEquals(response.status_code, 200)


    def test_login_logout(self):
        # try not logined
        response = self.perform_get(self.person_get_url)
        self.assertEquals(response.status_code, 403)

        # do login
        login_data = {
            'username' : self.person_data['email'],
            'password' : self.person_data['password'],
        }
        self.perform_post(self.person_login_url, login_data)

        response = self.perform_get(self.person_get_url, person=self.person)
        self._check_user(response)

        # do logout
        response = self.perform_post(self.person_logout_url)

        # try not logined again
        response = self.perform_get(self.person_get_url)
        self.assertEquals(response.status_code, 403)

    def test_person_feed(self):
        login_data = {
            'username' : self.person_data['email'],
            'password' : self.person_data['password'],
            }
        response = self.perform_post(self.person_login_url, login_data)
        self.assertEqual(response.status_code, 200)

        response = self.perform_get(self.person_feed_url, person=self.person)
        self.assertEqual(response.status_code, 200)
