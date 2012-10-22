# coding=utf-8
from xact import xact
from django.contrib.auth.models import User
from django.contrib.gis.geos import *
from django.contrib.gis.db import models
from django.contrib.gis.measure import D
from django.db.models import Avg, Q

from django.conf import settings
from django.core.urlresolvers import reverse
from person.models import Person
from ostrovok_common.storages import CDNImageStorage
from ostrovok_common.utils.thumbs import cdn_thumbnail

import random

from logging import getLogger

log = getLogger('web.poi.models')

class PlaceManager(models.GeoManager):
    DEFAULT_RADIUS=500

    def _provider_lazy_download(self, lat, lng):
        from poi.provider import get_poi_client
        client = get_poi_client('foursquare')
        result = client.search(lat, lng)
        return client.store(result)

    def search(self, lat, lng, person=None):
        provider_places = self._provider_lazy_download(lat, lng)
        point = fromstr('POINT(%s %s)' % (lng, lat))

        filterStatus = Q(moderated_status=Place.MODERATED_GOOD)
        if person:
            filterStatus |= Q(moderated_status=Place.MODERATED_NONE, creator_id=person.id)

        qs = self.get_query_set().select_related('placephoto').distance(point). \
            filter(position__distance_lt=(point, D(m=self.DEFAULT_RADIUS))). \
            filter(filterStatus). \
            order_by('distance')

        if qs.count() == 0:
            for p_place in provider_places:
                if p_place.checkins > 5:
                    p_place.merge_with_place()

            qs = self.get_query_set().select_related('placephoto').distance(point).exclude(moderated_status=Place.MODERATED_BAD).order_by('distance')
        return  qs


    def popular(self):
        other = list(self.get_query_set().select_related('checkin').filter(moderated_status=Place.MODERATED_GOOD, checkin__isnull=False).distinct()[:10])
        places = other
        return random.sample(places, min(10, len(places)))


    def create(self, title, lat, lng, type, address=None, creator=None, phone=None):
        proto = {
            'title' : title,
            'position' : 'POINT(%s %s)' % (lng, lat),
            'type' : type,
            'address' : address,
            'phone' : phone,
        }

        # check if place is already created
        point = fromstr('POINT(%s %s)' % (lng, lat))
        qs  =self.get_query_set().filter(position__distance_lt=(point, D(m=10)), title=title)
        if qs.count() > 0:
            return qs[0]

        if creator:
            proto['creator'] = creator
        place = Place(**proto)
        place.save()

        return place

class Place(models.Model):

    MODERATED_NONE = 0
    MODERATED_GOOD = 1
    MODERATED_BAD = 2

    MODERATED_CHOICES = (
        (MODERATED_NONE, ''),
        (MODERATED_GOOD, 'Одобрено'),
        (MODERATED_BAD, 'Отклонено'),
    )

    TYPE_UNKNOW = 0
    TYPE_HOTEL = 1
    TYPE_RESTAURANT = 2
    TYPE_GREAT_OUTDOOR = 3
    TYPE_ENTERTAINMENT = 4

    TYPE_CHOICES = (
        (TYPE_HOTEL, 'Отель'),
        (TYPE_RESTAURANT, 'Ресторан'),
        (TYPE_GREAT_OUTDOOR, 'Достопремечательность'),
        (TYPE_ENTERTAINMENT, 'Развлечения'),
        (TYPE_UNKNOW, 'Не определено'),
    )

    title = models.CharField(blank=False, null=False, max_length=255, verbose_name=u"Название места")
    description = models.TextField(blank=True, verbose_name=u"Описание места")
    position = models.PointField(null=False, blank=False, verbose_name=u"Координаты места")
    type = models.PositiveIntegerField(max_length=255, choices=TYPE_CHOICES, default=TYPE_UNKNOW, verbose_name=u"Тип места")

    # TODO: change types from provider string to our catalog by property
    type_text = models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Название типам места")

    gis_region_id = models.IntegerField(blank=True, null=True)
    country_name =  models.CharField(blank=True, null=True, max_length=255)
    city_name =  models.CharField(blank=True, null=True, max_length=255)

    address = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=255, blank=True, null=True)

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)
    rate = models.DecimalField(default=1, max_digits=2, decimal_places=1)

    moderated_status = models.IntegerField(default=MODERATED_NONE)
    provider_popularity = models.IntegerField(default=0)

    lock_moderation = models.DateTimeField(blank=True, null=True)
    lock_moderation_user = models.ForeignKey(User, null=True, related_name='+')

    moderated_by = models.ForeignKey(User, null=True, related_name='+')
    moderated_date = models.DateTimeField(blank=True, null=True)

    creator = models.ForeignKey(Person, null=True)

    objects = PlaceManager()

    def __init__(self, *args, **kwargs):
        self._photo_pairs_cache = None
        return super(Place, self).__init__(*args, **kwargs)

    @property
    def url(self):
        return reverse('place', kwargs={'pk' : self.id})

    def update_rate(self):
        avg_rate = Checkin.objects.filter(place=self).aggregate(Avg('rate'))['rate__avg'] or 0
        self.rate = avg_rate
        self.save()

    def get_last_checkin(self):
        checkin = Checkin.objects.filter(place=self).order_by('create_date')[0]
        if checkin:
            return checkin[0]
        else:
            return None

    def get_checkins(self):
        return Checkin.objects.filter(place=self, review__isnull=False).exclude(review='').distinct('person').order_by('person', 'create_date')[:20]

    def get_photos_url(self):
        return [pair[1] for pair in self.get_photos_with_meta()]


    def get_photos_with_meta(self):
        if self._photo_pairs_cache:
            return self._photo_pairs_cache
        placephotos_qs = self.placephoto_set.filter(moderated_status=PlacePhoto.MODERATED_GOOD)
        if placephotos_qs.count() > 0:
            pairs = [(photo.id, photo.url, photo.provider_url) for photo in placephotos_qs[:10]]
        else:
            pairs = []
            for checkin in Checkin.objects.prefetch_related('checkinphoto_set').filter(place=self).order_by('-create_date')[:10]:
                photos = checkin.checkinphoto_set.all()
                if photos.count() > 0:
                    pairs.append((checkin.id + 1000000000, photos[0].url, None))
        self._photo_pairs_cache = pairs
        return pairs


    def sync_gis_region(self):
        from gisclient import region_by_coords
        response = region_by_coords(self.position.y, self.position.x)
        self.gis_region_id = response.get('id')
        self.country_name = response.get('country_name')
        self.city_name = response.get('name')
        self.save()

    @property
    def format_position(self):
        def dot_replace(number):
            number = str(number)
            return number.replace(',', '.')
        return '%s,%s' % (dot_replace(self.position.y), dot_replace(self.position.x))

    @property
    def format_address(self):
        result = ''
        if self.gis_region_id:
            result += '%s, %s' % (self.country_name, self.city_name)
            if self.address:
                result += ', '
        if self.address:
            import re
            address = self.address
            if self.country_name:
                address = re.sub('(, )?' + re.escape(self.country_name), '', address)
            if self.city_name:
                address = re.sub('(, )?' + re.escape(self.city_name) , '', address)
            result += address
        return result

    def get_type_text(self):
        if self.type == Place.TYPE_UNKNOW:
            return self.type_text or ''
        return dict(Place.TYPE_CHOICES)[int(self.type)]

    def __unicode__(self):
        return '"%s" [%s]' % (self.title, self.position.geojson)

    def serialize(self):
        from api.v2.utils import model_to_dict
        return_fields = (
            'id',  'title', 'description', 'address', 'format_address', 'type', 'rate',
            )
        data = model_to_dict(self, return_fields)
        data['city_name'] = self.city_name or ''
        data['country_name'] = self.city_name or ''
        if not data['address']:
            data['address'] = ''
        data['position'] = {
            'lng' : self.position.x,
            'lat' : self.position.y,
            }
        data['photos'] = [ {'url' : pair[1], 'title': '', 'id': pair[0] } for pair in self.get_photos_with_meta() ]
        data['rate'] = int(float(data['rate']))
        data['type_text'] = self.get_type_text()
        return data


class PlacePhoto(models.Model):

    MODERATED_NONE = 0
    MODERATED_GOOD = 1
    MODERATED_BAD = 2

    place = models.ForeignKey(Place)
    external_id = models.CharField(blank=True, null=True, max_length=255)
    title =  models.TextField(blank=True, null=True, verbose_name=u"Название фото от провайдера")
    original_url = models.CharField(blank=True, null=True, max_length=512, verbose_name=u"URL фото")

    file = models.ImageField(
        db_index=True, upload_to=settings.CHECKIN_IMAGE_PATH, max_length=2048,
        storage=CDNImageStorage(formats=settings.CHEKIN_IMAGE_FORMATS, path=settings.CHECKIN_IMAGE_PATH),
        verbose_name=u"Импортированные фотографии", null=True
    )

    provider = models.CharField(blank=True, null=True, max_length=255, verbose_name=u"Провайдер")
    provider_url = models.CharField(blank=True, null=True, max_length=512, verbose_name=u"URL оригинала")
    moderated_status = models.IntegerField(default=MODERATED_NONE)


    @property
    def url(self):
        return self.file.url.replace('orig', settings.CHECKIN_IMAGE_FORMAT_640)


class CheckinError(Exception):
    pass

class CheckinManager(models.Manager):

    @xact
    def create_checkin(self, person, share_platform, place, review, rate, photo_file):
        from feed.models import FeedItem
        from person.models import Person

        if person.status not in [Person.PERSON_STATUS_ACTIVE, Person.PERSON_STATUS_CAN_ASK_INVITATION]:
            raise CheckinError('person has inappropriate status')

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

        # post to VK wall
        for social_person in person.get_social_profiles():
            if social_person.provider not in share_platform:
                continue

            from person.social import provider
            client = provider(social_person.provider)
            try:
                message=u'Посетил ' + place.title
                if review:
                    message += ' - ' + review

                client.wall_post(social_person=social_person,
                    message = message,
                    photo_url=checkin.photo_url,
                    link_url='http://ostronaut.com/',
                    lat=place.position.y,
                    lng=place.position.x,
                )
            except Exception as e:
                log.exception(e)

        # link checkin to feed post
        checkin.feed_item_id = feed_item.id
        checkin.save()
        place.update_rate()

        if person.status == Person.PERSON_STATUS_CAN_ASK_INVITATION:
            person.status = person.status_steps.get_next_state()
            person.save()

        person.update_checkins_count()

        return checkin

    def get_last_person_checkins(self, person, count=10):
        return self.get_query_set().select_related('place').filter(person=person).order_by('-create_date')[:count]

    def get_last_person_checkin(self, person):
        checkins = self.get_last_person_checkins(person, 1)
        if len(checkins) > 0:
            return checkins[0]

    def get_person_checkin_count(self, person):
        return self.get_query_set().filter(person=person).count()

class Checkin(models.Model):
    place = models.ForeignKey('Place')
    person = models.ForeignKey(Person)
    review = models.TextField(null=True, blank=True)
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
            'photos': [ { 'id': photo.id, 'title' : photo.title, 'url' : photo.url } for photo in self.checkinphoto_set.all() ]
        }
        return proto

    @property
    def photo_url(self):
        return self.checkinphoto_set.all()[0].url

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

    @property
    def url(self):
        return self.photo.url.replace('orig', settings.CHECKIN_IMAGE_FORMAT_640)
