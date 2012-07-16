from django.conf.urls import url
from tastypie.exceptions import ImmediateHttpResponse
from tastypie import http

from base import BaseResource
from poi.models import PlacePhoto


class PhotoResource(BaseResource):
    class Meta(BaseResource.Meta):
        queryset = PlacePhoto.objects.all()
