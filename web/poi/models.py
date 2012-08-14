# coding=utf-8
from xact import xact
from django.contrib.gis.geos import *
from django.contrib.gis.db import models
from django.contrib.gis.measure import D
from django.conf import settings
from django.core.urlresolvers import reverse
from person.models import Person
from ostrovok_common.storages import CDNImageStorage
from ostrovok_common.utils.thumbs import cdn_thumbnail

class PlaceManager(models.GeoManager):
    DEFAULT_RADIUS=500

    def _provider_lazy_download(self, lat, lng):
        from poi.provider import get_poi_client
        client = get_poi_client('foursquare')
        result = client.search(lat, lng)
        return client.store(result)

    def search(self, lat, lng):
        provider_places = self._provider_lazy_download(lat, lng)
        point = fromstr('POINT(%s %s)' % (lng, lat))
        qs = self.get_query_set().select_related('placephoto').distance(point).filter(position__distance_lt=(point, D(m=self.DEFAULT_RADIUS))).order_by('distance')

        if qs.count() == 0:
            for p_place in provider_places:
                if p_place.checkins > 5:
                    p_place.merge_with_place()

            qs = self.get_query_set().select_related('placephoto').distance(point).order_by('distance')

        return  qs


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
    gis_region_id = models.IntegerField(blank=True, null=True)
    country_name =  models.CharField(blank=True, null=True, max_length=255)
    city_name =  models.CharField(blank=True, null=True, max_length=255)

    address = models.CharField(max_length=255)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)
    rate = models.DecimalField(default=1, max_digits=2, decimal_places=1)

    #is_verified = models.BooleanField(default=False)

    objects = PlaceManager()

    @property
    def url(self):
        return reverse('place', kwargs={'pk' : self.id})

    def get_checkins(self):
        return Checkin.objects.filter(place=self).order_by('create_date')[:20]

    def get_photos_url(self):
        return [photo.url for photo in self.placephoto_set.all()[:10]]

    def sync_gis_region(self):
        from gisclient import region_by_coords
        response = region_by_coords(self.position.y, self.position.x)
        self.gis_region_id = response.get('id')
        self.country_name = response.get('country_name')
        self.city_name = response.get('name')
        self.save()

    @property
    def format_address(self):
        result = ''
        if self.gis_region_id:
            result += '%s, %s' % (self.country_name, self.city_name)
            if self.address:
                result += ', '
        if self.address:
            result += self.address
        return result

    def __unicode__(self):
        return '"%s" [%s]' % (self.title, self.position.geojson)

    def serialize(self):
        from api.v2.utils import model_to_dict
        return_fields = (
            'id',  'title', 'description', 'address', 'format_address', 'type', 'type_text'
            )
        data = model_to_dict(self, return_fields)
        data['position'] = {
            'lng' : self.position.x,
            'lat' : self.position.y,
            }
        data['photos'] = [ {'url' : photo.url, 'title': photo.title, 'id': photo.id } for photo in self.placephoto_set.all() ]
        return data

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

    @xact
    def create_checkin(self, person, place, review, rate, photo_file):
        from feed.models import FeedItem
        proto = {
            'place' : place,
            'person' : person,
            'review' : review,
            'rate' : rate,
            }
        checkin = Checkin(**proto)
        checkin.save()
        c_photo = CheckinPhoto()
        c_photo.checkin = checkin
        c_photo.photo.save(photo_file.name, photo_file)
        c_photo.save()
        # create feed post

        feed_item = FeedItem.objects.create_checkin_post(checkin)

        # link checkin to feed post
        checkin.feed_item_id = feed_item.id
        checkin.save()

        return checkin

    def get_last_person_checkin(self, person):
        checkins = self.get_query_set().filter(person=person).order_by('-create_date')
        if len(checkins) > 0:
            return checkins[0]

    def get_person_checkin_count(self, person):
        return self.get_query_set().filter(person=person).count()

class Checkin(models.Model):
    place = models.ForeignKey('Place')
    person = models.ForeignKey(Person)
    review = models.TextField()
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)
    rate = models.PositiveIntegerField(default=1)
    objects = CheckinManager()
    feed_item_id = models.IntegerField(blank=True, null=True)

    def save(self, *args, **kwargs):
        if self.rate > 5:
            self.rate = 5
        if self.rate < 1:
            self.rate = 1
        super(Checkin, self).save(*args, **kwargs)

    def __unicode__(self):
        return '"%s" [%s]' % (self.person.email, self.place.title)

    def get_feed_item_url(self):
        if self.feed_item_id:
            return reverse('feed-item', kwargs={'pk' : self.feed_item_id})
        return None

    def get_feed_proto(self):
        proto = {
            'id' : self.id,
            'person_id' : self.person.id,
            'create_date' : self.create_date.strftime("%Y-%m-%d %H:%M:%S %z"),
            'rate': self.rate,
            'review' : self.review,
            'place_id': self.place.id,
            'photos': [ { 'id': photo.id, 'title' : photo.title, 'url' : photo.photo.url.replace('orig', settings.CHECKIN_IMAGE_FORMAT_650) } for photo in self.checkinphoto_set.all() ]
        }
        return proto

    def serialize(self):
        return self.get_feed_proto()

class CheckinPhoto(models.Model):
    checkin = models.ForeignKey(Checkin)
    title =  models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Название фото от провайдера")
    photo = models.ImageField(
        db_index=True, upload_to=settings.CHECKIN_IMAGE_PATH, max_length=2048,
        storage=CDNImageStorage(formats=settings.CHEKIN_IMAGE_FORMATS, path=settings.CHECKIN_IMAGE_PATH),
        verbose_name=u"Фото пользователя"
    )
    provider = models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Провайдер")
