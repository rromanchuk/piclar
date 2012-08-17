from poi.models import Place, CheckinPhoto, Checkin
from person.models import Person

from utils import  filter_fields, AuthTokenMixin, date_in_words
from base import *

from feed_api import FeedApiMethod

from feed.models import FeedItem

class CheckinCreate(FeedApiMethod, AuthTokenMixin):

    def post(self):
        if not 'photo' in self.request.FILES:
            self.error(message='file uploading in "photo" field is required')

        required_fields = (
            'place_id',
            'rate'
        )
        data = filter_fields(self.request.POST, required_fields)
        if data:
            photo_file = self.request.FILES['photo']
            place = Place.objects.get(id=data['place_id'])
            person = self.request.user.get_profile()
            checkin = Checkin.objects.create_checkin(
                person,
                place,
                self.request.POST.get('review'),
                self.request.POST.get('rate'),
                photo_file
            )

            feed_item = FeedItem.objects.get(id=checkin.feed_item_id)
            return feed_item

        else:
            return self.error(message='required fields: place_id, rate')

