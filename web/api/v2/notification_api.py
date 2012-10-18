from utils import  filter_fields, AuthTokenMixin, doesnotexist_to_404
from django.conf import settings
from base import *
from notification.models import Notification
from person.models import Person
from feed.models import FeedItem

class NotificationsUnreadCount(ApiMethod, AuthTokenMixin):
    def get(self):
        person = self.request.user.get_profile()
        return {
            'unread_notifications': Notification.objects.get_person_notifications_unread_count(person),
        }


class NotificationsList(ApiMethod, AuthTokenMixin):
    def refine(self, obj):
        if isinstance(obj, Notification):
            return obj.serialize()
        return obj

    def get(self):
        if settings.API_DEBUG_FEED_EMPTY:
            return []
        person = self.request.user.get_profile()
        return Notification.objects.get_person_notifications(person)

class NotificationMarkAsRead(ApiMethod, AuthTokenMixin):
    def post(self):
        Notification.objects.mark_as_read_all(self.request.user.get_profile())
        return {}

class NotificationsGet(ApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        notification = Notification.objects.get(id=pk, receiver=self.request.user.get_profile())
        proto = notification.serialize()
        if notification.notification_type == Notification.NOTIFICATION_TYPE_NEW_COMMENT:
            proto['feed_item'] = FeedItem.objects.get(id=notification.object_id).serialize(self.request)

        return proto



