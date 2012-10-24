# coding=utf-8
from django.db import models
from django.db.models import Q
from person.models import Person
from datetime import datetime, timedelta

class IncorrectCode(Exception):
    pass


class CodeManager(models.Manager):

    def get_code_for_internal_invite(self, request):
        for_ip = request.META['REMOTE_ADDR']
        q = Q(lock_for=for_ip)
        code = self.get_query_set().filter(q).filter(person_used__isnull=True)
        if not code:
            q = Q(lock_date__lte=datetime.now()-timedelta(minutes=1)) | Q(lock_date__isnull=True)
            code = self.get_query_set().filter(q).filter(person_used__isnull=True)
        if not code:
            raise Code.DoesNotExist()

        code = code[0]
        code.lock_date = datetime.now()
        code.lock_for = for_ip
        code.save()
        return code

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

    lock_date = models.DateTimeField(null=True, blank=True)
    lock_for = models.CharField(null=True, blank=False, max_length=64)

    objects = CodeManager()

    def __unicode__(self):
        return '[Code:%s isUsed:%s]' % (self.value, self.person_used);

    def use_code(self, person):
        self.person_used = person
        self.used_date = datetime.now()
        self.save()


