# coding=utf-8
from django.contrib.gis.db import models
from poi.provider.models import BaseProviderPlaceModel

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
