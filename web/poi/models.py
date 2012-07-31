# coding=utf-8
from django.contrib.gis.geos import *
from django.contrib.gis.db import models
from django.contrib.gis.measure import D
from django.conf import settings
from django.core.urlresolvers import reverse
from person.models import Person
from ostrovok_common.storages import CDNImageStorage
from ostrovok_common.utils.thumbs import cdn_thumbnail

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
        return self.get_query_set().select_related('placephoto').distance(point).order_by('distance') #filter(position__distance_lt=(point, D(m=self.DEFAULT_RADIUS)))

    def popular(self):
        return self.get_query_set().filter(placephoto__isnull=False).distinct()[:10]



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
    review = models.ForeignKey('Review', blank=True, null=True, verbose_name=u"Обзоры")

    # TODO: add fields
    # geobase_region = ...
    address = models.CharField(max_length=255)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)
    rate = models.DecimalField(default=1, max_digits=2, decimal_places=1)

    objects = PlaceManager()

    @property
    def url(self):
        return reverse('place', kwargs={'pk' : self.id})


    def get_checkins(self):
        return Checkin.objects.filter(place=self).order_by('create_date')[:20]


def __unicode__(self):
        return '"%s" [%s]' % (self.title, self.position.geojson)

class Review(models.Model):
    pass

class PlacePhoto(models.Model):
    place = models.ForeignKey(Place)
    external_id = models.CharField(blank=True, null=True, max_length=255)
    title =  models.TextField(blank=True, null=True, verbose_name=u"Название фото от провайдера")
    url = models.CharField(blank=True, null=True, max_length=512, verbose_name=u"URL фото")
    provider = models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Провайдер")
    is_deleted = models.BooleanField()


class CheckinManager(models.Manager):
    def create_checkin(self, person, place, comment, rate, photo_file):
        from feed.models import FeedItem
        proto = {
            'place' : place,
            'person' : person,
            'comment' : comment,
            'rate' : rate,
            }
        checkin = Checkin(**proto)
        checkin.save()
        c_photo = CheckinPhoto()
        c_photo.checkin = checkin
        c_photo.photo.save(photo_file.name, photo_file)
        c_photo.save()
        # create feed post
        FeedItem.objects.create_checkin_post(checkin)
        return checkin


class Checkin(models.Model):
    place = models.ForeignKey('Place')
    person = models.ForeignKey(Person)
    comment = models.TextField()
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)
    rate = models.PositiveIntegerField(default=1)
    objects = CheckinManager()

    def save(self, *args, **kwargs):
        if self.rate > 5:
            self.rate = 5
        if self.rate < 1:
            self.rate = 1
        super(Checkin, self).save(*args, **kwargs)

    def __unicode__(self):
        return '"%s" [%s]' % (self.person.email, self.place.title)

    def get_feed_proto(self):
        proto = {
            'id' : self.id,
            'person' : self.person.id,
            'create_date' : self.create_date.strftime("%Y-%m-%d %H:%M:%S %z"),
            'rate': self.rate,
            'comment' : self.comment,
            'place': self.place.id,
            'photos': [ { 'title' : photo.title, 'url' : photo.photo.url.replace('orig', settings.CHECKIN_IMAGE_FORMAT_650) } for photo in self.checkinphoto_set.all() ]
        }
        return proto

class CheckinPhoto(models.Model):
    checkin = models.ForeignKey(Checkin)
    title =  models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Название фото от провайдера")
    photo = models.ImageField(
        db_index=True, upload_to=settings.CHECKIN_IMAGE_PATH, max_length=2048,
        storage=CDNImageStorage(formats=settings.CHEKIN_IMAGE_FORMATS, path=settings.CHECKIN_IMAGE_PATH),
        verbose_name=u"Фото пользователя"
    )
    provider = models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Провайдер")
