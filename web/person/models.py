# coding=utf-8
from xact import xact
from random import uniform, randint
import json
import urllib
import uuid
from datetime import datetime, date

from django.db import models
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.conf import settings
from django.core.files.base import ContentFile

from django.core.urlresolvers import reverse

from django.utils.http import int_to_base36, base36_to_int
from django.conf import settings

from ostrovok_common.storages import CDNImageStorage
from ostrovok_common.pgarray import fields
from ostrovok_common.models import JSONField

from exceptions import *
from mail import send_mail_to_person

import logging
log = logging.getLogger('web.person.models')

class PersonManager(models.Manager):

    def _load_friends(self, person):
        sp_list = SocialPerson.objects.filter(person=person)
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
                # HACK for correct auth backend works
                exists_person.user = user
                raise AlreadyRegistered(exists_person)
            except Person.DoesNotExist:
                # user is not bound - try login by "system" user
                log.error('Check already registred: trying sign in by User[%s, %s] does not has appropriate Person' % (exists_user.id, email))
                raise RegistrationFail()
                # user has bound Person


    def register_simple(self, firstname, lastname, email, password=None, fake_email=False, **kwargs):
        if password:
            self._try_already_registred(username=email, password=password)
        with xact():
            try:
                exists_user = User.objects.get(username=email)
                log.error('Trying sign in by existent User[%s, %s]' % (exists_user.id, email))
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
            person.followers = []
            person.following = []
            person.email = email
            person.user = user
            person.status = person.status_steps.get_initial_state()
            person.reset_token()

            if not fake_email:
                person.status = person.status_steps.get_next_state()
                user.email = email
                user.save()

            person.save()

            if person.status == Person.PERSON_STATUS_ACTIVE:
                person.email_notify(Person.EMAIL_TYPE_WELCOME)

        return person

    def register_provider(self, provider, access_token, user_id, email=None, **kwargs):
        response = provider.fetch_user(access_token, user_id)
        sp = response.get_social_person()
        if not sp:
            raise RegistrationFail()

        self._try_already_registred(provider=provider, access_token=access_token, user_id=user_id)

        if sp.person:
            log.error('social person [%s] have linked profile [%s] but it not authorized' % (sp, sp.person))
            raise RegistrationFail()

        if not email and 'email' in response.raw_response:
            # if person with same email is already exist - skip prefilling email from social
            # and ask it in WAIT_FOR_EMAIL step

            # change it after refactoring: move social registration to "link social profile"
            if Person.objects.filter(email=response.raw_response['email']).count() == 0:
                email = response.raw_response['email']

        with xact():
            # add person with fake email if he comes from vkontakte
            fake_email = False
            if not email:
                email = 'fake-%s@%s.com' % (sp.external_id, sp.provider)
                fake_email = True

            person = self.register_simple(
                sp.firstname,
                sp.lastname,
                email,
                fake_email=fake_email
            )
            sp.person = person
            sp.save()

            person.location = sp.location
            person.sex = sp.sex

            # download photo
            if sp.photo_url:
                try:
                    uf = urllib.urlopen(sp.photo_url)
                    content = uf.read()
                    uf.close()

                    ext = sp.photo_url.split('.').pop()
                    person.photo.save('%d.%s' % (person.id, ext), ContentFile(content))
                    person.save()
                except Exception as e:
                    log.exception(e)
            else:
                log.info('photo for person %s not loaded' % person)
            self._load_friends(person)
        return person

    def get_followers(self, person):
        return self.get_query_set().prefetch_related('socialperson_set').filter(id__in=person.followers)

    def get_following(self, person):
        return self.get_query_set().prefetch_related('socialperson_set').filter(id__in=person.following)


# TODO: move registration methods to manager
class Person(models.Model):
    EMAIL_TYPE_WELCOME = 'welcome'
    EMAIL_TYPE_EMAILCHANGE = 'email_changed'
    EMAIL_TYPE_NEW_FRIEND = 'new_friend'

    PERSON_SEX_MALE = 1
    PERSON_SEX_FEMALE = 2
    PERSON_SEX_UNDEFINED = 0

    PERSON_SEX_CHOICES = (
        (PERSON_SEX_UNDEFINED, 'Не определен' ),
        (PERSON_SEX_MALE,'Мужской', ),
        (PERSON_SEX_FEMALE,'Женский',),
    )


    PERSON_STATUS_ACTIVE = 1
    PERSON_STATUS_WAIT_FOR_EMAIL = 2

    PERSON_STATUS_CAN_ASK_INVITATION = 10
    PEREON_STATUS_WAIT_FOR_CONFIRM_INVITATION = 11

    PERSON_STATUS_BLOCKED = 20

    PERSON_STATUS_CHOICES = (
        (PERSON_STATUS_ACTIVE, 'Активный',),
        (PERSON_STATUS_WAIT_FOR_EMAIL, 'Не заполнен email',),
        (PERSON_STATUS_CAN_ASK_INVITATION, 'Должен запросить приглашение',),
        (PEREON_STATUS_WAIT_FOR_CONFIRM_INVITATION, 'Ожидает подтверждения на приглашение',),

        )

    user = models.OneToOneField(User)
    firstname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Имя")
    lastname = models.CharField(null=False, blank=False, max_length=255, verbose_name=u"Фамилия")
    email = models.EmailField(verbose_name=u"Email", null=True, blank=True)

    birthday = models.DateField(null=True, blank=True)
    sex = models.IntegerField(default=PERSON_SEX_UNDEFINED, choices=PERSON_SEX_CHOICES)
    location = models.CharField(null=True, blank=True, max_length=255)
    status = models.IntegerField(default=PERSON_STATUS_WAIT_FOR_EMAIL, choices=PERSON_STATUS_CHOICES)

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    is_email_verified = models.BooleanField(default=False)
    token = models.CharField(max_length=32)

    moderated_by = models.ForeignKey('Person', null=True, blank=True)
    moderated_date = models.DateTimeField(blank=True, null=True)

    following = fields.IntArrayField(editable=False)
    followers = fields.IntArrayField(editable=False)

    checkins_count = models.IntegerField(default=0)

    photo = models.ImageField(
        db_index=True, upload_to=settings.PERSON_IMAGE_PATH, max_length=2048,
        storage=CDNImageStorage(formats=settings.PERSON_IMAGE_FORMATS, path=settings.PERSON_IMAGE_PATH),
        verbose_name=u"Фото пользователя"
    )

    settings = models.OneToOneField('PersonSetting', null=True)

    objects = PersonManager()

    def __unicode__(self):
        return '%s %s [%s]' % (self.firstname, self.lastname, self.email)

    def is_active(self):
        return self.status == Person.PERSON_STATUS_ACTIVE

    @staticmethod
    def only_active(field_name=''):
        from django.db.models import Q
        param = {}
        key = 'status'
        if field_name:
            key = field_name + '__' + key
        param[key] = Person.PERSON_STATUS_ACTIVE
        return Q(**param)

    @property
    def photo_url(self):
        #if not self.photo:
        #    return ''
        #return "%s%s" % (settings.MEDIA_URL, self.photo)
        try:
            return self.photo.url.replace('orig', settings.PERSON_IMAGE_FORMAT_120)
        except ValueError:
            return settings.DEFAULT_USERPIC_URL

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
            'full_name' : self.full_name,
            'photo': self.photo_url,
            'profile': self.url,
            'sex' : self.sex,
        }

    def reset_token(self, save=False):
        self.token = uuid.uuid4().get_hex()
        if save:
            self.save()

    def change_password(self, password):
        self.user.set_password(password)
        self.user.save()
        self.reset_token()
        self.save()

    @xact
    def change_email(self, email):
        if email and (email != self.email or self.status != Person.PERSON_STATUS_ACTIVE):
            self.user.username = email
            self.user.email = email
            self.user.save()

            oldemail = self.email
            self.email = email
            self.is_email_verified = False
            if self.status == Person.PERSON_STATUS_WAIT_FOR_EMAIL:
                self.status = self.status_steps.get_next_state();
                self.email_notify(self.EMAIL_TYPE_WELCOME)
            else:
                self.email_notify(self.EMAIL_TYPE_EMAILCHANGE, oldemail=oldemail)
            self.save()

    @xact
    def change_credentials(self, email, old_password, new_password=None):
        user = authenticate(username=self.email, password=old_password)
        if not user or not user.is_active:
            return

        self.change_email(email)

        if new_password:
            self.change_password(new_password)
        self.save()


    def update_social_token(self, provider_name, token):
        socials = SocialPerson.objects.filter(person=self, provider=provider_name)
        for social in socials:
            social.token = token
            social.save()

    def update_checkins_count(self):
        self.checkins_count = self.checkin_set.all().count()
        self.save()

    def change_profile(self, firstname, lastname, photo=None, birthday='', location=None):
        self.firstname = firstname
        self.lastname = lastname

        if photo:
            self.photo = photo

        if birthday <> '':
            if not isinstance(birthday, date):
                import dateutil.parser
                birthday = dateutil.parser.parse(birthday).date()
            self.birthday = birthday

        if location:
            self.location = location
        self.save()

    def email_notify(self, type, **kwargs):
        send_mail_to_person(self, type, kwargs)

    def is_following(self, user):
        return user.id in self.following

    def is_follower(self, user):
        return user.id in self.followers

    @xact
    def follow(self, friend, skip_notification=False):
        if friend.id == self.id:
            return
        edge = PersonEdge()
        edge.edge_from = self
        edge.edge_to = friend
        edge.save()
        if friend.id not in self.following:
            self.following.append(friend.id)
            self.save()

        if self.id not in friend.followers:
            friend.followers.append(self.id)
            friend.save()
        self.email_notify(self.EMAIL_TYPE_NEW_FRIEND, friend=friend)

        if not skip_notification:
            from notification.models import Notification
            Notification.objects.create_friend_notification(friend, self)
        return edge

    @xact
    def unfollow(self, friend):
        if friend.id == self.id:
            return

        if friend.id in self.following:
            del self.following[self.following.index(friend.id)]
            self.save()

        if self.id in friend.followers:
            del friend.followers[friend.followers.index(self.id)]
            friend.save()

        res = PersonEdge.objects.filter(edge_from=self, edge_to=friend)
        if res.count() > 0:
            res.delete()

    def get_social_profiles(self):
        return self.socialperson_set.all()

    def get_social_friends(self):
        friends = []
        for social_profile in self.socialperson_set.filter(provider=SocialPerson.PROVIDER_VKONTAKTE):
            for friend in SocialPersonEdge.objects.select_related().filter(person_1=social_profile, person_2__photo_url__isnull=False)[:20]:
                friends.append(friend.person_2)
            if len(friends) >= 20:
                break
        result = []
        for i in range(min(3, len(friends))):
            idx = randint(0, len(friends)-1)
            result.append(friends[idx])
            del friends[idx]
        return result

    def _create_settings(self):
        # create settings if not exists
        ps = PersonSetting()
        ps.data = {}
        ps.save()
        self.settings = ps
        self.save()


    def get_settings(self):
        if not self.settings:
            self._create_settings()
        return self.settings.get_settings()

    def set_settings(self, p_settings):
        if not self.settings:
            self._create_settings()
        self.settings.set_settings(p_settings)
        self.save()

    def serialize(self):
        from api.v2.utils import model_to_dict
        from notification.models import APNDeviceToken
        person_fields = (
            'id', 'firstname', 'lastname', 'full_name', 'email', 'photo_url', 'location', 'sex', 'url', 'status', 'checkins_count'
            )
        data = model_to_dict(self, person_fields)

        try:
            data['apn_device_token'] = self.apndevicetoken.value
        except APNDeviceToken.DoesNotExist:
            data['apn_device_token'] = ''

        data['social_profile_urls'] = self.social_profile_urls
        if self.birthday:
            data['birthday'] = self.birthday.strftime("%Y-%m-%d %H:%M:%S %z")
        else:
            data['birthday'] = ''

        data['is_followed'] = False;
        return data

    @property
    def status_steps(self):
        return PersonStatusFSM(self.status)



class PersonStatusFSM(object):
    TRANSITIONS = {
        None :  Person.PERSON_STATUS_WAIT_FOR_EMAIL,
   #     Person.PERSON_STATUS_WAIT_FOR_EMAIL :  Person.PERSON_STATUS_ACTIVE,
       Person.PERSON_STATUS_WAIT_FOR_EMAIL :  Person.PERSON_STATUS_CAN_ASK_INVITATION,
        Person.PERSON_STATUS_CAN_ASK_INVITATION : Person.PEREON_STATUS_WAIT_FOR_CONFIRM_INVITATION,
        Person.PEREON_STATUS_WAIT_FOR_CONFIRM_INVITATION : Person.PERSON_STATUS_ACTIVE,
        Person.PERSON_STATUS_ACTIVE : None,
        }

    def __init__(self, status):
        self.status = status

    def get_initial_state(self):
        return self.TRANSITIONS[None]

    def get_next_state(self):
        if not self.TRANSITIONS[self.status]:
            return self.status
        else:
            return self.TRANSITIONS[self.status]

    def get_action_url(self):
        map = {
            Person.PERSON_STATUS_ACTIVE : reverse('feed'),
            Person.PERSON_STATUS_WAIT_FOR_EMAIL : reverse('person-fillemail'),
            Person.PERSON_STATUS_CAN_ASK_INVITATION : reverse('person-ask-invite'),
            Person.PEREON_STATUS_WAIT_FOR_CONFIRM_INVITATION : reverse('person-wait-invite-confirm'),
            }
        return map[self.status]


def convert_bool(obj):
    if obj in ['True', '1', 't', 1, True]:
        return True
    return False

class PersonSetting(models.Model):

    SETTINGS_VK_SHARE = 'vk_share'
    SETTINGS_STORE_ORIGINAL = 'store_orig'
    SETTINGS_STORE_FILTERED = 'store_filter'

    SETTINGS_CHOICES  = (
        (SETTINGS_VK_SHARE, 'Трансляция ВКонтакте'),
        (SETTINGS_STORE_ORIGINAL, 'Сохранять оригинальные'),
        (SETTINGS_STORE_FILTERED, 'Сохранять редактированные'),
    )

    SETTINGS_MAP = {
        SETTINGS_VK_SHARE : (convert_bool, True),
        SETTINGS_STORE_ORIGINAL : (convert_bool, True),
        SETTINGS_STORE_FILTERED : (convert_bool, True),
    }

    data = JSONField()

    def _normalize(self, p_settings):
        result = {}
        saved_data = self.data or {}
        for name, s_meta in PersonSetting.SETTINGS_MAP.items():
            (s_type, s_default) = s_meta
            if name in p_settings and p_settings[name] <> None:
                try:
                    result[name] = s_type(p_settings[name])
                except ValueError as e:
                    result[name] = saved_data.get(name, s_default)
            else:
                result[name] = saved_data.get(name, s_default)
        return result

    def set_settings(self, p_settings):
        self.data = self._normalize(p_settings)
        self.save()

    def get_settings(self):
        return self._normalize(self.data or {})

class PersonEdge(models.Model):
    edge_from = models.ForeignKey('Person', related_name='edge_from')
    edge_to = models.ForeignKey('Person', related_name='edge_to')

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

class SocialPerson(models.Model):
    PROVIDER_VKONTAKTE = 'vkontakte'
    PROVIDER_FACEBOOK = 'facebook'
    PROVIDER_CHOICES = (
        (PROVIDER_VKONTAKTE, 'ВКонтакте'),
        (PROVIDER_FACEBOOK, 'Facebook'),
    )

    person = models.ForeignKey(Person, null=True)
    firstname = models.CharField(null=False, blank=False, max_length=255)
    lastname = models.CharField(null=False, blank=False, max_length=255)
    birthday = models.DateTimeField(null=True, blank=True)

    photo_url = models.CharField(null=True, blank=False, max_length=255)
    sex = models.IntegerField(default=Person.PERSON_SEX_UNDEFINED, choices=Person.PERSON_SEX_CHOICES)

    provider = models.CharField(choices=PROVIDER_CHOICES, max_length=255)
    external_id = models.BigIntegerField()

    profile_url = models.CharField(null=True, blank=False, max_length=255)

    token = models.CharField(choices=PROVIDER_CHOICES, max_length=255, blank=True, null=True)
    # TODO: change it to JSONField from ostrovok-common and remove loads/dumps from code
    data = models.TextField(blank=True)

    create_date = models.DateTimeField(auto_now_add=True)
    modified_date = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("provider", "external_id")

    @property
    def url(self):
        return self.profile_url

    def __unicode__(self):
        return '[%s] %s %s %s' % (self.provider, self.external_id, self.firstname, self.lastname)


    def add_social_friend(self, friend):
        s_edge = SocialPersonEdge()
        s_edge.person_1 = self
        s_edge.person_2 = friend
        s_edge.save()
        return s_edge

    def load_friends(self):
        from social import provider
        client = provider(self.provider)
        responses = client.fetch_friends(social_person=self)
        for response in responses:
            friend = response.get_social_person()
            friend.save()

            # create social edge
            s_edge = self.add_social_friend(friend)

            # create edge
            if friend.person:
                edge = self.person.follow(friend.person)

                # follow back
                friend.person.follow(self.person, skip_notification=True)

                s_edge.edge = edge
                s_edge.save()


class SocialPersonEdge(models.Model):
    edge = models.OneToOneField(PersonEdge, null=True)
    person_1 = models.ForeignKey('SocialPerson', related_name='person_1')
    person_2 = models.ForeignKey('SocialPerson', related_name='person_2')

    create_date = models.DateTimeField(auto_now_add=True)


class InvitationCodeManager(models.Manager):
    def find_code(self, code):
        return self.get_query_set().get(code=code)

class InvitationCode(models.Model):
    code = models.TextField()
    is_used = models.BooleanField(default=False)
    person_used = models.OneToOneField(Person, null=True)
    used_date = models.DateTimeField()

    objects = InvitationCodeManager()

    def use(self, person):
        self.is_used = True
        self.person_used = person
        self.used_date = datetime.now()
        self.save()
