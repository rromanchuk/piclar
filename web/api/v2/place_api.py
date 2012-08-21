from base import *
from logging import getLogger
from poi.models import Place, Checkin

log = getLogger('web.api.person')

from utils import model_to_dict, doesnotexist_to_404, date_in_words

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

class PlaceSearch(PlaceApiMethod):

    def get(self):
        lat = self.request.GET.get('lat')
        lng = self.request.GET.get('lng')
        if not lat or not lng:
            return self.error(message='lat and lng params are required')

        result = Place.objects.search(lat, lng).all()[:50]
        return list(result)

class PlaceCreate(PlaceApiMethod):
    def post(self):
        pass
