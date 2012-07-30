from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from django.core.files.base import ContentFile
from poi.models import Place, Checkin

from util import BaseTest

import json
import PIL
import StringIO

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
        self.person.add_friend(self.person2)
        img = PIL.Image.new('RGBA', (100,100))
        f = StringIO.StringIO()
        img.save(f, format='JPEG')
        file = ContentFile(f.getvalue())
        f.close()

        file.name = 'test.jpeg'

        self.checkin = Checkin.objects.create_checkin(self.person, self.place, 'test', file)
        self.person_feed_url = reverse('api_person_logged_feed', args=('json',))

    def get_feed(self, person):
        response = self.perform_get(self.person_feed_url, person=person)
        self.assertEquals(response.status_code, 200)
        data = json.loads(response.content)
        return data

    def test_feed_get(self):
        data = self.get_feed(self.person)
        feed_get_url = reverse('api_feed_get', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_get(feed_get_url, person=self.person)
        self.assertEquals(response.status_code, 200)

    def test_feed_comment(self):
        data = self.get_feed(self.person)
        feed_get_url = reverse('api_feed_comment', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_post(feed_get_url, data={'comment' : 'test'}, person=self.person)

        self.assertEquals(response.status_code, 200)
        data = self.get_feed(self.person2)
        self.assertEquals(len(data), 1)

    def test_feed_like(self):
        data = self.get_feed(self.person)
        feed_like_url = reverse('api_feed_like', kwargs={'content_type': 'json', 'pk' : data[0]['id']})
        response = self.perform_post(feed_like_url, person=self.person)
        print response.content
        self.assertEquals(response.status_code, 200)
        self.assertEquals(json.loads(response.content)['id'], data[0]['id'])

