# coding=utf-8
from xact import xact
from random import uniform
import json
import urllib
import uuid

from django.db import models
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.conf import settings
from django.core.files.base import ContentFile

from django.core.urlresolvers import reverse

from django.utils.http import int_to_base36, base36_to_int
from django.conf import settings

from ostrovok_common.storages import CDNImageStorage


from exceptions import *
from poi.provider import get_poi_client
from mail import send_mail_to_person

import logging
log = logging.getLogger('web.person.models')

class PersonManager(models.Manager):

    def _load_friends(self, person):
        # TODO: remove provider filter after add another social net
        sp_list = SocialPerson.objects.filter(person=person, provider=SocialPerson.PROVIDER_VKONTAKTE)
        if sp_list.count() == 0:
            return
        for sp in sp_list:
            sp.load_friends()


    def _try_already_registred(self, **kwarg):
        user = authenticate(**kwarg)
        if user is not None and user.is_active:
            try:
                # check if user bound to Person
                exists_person = user.person
                # hack for correct auth backend works
                exists_person.user = user
                raise AlreadyRegistered(exists_person)
            except Person.DoesNotExist:
                # user is not bound - try login by "system" user
                log.error('Trying sign in by User[%s, %s] does not has appropriate Person' % (exists_user.id, email))
                raise RegistrationFail()
                # user has bound Person

    @xact
    def register_simple(self, firstname, lastname, email, password=None, **kwargs):
        if password:
            self._try_already_registred(username=email, password=password)

        try:
            exists_user = User.objects.get(username=email)
            log.error('Trying sign in by User[%s, %s] does not has appropriate Person' % (exists_user.id, email))
            raise RegistrationFail()
        except User.DoesNotExist:
            pass

        user = User()
        user.username = email
        user.first_name = firstname
        user.last_name = lastname

        if not password:
            # TODO: autogenerated password, send email with it
            password = str(int(uniform(1, 1000000)))

        user.set_password(password)
        user.save()

        user = authenticate(username=email, password=password)

        person = Person()
        person.firstname = firstname
        person.lastname = lastname
        person.email = email
        person.user = user
        person.reset_token()
        person.save()


        person.email_notify(Person.EMAIL_TYPE_WELCOME)

        return person

    @xact
    def register_provider(self, provider, access_token, user_id, email=None, **kwargs):
        self._try_already_registred(access_token=access_token, user_id=user_id)
        sp = provider.fetch_user(access_token, user_id)

        if not sp:
            raise RegistrationFail()

        # TODO: remove after make decision
        email = 'test%d@vkontakte.com' % uniform(1, 10000)
        person = self.register_simple(
            sp.firstname,
            sp.lastname,
            email
        )
        sp.person = person
        sp.save()
        # download photo
        photo_field = ('photo_big', 'photo_medium', 'photo')
        photo_url = None
        for field in photo_field:
            fetched_person = json.loads(sp.data)
            if field in fetched_person:
                photo_url = fetched_person[field]
                break

        if photo_url:
            #try:
            uf = urllib.urlopen(photo_url)
            content = uf.read()
            uf.close()

            ext = photo_url.split('.').pop()
            person.photo.save('%d.%s' % (person.id, ext), ContentFile(content))
            person.save()
            #except E:
        else:
            log.info('photo for person %s not loaded' % person)
        self._load_friends(person)
        return person

    def friends_of_user(self, user):
        friends = []
        for edge in PersonEdge.objects.select_related().filter(person_1=user):
            friends.append(edge.person_2)
        for edge in PersonEdge.objects.select_related().filter(person_2=user):
            friends.append(edge.person_1)
        return friends


# TODO: move registration methods to manager
class Person(models.Model):
    EMAIL_TYPE_WELCOME = 'welcome'
    EMAIL_TYPE_EMAILCHANGE = 'email_changed'
    EMAIL_TYPE_NEW_FRIEND = 'new_friend'

    user = models.OneToOneField(User)
    firstname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Имя")
    lastname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Фамилия")
    email = models.EmailField(verbose_name=u"Email")
    is_email_verified = models.BooleanField(default=False)
    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)
    token = models.CharField(max_length=32)


    photo = models.ImageField(
        db_index=True, upload_to=settings.PERSON_IMAGE_PATH, max_length=2048,
        storage=CDNImageStorage(formats=settings.PERSON_IMAGE_FORMATS, path=settings.PERSON_IMAGE_PATH),
        verbose_name=u"Фото пользователя"
    )

    objects = PersonManager()

    def __unicode__(self):
        return '%s %s [%s]' % (self.firstname, self.lastname, self.email)

    @property
    def photo_url(self):
        if not self.photo:
            return ''
        return "%s%s" % (settings.MEDIA_URL, self.photo)

    @property
    def friends(self):
        return Person.objects.friends_of_user(self)

    @property
    def friends_ids(self):
        return [ person.id for person in self.friends ]

    @property
    def full_name(self):
        return '%s %s' % (self.lastname, self.firstname)
    @property
    def email_verify_token(self):
        return int_to_base36(123123123123123123)

    @property
    def url(self):
        return reverse('person-profile', kwargs={'pk' : self.id})

    @property
    def social_profile_urls(self):
        result = {}
        for profile in self.socialperson_set.all():
            if profile.provider not in result:
                result[profile.provider] = []
            result[profile.provider].append(profile.url)
        return result

    def get_profile_data(self):
        return {
            'id' : self.id,
            'firstname' : self.firstname,
            'lastname' : self.lastname,
            'fullname' : self.full_name,
            'photo': self.photo_url,
            'profile': self.url,
        }

    def reset_token(self, save=False):
        self.token = uuid.uuid4().get_hex()
        if save:
            self.save()

    def change_password(self, password):
        self.user.set_password(password)
        self.reset_token()
        self.save()


    def change_profile(self, firstname, lastname, email, password):
        self.firstname = firstname
        self.lastname = lastname
        if email != self.email:
            oldemail = self.email
            self.email = email
            self.is_email_verified = False
            self.email_notify(self.EMAIL_TYPE_EMAILCHANGE, oldemail=oldemail)
        self.change_password(password)
        self.save()

    def email_notify(self, type, **kwargs):
        send_mail_to_person(self, type, kwargs)


    def is_friend_of(self, user):
        friends = self.friends
        if user in friends:
            return True
        else:
            return False

    def add_friend(self, friend):
        edge = PersonEdge()
        edge.person_1 = self
        edge.person_2 = friend
        edge.save()
        self.email_notify(self.EMAIL_TYPE_NEW_FRIEND, friend=friend)
        return edge



class PersonEdge(models.Model):
    person_1 = models.ForeignKey('Person', related_name='person_1')
    person_2 = models.ForeignKey('Person', related_name='person_2')

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

class SocialPerson(models.Model):
    PROVIDER_VKONTAKTE = 'vkontakte'
    PROVIDER_CHOICES = (
        (PROVIDER_VKONTAKTE, 'ВКонтакте'),
    )

    person = models.ForeignKey(Person, null=True)
    firstname = models.CharField(null=False, blank=False, max_length=255)
    lastname = models.CharField(null=False, blank=False, max_length=255)
    birthday = models.DateTimeField(null=True, blank=True)

    provider = models.CharField(choices=PROVIDER_CHOICES, max_length=255)
    external_id = models.IntegerField()
    token = models.CharField(choices=PROVIDER_CHOICES, max_length=255)
    # TODO: change it to JSONField from ostrovok-common and remove loads/dumps from code
    data = models.TextField(blank=True)

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("provider", "external_id")

    @property
    def url(self):
        # TODO: remove this hardcode to column in model
        if self.provider == self.PROVIDER_VKONTAKTE:
            return 'http://vk.com/id%s' % self.external_id
        return ''

    def __unicode__(self):
        return '[%s] %s %s %s' % (self.provider, self.external_id, self.firstname, self.lastname)

    def get_client(self):
        return get_poi_client(self.provider)

    def add_social_friend(self, friend):
        s_edge = SocialPersonEdge()
        s_edge.person_1 = self
        s_edge.person_2 = friend
        s_edge.save()
        return s_edge

    def load_friends(self):
        client = self.get_client()
        friends = client.fetch_friends(social_person=self)
        for friend in friends:
            friend.save()


            # create social edge
            s_edge = self.add_social_friend(friend)

            # create edge
            if friend.person:
                edge = self.person.add_friend(friend.person)
                s_edge.edge = edge
                s_edge.save()


class SocialPersonEdge(models.Model):
    edge = models.OneToOneField(PersonEdge, null=True)
    person_1 = models.ForeignKey('SocialPerson', related_name='person_1')
    person_2 = models.ForeignKey('SocialPerson', related_name='person_2')

    create_date = models.DateTimeField(auto_now_add=True)

