from utils import  filter_fields, AuthTokenMixin, doesnotexist_to_404
from base import *
from person.models import Person
from poi.models import Place
from feed.models import FeedItem, FeedPersonItem, FeedItemComment

from person_api import person_to_dict
from place_api import place_to_dict
from serializers import iter_response


class FeedApiMethod(ApiMethod):
    def refine(self, obj):
        if isinstance(obj, FeedItemComment):
            return {
                'id' : obj.id,
                'comment' : obj.comment,
                'creator' : iter_response(obj.creator, self.refine),
                'create_date': obj.create_date,
            }
        if isinstance(obj, Person):
            return person_to_dict(obj)

        if isinstance(obj, Place):
            return place_to_dict(obj)
        if isinstance(obj, FeedItem):
            return {
                'creator' : iter_response(obj.creator, self.refine),
                'count_likes' : len(obj.liked),
                'type' : obj.type,
                'data' : iter_response(obj.get_data(), self.refine),
                'id' : obj.id,
                'comments'  : obj.feeditemcomment_set.all().order_by('create_date')
                }
        return obj

class FeedGet(FeedApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        feed_item = FeedItem.objects.get(id=pk)
        return feed_item

class FeedComment(FeedApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def post(self, pk):
        comment = self.request.POST.get('comment')
        if not comment:
            return self.error(message='comment required')
        feed_item = FeedItem.objects.get(id=pk)
        comment = feed_item.comment(self.request.user.get_profile(), comment)
        return comment


class FeedLike(FeedApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def post(self, pk):
        feed_item = FeedItem.objects.get(id=pk)
        feed_item.like(self.request.user.get_profile())
        return feed_item


class FeedUnlike(FeedApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def post(self, pk):
        feed_item = FeedItem.objects.get(id=pk)
        feed_item.unlike(self.request.user.get_profile())
        return feed_item
