from django.core.management.base import BaseCommand, CommandError
from poi.models import Place

from logging import getLogger
log = getLogger('web.poi.commands.update_rate')

class Command(BaseCommand):
    def handle(self, *args, **options):
        qs = Place.objects.all()
        log.info('Start processing %s places...' % qs.count())
        cnt = 1
        for place in qs:
            place.update_rate()
            cnt +=1
            if cnt % 100 == 0:
                log.info('%s places processed' % cnt)

        log.info('Done')