from base import *
from logging import getLogger
from poi.models import Place, Checkin

log = getLogger('web.api.person')

from utils import filter_fields, doesnotexist_to_404, AuthTokenMixin, CommonRefineMixin

class PlaceApiMethod(ApiMethod, CommonRefineMixin):
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


    def auth(self):
        result = super(PlaceSearch, self).auth()
        if isinstance(result, HttpResponse):
            return

    def get(self):
        person = None
        # check if search request was subscribed
        if self.request.user and self.request.user.is_authenticated():
            person = self.request.user.get_profile()
        lat = self.request.GET.get('lat')
        lng = self.request.GET.get('lng')
        if not lat or not lng:
            return self.error(message='lat and lng params are required')

        result = Place.objects.search(lat, lng, person).all()
        limit = self.request.GET.get('limit')
        if limit:
            result = result[:limit]
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
        if not fields['title'].strip():
            return self.error(message='title is required')
        fields['creator'] = self.request.user.get_profile()
        fields['address'] = self.request.POST.get('address')
        fields['phone'] = self.request.POST.get('phone'
                                                '')
        place = Place.objects.create(**fields)
        return place

