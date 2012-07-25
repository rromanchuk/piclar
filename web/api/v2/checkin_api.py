from poi.models import Place, CheckinPhoto, Checkin
from person.models import Person

from utils import  filter_fields, AuthTokenMixin
from person_api import person_to_dict
from base import *

class CheckinCreate(ApiMethod, AuthTokenMixin):
    def refine(self, obj):
        if isinstance(obj, Person):
            return person_to_dict(obj)

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
            person = self.request.user.get_profile()
            checkin = Checkin.objects.create_checkin(
                person,
                place,
                self.request.POST.get('comment'),
                photo_file
            )
            return {
                'id' : checkin.id,
                'place' : checkin.place.id,
                'person' : checkin.person,
                'comment' : checkin.comment,
                'photos' : [ photo.photo.url for photo in checkin.checkinphoto_set.all() ],
                'create_date' : checkin.create_date,
            }
        else:
            return self.error(message='required fields')

