# coding=utf-8
from django.contrib.gis.db import models
from poi.models import Place
from poi.provider.models import BaseProviderPlaceModel
from poi.provider.models import PROVIDER_PLACE_STATUS_MERGED, PROVIDER_PLACE_STATUS_SKIPPED, PROVIDER_PLACE_STATUS_WAITING


class AltergeoPlace(BaseProviderPlaceModel):

    description = models.TextField(blank=True, null=True, verbose_name=u"Описание места")
    type = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Тип места")
    city = models.CharField(max_length=255, null=True)
    country = models.CharField(max_length=255, null=True)
    address = models.CharField(max_length=255, null=True)
    rating = models.FloatField()
    rating_vote_count = models.IntegerField()
    checkin_count = models.IntegerField()

    def __unicode__(self):
        return '"%s" [%s]' % (self.title, self.position.geojson)

    def merge_with_place(self, place=None):
        if not place:
            place_proto = {
                'title' : self.title,
                'description' : self.description or '',
                'position' : self.position,
                'address' : self.address or '',

                # TODO: map fsq types to our types
                'type' : Place.TYPE_UNKNOW,
                'type_text' : self.type,
                }
            place = Place(**place_proto)
            place.save()

        self.status = PROVIDER_PLACE_STATUS_MERGED
        self.mapped_place = place
        self.save()
        return place