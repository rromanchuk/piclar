# coding=utf-8
from django.db import models

class Person(models.Model):
    firstname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Имя пользователя")
    lastname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Фамилия пользователя")

    create_date = models.DateTimeField(auto_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    social_person = models.ForeignKey('SocialPerson')


class PersonEdge(models.Model):
    person_1 = models.OneToOneField('Person')
    person_2 = models.OneToOneField('Person')

    create_date = models.DateTimeField(auto_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    social_edge = models.OneToOneField('SocialPersonEdge')

class SocialPerson(models.Model):

    PROVIDER_VKONTAKTE = 'vkontakte'
    PROVIDER_CHOICES = (
        (PROVIDER_VKONTAKTE, 'ВКонтакте')
    )

    firstname = models.CharField(null=False, blank=False, max_length=255)
    lastname = models.CharField(null=False, blank=False, max_length=255)
    birthday = models.DateTime(blank=True)

    provider = models.CharField(choices=PROVIDER_CHOICES)
    provider_id = models.IntegerField()

    create_date = models.DateTimeField(auto_add=True)
    modified_date = models.DateTimeField(auto_now=True)

class SocialPersonEdge(models.Model):
    person_1 = models.OneToOneField('SocialPerson')
    person_2 = models.OneToOneField('SocialPerson')

    create_date = models.DateTimeField(auto_add=True)
