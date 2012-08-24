# coding=utf-8
from django.test import TestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
import json
from poi.models import Place
from util import BaseTest
from api.v2.utils import create_signature

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
        person_data = json.loads(self.login_person().content)

        url = reverse('api_checkin_get', args=('json',))
        data = {
            'place_id' : 1,
            'review' : 'Классыный русский текст',
            'rate' : 5,
        }
        data['auth'] = create_signature(self.person.id, person_data['token'], 'POST', data)
        data['photo'] = self.get_photo_file()
        response = self.client.post(url, data, HTTP_ACCEPT='application/json')
        self.assertEquals(response.status_code, 200)
