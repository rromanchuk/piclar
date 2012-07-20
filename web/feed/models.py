from xact import xact
from django.db import models
from person.models import Person
from ostrovok_common.pgarray import fields
from ostrovok_common.models import JSONField

from django.forms.models import model_to_dict

from logging import getLogger

log = getLogger('web.feed.models')

class FeedItemManager(models.Manager):

    @xact
    def create_checkin_post(self, checkin):
        receivers_ids = list(checkin.person.friends_ids)
        receivers_ids.append(checkin.person.id)

        proto = {
            'creator' : checkin.person,
            'data' : { 'checkin' : checkin.get_feed_proto() },
            'type' : FeedItem.ITEM_TYPE_CHECKIN,
            'shared' : receivers_ids
        }
        item = FeedItem(**proto)
        item.save()

        FeedPersonItem.objects.share_for_persons(recievers_ids, item)

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

    def get_data(self):
        # expand data for feed list
        # TODO: we need more complex prefetching logic here to avoid db query for every person
        data = self.data[self.type]
        if self.type == self.ITEM_TYPE_CHECKIN:
            try:
                data['person'] = Person.objects.get(id=data['person'])
            except Person.DoesNotExist:
                log.error('feed item[%s][%s] contain not existent person[%s]' % (
                    self.id, self.type, data['person']
                ))
                data['person'] = {'id' : data['person']}

        return { self.type : data }

    @xact
    def like(self, person):
        liked = set(self.liked)
        shared = set(self.shared)

        recievers_ids = person.friends_ids
        recievers_ids.append(person.id)

        FeedPersonItem.objects.share_for_persons(recievers_ids, self)

        shared.update(recievers_ids)
        liked.update(recievers_ids)

        self.liked = list(liked)
        self.shared = list(shared)
        self.save()

    @xact
    def unlike(self, person):
        try:
            pos = self.liked.pos(person.id)
            del self.liked[pos]
        except ValueError:
            pass
        self.save()

    @xact
    def comment(self, person, comment):
        recievers_ids = person.friends_ids
        recievers_ids.append(person.id)

        FeedPersonItem.objects.share_for_persons(recievers_ids, self)

        shared = set(self.shared)
        shared.update(recievers_ids)
        self.shared = list(shared)

        comment = FeedItemComment({
            'item' : self,
            'comment' : comment,
        })

        comment.save()
        self.save()


class FeedItemComment(models.Model):
    item = models.ForeignKey(FeedItem)
    create_date = models.DateTimeField(auto_now_add=True)
    comment = models.TextField()

class FeedPersonItemManager(models.Manager):

    def share_for_persons(self, person_ids, item):
        for receiver_id in person_ids:
            proto  = {
                'creator' : item.creator,
                'receiver_id' : receiver_id,
                'item' : item,
            }
            person_item = FeedPersonItem(**proto)
            person_item.save()


class FeedPersonItem(models.Model):
    item = models.ForeignKey(FeedItem)
    is_hidden = models.BooleanField(default=False)
    creator = models.ForeignKey(Person, related_name='+')
    receiver = models.ForeignKey(Person, related_name='+')

    objects = FeedPersonItemManager()