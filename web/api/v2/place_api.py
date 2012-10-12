from base import *
from logging import getLogger
from poi.models import Place, Checkin

log = getLogger('web.api.person')

from utils import filter_fields, doesnotexist_to_404, AuthTokenMixin

class PlaceApiMethod(ApiMethod):
    def refine(self, obj):
        if isinstance(obj, Place):
            return obj.serialize()


class PlaceGet(PlaceApiMethod):
    def refine(self, obj):
        if isinstance(obj, Checkin):
            return obj.serialize()

        if isinstance(obj, Place):
            data = obj.serialize()
            data['checkins'] = iter_response(obj.get_checkins(), self.refine)
            return data
        return obj

    @doesnotexist_to_404
    def get(self, pk):
        place = Place.objects.get(id=pk)
        return place

class PlaceReviews(PlaceApiMethod):

    def refine(self, obj):
        if isinstance(obj, Checkin):
            return obj.serialize()

    @doesnotexist_to_404
    def get(self, pk):
        place = Place.objects.get(id=pk)
        return place.get_checkins()

class PlaceSearch(PlaceApiMethod, AuthTokenMixin):

    def get(self):
        person = self.request.user.get_profile()
        lat = self.request.GET.get('lat')
        lng = self.request.GET.get('lng')
        if not lat or not lng:
            return self.error(message='lat and lng params are required')

        result = Place.objects.search(person, lat, lng).all()[:50]
        return list(result)

class PlaceCreate(PlaceApiMethod, AuthTokenMixin):
    def refine(self, obj):
        if isinstance(obj, Checkin):
            return obj.serialize()

        if isinstance(obj, Place):
            data = obj.serialize()
            data['checkins'] = iter_response(obj.get_checkins(), self.refine)
            return data
        return obj

    def post(self):
        fields = filter_fields(self.request.POST, (
            'title', 'lat', 'lng', 'type',
        ))

        if not fields:
            return self.error(message='Registration with args [%s] not implemented' %
                (', ').join(self.request.POST.keys())
            )
        fields['creator'] = self.request.user.get_profile()
        fields['address'] = self.request.POST.get('address')
        fields['phone'] = self.request.POST.get('phone'
                                                '')
        place = Place.objects.create(**fields)
        return place

