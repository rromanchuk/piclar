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
        if isinstance(obj, FeedPersonItem):
            return {
                'creator' : iter_response(obj.creator, self.refine),
                'type' : obj.item.type,
                'data' : iter_response(obj.item.get_data(), self.refine),
                'id' : obj.item.id,
                }
        return obj

class FeedGet(FeedApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        feed_person = FeedItem.objects.feeditem_for_person_by_id(pk, self.request.user.get_profile().id)
        return feed_person

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
