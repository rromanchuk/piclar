from django.core.management.base import BaseCommand, CommandError

from person.models import Person
from logging import getLogger

log = getLogger('web.person.commands')
class Command(BaseCommand):

    def handle(self, *args, **kwargs):
        persons = Person.objects.exclude(status=Person.PERSON_STATUS_ACTIVE)
        log.info('Token will be reset for %s persons' % persons.count())
        for person in persons:
            person.reset_token()
            