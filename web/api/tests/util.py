from django.test import TestCase, TransactionTestCase
from django.test.client import Client, RequestFactory
from django.core.urlresolvers import reverse
from django.core.files.base import ContentFile

from person.models import Person, SocialPerson
from api.v1.utils import create_signature

import urllib
import PIL
import StringIO


class BaseTest(TransactionTestCase):
    def setUp(self):
        self.client = Client()

    def  _prep_param(self, url, data=None, person=None):
        params = {
            'content_type': 'application/x-www-form-urlencoded',
            'HTTP_ACCEPT': 'application/json',
            }

        if data:
            params['data'] = urllib.urlencode(data)

        return params

    def perform_post(self, url, data=None, person=None):

        if person:
            url = url + '?auth=' + create_signature(person.id, person.token, 'POST', data)
        params = self._prep_param(url, data, person)
        return self.client.post(url, **params)

    def perform_get(self, url, data=None, person=None):
        if not data:
            data = {}
        if person:
            data['auth'] = create_signature(person.id, person.token, 'GET', data)

        return self.client.get(url, data=data)

    def register_person(self, person_data=None, active=True):
        if not person_data:
            person_data = {
                'email' : 'test1@gmail.com',
                'firstname': 'test',
                'lastname' : 'test',
                'password' : 'test',
                }
        person = Person.objects.register_simple(**person_data)
        if active:
            person.status = Person.PERSON_STATUS_ACTIVE
            person.save()
        return person

    def login_person(self):
        url = reverse('v1:api_person_login', args=('json',))
        login_data = {
            'username' : 'test1@gmail.com',
            'password' :'test',
            }
        return self.perform_post(url, login_data)

    def get_photo_file(self):
        img = PIL.Image.new('RGBA', (100,100))
        f = StringIO.StringIO()
        img.save(f, format='JPEG')
        file = ContentFile(f.getvalue())
        f.close()

        file.name = 'test.jpeg'

        return file
