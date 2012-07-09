from django.conf.urls import url
from tastypie.exceptions import ImmediateHttpResponse
from tastypie import http

from base import BaseResource
from poi.models import Place


class PlaceResource(BaseResource):
    class Meta(BaseResource.Meta):
        queryset = Place.objects.all()

    def override_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/search/$" % self._meta.resource_name, self.wrap_view('obj_search'), name="api_search_poi"),
            ]

    def obj_search(self, request, **kwargs):
        self.method_check(request, allowed=['get'])
        lat = request.GET.get('lat')
        lng = request.GET.get('lng')
        if not lat or not lng:
            raise ImmediateHttpResponse(response=http.HttpBadRequest('lat and lng params are required'))


        objects = []
        result = Place.places.search(lat, lng).all()[:50]
        for item in result:
            bundle = self.build_bundle(obj=item, request=request)
            bundle = self.full_dehydrate(bundle)
            objects.append(bundle)

        object_list = {
            'objects': objects,
            }

        self.log_throttled_access(request)
        return self.create_response(request, object_list)