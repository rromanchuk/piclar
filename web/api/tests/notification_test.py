import json

from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from person.social.vkontakte import Client as VKClient
from person.models import Person, SocialPerson



from util import BaseTest

class NotificationTest(BaseTest):

    def setUp(self):
        super(NotificationTest, self).setUp()
        self.person_data = {
            'email' : 'test1@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
            }
        self.person = self.register_person(self.person_data)

        self.person_data2 = {
            'email' : 'test2@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
        }
        self.person2 = self.register_person(self.person_data2)
        self.list_url = reverse('api_notification_list', args=('json',))


    def test_no_notification(self):
        result = self.perform_get(self.list_url, person=self.person)
        self.assertEquals(result.status_code, 200)
        self.assertEquals(json.loads(result.content), [])

    def test_has_notification_read(self):
        self.person2.follow(self.person)
        result = self.perform_get(self.list_url, person=self.person)
        self.assertEquals(result.status_code, 200)
        content = json.loads(result.content)
        self.assertFalse(content[0]['is_read'])

        markasread_url = reverse('api_notification_markasread', args=('json',))
        result = self.perform_post(markasread_url, data={'test':'test'}, person=self.person)
        self.assertEquals(result.status_code, 200)

        result = self.perform_get(self.list_url, person=self.person)
        self.assertEquals(result.status_code, 200)

        content = json.loads(result.content)
        self.assertTrue(content[0]['is_read'])





