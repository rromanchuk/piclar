# coding=utf-8
from django.core.management.base import BaseCommand, CommandError

from poi.provider.altergeo.models import AltergeoPlace
from poi.provider.foursquare.models import FoursquarePlace

from django.contrib.gis.geos import *
from django.contrib.gis.measure import D
from django.conf import settings
from pymorphy import get_morph


import re
import logging
import difflib

log = logging.getLogger('web.poi.merger')

class Command(BaseCommand):

    def __init__(self, *args, **kwargs):
        self.base_words = set(file('basewords.txt', 'r'))
        self.morph = get_morph(settings.DICTIONARY_PATH)

        super(Command, self).__init__(*args, **kwargs)

    def _normalize(self, text, to_cls):
        result = []
        text = re.sub(u'[^A-Z0-9А-Я]', ' ', text.upper(), re.U)
        for word in text.split(' '):
            word = word.strip()
            if len(word) < 3:
                continue
            word = morph.normalize(word)
            if isinstance(word, set):
                word = word.pop()
            result.append(word)
        if not to_cls:
            return ' '.join(result)
        else:
            return to_cls(result)

    def handle(self, *args, **options):

        # experiment with altergeo to fsq matching
        for item in FoursquarePlace.objects.all():
            to_compare = []
            for near_place in AltergeoPlace.objects.filter(position__distance_lte=(item.position, D(m=300))):
                title1 = self._normalize(near_place.title, list)
                title2 = self._normalize(item.title, list)

                # remove base words
                t1_set = set(title1)
                t2_set = set(title2)
                res_set = self.base_words.intersection(t1_set).intersection(t2_set)
                if res_set:
                    print res_set

                ratio = difflib.SequenceMatcher(None, title1, title2).ratio()
                to_compare.append({ 'a' : near_place, 'b' : item, 'ratio' : ratio})

            if len(to_compare) == 0:
                continue

            max_item = max(to_compare, key=lambda x: x['ratio'])
            if max_item['ratio'] > 0.6:
                log.info('Good: %s - %s - %s' % (max_item['a'].title, max_item['b'].title, max_item['ratio']))

