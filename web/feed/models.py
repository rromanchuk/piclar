#coding=utf-8
from xact import xact
from django.db import models
from django.core.urlresolvers import reverse
from person.models import Person, PersonSetting
from ostrovok_common.pgarray import fields
from ostrovok_common.models import JSONField

from django.forms.models import model_to_dict

from poi.models import Place
from notification.models import Notification

from logging import getLogger
from api.v2.serializers import wrap_serialization

log = getLogger('web.feed.models')

ITEM_ON_PAGE = 30

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


    def _prefetch_data(self, qs, model_cls, field, assign):
        ids = set()
        for pitem in qs:
            item_type = pitem.item.type
            ids.add(pitem.item.data[item_type][field])

        prefetched = dict([(item.id, item) for item in model_cls.objects.filter(id__in=ids)])
        result = []
        for pitem in qs:
            item_type = pitem.item.type
            field_value = pitem.item.data[item_type][field]
            if field_value not in prefetched:
                log.info('item %s droped on broken prefech for %s=%s' % (pitem.id, field, field_value))
                continue
            pitem.item.data[item_type][assign] = prefetched[field_value]
            del pitem.item.data[item_type][field]
            result.append(pitem)
        return result


    def feed_for_person(self, person, from_uid=None, limit=ITEM_ON_PAGE):
        qs = FeedPersonItem.objects.\
            select_related('item', 'item__creator').\
            prefetch_related('item__feeditemcomment_set', 'item__feeditemcomment_set__creator').\
            filter(Person.only_active('creator'), receiver=person, is_hidden=False)

        if from_uid:
            from datetime import datetime
            from_date = datetime.strptime(from_uid, '%Y%m%d%H%M%S%f')
            qs = qs.filter(create_date__lt=from_date)

        # if this become slow - we can use method, described here:
        # http://stackoverflow.com/questions/6618366/improving-offset-performance-in-postgresql
        qs = qs.order_by('-create_date')[:limit]

        qs = self._prefetch_data(qs, Person, 'person_id', 'person')
        qs = self._prefetch_data(qs, Place, 'place_id', 'place')

        friends = set(person.following)
        friends.add(person.id)
        friends_map = dict([(item.id, item) for item in  Person.objects.get_following(person)])
        friends_map[person.id] = person
        for item in qs:
            item.uniqid = item.create_date.strftime('%Y%m%d%H%M%S%f')
            if item.item.creator.id in friends and item.item.creator.id != person.id:
                item.item.show_reason = {
                    'reason' : 'created_by_friend',
                    'who' : item.item.creator,
                }
                continue

            try:
                liked_friends = set(item.item.liked).intersection(friends)
                if liked_friends:
                    item.item.show_reason = {
                        'reason' : 'liked_by_friend',
                        'who'    : friends_map[liked_friends.pop()],
                    }
                    continue
                commented_friends = set(item.item.commented).intersection(friends)
                if commented_friends:
                    item.item.show_reason = {
                        'reason' : 'commented_by_friend',
                        'who'    : friends_map[commented_friends.pop()],
                        }
                    continue
                item.item.show_reason = {}
            except KeyError:
                item.item.show_reason = {}
                # skip if user from shared or commented isn't exists in friends list (maybe deleted or have non active status)
                pass

        return qs

    def feed_for_person_owner(self, person):
        qs = FeedPersonItem.objects.\
               select_related('item', 'item__creator').\
               prefetch_related('item__feeditemcomment_set', 'item__feeditemcomment_set__creator').\
               filter(receiver=person, creator=person, is_hidden=False).order_by('-create_date')[:ITEM_ON_PAGE]

        qs = self._prefetch_data(qs, Person, 'person_id', 'person')
        qs = self._prefetch_data(qs, Place, 'place_id', 'place')
        return qs

    def feeditem_for_person(self, feeditem, person, skip_creator_check=False):
        return self.feeditem_for_person_by_id(feeditem.id, person.id, skip_creator_check)

    def feeditem_for_person_by_id(self, feed_pk, person_id, skip_creator_check=False):
        filter = {
            'item_id' : feed_pk,
            'receiver_id' : person_id
        }
        if not skip_creator_check:
            pitem = FeedPersonItem.objects.get(Person.only_active('creator'), **filter)
        else:
            pitem = FeedPersonItem.objects.get(**filter)
        pitem.uniqid = pitem.create_date.strftime('%Y%m%d%H%M%S%f')
        return pitem


    def feeditem_by_id_hack(self, feed_pk):
        return FeedItem.objects.get(id=feed_pk)

    def add_new_items_from_friend(self, person, friend):
        # FUCKING SLOW
        feed_items = self.get_query_set().filter(creator=friend, type=FeedItem.ITEM_TYPE_CHECKIN).order_by('-create_date')[:10]
        for item in feed_items:
            shared = set(item.shared)
            shared.add(person.id)
            item.shared = list(shared)
            item.save()
            FeedPersonItem.objects.share_for_persons([person.id], item, force_sync_create_date=True)

    @xact
    def hide_friend_items(self, person, friend):
        # FUCKING SLOW
        for item in self.get_query_set().filter(creator=friend).extra(where=['%d = ANY(shared)' % person.id]):
            del(item.shared[item.shared.index(person.id)])
            item.save()

        FeedPersonItem.objects.filter(receiver=person, creator=friend).update(is_hidden=True)



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
    commented = fields.IntArrayField()
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

    @property
    def liked_person(self):
        if hasattr(self, '_liked_person') and self._liked_person:
            return self._liked_person
        else:
            return Person.objects.filter(id__in = self.liked)

    def get_data(self):
        import dateutil.parser
        # expand data for feed list
        # TODO: we need more complex prefetching logic here to avoid db query for every person
        data = self.data[self.type].copy()
        if self.type == self.ITEM_TYPE_CHECKIN:
            if not 'place' in data:
                data['place'] = Place.objects.get(id=data['place_id'])
                del data['place_id']

            if not 'person' in data:
                try:
                    data['person'] = Person.objects.get(id=data['person_id'])
                except Person.DoesNotExist:
                    log.error('feed item[%s][%s] contain not existent person[%s]' % (
                        self.id, self.type, data['person_id']
                        ))
                    data['person'] = {'id' : data['person_id']}
                del data['person_id']

            data['create_date'] = dateutil.parser.parse(data['create_date'])
            from api.v2.utils import date_in_words
            data['create_date_words'] =date_in_words(data['create_date'])
            data['feed_item_id'] = self.id

        return data

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

        if self.creator.get_settings()[PersonSetting.SETTINGS_PUSH_LIKES]:
            from notification import urbanairship
            urbanairship.send_notification(self.creator.id, u'%s понравилась ваша фотография в %s' % (person.full_name, self.get_data()['place'].title), extra={'type' : 'notification_like'})
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

        if person.id not in self.commented:
            self.commented.append(person.id)

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
    def delete_comment(self, creator, comment_id):
        comment = FeedItemComment.objects.get(item=self, creator=creator, id=comment_id)
        comment.delete()

    def get_comments(self):
        comments = self.feeditemcomment_set.all()
        return sorted(comments, key=lambda x:x.create_date)
        #return self.feeditemcomment_set.select_related('creator').order_by('create_date').all()

    def get_last_comments(self):
        return self.feeditemcomment_set.select_related('creator').order_by('create_date').all()[:2]

    def get_comments_count(self):
        return self.feeditemcomment_set.count()


    def serialize(self, request):
        from api.v2.serializers import iter_response
        def _serializer(obj):
            if hasattr(obj, 'serialize'):
                return obj.serialize()
            return obj
        person = request.user.get_profile()
        proto =  {
            'creator' : self.creator.serialize(),
            'liked' : iter_response(self.liked_person, _serializer),
            'create_date': self.create_date,
            'count_likes' : len(self.liked),
            'me_liked' : person.id in self.liked,
            'show_in_my_feed' : person.id in self.shared,
            'type' : self.type,
             self.type : iter_response(self.get_data(), _serializer),
            'id' : self.id,
            'comments'  : iter_response(self.get_comments(), _serializer)

        }
        return wrap_serialization(proto, self)


class FeedItemComment(models.Model):
    item = models.ForeignKey(FeedItem)
    create_date = models.DateTimeField(auto_now_add=True)
    creator = models.ForeignKey(Person)
    comment = models.TextField()

    def serialize(self):
        proto = {
            'id' : self.id,
            'comment' : self.comment.replace('\n',' ').replace('\r', ' '),
            'creator' : self.creator.serialize(),
            'create_date': self.create_date,
        }
        return wrap_serialization(proto, self)

class FeedPersonItemManager(models.Manager):

    @xact
    def share_for_persons(self, person_ids, item, force_sync_create_date=False):
        already_exists = dict([(fitem.receiver.id, fitem) for fitem in FeedPersonItem.objects.filter(item=item)])
        if set(item.shared).difference(set(person_ids)):
            new_shared = set(item.shared)
            new_shared.update(person_ids)
            item.shared = list(new_shared)
            item.save()

        for receiver_id in person_ids:
            if receiver_id in already_exists:
                already_exists[receiver_id].is_hidden = False
                already_exists[receiver_id].save()
                continue

            try:
                Person.objects.get(id=receiver_id)
            except Person.DoesNotExist:
                log.error('trying share feeditem to does not exists person person=[%s] feeditem=[%s]' % (receiver_id, item.id))
                continue

            proto  = {
                'creator' : item.creator,
                'receiver_id' : receiver_id,
                'item' : item,
            }
            person_item = FeedPersonItem(**proto)
            person_item.save()

            if force_sync_create_date:
                person_item.create_date = item.create_date
                person_item.save()

class FeedPersonItem(models.Model):
    item = models.ForeignKey(FeedItem)
    is_hidden = models.BooleanField(default=False)
    creator = models.ForeignKey(Person, related_name='+')
    receiver = models.ForeignKey(Person, related_name='+')
    create_date = models.DateTimeField(auto_now_add=True)

    objects = FeedPersonItemManager()