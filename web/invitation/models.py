# coding=utf-8
from django.db import models
from person.models import Person
from datetime import datetime

class IncorrectCode(Exception):
    pass


class CodeManager(models.Manager):

    def check_code(self, value):
        try:
            code = self.get_query_set().get(value=value.lower(), person_used__isnull=True)
            return code
        except Code.DoesNotExist:
            raise IncorrectCode('code %s not found' % value)

class Code(models.Model):

    value = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Значение кода", unique=True)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    person_used = models.OneToOneField(Person, blank=True, null=True)
    used_date = models.DateTimeField(blank=True, null=True)

    objects = CodeManager()

    def __unicode__(self):
        return '[Code:%s isUsed:%s]' % (self.value, self.person_used);

    def use_code(self, person):
        self.person_used = person
        self.used_date = datetime.now()
        self.save()


