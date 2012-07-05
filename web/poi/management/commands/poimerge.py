from django.core.management.base import BaseCommand, CommandError

from poi.provider.altergeo.models import AltergeoPlace
from poi.provider.foursquare.models import FoursquarePlace

from django.contrib.gis.geos import *
from django.contrib.gis.measure import D

import logging
import difflib

log = logging.getLogger('web.poi.merger')

class Command(BaseCommand):
    def _normalize(self, text):
        return

    def handle(self, *args, **options):
        # experiment with altergeo to fsq matching
        for item in FoursquarePlace.objects.all():
            to_compare = []
            for near_place in AltergeoPlace.objects.filter(position__distance_lte=(item.position, D(m=300))):
                ratio = difflib.SequenceMatcher(None, near_place.title, item.title).ratio()
                to_compare.append({ 'a' : near_place, 'b' : item, 'ratio' : ratio})

            if len(to_compare) == 0:
                continue

            max_item = max(to_compare, key=lambda x: x['ratio'])
            if max_item['ratio'] > 0.6:
                log.info('Good: %s - %s - %s' % (max_item['a'].title, max_item['b'].title, max_item['ratio']))

