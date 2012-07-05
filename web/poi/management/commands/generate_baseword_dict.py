# coding=utf8
from django.core.management.base import BaseCommand, CommandError
from poi.provider.foursquare.models import FoursquarePlace

from pymorphy import get_morph
from django.conf import settings
import re


class Command(BaseCommand):
    def handle(self, *args, **options):
        morph = get_morph(settings.DICTIONARY_PATH)
        base_words = {}
        for item in FoursquarePlace.objects.all():
            title = re.sub(u'[^A-Z0-9А-Я]', ' ', item.title.upper(), re.U)
            for word in title.split(' '):
                word = word.strip()
                if len(word) < 3:
                    continue
                word = morph.normalize(word)
                if isinstance(word, set):
                    word = word.pop()
                if word not in base_words:
                    base_words[word] = 1
                else:
                    base_words[word] +=1

        def _cmp(x,y):
            if x[1] < y[1]:
                return 1
            return -1
        top = sorted(base_words.items(), cmp=_cmp)[:100]
        f = file('basewords.txt', 'wb')
        for item in top:
            gram_info = morph.get_graminfo(item[0])
            if gram_info:
                gram_info = gram_info[0]['class']
            else:
                gram_info = ''
            #print u"%s %s %s" % (item[0], item[1], gram_info)
            #print item[0]
            f.write(item[0].encode('utf-8') + '\n')