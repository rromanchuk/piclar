from django.conf.urls import patterns, include, url
from tastypie.api import Api
from views.person_api import PersonResource
from views.place_api import PlaceResource
from views.photo_api import PhotoResource
from views.checkin_api import CheckinResource

v1_api = Api(api_name='v1')
v1_api.register(PersonResource())
v1_api.register(PlaceResource())
v1_api.register(PhotoResource())
v1_api.register(CheckinResource())

urlpatterns = patterns('',
       url(r'^',include(v1_api.urls)),

)
