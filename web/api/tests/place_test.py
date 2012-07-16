from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse

from util import BaseTest

class SearchTest(BaseTest):


    def test_search(self):
        url = reverse('api_search_poi',
            kwargs={
              'resource_name' : 'place',
              'api_name' : 'v1'
            }
        )
        response = self.perform_get(url)
        self.assertEquals(response.status_code, 400)
        url += '?lat=33.33&lng=33'
        response = self.client.get(url)
        self.assertEquals(response.status_code, 200)

