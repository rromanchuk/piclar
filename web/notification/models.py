from django.db import models
from xact import xact
from person.models import Person

from logging import getLogger

log = getLogger('web.notification.models')

class NotificationManager(models.Manager):
    @xact
    def create_friend_notification(self, receiver, friend):
        # avoid duplicating notifications about following
        if self.get_query_set().filter(receiver=receiver, sender=friend).count() > 0:
            return
        proto = {
            'sender' : friend,
            'receiver' : receiver,
            'notification_type' : Notification.NOTIFICATION_TYPE_NEW_FRIEND,
        }
        n = Notification(**proto)
        n.save()
        return n

    @xact
    def create_comment_notification(self, comment):
        for person_id in comment.item.shared:
            if person_id == comment.creator.id:
                continue

            try:
                Person.objects.get(id=person_id)
            except Person.DoesNotExist:
                log.error('person from shared does not exists person=[%s], feeditem=[%s] ' % (person_id, comment.item.id))
                continue

            proto = {
                'receiver_id' : person_id,
                'sender' : comment.creator,
                'object_id' : comment.item.id,
                'notification_type' : Notification.NOTIFICATION_TYPE_NEW_COMMENT,
            }
            n = Notification(**proto)
            n.save()

    def get_person_notifications_popup(self, person):
        return self.get_person_notifications(person)[:5]

    def get_person_notifications(self, person):
        return self.get_query_set().filter(receiver=person).select_related('person').order_by('-create_date')

    def mark_as_read_all(self, person):
        self.get_query_set().filter(receiver=person).update(is_read=True)

    def mark_as_read(self, person, ids):
        self.get_query_set().filter(receiver=person, id__in=ids).update(is_read=True)


class Notification(models.Model):
    NOTIFICATION_TYPE_NEW_COMMENT = 1
    NOTIFICATION_TYPE_NEW_FRIEND = 2
    NOTIFICATION_TYPE_CHOICES = (
        ('new comment', NOTIFICATION_TYPE_NEW_COMMENT),
        ('new friend', NOTIFICATION_TYPE_NEW_FRIEND),
    )

    sender = models.ForeignKey(Person, null=True, related_name='+')
    receiver = models.ForeignKey(Person)
    notification_type = models.IntegerField(choices=NOTIFICATION_TYPE_CHOICES)

    is_read = models.BooleanField(default=False)
    object_id = models.IntegerField(null=True)

    objects = NotificationManager()
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    def mark_as_read(self, person):
        if self.receiver.id != person.id:
            return
        self.is_read = True
        self.save()
