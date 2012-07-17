from django.conf.urls import patterns, include, url
from tastypie.api import Api
from v1.person_api import PersonResource
from v1.place_api import PlaceResource
from v1.photo_api import PhotoResource
from v1.checkin_api import CheckinResource

v1_api = Api(api_name='v1')
v1_api.register(PersonResource())
v1_api.register(PlaceResource())
v1_api.register(PhotoResource())
v1_api.register(CheckinResource())

urlpatterns = patterns('',
    url(r'^',include(v1_api.urls)),
)

'''
    url(r'^v2/person/', 'person_api.singup', 'api_person_signup'),
    url(r'^v2/person/(?P<id>)', 'person_api.get', 'api_person_signup'),
    url(r'^v2/person/login', 'person_api.login', 'api_person_login'),
    url(r'^v2/person/logout', 'person_api.logout', 'api_person_logout'),
    url(r'^v2/person/logged', 'person_api.logged', 'api_person_logged'),
    url(r'^v2/person/logged/feed', 'person_api.logged_feed', 'api_person_logged_feed'),
'''

