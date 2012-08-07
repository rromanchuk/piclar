"""
This file demonstrates writing tests using the unittest module. These will pass
when you run "manage.py test".

Replace this with more appropriate tests for your application.
"""

from django.test import TestCase
from notification.models import Notification
from person.models import Person

class NotificationTest(TestCase):
    def setUp(self):
        person_data = {
            'email' : 'test1@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
            }
        self.person1 = Person.objects.register_simple(**person_data)

        person_data['email'] = 'test2@gmail.com'
        self.person2 = Person.objects.register_simple(**person_data)

    def test_empty(self):
        notifications = Notification.objects.get_person_notifications(self.person1)
        self.assertEquals(notifications.count(), 0)


    def test_follow(self):
        self.person1.follow(self.person2)
        notifications = Notification.objects.get_person_notifications(self.person2)
        self.assertEquals(notifications.count(), 1)


    def test_comment(self):
        pass
