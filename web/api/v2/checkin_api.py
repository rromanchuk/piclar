from poi.models import Place, CheckinPhoto, Checkin, CheckinError
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

            share_platform = []
            for platform in ['facebook', 'vkontakte']:
                if self.request.POST.get('share_%s' % platform):
                    share_platform.append(platform)
            try:
                checkin = Checkin.objects.create_checkin(
                    person,
                    share_platform,
                    place,
                    self.request.POST.get('review'),
                    int(self.request.POST.get('rate')),
                    photo_file
                )
            except CheckinError as e:
                return self.error(message=e.message)

            feed_item = FeedItem.objects.get(id=checkin.feed_item_id)
            feed_pitem = FeedItem.objects.feeditem_for_person(feed_item, person)
            proto = feed_pitem.item.serialize(self.request)
            proto['share_date'] = feed_pitem.create_date
            return proto

        else:
            return self.error(message='required fields: place_id, rate')

