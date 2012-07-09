from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse

class SearchTest(TestCase):

    def setUp(self):
        self.client = Client()
        pass

    def tearDown(self):
        pass

    def test_search(self):
        url = reverse('api_search_poi',
            kwargs={
              'resource_name' : 'place',
              'api_name' : 'v1'
            }
        )
        self.assertEquals(self.client.get(url).status_code, 400)
        url += '?lat=33.33&lng=33'
        response = self.client.get(url)
        print response.content
        self.assertEquals(response.status_code, 200)

