# coding=utf-8
from django.contrib.gis.db import models


class FoursquarePlace(models.Model):
    external_id = models.CharField(max_length=255, unique=True)
    external_data = models.TextField()

    title = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Название места")
    description = models.TextField(blank=True, null=True, verbose_name=u"Описание места")

    phone = models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Телефон")

    position = models.PointField(null=False, blank=False, verbose_name=u"Координаты места")

    type = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Тип места")

    city = models.CharField(max_length=255, null=True)
    country = models.CharField(max_length=255, null=True)
    address = models.CharField(max_length=255, null=True)
    crossing = models.CharField(max_length=255, null=True)
    checkins = models.IntegerField(default=0)
    users = models.IntegerField(default=0)
    tips = models.IntegerField(default=0)

    create_date = models.DateTimeField(auto_now_add=True)
    objects = models.GeoManager()

    def __unicode__(self):
        return '"%s" [%s]' % (self.title, self.position.geojson)
