from xact import xact
import dateutil
from django.db import models
from django.core.urlresolvers import reverse
from person.models import Person
from ostrovok_common.pgarray import fields
from ostrovok_common.models import JSONField

from django.forms.models import model_to_dict

from poi.models import Place
from notification.models import Notification

from logging import getLogger

log = getLogger('web.feed.models')

class FeedItemManager(models.Manager):

    @xact
    def create_checkin_post(self, checkin):
        receivers_ids = list(checkin.person.followers)
        receivers_ids.append(checkin.person.id)

        proto = {
            'creator' : checkin.person,
            'data' : { 'checkin' : checkin.get_feed_proto() },
            'type' : FeedItem.ITEM_TYPE_CHECKIN,
            'shared' : receivers_ids
        }
        item = FeedItem(**proto)
        item.save()
        FeedPersonItem.objects.share_for_persons(receivers_ids, item)
        return item

    @xact
    def create_friends_post(self, creator, friend):
        pass

    def feed_for_person(self, person):
        return FeedPersonItem.objects.select_related().filter(receiver=person).order_by('create_date')

    def feeditem_for_person(self, feeditem, person):
        return self.feeditem_for_person_by_id(feeditem.id, person.id)

    def feeditem_for_person_by_id(self, feed_pk, person_id):
        return FeedPersonItem.objects.get(item_id=feed_pk, receiver_id=person_id)

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

    @property
    def url(self):
        return reverse('feed-item', kwargs={'pk' : self.id})

    @property
    def count_likes(self):
        return len(self.liked)

    def get_data(self):
        # expand data for feed list
        # TODO: we need more complex prefetching logic here to avoid db query for every person
        data = self.data[self.type].copy()
        if self.type == self.ITEM_TYPE_CHECKIN:
            data['place'] = Place.objects.get(id=data['place_id'])
            del datap['place_id']
            data['create_date'] = dateutil.parser.parse(data['create_date'])
            from api.v2.utils import date_in_words
            data['create_date_words'] =date_in_words(data['create_date'])
            try:
                data['person'] = Person.objects.get(id=data['person_id'])
            except Person.DoesNotExist:
                log.error('feed item[%s][%s] contain not existent person[%s]' % (
                    self.id, self.type, data['person_id']
                ))
                data['person'] = {'id' : data['person_id']}
            del data['place_id']

        return data


    def get_comments(self):
        return self.feeditemcomment_set.select_related('creator').order_by('create_date').all()


    def liked_by_person(self, person):
        return person.id in self.liked

    @xact
    def like(self, person):
        if person.id in self.liked:
            return self

        liked = set(self.liked)
        shared = set(self.shared)

        recievers_ids = person.followers
        recievers_ids.append(person.id)

        person_to_share = list(set(recievers_ids).difference(shared))
        FeedPersonItem.objects.share_for_persons(person_to_share, self)

        shared.update(recievers_ids)
        liked.add(person.id)

        self.liked = list(liked)
        self.shared = list(shared)
        self.save()
        return self


    @xact
    def unlike(self, person):
        try:
            pos = self.liked.index(person.id)
            del self.liked[pos]
        except ValueError:
            pass
        self.save()

    @xact
    def create_comment(self, person, comment):
        recievers_ids = person.followers
        recievers_ids.append(person.id)

        shared = set(self.shared)
        person_to_share = list(set(recievers_ids).difference(shared))

        FeedPersonItem.objects.share_for_persons(person_to_share, self)

        shared.update(recievers_ids)
        self.shared = list(shared)

        comment = FeedItemComment(**{
            'creator' : person,
            'item' : self,
            'comment' : comment,
        })

        comment.save()
        self.save()

        Notification.objects.create_comment_notification(comment)

        return comment

    @xact
    def delete_comment(self, comment_id):
        comment = FeedItemComment.objects.get(item=self, id=comment_id)
        comment.delete()

    def get_comments(self):
        return self.feeditemcomment_set.all().order_by('create_date').all()


class FeedItemComment(models.Model):
    item = models.ForeignKey(FeedItem)
    create_date = models.DateTimeField(auto_now_add=True)
    creator = models.ForeignKey(Person)
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
    create_date = models.DateTimeField(auto_now_add=True)

    objects = FeedPersonItemManager()