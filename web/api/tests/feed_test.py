from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse

from poi.models import Place, Checkin

from util import BaseTest

import json

class FeedTest(BaseTest):
    def setUp(self):
        super(FeedTest, self).setUp()
        proto = {
            'position' : 'POINT(33 55)',
            'title' : 'test',
            'type': Place.TYPE_RESTAURANT,
            }
        self.place = Place(**proto)
        self.place.save()

        self.person = self.register_person()
        self.person2 = self.register_person(person_data = {
            'email' : 'test2@gmail.com',
            'firstname': 'test2',
            'lastname' : 'test2',
            'password' : 'test2',
            })
        self.person2.follow(self.person)

        file = self.get_photo_file()
        self.checkin = Checkin.objects.create_checkin(self.person, ['vkontakte'], self.place, 'test', 5, file)
        self.person_feed_url = reverse('v1:api_person_logged_feed', args=('json',))

    def get_feed(self, person):
        response = self.perform_get(self.person_feed_url, person=person)
        self.assertEquals(response.status_code, 200)
        data = json.loads(response.content)
        return data

    def test_feed_get(self):
        data = self.get_feed(self.person)
        feed_get_url = reverse('v1:api_feed_get', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_get(feed_get_url, person=self.person)
        self.assertEquals(response.status_code, 200)

    def test_feed_comment(self):
        data = self.get_feed(self.person)
        feed_get_url = reverse('v1:api_feed_comment', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_post(feed_get_url, data={'comment' : 'test'}, person=self.person)

        comment_id = json.loads(response.content)['id']
        self.assertEquals(response.status_code, 200)
        data = self.get_feed(self.person2)
        self.assertTrue(data[0]['creator']['is_followed'])
        self.assertEquals(len(data), 1)

        feed_comment_delete_url = reverse('v1:api_feed_comment_delete', kwargs={'content_type': 'json', 'pk' : data[0]['id'], 'comment_id': comment_id})
        response = self.perform_post(feed_comment_delete_url, data={'comment' : 'test'}, person=self.person)
        self.assertEquals(response.status_code, 200)

    def test_feed_like(self):
        data = self.get_feed(self.person)
        feed_like_url = reverse('v1:api_feed_like', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_post(feed_like_url, data={'test' : 'test'}, person=self.person)
        self.assertEquals(response.status_code, 200)
        self.assertEquals(json.loads(response.content)['id'], data[0]['id'])
        self.assertTrue(json.loads(response.content)['me_liked'])

        feed_unlike_url = reverse('v1:api_feed_unlike', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_post(feed_unlike_url, data={'test' : 'test'}, person=self.person)
        self.assertEquals(response.status_code, 200)
        self.assertFalse(json.loads(response.content)['me_liked'])


    def test_feed_item_delete(self):


        data = self.get_feed(self.person)

        feed_get_url = reverse('v1:api_feed_comment', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_post(feed_get_url, data={'comment' : 'test'}, person=self.person2)

        notifications_url = reverse('v1:api_notification_list', args=('json',))
        notifiations_resp = self.perform_get(notifications_url, person=self.person)
        notifiations_resp = json.loads(notifiations_resp.content)

        feed_delete_url = reverse('v1:api_feed_delete', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_post(feed_delete_url, data={'test' : 'test'}, person=self.person)

        feed_get_url = reverse('v1:api_feed_get', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_get(feed_get_url, data={'test' : 'test'}, person=self.person)
        self.assertEquals(response.status_code, 404)

        new_data = self.get_feed(self.person)
        self.assertEquals(len(data) - 1, len(new_data))


        notifications_url = reverse('v1:api_notification_list', args=('json',))
        new_notifiations_resp = self.perform_get(notifications_url, person=self.person)
        new_notifiations_resp = json.loads(new_notifiations_resp.content)
        self.assertEquals(len(notifiations_resp) - 1, len(new_notifiations_resp))

