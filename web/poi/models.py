# coding=utf-8
from django.contrib.gis.geos import *
from django.contrib.gis.db import models
from django.contrib.gis.measure import D

from person.models import Person

class PlaceManager(models.GeoManager):
    DEFAULT_RADIUS=700

    def _provider_lazy_download(self, lat, lng):
        from poi.provider import get_poi_client
        client = get_poi_client('foursquare')
        result = client.search(lat, lng)
        client.store(result)

    def search(self, lat, lng):
        self._provider_lazy_download(lat, lng)

        point = fromstr('POINT(%s %s)' % (lng, lat))

        return self.get_query_set().filter(position__distance_lt=(point, D(m=self.DEFAULT_RADIUS)))

class Place(models.Model):

    TYPE_UNKNOW = 0
    TYPE_HOTEL = 1
    TYPE_RESTAURANT = 2

    TYPE_CHOICES = (
        (TYPE_HOTEL, 'Отель'),
        (TYPE_RESTAURANT, 'Ресторан'),
        (TYPE_UNKNOW, 'Точка'),
    )

    title = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Название места")
    description = models.TextField(blank=True, verbose_name=u"Описание места")
    position = models.PointField(null=False, blank=False, verbose_name=u"Координаты места")
    type = models.PositiveIntegerField(max_length=255, choices=TYPE_CHOICES, default=TYPE_UNKNOW, verbose_name=u"Тип места")

    # TODO: change types from provider string to our catalog by property
    type_text = models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Название типам места")
    photo = models.ForeignKey('Photo', blank=True, null=True, verbose_name=u"Фотографии")
    review = models.ForeignKey('Review', blank=True, null=True, verbose_name=u"Обзоры")

    # TODO: add fields
    # geobase_region = ...

    address = models.CharField(max_length=255)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    objects = models.GeoManager()
    places = PlaceManager()

    def __unicode__(self):
        return '"%s" [%s]' % (self.title, self.position.geojson)



class Review(models.Model):
    pass

class Photo(models.Model):
    pass

class Checkin(models.Model):
    place = models.ForeignKey('Place')
    person = models.ForeignKey(Person)
    photo =  models.ForeignKey('Photo', blank=True, null=True)
    comment = models.TextField()
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    def __unicode__(self):
        return '"%s" [%s]' % (str(self.person), self.place.title)


