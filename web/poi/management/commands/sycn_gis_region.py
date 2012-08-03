from django.core.management.base import BaseCommand, CommandError
from django.conf import settings
from poi.models import Place
from gis.models import Region
class Command(BaseCommand):

    def handle(self, *args, **options):
        for place in Place.objects.filter(gis_region__isnull=True):
            Region.active.filter(type='City', cet)
