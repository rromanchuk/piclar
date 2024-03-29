from person.models import Person
from notification.models import Notification

def notifications(request):
    try:
        if not request.user or not request.user.is_authenticated() or request.user.get_profile().status != Person.PERSON_STATUS_ACTIVE:
            return {}
    except Person.DoesNotExist:
        return {}

    person = request.user.get_profile()
    notification_list =  Notification.objects.get_person_notifications_popup(person)
    unread = Notification.objects.get_person_notifications_unread_count(person)
    return {
        'notification_popup' : notification_list,
        'notification_popup_unread_count' : unread
    }
