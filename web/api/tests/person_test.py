import json

from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from person.social.vkontakte import Client as VKClient
from person.models import Person, SocialPerson, PersonSetting

from util import BaseTest

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

    def get_settings(self, *args, **kwargs):
        return []

@override_settings(SOCIAL_PROVIDER_CLIENTS={'vkontakte':'api.tests.DummyVkClient'})
class PersonTest(BaseTest):

    def setUp(self):
        super(PersonTest, self).setUp()


        self.person_data = {
            'email' : 'test1@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
            }
        self.person = self.register_person(self.person_data)

        self.person_data2 = self.person_data
        self.person_data2['email'] = 'test2@gmail.com'
        self.person2 = self.register_person(self.person_data2)

        self.person_url = reverse('api_person', args=('json',))
        self.person_get_url = reverse('api_person_get', kwargs={'content_type' : 'json', 'pk' : self.person.id})
        self.person_login_url = reverse('api_person_login', args=('json',))
        self.person_logout_url = reverse('api_person_logout', args=('json',))
        self.person_feed_url = reverse('api_person_logged_feed', args=('json',))

        self.person_following_url = reverse('api_person_following', kwargs={'content_type' : 'json', 'pk' : 'logged'})
        self.person_followers_url = reverse('api_person_followers', kwargs={'content_type' : 'json', 'pk' : 'logged'})


        self.person_follow_url = reverse('api_person_follow_unfollow', kwargs={'content_type' : 'json', 'action' : 'follow', 'pk' : self.person2.id})
        self.person_unfollow_url = reverse('api_person_follow_unfollow', kwargs={'content_type' : 'json', 'action' : 'unfollow', 'pk' : self.person2.id})

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

    def test_follow_unfollow(self):
        response = self.perform_get(self.person_following_url, person=self.person)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(json.loads(response.content), [])

        response = self.perform_post(self.person_follow_url, data={'test':'test'}, person=self.person)
        self.assertEqual(response.status_code, 200)

        response = self.perform_get(self.person_following_url, person=self.person)
        self.assertEqual(json.loads(response.content)[0]['id'], str(self.person2.id))

        response = self.perform_post(self.person_unfollow_url, data={'test':'test'}, person=self.person)
        self.assertEqual(response.status_code, 200)

        response = self.perform_get(self.person_following_url, person=self.person)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(json.loads(response.content), [])

    def test_update(self):
        update_url = reverse('api_person_update', args=('json',))
        response = self.perform_post(update_url, {
            'firstname' : 'test1',
            'lastname' : 'test2',
            'email' : 'emailnew@test.ru'
        }, person=self.person)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(json.loads(response.content)['email'], 'emailnew@test.ru')

        response = self.perform_post(update_url, {
            'firstname' : 'test1',
            'lastname' : '',
        }, person=self.person)
        self.assertEqual(response.status_code, 400)

    def test_settings(self):
        settings_url = reverse('api_person_logged_settings', args=('json',))
        response = self.perform_get(settings_url, person=self.person)
        self.assertEqual(response.status_code, 200)

        data = json.loads(response.content)

        for name in PersonSetting.SETTINGS_MAP.keys():
            self.assertTrue(data[name])

        response = self.perform_post(settings_url, data={ PersonSetting.SETTINGS_VK_SHARE : 0 }, person=self.person)
        self.assertEqual(response.status_code, 200)

        response = self.perform_get(settings_url, person=self.person)
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.content)
        self.assertFalse(data[PersonSetting.SETTINGS_VK_SHARE])
