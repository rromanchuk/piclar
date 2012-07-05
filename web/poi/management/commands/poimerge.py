# coding=utf-8
from django.core.management.base import BaseCommand, CommandError

from poi.provider.altergeo.models import AltergeoPlace
from poi.provider.foursquare.models import FoursquarePlace

from django.contrib.gis.geos import *
from django.contrib.gis.measure import D
from django.conf import settings
from pymorphy import get_morph

from pymorphy import get_morph

import re
import logging
import difflib

log = logging.getLogger('web.poi.merger')

class Command(BaseCommand):

    def __init__(self, *args, **kwargs):
        self.base_words = set()
        for line in file('basewords.txt', 'r'):
            self.base_words.add(line.strip().decode('utf-8'))
        self.morph = get_morph(settings.DICTIONARY_PATH)
        super(Command, self).__init__(*args, **kwargs)

    def _normalize(self, text, to_cls):
        result = []
        text = re.sub(u'[^A-ZА-ЯЁ0-9]', ' ', text.upper(), re.U)
        for word in text.split(' '):
            word = word.strip()
            if len(word) < 3:
                continue
            norm_word = self.morph.normalize(word)
            if isinstance(norm_word, set):
                norm_word = norm_word.pop()
            result.append(norm_word)

        if not to_cls:
            return ' '.join(result)
        else:
            return to_cls(result)

    def handle(self, *args, **options):

        # experiment with altergeo to fsq matching
        for item in FoursquarePlace.objects.all(): # filter(id__in=[505,506]):
            to_compare = []
            for near_place in AltergeoPlace.objects.filter(position__distance_lte=(item.position, D(m=100))): # .filter(id__in=[715, 790]).
                title1 = self._normalize(near_place.title, list)
                title2 = self._normalize(item.title, list)

                ratio = difflib.SequenceMatcher(None, title1, title2).ratio()
                to_compare.append({
                    'a' : near_place,
                    'a_title': title1,
                    'b' : item,
                    'b_title': title2,
                    'ratio' : ratio,
                })

            if len(to_compare) == 0:
                continue

            max_item = max(to_compare, key=lambda x: x['ratio'])
            if max_item['ratio'] > 0.5:
                log.info('Good: %s[%d] - %s[%d] - %s' % (
                    max_item['a'].title,
                    max_item['a'].id,
                    max_item['b'].title,
                    max_item['b'].id,
                    max_item['ratio']
                ))
                # remove base words
                t1_set = set(max_item['a_title'])
                t2_set = set(max_item['b_title'])

                title1 = ' '.join(max_item['a_title'])
                title2 = ' '.join(max_item['b_title'])

                res_set = self.base_words.intersection(t2_set).intersection(t1_set)
                if len(res_set):
                    for duplicate in res_set:
                        title1 = re.sub(re.escape(duplicate), '', title1, re.U)
                        title2 = re.sub(re.escape(duplicate), '', title2, re.U)

                    ratio = difflib.SequenceMatcher(None, title1, title2).ratio()
                    log.info('Refine: %s - %s - %s' % (title1, title2, ratio))


