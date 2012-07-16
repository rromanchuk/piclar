from django.conf.urls import url
from tastypie.exceptions import ImmediateHttpResponse, BadRequest
from tastypie import http

from base import BaseResource
from poi.models import Place, CheckinPhoto, Checkin

class MultipartResource(object):
    def deserialize(self, request, data, format=None):
        if not format:
            format = request.META.get('CONTENT_TYPE', 'application/json')

        if format == 'application/x-www-form-urlencoded':
            return request.POST

        if format.startswith('multipart'):
            data = request.POST.copy()
            data.update(request.FILES)

            return data

        return super(MultipartResource, self).deserialize(request, data, format)

class CheckinResource(MultipartResource, BaseResource):
    class Meta(BaseResource.Meta):
        queryset = Checkin.objects.all()


    #def override_urls(self):
        #return [
        #    url(r"^(?P<resource_name>%s)/add/$" % self._meta.resource_name, self.wrap_view('obj_search'), name="api_search_poi"),


    def obj_create(self, bundle, request=None):
        self.method_check(request, allowed=['post'])
        self.throttle_check(request)

        if not 'photo' in request.FILES:
            raise BadRequest('file uploading in "photo" field is required')

        required_fields = (
            'place_id',
        )

        if self._check_field_list(bundle, required_fields):
            photo_file = request.FILES['photo']
            place = Place.objects.get(id=bundle.data['place_id'])
            proto = {
                'place' : place,
                'person' : request.user.get_profile()

            }
            checkin = Checkin(**proto)
            checkin.save()
            c_photo = CheckinPhoto()
            c_photo.checkin = checkin
            c_photo.photo.save(photo_file.name, photo_file)

        else:
            raise BadRequest('required fields')


        self.log_throttled_access(request)
        return bundle