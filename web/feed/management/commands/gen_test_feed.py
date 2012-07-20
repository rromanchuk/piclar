import urllib
from django.core.management.base import BaseCommand, CommandError

from person.models import Person
from place.models import Place, Checkin


class Command(BaseCommand):

    def handle(self, *args, **options):
        person = Person.objects.get(args[0])
        places = Place.objects.popular()[:10]
        for place in places:
            url = place.placephoto_set.all()[0].url
            photo = None
            Checkin.objects.create_checkin(person, place, 'test checkin', photo)

