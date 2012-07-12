from django.core.management.base import BaseCommand, CommandError

from poi.provider import get_poi_client

import time

def pair_range(start, stop, step=1):
    x = start
    while x < stop:
        yield (x, min(x+step, stop))
        x += step


class Command(BaseCommand):

    FETCH_BOX = {
        'upper_left_lat' : 55.769718,
        'upper_left_lng' : 37.596245,
        'lower_right_lat' : 55.736293,
        'lower_right_lng' : 37.646713,
    }
    STEP = 0.01

    def fetch(self, client, sleep, step):
        for x in pair_range(self.FETCH_BOX['lower_right_lat'], self.FETCH_BOX['upper_left_lat'], step):
            for y in pair_range(self.FETCH_BOX['upper_left_lng'], self.FETCH_BOX['lower_right_lng'], step):
                box = {
                    'upper_left_lat' : x[0],
                    'lower_right_lat' : x[1],
                    'lower_right_lng' : y[0],
                    'upper_left_lng' : y[1],
                    }
                result = client.download(box)
                client.store(result)
                time.sleep(6)


    def handle(self, *args, **options):
        fsq = get_poi_client('foursquare')
        #alter = AlterClient()
        #self.fetch(alter, 6, self.STEP)
        self.fetch(fsq, 1, 0.001)

