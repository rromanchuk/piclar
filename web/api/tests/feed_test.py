from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from django.core.files.base import ContentFile
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

        file = ContentFile('test')
        file.name = 'test'

        self.checkin = Checkin.objects.create_checkin(self.person, self.place, 'test', file)
        self.person_feed_url = reverse('api_person_logged_feed', args=('json',))




    def test_feed_get(self):
        response = self.perform_get(self.person_feed_url, person=self.person)
        self.assertEquals(response.status_code, 200)
        data = response.content
        self.feed_get_url = reverse('api_person_logged_feed', args=('json',))