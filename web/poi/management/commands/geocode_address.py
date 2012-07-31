from django.core.management.base import BaseCommand, CommandError
from django.conf import settings
from poi.models import Place
from geopy import geocoders

from time import sleep
import logging
import urllib
import json
log = logging.getLogger('web.poi.geocode_address')

class Command(BaseCommand):

    def rev_geocode(self, lat, lng):
        url = 'http://geocode-maps.yandex.ru/1.x/?geocode=%s,%s&format=json&kind=house&lang=ru-RU&key=%s' % (lat, lng, settings.YANDEXMAPS_API_KEY)
        print url
        response = urllib.urlopen(url).read()
        return json.loads(response)['response']


    def handle(self, *args, **options):
        qs = Place.objects.filter(address='')
        log.info('Starting geocode addresses for %s places' % qs.count())
        for place in qs:
            #geocoder = geocoders.Google(settings.GMAPS_API_KEY)
            #address, point = geocoder.reverse((place.position.y, place.position.x))

            response =  self.rev_geocode(place.position.x, place.position.y)
            print place.position
            print response['GeoObjectCollection']['featureMember'][0]['GeoObject']['name']
            break
            #log.info('geocoded: %s, %s' % (address, point))
            #place.address = address
            #place.save()
            sleep(0.5)