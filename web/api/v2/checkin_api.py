from django.conf.urls import url
from poi.models import Place, CheckinPhoto, Checkin
from person.models import Person

from utils import  filter_fields

from .base import *

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

            # TODO: remove it after implement token auth
            if self.request.POST.get('person_id'):
                person = Person.objects.get(id=self.request.POST.get('person_id'))
            else:
                person = self.request.user.get_profile()
            checkin = Checkin.objects.create_checkin(
                person,
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

