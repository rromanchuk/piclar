# coding=utf-8
from django.conf import settings
from pymorphy import get_morph

import re
import logging
import difflib
log = logging.getLogger('web.poi.merge')

class TextMerge(object):
    RESULT_NO_MATCH = 'no_match'
    RESULT_MATCH = 'match'

    def __init__(self, limit=0.6):
        self.limit = limit
        self.base_words = set()
        for line in file('basewords.txt', 'r'):
            self.base_words.add(line.strip().decode('utf-8'))
        self.morph = get_morph(settings.DICTIONARY_PATH)

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

    def merge(self, text, variants):
        # experiment with altergeo to fsq matching
        to_compare = []
        for variant in variants:
            title1 = self._normalize(text, list)
            title2 = self._normalize(variant, list)
            ratio = difflib.SequenceMatcher(None, title1, title2).ratio()
            to_compare.append({
                'a' : text,
                'a_title': title1,
                'b' : variant,
                'b_title': title2,
                'ratio' : ratio,
            })

        if len(to_compare) == 0:
            log.info('New object [%s]' % (text))
            return (self.RESULT_NO_MATCH, text)

        max_item = max(to_compare, key=lambda x: x['ratio'])
        if max_item['ratio'] > self.limit:
            log.info('Good: %s - %s - %s' % (
                max_item['a'],
                max_item['b'],
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
        else:
            log.info('Bad: %s - %s - %s' % (
                max_item['a'],
                max_item['b'],
                max_item['ratio']
                ))


