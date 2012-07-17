from xact import xact
from django.db import models
from person.models import Person
from ostrovok_common.pgarray import fields
from ostrovok_common.models import JSONField

from django.forms.models import model_to_dict

class FeedItemManager(models.Manager):

    @xact
    def create_checkin_post(self, checkin):
        receivers = list(checkin.person.friends)
        receivers.append(checkin.person)
        receivers_ids = [ receiver.id for receiver in receivers ]

        proto = {
            'creator' : checkin.person,
            'data' : { 'checkin' : checkin.get_feed_proto() },
            'type' : FeedItem.ITEM_TYPE_CHECKIN,
            'shared' : receivers_ids
        }
        item = FeedItem(**proto)
        item.save()

        for receiver in receivers:
            proto  = {
                'creator' : checkin.person,
                'receiver' : receiver,
                'item' : item
            }
            person_item = FeedPersonItem(**proto)
            person_item.save()

    @xact
    def create_friends_post(self, creator, friend):
        pass

    def feed_for_person(self, person):
        return FeedPersonItem.objects.select_related().filter(receiver=person)


class FeedItem(models.Model):
    ITEM_TYPE_CHECKIN = 'checkin'
    ITEM_TYPE_ADD_FRIEND = 'friend'
    ITEM_TYPE_CHOICES = (
        (ITEM_TYPE_CHECKIN, ITEM_TYPE_CHECKIN),
        (ITEM_TYPE_ADD_FRIEND, ITEM_TYPE_ADD_FRIEND),
    )

    creator = models.ForeignKey(Person)
    shared = fields.IntArrayField()
    liked = fields.IntArrayField()

    data = JSONField()

    type = models.CharField(max_length=255, choices=ITEM_TYPE_CHOICES)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    objects = FeedItemManager()

class FeedItemComment(models.Model):
    item = models.ForeignKey(FeedItem)
    create_date = models.DateTimeField(auto_now_add=True)
    comment = models.TextField()


class FeedPersonItem(models.Model):
    item = models.ForeignKey(FeedItem)
    is_hidden = models.BooleanField(default=False)
    creator = models.ForeignKey(Person, related_name='+')
    receiver = models.ForeignKey(Person, related_name='+')
