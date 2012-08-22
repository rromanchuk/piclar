from django.core.management.base import BaseCommand, CommandError
from poi.models import Place
from poi.provider.foursquare.models import FoursquarePlace

from logging import getLogger
log = getLogger('web.poi.commands.fill_provider_popularity')

class Command(BaseCommand):
    def handle(self, *args, **options):
        qs = Place.objects.filter(provider_popularity=0)
        log.info('Start processing %s places...' % qs.count())
        cnt = 1
        for place in qs:
            mapped = FoursquarePlace.objects.filter(mapped_place=place)
            if mapped.count() > 0:
                place.provider_popularity = mapped[0].checkins
                place.save()
                cnt +=1

            if cnt % 100 == 0:
                log.info('%s places processed' % cnt)

        log.info('Done')