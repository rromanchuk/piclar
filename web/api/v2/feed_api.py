from utils import  filter_fields, AuthTokenMixin
from base import *
from feed.models import FeedItem, FeedPersonItem

class FeedApiMethod(ApiMethod):
    def refine(self, obj):
        if isinstance(obj, FeedPersonItem):
            return {
                'creator' : pitem.creator,
                'type' : pitem.item.type,
                'data' : pitem.item.get_data(),
                }
        return obj

class FeedGet(ApiMethod, AuthTokenMixin):
    def get(self, pk):
        feed_person = FeedPersonItem.objects.get(item_id=pk, receiver_id=self.request.user.get_profile().id)
        return feed_person

class FeedComment(ApiMethod, AuthTokenMixin):
    def post(self, pk):
        pass


class FeedLike(ApiMethod, AuthTokenMixin):
    def post(self, pk):
        pass