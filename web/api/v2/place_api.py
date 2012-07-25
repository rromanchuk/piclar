from base import *
from logging import getLogger
from poi.models import Place

log = getLogger('web.api.person')

from utils import model_to_dict, doesnotexist_to_404

def place_to_dict(obj):
    if isinstance(obj, Place):
        return_fields = (
            'id',  'title', 'description', 'address', 'type', 'type_text'
            )
        data = model_to_dict(obj, return_fields)
        data['position'] = {
            'lat' : obj.position.x,
            'lng' : obj.position.y,
            }
        data['photos'] = [ {'url' : photo.url, 'title': photo.title } for photo in obj.placephoto_set.all() ]
        return data
    return obj

class PlaceApiMethod(ApiMethod):
    def refine(self, obj):
        return place_to_dict(obj)


class PlaceGet(PlaceApiMethod):

    @doesnotexist_to_404
    def get(self, pk):
        place = Place.objects.get(id=pk)
        return place

class PlaceSearch(PlaceApiMethod):


    def get(self):
        lat = self.request.GET.get('lat')
        lng = self.request.GET.get('lng')
        if not lat or not lng:
            return self.error(message='lat and lng params are required')

        result = Place.objects.search(lat, lng).all()[:50]
        object_list = {
            'objects': list(result)

        }
        return object_list
