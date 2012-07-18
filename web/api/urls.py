from django.conf.urls import patterns, include, url
from tastypie.api import Api
from v1.person_api import PersonResource
from v1.place_api import PlaceResource
from v1.photo_api import PhotoResource
from v1.checkin_api import CheckinResource

from v2.person_api import *


v1_api = Api(api_name='v1')
v1_api.register(PersonResource())
v1_api.register(PlaceResource())
v1_api.register(PhotoResource())
v1_api.register(CheckinResource())

urlpatterns = patterns('',
    url(r'^',include(v1_api.urls)),
    url(r'^v2/person\.(xml|json)$', PersonCreate.view, name='api_person'),
    url(r'^v2/person/(?P<pk>\d+)\.(?P<content_type>xml|json)$', PersonGet.view, name='api_person_get'),
    url(r'^v2/person/login\.(xml|json)$', PersonLogin.view, name='api_person_login'),
    url(r'^v2/person/logout\.(xml|json)$', PersonLogout.view, name='api_person_logout'),
    url(r'^v2/person/logged\.(xml|json)$', PersonLogged.view, name='api_person_logged'),
    url(r'^v2/person/logged/feed\.(xml|json)$', PersonFeed.view, name='api_person_logged_feed'),
)
