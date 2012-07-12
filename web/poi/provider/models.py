# coding=utf-8
from poi.models import Place
from django.contrib.gis.db import models


PROVIDER_PLACE_STATUS_MERGED = 1
PROVIDER_PLACE_STATUS_SKIPPED = 2
PROVIDER_PLACE_STATUS_WAITING = 0

PROVIDER_PLACE_STATUS_CHOICES = (
    ('Не обработано', PROVIDER_PLACE_STATUS_WAITING),
    ('Включено в базу', PROVIDER_PLACE_STATUS_MERGED),
    ('Пропущено', PROVIDER_PLACE_STATUS_SKIPPED),

)

class BaseProviderPlaceModel(models.Model):
    external_id = models.CharField(max_length=255, unique=True)
    external_data = models.TextField()
    mapped_place = models.ForeignKey(Place, null=True)

    title = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Название места")
    position = models.PointField(null=False, blank=False, verbose_name=u"Координаты места")

    status = models.IntegerField(choices=PROVIDER_PLACE_STATUS_CHOICES, default=PROVIDER_PLACE_STATUS_WAITING)

    create_date = models.DateTimeField(auto_now_add=True)
    objects = models.GeoManager()

    class Meta:
        abstract = True