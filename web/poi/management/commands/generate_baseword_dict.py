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
                if not word:
                    continue
                word = morph.normalize(word).pop()
                if word not in base_words:
                    base_words[word] = 1
            break