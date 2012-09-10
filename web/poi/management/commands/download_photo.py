import urllib

from django.core.management.base import BaseCommand, CommandError
from poi.models import Place, PlacePhoto
from poi.merge import TextMerge
from poi.provider import get_poi_client
from ostrovok_common.storages import CDNImageStorageError
import json

from logging import getLogger

log = getLogger('web.poi.download_photo')


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


    def altergeo(self, place):
        a_place = place.altergeoplace_set.all()
        if not a_place:
            return
        client = get_poi_client('altergeo')
        response = client.get_photos(a_place)

    def _save_photo(self, proto):
        try:
            photo = PlacePhoto.objects.get(external_id=proto['external_id'], provider=proto['provider'])
            photo.provider_url = proto.get('provider_url')
            photo.save()
            return
        except PlacePhoto.DoesNotExist:
            pass
        photo = PlacePhoto(**proto)
        if not proto['original_url']:
            return
        try:
            uf = urllib.urlopen(proto['original_url'])
        except IOError as e:
            # skip this photo, will download it later
            log.exception(e)
            return
        url = proto['original_url']
        name = url[url.rfind('/'):]
        from django.core.files.base import ContentFile
        photo_file = ContentFile(uf.read())
        try:
            photo.file.save(name, photo_file)
        except CDNImageStorageError as e:
            log.exception(e)
            return
        photo.save()

    def foursquare(self, place):
        client = get_poi_client('foursquare')
        instgrm = get_poi_client('instagram')

        f_place = place.foursquareplace_set.all()
        if not f_place:
            return
        f_place = f_place[0]
        try:
            response = client.get_photos(f_place)
        except Exception as e:
            log.error(e)
            return

        if response['count']:
            for photo in response['items']:
                url = '%s%s%s' % (photo['prefix'], 'original', photo['suffix'])
                proto = {
                    'external_id': photo['id'],
                    'place' : place,
                    'title' : '',
                    'original_url' : url,
                    'provider': client.PROVIDER
                }
                self._save_photo(proto)

        response = instgrm.get_photos(f_place=f_place)
        for photo in response:
            title = ''
            if photo['caption']:
                title = photo['caption'].get('text')
            proto = {
                'external_id': photo['id'],
                'place' : place,
                'title' : title,
                'provider_url' : photo['link'],
                'original_url' : photo['images']['standard_resolution']['url'],
                'provider': instgrm.PROVIDER
            }
            self._save_photo(proto)
    def ota(self, place):
        ota_place = place.otaplace_set.all()
        if not ota_place:
            return False
        ota_place = ota_place[0]
        proto = {
            'external_id': ota_place.id,
            'place' : place,
            'title' : '',
            'original_url' : ota_place.photo,
            'provider': 'ota'
        }
        self._save_photo(proto)
        return True


    def handle(self, *args, **options):

        qs = Place.objects.all()
        if len(args) and args[0] == 'new':
            qs = qs.filter(placephoto__isnull=True)
        for place in qs:
            if not self.ota(place):
                self.foursquare(place)