from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from poi.models import Place, Checkin
from api.v2.utils import create_signature

from util import BaseTest

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
        self.checkin = Checkin.objects.create_checkin
        self.person = self.register_person()

    def test_feed_get(self):
        pass