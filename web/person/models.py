# coding=utf-8
from django.db import models
from django.contrib.auth.models import User
from xact import xact

class Person(models.Model):

    user = models.OneToOneField(User)
    firstname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Имя")
    lastname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Фамилия")
    email = models.EmailField(verbose_name=u"Email")

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    @xact
    def register_simple(self, firstname, lastname, email, password):
        user = User()
        user.username = email
        user.first_name = firstname
        user.last_name = lastname
        user.set_password(password)
        user.save()

        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.user = user

        self.save()

    social_person = models.ForeignKey('SocialPerson', null=True, blank=True)

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

    firstname = models.CharField(null=False, blank=False, max_length=255)
    lastname = models.CharField(null=False, blank=False, max_length=255)
    birthday = models.DateTimeField(blank=True)

    provider = models.CharField(choices=PROVIDER_CHOICES, max_length=255)
    provider_id = models.IntegerField()

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

class SocialPersonEdge(models.Model):
    person_1 = models.OneToOneField('SocialPerson', related_name='person_1')
    person_2 = models.OneToOneField('SocialPerson', related_name='person_2')

    create_date = models.DateTimeField(auto_now_add=True)
