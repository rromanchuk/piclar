from django.conf.urls import patterns, include, url

from v2.person_api import *
from v2.checkin_api import *
from v2.place_api import *
from v2.feed_api import *
from v2.settings_api import *
from v2.notification_api import *



urlpatterns = patterns('',
    url(r'^v1/person\.(xml|json)$', PersonCreate.view, name='api_person'),
    url(r'^v1/person/(?P<pk>\d+)\.(?P<content_type>xml|json)$', PersonGet.view, name='api_person_get'),
    url(r'^v1/person/(?P<pk>\d+)/(?P<action>follow|unfollow)\.(?P<content_type>xml|json)$', PersonFollowUnfollow.view, name='api_person_follow_unfollow'),
    url(r'^v1/person/(?P<pk>\d+|logged)/followers\.(?P<content_type>xml|json)$', PersonFollowers.view, name='api_person_followers'),
    url(r'^v1/person/(?P<pk>\d+|logged)/following\.(?P<content_type>xml|json)$', PersonFollowing.view, name='api_person_following'),
    url(r'^v1/person/login\.(xml|json)$', PersonLogin.view, name='api_person_login'),
    url(r'^v1/person/logout\.(xml|json)$', PersonLogout.view, name='api_person_logout'),
    url(r'^v1/person/logged\.(xml|json)$', PersonLogged.view, name='api_person_logged'),
    url(r'^v1/person/logged/feed\.(xml|json)$', PersonFeed.view, name='api_person_logged_feed'),
    url(r'^v1/person/(?P<pk>\d+)/feed\.(?P<content_type>xml|json)$', PersonFeedOwned.view, name='api_person_feed_owned'),

    url(r'^v1/place/search\.(xml|json)$', PlaceSearch.view, name='api_place_search'),
    url(r'^v1/place/(?P<pk>\d+)\.(?P<content_type>xml|json)$', PlaceGet.view, name='api_place_get'),
    url(r'^v1/place/(?P<pk>\d+)/reviews\.(?P<content_type>xml|json)$', PlaceReviews.view, name='api_place_reviews_get'),

    url(r'^v1/notification/unread\.(xml|json)$', NotificationsUnreadCount.view, name='api_notification_unread'),
    url(r'^v1/notification/list\.(xml|json)$', NotificationsList.view, name='api_notification_unread'),

    url(r'^v1/checkin\.(xml|json)$', CheckinCreate.view, name='api_checkin_get'),

    url(r'^v1/feed/(?P<pk>\d+)\.(?P<content_type>xml|json)$', FeedGet.view, name='api_feed_get'),
    url(r'^v1/feed/(?P<pk>\d+)/comment\.(?P<content_type>xml|json)$', FeedComment.view, name='api_feed_comment'),
    url(r'^v1/feed/(?P<pk>\d+)/like\.(?P<content_type>xml|json)$', FeedLike.view, name='api_feed_like'),
    url(r'^v1/feed/(?P<pk>\d+)/unlike\.(?P<content_type>xml|json)$', FeedLike.view, name='api_feed_unlike'),
    url(r'^v1/settings\.(xml|json)$', SettingsGet.view, name='api_settings'),
)
