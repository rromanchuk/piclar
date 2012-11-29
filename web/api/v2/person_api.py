# coding=utf-8
from django.contrib.auth import authenticate, login, logout
from django.db import IntegrityError
from feed.models import FeedItem

from person.models import Person, PersonSetting
from person.exceptions import *

from poi.models import Place
from invitation.models import Code, IncorrectCode

from base import *
from logging import getLogger

log = getLogger('web.api.person')

from utils import model_to_dict, filter_fields, AuthTokenMixin, doesnotexist_to_404, CommonRefineMixin

class PersonApiMethod(ApiMethod, CommonRefineMixin):
    pass

class PersonCreate(PersonApiMethod):

    def post(self):
            # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email', 'password'
            )

        social_fields = (
            'user_id', 'access_token', 'platform',
        )

        is_new_user_created = True
        # TODO: correct validation processing
        try:
            social_data = filter_fields(self.request.POST, social_fields)
            simple_data = filter_fields(self.request.POST, simple_fields)
            if simple_data:
                person = Person.objects.register_simple(**simple_data)
            elif social_data:
                import person.social
                social_client = person.social.provider(self.request.POST.get('platform', 'vkontakte'))
                if 'email' in self.request.POST:
                    social_data['email'] = self.request.POST['email']
                person = Person.objects.register_provider(provider=social_client, good_token=True, **social_data)
            else:
                return self.error(message='Registration with args [%s] not implemented' %
                     (', ').join(self.request.POST.keys())
                )
        except AlreadyRegistered as e:
            is_new_user_created = False
            person = e.get_person()

        except RegistrationException as e:
            return self.error(message='registration error')

        login(self.request, person.user)

        # HACK: here we don't use CommonRefineMixin to add custom values
        data = person.serialize()
        data['token'] = person.token
        data['is_new_user_created'] = is_new_user_created
        return data

class PersonUpdate(PersonApiMethod, AuthTokenMixin):
    def post(self):
        non_empty_fields = {
            'email', 'firstname', 'lastname'
        }
        for field in non_empty_fields:
            if field in self.request.POST and not self.request.POST.get(field):
                return self.error(message='field %s must be not empty' % field)

        person = self.request.user.get_profile()
        if self.request.POST.get('email'):

            try:
                person.change_email(self.request.POST.get('email'))
            except IntegrityError:
                return self.error(message='User with such email is already exists')

        profile = {
            'firstname' : self.request.POST.get('firstname') or person.firstname,
            'lastname' : self.request.POST.get('lastname') or person.lastname,
        }

        for field in ['location', 'birthday']:
            if self.request.POST.get(field):
                profile[field] = self.request.POST.get(field)

        person.change_profile(**profile)
        return person

class PersonGet(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        person = Person.objects.get(id=pk)
        return person

class PersonLogin(PersonApiMethod):
    is_auth_required = False
    def post(self):
        username = self.request.POST.get('username')
        password = self.request.POST.get('password')
        user = authenticate(username=username, password=password)
        if user is not None:
            if user.is_active:
                login(self.request, user)
                data = user.get_profile().serialize()
                data['token'] = user.get_profile().token
                return data

        return self.error(message='unauthorized', status_code=401)

class PersonLogout(PersonApiMethod, AuthTokenMixin):
    def get(self):
        logout(self.request)

    def post(self):
        logout(self.request)

class PersonUpdateSocial(PersonApiMethod, AuthTokenMixin):
    def post(self):
        provider_name = self.request.POST.get('provider')
        token = self.request.POST.get('token')
        self.request.user.get_profile().update_social_token(provider_name, token)


class PersonLogged(PersonApiMethod, AuthTokenMixin):
    def get(self):
        person = self.request.user.get_profile()
        return person

class PersonFeed(PersonApiMethod, AuthTokenMixin):

    def get(self):
        if settings.API_DEBUG_FEED_EMPTY and settings.DEBUG:
            return []
        feed =  FeedItem.objects.feed_for_person(self.request.user.get_profile())
        result = []
        for item in feed:
            proto = item.item.serialize(self.request)
            proto['share_date'] = item.create_date
            result.append(proto)
        return result

class PersonFeedOwned(PersonFeed):
    @doesnotexist_to_404
    def get(self, pk):
        if settings.API_DEBUG_FEED_EMPTY and settings.DEBUG:
            return []
        person = Person.objects.get(id=pk)
        feed =  FeedItem.objects.feed_for_person_owner(person)
        result = []
        for item in feed:
            proto = item.item.serialize(self.request)
            proto['share_date'] = item.create_date
            result.append(proto)
        return result

class PersonSuggested(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        if pk == 'logged':
            person = self.request.user.get_profile()
        else:
            person = Person.objects.get(id=pk)
        return Person.objects.get_suggested(person)

class PersonFollowers(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        if pk == 'logged':
            person = self.request.user.get_profile()
        else:
            person = Person.objects.get(id=pk)
        return Person.objects.get_followers(person)


class PersonFollowing(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def get(self, pk):
        if pk == 'logged':
            person = self.request.user.get_profile()
        else:
            person = Person.objects.get(id=pk)
        return Person.objects.get_following(person)

class PersonFollowUnfollow(PersonApiMethod, AuthTokenMixin):
    @doesnotexist_to_404
    def post(self, pk, action):
        person = self.request.user.get_profile()
        friend = Person.objects.get(id=pk)
        if action == 'unfollow' :
            person.unfollow(friend)
        elif action == 'follow':
            person.follow(friend)
        return person

class PersonSettingApi(PersonApiMethod, AuthTokenMixin):
    def post(self):
        proto = {}
        for key in PersonSetting.SETTINGS_MAP.keys():
            proto[key] = self.request.POST.get(key)

        self.request.user.get_profile().set_settings(proto)
        return {}

    def get(self):
        return self.request.user.get_profile().get_settings()

class PersonInvitationCode(PersonApiMethod, AuthTokenMixin):

    def post(self):
        code = self.request.POST.get('code')
        person = self.request.user.get_profile()
        if person.status != person.PERSON_STATUS_CAN_ASK_INVITATION:
            return self.error(message='user have inappropriate status for use code')
        try:
            code = Code.objects.check_code(code)
            code.use_code(person)
            person.status = person.PERSON_STATUS_ACTIVE
            person.save()
            return person
        except IncorrectCode:
            return self.error(message='bad code')
