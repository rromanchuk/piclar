from django.test import TestCase
from django.test.utils import override_settings
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
import json
from util import BaseTest

class PlaceTest(BaseTest):
    def test_search(self):
        url = reverse('api_place_search', args=('json',))
        response = self.perform_get(url)
        self.assertEquals(response.status_code, 400)
        url += '?lat=33.33&lng=33'
        response = self.perform_get(url)
        self.assertEquals(response.status_code, 200)

    def test_create(self):
        url = reverse('api_place_create', args=('json',))
        person = self.register_person({
            'email' : 'test1@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
        })
        data = {
            'title' : 'Test place',
            'lat': 40,
            'lng': 40,
            'type' : 1,
            'address' : 'test',
            'phone' : '322443434',
        }
        response = self.perform_post(url, data, person=person)
        self.assertEquals(response.status_code, 200)

        url = reverse('api_place_search', args=('json',)) + '?lat=40&lng=40'
        response = self.perform_get(url)
        self.assertEquals(response.status_code, 200)
        self.assertEquals(json.loads(response.content)[0]['title'], data['title'])

