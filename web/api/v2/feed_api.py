from utils import  filter_fields, AuthTokenMixin
from base import *

class FeedGet(ApiMethod, AuthTokenMixin):
    def get(self, pk):
        pass

class FeedComment(ApiMethod, AuthTokenMixin):
    def post(self, pk):
        pass


class FeedLike(ApiMethod, AuthTokenMixin):
    def post(self, pk):
        pass