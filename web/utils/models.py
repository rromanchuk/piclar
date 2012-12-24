# charset=utf-8
from django.db import models

class ActiveObjectsManager(models.Manager):
    def active_objects(self):
        return super(ActiveObjectsManager, self).get_query_set().filter(is_active=True)


class DeletableModel(models.Model):
    is_active = models.BooleanField(default=True)

    def safe_delete(self):
        self.is_active = False
        self.save()

    def safe_undelete(self):
        self.is_active = True
        self.save()

    class Meta:
        abstract = True