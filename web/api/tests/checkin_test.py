from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
import StringIO

from poi.models import Place
from util import BaseTest

class CheckinTest(BaseTest):

    def setUp(self):
        super(CheckinTest, self).setUp()
        proto = {
            'position' : 'POINT(33 55)',
            'title' : 'test',
            'type': Place.TYPE_RESTAURANT,
        }
        self.place = Place(**proto)
        self.place.save()
        self.person = self.register_person()


    def tearDown(self):
        pass

    def test_create(self):
        self.login_person()
        file = StringIO.StringIO('test')
        file.name = 'test'

        url = reverse('api_dispatch_list', kwargs={'api_name': 'v1', 'resource_name': 'checkin'})
        data = {
            'place_id' : 1,
            'comment' : 'test',
            'photo' : file
        }
        response = self.client.post(url, data, HTTP_ACCEPT='application/json')
        print response.content
        self.assertEquals(response.status_code, 201)
