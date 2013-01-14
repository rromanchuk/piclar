from django.conf.urls import patterns, include, url

from v1.serializers import to_json_custom, to_xml_custom, to_jsonp_custom
from v1.base import Api
from v1.person_api import *
from v1.checkin_api import *
from v1.place_api import *
from v1.feed_api import *
from v1.settings_api import *
from v1.notification_api import *
from v1.game_api import *

api_v1 = Api()
api_v11 = Api()
api_v11.setSerializer('json', to_json_custom)
api_v11.setSerializer('jsonp', to_jsonp_custom)
api_v11.setSerializer('xml', to_xml_custom)


def get_urls(url_prefix, api):
    urls = (
            url(r'^person\.(xml|json)$', api.method(PersonCreate), name='api_person'),
            url(r'^person/', include(patterns('',
                url(r'^logged/update\.(xml|json)$', api.method(PersonUpdate), name='api_person_update'),
                url(r'^(?P<pk>\d+)\.(?P<content_type>xml|json)$', api.method(PersonGet), name='api_person_get'),
                url(r'^(?P<pk>\d+)/(?P<action>follow|unfollow)\.(?P<content_type>xml|json)$', api.method(PersonFollowUnfollow), name='api_person_follow_unfollow'),
                url(r'^(?P<pk>\d+|logged)/followers\.(?P<content_type>xml|json)$', api.method(PersonFollowers), name='api_person_followers'),
                url(r'^(?P<pk>\d+|logged)/following\.(?P<content_type>xml|json)$', api.method(PersonFollowing), name='api_person_following'),
                url(r'^logged/fullinfo\.(?P<content_type>xml|json)$', api.method(PersonFollowingFollowers), name='api_person_following_followers'),
                url(r'^(?P<pk>\d+|logged)/followingfollowers\.(?P<content_type>xml|json)$', api.method(PersonFollowingFollowers), name='api_person_following_followers'),
                url(r'^(?P<pk>\d+|logged)/suggested\.(?P<content_type>xml|json)$', api.method(PersonSuggested), name='api_person_suggested'),
                url(r'^login\.(xml|json)$', api.method(PersonLogin), name='api_person_login'),
                url(r'^logout\.(xml|json)$', api.method(PersonLogout), name='api_person_logout'),
                url(r'^logged\.(xml|json)$', api.method(PersonLogged), name='api_person_logged'),
                url(r'^logged/updatesocial\.(xml|json)$', api.method(PersonUpdateSocial), name='api_person_logged_update_social'),
                url(r'^logged/feed\.(xml|json)$', api.method(PersonFeed), name='api_person_logged_feed'),
                url(r'^logged/settings\.(xml|json)$', api.method(PersonSettingApi), name='api_person_logged_settings'),
                url(r'^logged/check_code\.(xml|json)$', api.method(PersonInvitationCode), name='api_person_logged_check_code'),
                url(r'^(?P<pk>\d+)/feed\.(?P<content_type>xml|json)$', api.method(PersonFeedOwned), name='api_person_feed_owned'),
            ))),

        url(r'^place/search\.(xml|json)$', api.method(PlaceSearch), name='api_place_search'),
        url(r'^place\.(xml|json)$', api.method(PlaceCreate), name='api_place_create'),
        url(r'^place/(?P<pk>\d+)\.(?P<content_type>xml|json)$', api.method(PlaceGet), name='api_place_get'),
        url(r'^place/(?P<pk>\d+)/reviews\.(?P<content_type>xml|json)$', api.method(PlaceReviews), name='api_place_reviews_get'),

        url(r'^notification/unread\.(xml|json)$', api.method(NotificationsUnreadCount), name='api_notification_unread'),
        url(r'^notification/list\.(xml|json)$', api.method(NotificationsList), name='api_notification_list'),
        url(r'^notification/(?P<pk>\d+)\.(?P<content_type>xml|json)$', api.method(NotificationsGet), name='api_notification_get'),
        url(r'^notification/markasread\.(xml|json)$', api.method(NotificationMarkAsRead), name='api_notification_markasread'),

        url(r'^checkin\.(xml|json)$', api.method(CheckinCreate), name='api_checkin_get'),

        url(r'^feed/(?P<pk>\d+)\.(?P<content_type>xml|json)$', api.method(FeedGet), name='api_feed_get'),
        url(r'^feed/(?P<pk>\d+)/comment\.(?P<content_type>xml|json)$', api.method(FeedComment), name='api_feed_comment'),
        url(r'^feed/(?P<pk>\d+)/comment/(?P<comment_id>\d+)/delete\.(?P<content_type>xml|json)$', api.method(FeedCommentDelete), name='api_feed_comment_delete'),
        url(r'^feed/(?P<pk>\d+)/like\.(?P<content_type>xml|json)$', api.method(FeedLike), name='api_feed_like'),
        url(r'^feed/(?P<pk>\d+)/delete\.(?P<content_type>xml|json)$', api.method(FeedDelete), name='api_feed_delete'),
        url(r'^feed/(?P<pk>\d+)/unlike\.(?P<content_type>xml|json)$', api.method(FeedUnlike), name='api_feed_unlike'),
        url(r'^settings\.(xml|json)$', api.method(SettingsGet), name='api_settings'),
        url(r'^game/score\.(xml|json)$', api.method(ScoreGetPost), name='api_game_score_getpost'),
    )
    return url(r'^%s/'% url_prefix, include(patterns('', *urls), url_prefix))

urlpatterns = patterns('', get_urls('v1', api_v1))
urlpatterns += patterns('', get_urls('v1.1', api_v11))
