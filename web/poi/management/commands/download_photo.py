import urllib

from django.core.management.base import BaseCommand, CommandError
from poi.models import Place, PlacePhoto
from poi.merge import TextMerge
from poi.provider import get_poi_client

import json


class Command(BaseCommand):
    URL = 'http://www.panoramio.com/map/get_panoramas.php?set=full&minx=%s&miny=%s&maxx=%s&maxy=%s&size=medium&from=0&to=100&order=popularity'
    STEP = 0.0005

    def __init__(self, *args, **kwargs):
        self.merger = TextMerge(limit=0.1)
        super(Command, self).__init__(*args, **kwargs)

    def panaramio(self, place):
        x = place.position.get_x()
        y = place.position.get_y()
        url = self.URL % (x, y, x + self.STEP, y + self.STEP)
        ufp = urllib.urlopen(url)
        content = ufp.read()
        data = json.loads(content)
        for photo in data['photos']:
            print photo['photo_title'], photo['photo_file_url']
        print "\n"

    def flickr(self, place):
        url = "http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=a38eabeae601553c1168eb3fa4aa6872&lat=%s&lon=%s&radius=0.05&min_taken_date=1970-01-01 00:00:00&format=json&nojsoncallback=1"
        x = place.position.get_x()
        y = place.position.get_y()
        url = url % (y, x)
        ufp = urllib.urlopen(url)
        content = ufp.read()
        data = json.loads(content)
        titles = map(lambda x: x['title'], data['photos']['photo'])
        self.merger.merge(place.title, titles)
        print "\n"


    def foursquare(self, place):
        client = get_poi_client('foursquare')
        f_place = place.foursquareplace_set.all()
        if not f_place:
            return
        f_place = f_place[0]
        response = client.get_photos(f_place)
        print place.title
        if response['photos']['count']:
            for photo in response['photos']['items']:
                url = '%s%s%s' % (photo['prefix'], 'original', photo['suffix'])
                photo = PlacePhoto()
                photo.place = place
                photo.title = ''
                photo.url = url
                photo.provider = client.PROVIDER
                photo.save()


    def handle(self, *args, **options):
        for place in Place.objects.all():
            #self.panaramio(place)
            self.foursquare(place)