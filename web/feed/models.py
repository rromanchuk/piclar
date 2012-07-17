from xact import xact
from django.db import models
from person.models import Person
from ostrovok_common.pgarray import fields
from ostrovok_common.models import JSONField


def get_model_values(model):
    res = {}
    for name in model._meta.get_all_field_names():
        res[name] = getattr(model, name)
    return res

class FeedItemManager(models.Manager):

    @xact
    def create_checkin(self, checkin):
        friends = checkin.person.friends
        friends_ids = [ friend.id for friend in friends ]
        friends_ids.append(checkin.person.id)
        proto = {
            'creator' : checkin.person,
            'data' : {
                'checkin' : get_model_values(checkin)
            },
            'type' : FeedItem.ITEM_TYPE_CHECKIN,
            'shared' : friends_ids
        }
        item = FeedItem(**proto)
        item.save()
        
        for friend in list(friends).append(checkin.person):
            proto  = {
                'creator' : checkin.person,
                'receiver' : friend,
                'item' : item
            }
            person_item = FeedPersonItem(**proto)
            person_item.save()


class FeedItem(models.Models):
    ITEM_TYPE_CHECKIN = 'checkin'
    ITEM_TYPE_ADD_FRIEND = 'friend'
    ITEM_TYPE_CHOICES = (
        (ITEM_TYPE_CHECKIN, ITEM_TYPE_CHECKIN),
        (ITEM_TYPE_ADD_FRIEND, ITEM_TYPE_ADD_FRIEND),
    )

    creator = models.OneToOneField(Person)
    shared = fields.IntArrayField()
    liked = fields.IntArrayField()

    data = JSONField()

    type = model.CharField(max_lenght=255, choices=ITEM_TYPE_CHOICES)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    objects = FeedItemManager()

class FeedItemComment(models.Models):
    item = models.ForeignKey(FeedItem)
    create_date = models.DateTimeField(auto_now_add=True)
    comment = models.TextField()


class FeedPersonItem(models.Models):
    item = models.ForeignKey(FeedItem)
    is_hidden = models.BooleanField(default=False)
    creator = models.OneToOneField(Person)
    receiver = models.OneToOneField(Person)
