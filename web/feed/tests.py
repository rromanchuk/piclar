# coding=utf-8
from django.test import TestCase
from django.core.files.base import ContentFile

from feed.models import FeedItem
from poi.models import Place, Checkin
from person.models import Person


class FeedTest(TestCase):
    def get_photo_file(self):
        import PIL
        import StringIO
        img = PIL.Image.new('RGBA', (100,100))
        f = StringIO.StringIO()
        img.save(f, format='JPEG')
        file = ContentFile(f.getvalue())
        f.close()

        file.name = 'test.jpeg'

        return file

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

        self.file = self.get_photo_file()
        self.checkin =  Checkin.objects.create_checkin(
            self.person,
            self.place,
            'test',
            5,
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
        friend.follow(self.person)

        new_checkin =  Checkin.objects.create_checkin(
            self.person,
            self.place,
            'test',
            3,
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
        self.assertTrue(friend.id in feed_item.item.shared)
        self.assertTrue(self.person.id in feed_item.item.shared)






