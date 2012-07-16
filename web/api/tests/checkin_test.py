from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
import StringIO

class CheckinTest(TestCase):

    def setUp(self):
        self.client = Client()
        pass

    def tearDown(self):
        pass

    def test_create(self):
        file = StringIO.StringIO('test')
        file.name = 'test'

        url = reverse('api_dispatch_list', kwargs={'api_name': 'v1', 'resource_name': 'checkin'})
        data = {
            'place_id' : 1,
            'comment' : 'test',
            'photo' : file
        }
        response = self.client.post(url, data, HTTP_ACCEPT='application/json')