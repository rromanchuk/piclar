from base import *
from logging import getLogger
from poi.models import Place

log = getLogger('web.api.person')

from utils import model_to_dict

class PlaceSearch(ApiMethod):

    return_fields = (
        'title', 'description', 'address', 'type', 'type_text'
    )

    def get(self):
        lat = self.request.GET.get('lat')
        lng = self.request.GET.get('lng')
        if not lat or not lng:
            return self.error(message='lat and lng params are required')

        objects = []
        result = Place.objects.search(lat, lng).all()[:50]
        for item in result:
            place_data = model_to_dict(item, self.return_fields)
            place_data['position'] = {
                'lat' : item.position.x,
                'lng' : item.position.y,
            }
            place_data['photos'] = [ {'url' : photo.url, 'title': photo.title } for photo in item.placephoto_set.all() ]
            objects.append(place_data)

        object_list = {
            'objects': objects,

        }

        return object_list
