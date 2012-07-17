# coding=utf-8
from django.test import TestCase
from django.core.files.base import ContentFile

from feed.models import FeedItem
from poi.models import Place, Checkin
from person.models import Person


class FeedTest(TestCase):
    def setUp(self):
        person_data = {
            'email' : 'test1@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
            }
        self.person = Person.objects.register_simple(**person_data)


        place_proto = {
            'title' : 'test',
            'description' : 'test',
            'position' : 'POINT (33 55)',
            'address' : 'Moscow'
        }
        self.place = Place(**place_proto)
        self.place.save()

        self.file = myfile = ContentFile("hello world")
        self.file.name = 'test'
        self.checkin =  Checkin.objects.create_checkin(
            self.person,
            self.place,
            'test',
            self.file
        )


    def test_create_checkin(self):
        feed = FeedItem.objects.feed_for_person(self.person)
        self.assertEquals(feed.count(), 1)
        self.assertEquals(feed[0].item.data['checkin']['id'], self.checkin.id)
        self.assertEquals(feed[0].item.shared[0], self.person.id)

    def test_friend(self):
        person_data = {
            'email' : 'test2@gmail.com',
            'firstname': 'test',
            'lastname' : 'test',
            'password' : 'test',
            }
        friend = Person.objects.register_simple(**person_data)
        self.person.add_friend(friend)
        new_checkin =  Checkin.objects.create_checkin(
            self.person,
            self.place,
            'test',
            self.file
        )
        my_feed = FeedItem.objects.feed_for_person(self.person)
        friend_feed = FeedItem.objects.feed_for_person(friend)
        self.assertEquals(my_feed.count(), 2)
        self.assertEquals(friend_feed.count(), 1)

        feed_item = friend_feed[0]
        self.assertEquals(feed_item.creator, self.person)
        self.assertEquals(feed_item.receiver, friend)
        self.assertEquals(feed_item.item.data['checkin']['id'], new_checkin.id)





