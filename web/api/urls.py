from django.conf.urls import patterns, include, url
from tastypie.api import Api
from v1.person_api import PersonResource
from v1.place_api import PlaceResource
from v1.photo_api import PhotoResource
from v1.checkin_api import CheckinResource

from v2.person_api import *
from v2.checkin_api import *
from v2.place_api import *
from v2.feed_api import *
from v2.settings_api import *


v1_api = Api(api_name='v1')
v1_api.register(PersonResource())
v1_api.register(PlaceResource())
v1_api.register(PhotoResource())
v1_api.register(CheckinResource())


urlpatterns = patterns('',
    url(r'^',include(v1_api.urls)),
    url(r'^v1/person\.(xml|json)$', PersonCreate.view, name='api_person'),
    url(r'^v1/person/(?P<pk>\d+)\.(?P<content_type>xml|json)$', PersonGet.view, name='api_person_get'),
    url(r'^v1/person/login\.(xml|json)$', PersonLogin.view, name='api_person_login'),
    url(r'^v1/person/logout\.(xml|json)$', PersonLogout.view, name='api_person_logout'),
    url(r'^v1/person/logged\.(xml|json)$', PersonLogged.view, name='api_person_logged'),
    url(r'^v1/person/logged/feed\.(xml|json)$', PersonFeed.view, name='api_person_logged_feed'),
    url(r'^v1/place/search\.(xml|json)$', PlaceSearch.view, name='api_place_search'),
    url(r'^v1/place/(?P<pk>\d+)\.(?P<content_type>xml|json)$', PlaceGet.view, name='api_place_get'),
    url(r'^v1/place/(?P<pk>\d+)/reviews\.(?P<content_type>xml|json)$', PlaceReviews.view, name='api_place_reviews_get'),


    url(r'^v1/checkin\.(xml|json)$', CheckinCreate.view, name='api_checkin_get'),

    url(r'^v1/feed/(?P<pk>\d+)\.(?P<content_type>xml|json)$', FeedGet.view, name='api_feed_get'),
    url(r'^v1/feed/(?P<pk>\d+)/comment\.(?P<content_type>xml|json)$', FeedComment.view, name='api_feed_comment'),
    url(r'^v1/feed/(?P<pk>\d+)/like\.(?P<content_type>xml|json)$', FeedLike.view, name='api_feed_like'),
    url(r'^v1/feed/(?P<pk>\d+)/unlike\.(?P<content_type>xml|json)$', FeedLike.view, name='api_feed_unlike'),
    url(r'^v1/settings\.(xml|json)$', SettingsGet.view, name='api_settings'),
)
