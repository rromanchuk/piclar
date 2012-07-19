from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse

from util import BaseTest

class PlaceTest(BaseTest):
    def test_search(self):
        url = reverse('api_place_search', args=('json',))
        response = self.perform_get(url)
        self.assertEquals(response.status_code, 400)
        url += '?lat=33.33&lng=33'
        response = self.perform_get(url)
        self.assertEquals(response.status_code, 200)

