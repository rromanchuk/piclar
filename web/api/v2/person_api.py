# coding=utf-8
from django.contrib.auth import authenticate, login, logout

from feed.models import FeedItem

from person.models import Person
from person.exceptions import *
from person.social import provider

from poi.models import Place

from feed_api import feeditemcomment_to_dict

from base import *
from logging import getLogger

log = getLogger('web.api.person')

from utils import model_to_dict, filter_fields, AuthTokenMixin, doesnotexist_to_404

class PersonApiMethod(ApiMethod):
    def refine(self, obj):
        if isinstance(obj, Person):
            return obj.serialize()

        return obj

class PersonCreate(PersonApiMethod):

    def post(self):
            # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email', 'password'
            )

        vk_fields = (
            'user_id', 'access_token', #'email'
            )

        # TODO: correct validation processing
        try:
            vk_data = filter_fields(self.request.POST, vk_fields)
            simple_data = filter_fields(self.request.POST, simple_fields)
            if simple_data:
                person = Person.objects.register_simple(**simple_data)
            elif vk_data:
                social_client = provider('vkontakte')
                person = Person.objects.register_provider(provider=social_client, **vk_data)
            else:
                return self.error(message='Registration with args [%s] not implemented' %
                     (', ').join(self.request.POST.keys())
                )
        except AlreadyRegistered as e:
            person = e.get_person()

        except RegistrationException as e:
            return self.error(message='registration error')

        login(self.request, person.user)
        data = person.serialize()
        data['token'] = person.token
        return data

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

class PersonLogged(PersonApiMethod, AuthTokenMixin):
    def get(self):
        person = self.request.user.get_profile()
        return person

class PersonFeed(PersonApiMethod, AuthTokenMixin):
    def refine(self, obj):
        obj = feeditemcomment_to_dict(obj)
        if isinstance(obj, Place):
            return obj.serialize()

        return super(PersonFeed, self).refine(obj)

    def format_feed(self, feed):
        feed_list = []
        for pitem in feed:
            item = {
                'id' : pitem.item.id,
                'create_date': pitem.create_date,
                'creator' : pitem.creator,
                'likes' : pitem.item.liked,
                'count_likes' : len(pitem.item.liked),
                'me_liked' : self.request.user.get_profile().id in pitem.item.liked,
                'comments'  : pitem.item.get_comments()[:5],
                'type' : pitem.item.type,
                pitem.item.type : pitem.item.get_data(),
                }
            feed_list.append(item)

        return feed_list

    def get(self):
        feed =  FeedItem.objects.feed_for_person(self.request.user.get_profile())[:20]
        return self.format_feed(feed)

class PersonFeedOwned(PersonFeed):
    @doesnotexist_to_404
    def get(self, pk):
        person = Person.objects.get(id=pk)
        feed =  FeedItem.objects.feed_for_person_owner(person)[:20]
        return self.format_feed(feed)


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