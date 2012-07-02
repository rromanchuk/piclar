"""
This file demonstrates writing tests using the unittest module. These will pass
when you run "manage.py test".

Replace this with more appropriate tests for your application.
"""

from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse

class SimpleTest(TestCase):

    def setUp(self):
        self.client = Client()
        self.person_url = reverse('api_dispatch_list',
            kwargs={
                'resource_name' : 'person',
               'api_name' : 'v1'
            }
        )
        self.person_url += '?format=json'

    def tearDown(self):
        pass

    def test_simple_register(self):
        print self.person_url
        data = {
            'login' : 'test',
            'password' : 'test',
        }

        response = self.client.post(self.person_url, data=data)
        print response