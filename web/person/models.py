# coding=utf-8
from xact import xact
from random import uniform
import json

from django.db import models
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.conf import settings

from exceptions import *
from poi.provider import get_poi_client


import logging
log = logging.getLogger('web.person.models')

class Person(models.Model):

    user = models.OneToOneField(User)
    firstname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Имя")
    lastname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Фамилия")
    email = models.EmailField(verbose_name=u"Email")

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)


    def __unicode__(self):
        return '%s %s [%s]' % (self.firstname, self.lastname, self.email)

    def reset_password(self, password):
        person.user.set_password(password)
        person.save()

    @staticmethod
    def _try_already_registred(**kwarg):
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


    @staticmethod
    @xact
    def register_simple(firstname, lastname, email, password=None):

        if password:
            Person._try_already_registred(username=email, password=password)

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
        person.save()

        return person

    @staticmethod
    #@xact
    def register_vk(access_token, user_id, email=None, **kwargs):
        Person._try_already_registred(access_token=access_token, user_id=user_id)

        client = get_poi_client('vkontakte')
        fetched_person = client.fetch_user(access_token, user_id)

        if not fetched_person:
            raise RegistrationFail()


        # TODO: remove after make decision
        email = 'test%d@vkontakte.com' % uniform(1, 10000)
        person = Person.register_simple(
            fetched_person['first_name'],
            fetched_person['last_name'],
            email
        )

        social_person = SocialPerson()
        social_person.fill_from_person(person)

        social_person.external_id = fetched_person['uid']
        #social_person.birthday = fetched_person.get('bdate')
        social_person.provider = SocialPerson.PROVIDER_VKONTAKTE
        social_person.token = access_token
        social_person.data = json.dumps(fetched_person)
        social_person.save()

        return person



class PersonEdge(models.Model):
    person_1 = models.OneToOneField('Person', related_name='person_1')
    person_2 = models.OneToOneField('Person', related_name='person_2')

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    social_edge = models.OneToOneField('SocialPersonEdge')

class SocialPerson(models.Model):

    PROVIDER_VKONTAKTE = 'vkontakte'
    PROVIDER_CHOICES = (
        (PROVIDER_VKONTAKTE, 'ВКонтакте'),
    )

    person = models.ForeignKey(Person)
    firstname = models.CharField(null=False, blank=False, max_length=255)
    lastname = models.CharField(null=False, blank=False, max_length=255)
    birthday = models.DateTimeField(null=True, blank=True)

    provider = models.CharField(choices=PROVIDER_CHOICES, max_length=255)
    external_id = models.IntegerField()
    token = models.CharField(choices=PROVIDER_CHOICES, max_length=255)
    data = models.TextField(blank=True)

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("provider", "external_id")

    def __unicode__(self):
        return '[%s] %s %s %s' % (self.provider, self.external_id, self.firstname, self.lastname)

    def fill_from_person(self, person):
        self.person = person
        self.firstname = person.firstname
        self.lastname = person.lastname

class SocialPersonEdge(models.Model):
    person_1 = models.OneToOneField('SocialPerson', related_name='person_1')
    person_2 = models.OneToOneField('SocialPerson', related_name='person_2')

    create_date = models.DateTimeField(auto_now_add=True)
