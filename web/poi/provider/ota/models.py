# coding=utf-8
from django.contrib.gis.db import models
from poi.models import Place, PlacePhoto
from poi.provider.models import BaseProviderPlaceModel
from poi.provider.models import PROVIDER_PLACE_STATUS_MERGED, PROVIDER_PLACE_STATUS_SKIPPED, PROVIDER_PLACE_STATUS_WAITING


class OtaPlace(BaseProviderPlaceModel):
    description = models.TextField(blank=True, null=True, verbose_name=u"Описание места")

    address = models.CharField(max_length=255, null=True)
    photo = models.CharField(max_length=255, null=True)
    url = models.CharField(max_length=255, null=True)

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
                'type' : Place.TYPE_HOTEL,
                #'type_text' : self.type,
                }
            place = Place(**place_proto)
            place.save()


        self.status = PROVIDER_PLACE_STATUS_MERGED
        self.mapped_place = place
        self.save()
        return place