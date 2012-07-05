from django.conf.urls import patterns, include, url
from tastypie.api import Api
from views import PersonResource, PlaceResource

v1_api = Api(api_name='v1')
v1_api.register(PersonResource())
v1_api.register(PlaceResource())

urlpatterns = patterns('',
       url(r'^',include(v1_api.urls)),

)
