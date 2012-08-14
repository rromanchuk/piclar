from utils import  filter_fields, AuthTokenMixin, doesnotexist_to_404
from base import *
from notification.models import Notification

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
        person = self.request.user.get_profile()
        return Notification.objects.get_person_notifications(person)

