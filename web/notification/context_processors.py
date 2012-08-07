from person.models import Person
from notification.models import Notification

def notifications(request):
    if not request.user or not request.user.is_authenticated() or request.user.get_profile().status != Person.PERSON_STATUS_ACTIVE:
        return {}

    person = request.user.get_profile()
    notification_list =  Notification.objects.get_person_notifications_popup(person)
    unread = len([n for n in notification_list if not n.is_read])
    return {
        'notification_popup' : notification_list,
        'notification_popup_unread_count' : unread
    }
