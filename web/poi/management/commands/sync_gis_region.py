from django.core.management.base import BaseCommand, CommandError
from poi.models import Place

class Command(BaseCommand):
    def handle(self, *args, **options):
        for place in Place.objects.filter(gis_region_id__isnull=True):
            place.sync_gis_region()

