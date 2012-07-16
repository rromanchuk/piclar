# coding=utf-8
from django.conf.urls import url
from django.http import HttpResponseRedirect
from django.contrib.auth import authenticate, login, logout

from tastypie.exceptions import NotFound, BadRequest, ImmediateHttpResponse
from tastypie import http

from person.models import Person
from person.exceptions import RegistrationException, AlreadyRegistered
from poi.provider import get_poi_client

from base import BaseResource

import logging
log = logging.getLogger('web.api')


class PersonResource(BaseResource):
    class Meta(BaseResource.Meta):
        list_allowed_methods = ['get', 'post']
        detail_allowed_methods = ['get', 'post']
        queryset = Person.objects.all()


    def override_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/logged/$" % self._meta.resource_name, self.wrap_view('obj_logged_user'), name="api_logged_user"),
            url(r"^(?P<resource_name>%s)/login/$" % self._meta.resource_name, self.wrap_view('obj_login_user'), name="api_login_user"),
            url(r"^(?P<resource_name>%s)/logout/$" % self._meta.resource_name, self.wrap_view('obj_logout_user'), name="api_logout_user"),
        ]

    def dehydrate(self, bundle):
        bundle.data['photo'] = bundle.obj.photo_url
        return bundle

    def obj_login_user(self, request, api_name, resource_name):
        self.method_check(request, allowed=['post'])
        self.throttle_check(request)

        username = request.POST.get('login')
        password = request.POST.get('password')
        user = authenticate(username=username, password=password)
        self.log_throttled_access(request)
        if user is not None:
            if user.is_active:
                login(request, user)
                object_uri = self.get_resource_uri(user.get_profile())
                raise ImmediateHttpResponse(response=HttpResponseRedirect(object_uri))

        raise ImmediateHttpResponse(response=http.HttpUnauthorized())

    def obj_logout_user(self, request, api_name, resource_name):
        self.method_check(request, allowed=['post'])
        self.throttle_check(request)
        logout(request)
        self.log_throttled_access(request)
        return self.create_response(request, None)

    def obj_logged_user(self, request, api_name, resource_name):
        self.method_check(request, allowed=['get'])
        self.throttle_check(request)

        if not request.user.is_authenticated():
            raise ImmediateHttpResponse(response=http.HttpUnauthorized())

        try:
            bundle = self.build_bundle(obj=request.user.get_profile(), request=request)
        except Person.DoesNotExist:
            raise ImmediateHttpResponse(response=http.HttpUnauthorized())
        bundle = self.full_dehydrate(bundle)
        bundle = self.alter_detail_data_to_serialize(request, bundle)

        self.log_throttled_access(request)
        return self.create_response(request, bundle)

    def obj_create(self, bundle, request=None):
        self.method_check(request, allowed=['post'])
        self.throttle_check(request)

        # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email'
        )

        vk_fields = (
            'user_id', 'access_token'
        )

        # TODO: correct validation processing
        try:
            # is simple registration
            if self._check_field_list(bundle, simple_fields):
                bundle.obj = Person.register_simple(**bundle.data)
            elif self._check_field_list(bundle, vk_fields):
                provider = get_poi_client('vkontakte')
                bundle.obj = Person.register_provider(provider=provider, **bundle.data)
            else:
                raise BadRequest('Registration with args [%s] not implemented' %
                   (', ').join(bundle.data.keys())
                )
        except AlreadyRegistered as e:
            login(request, e.get_person().user)
            object_uri = self.get_resource_uri(e.get_person())
            raise ImmediateHttpResponse(response=HttpResponseRedirect(object_uri))
        except RegistrationException as e:
            raise BadRequest(e.__class__.__name__)
        login(request, bundle.obj.user)
        self.log_throttled_access(request)
        return bundle

