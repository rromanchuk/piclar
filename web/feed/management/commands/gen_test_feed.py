import urllib
import random
from django.core.files.base import ContentFile
from django.core.management.base import BaseCommand, CommandError

from person.models import Person
from poi.models import Place, Checkin
from random import randint

from xact import xact


class Command(BaseCommand):

    @xact
    def handle(self, *args, **options):
        person = Person.objects.get(id=args[0])
        places = list(Place.objects.filter(type=0)[:5])
        places += list(Place.objects.filter(type=1)[:5])
        for place in places:
            photos = place.placephoto_set.all()
            photo_cnt = photos.count()
            if photo_cnt == 0:
                continue
            idx = random.randint(0, photo_cnt-1)
            url = photos[idx].url
            photo = urllib.urlopen(url).read()
            photo_file = ContentFile(photo)
            photo_file.name = 'feed.jpg'
            Checkin.objects.create_checkin(person, place, 'test checkin', randint(1,5), photo_file)

