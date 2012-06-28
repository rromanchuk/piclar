# coding=utf-8
from django.contrib.gis.db import models
from poi.models import Photo
class AltergeoPlace(models.Model):
    external_id = models.IntegerField()
    external_data = models.TextField()

    title = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Название места")
    description = models.TextField(blank=True, null=True, verbose_name=u"Описание места")
    position = models.PointField(null=False, blank=False, verbose_name=u"Координаты места")

    type = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Тип места")
    photo = models.ForeignKey(Photo, blank=True, null=True, verbose_name=u"Фотографии")

    city = models.CharField(max_length=255, null=True)
    country = models.CharField(max_length=255, null=True)
    address = models.CharField(max_length=255, null=True)

    create_date = models.DateTimeField(auto_now_add=True)
