from django.conf.urls import url
from poi.models import Place, CheckinPhoto, Checkin

from utils import model_to_dict, filter_fields

from ..base import *

class CheckinCreate(ApiMethod):
    def post(self):
        if not 'photo' in self.request.FILES:
            self.error(message='file uploading in "photo" field is required')

        required_fields = (
            'place_id',
        )
        data = filter_fields(self.request.POST, required_fields)
        if data:
            photo_file = self.request.FILES['photo']
            place = Place.objects.get(id=data['place_id'])
            checkin = Checkin.objects.create_checkin(
                self.request.user.get_profile(),
                place,
                self.request.POST.get('comment'),
                photo_file
            )
            return {
                'id' : checkin.id,
                'place_id' : checkin.place.id,
                'person_id' : checkin.person.id,
                'comment' : checkin.comment,
                'photo' : checkin.checkinphoto_set.all()[0].photo.url,
                'create_date' : checkin.create_date,
            }
        else:
            raise self.error(message='required fields')

