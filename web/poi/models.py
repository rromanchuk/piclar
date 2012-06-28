# coding=utf-8
from django.contrib.gis.db import models
from person.models import Person
from provider.altergeo.models import *

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
    photo = models.ForeignKey('Photo', blank=True, null=True, verbose_name=u"Фотографии")
    review = models.ForeignKey('Review', blank=True, null=True, verbose_name=u"Обзоры")

    # TODO: add fields
    # geobase_region = ...

    address = models.CharField(max_length=255)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    objects = models.GeoManager()

    def __unicode__(self):
        return '"%s" [%s]' % (self.title, self.position.geojson)

class Review(models.Model):
    pass


class Photo(models.Model):
    pass

class Checkin(models.Model):
    place = models.ForeignKey('Place')
    person = models.ForeignKey(Person)
    photo =  models.ForeignKey('Photo')
    comment = models.TextField()
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)


