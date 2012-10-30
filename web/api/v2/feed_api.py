from utils import  filter_fields, AuthTokenMixin, doesnotexist_to_404, date_in_words, CommonRefineMixin
from base import *
from person.models import Person
from poi.models import Place
from feed.models import FeedItem, FeedPersonItem, FeedItemComment

from serializers import iter_response


def feeditemcomment_to_dict(obj):
    if isinstance(obj, FeedItemComment):
        return {
            'id' : obj.id,
            'comment' : obj.comment.replace('\n',' ').replace('\r', ' '),
            'creator' : obj.creator.serialize(),
            'create_date': obj.create_date,
            'create_date_words' : date_in_words(obj.create_date)
        }
    return obj

class FeedApiMethod(ApiMethod, AuthTokenMixin, CommonRefineMixin):
    def refine(self, obj):
        if isinstance(obj, FeedItemComment):
            return obj.serialize()
        if isinstance(obj, Place):
            return obj.serialize()
        if isinstance(obj, FeedItem):
            return obj.serialize(self.request)
        return obj

class FeedGet(FeedApiMethod):
    @doesnotexist_to_404
    def get(self, pk):
        feed_item = FeedItem.objects.get(id=pk)
        return feed_item

class FeedComment(FeedApiMethod):
    @doesnotexist_to_404
    def post(self, pk):
        comment = self.request.POST.get('comment')
        if not comment:
            return self.error(message='comment required')
        feed_item = FeedItem.objects.get(id=pk)
        comment = feed_item.create_comment(self.request.user.get_profile(), comment)
        return comment

class FeedCommentDelete(FeedApiMethod):
    @doesnotexist_to_404
    def post(self, pk, comment_id):
        feed_item = FeedItem.objects.get(id=pk)
        feed_item.delete_comment(self.request.user.get_profile(), comment_id)
        return {}



class FeedLike(FeedApiMethod):
    @doesnotexist_to_404
    def post(self, pk):
        feed_item = FeedItem.objects.get(id=pk)
        feed_item.like(self.request.user.get_profile())
        return feed_item


class FeedUnlike(FeedApiMethod):
    @doesnotexist_to_404
    def post(self, pk):
        feed_item = FeedItem.objects.get(id=pk)
        feed_item.unlike(self.request.user.get_profile())
        return feed_item
