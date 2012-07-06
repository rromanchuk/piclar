import logging

from django.conf.urls import url
from django.http import HttpResponseRedirect
from django.contrib.auth import authenticate, login, logout

from tastypie.authorization import Authorization, DjangoAuthorization
from tastypie.authentication import Authentication, BasicAuthentication
from tastypie.resources import ModelResource, Resource
from tastypie.validation import Validation
from tastypie.exceptions import NotFound, BadRequest, ImmediateHttpResponse
from tastypie import http
from tastypie.serializers import Serializer

from person.models import Person
from person.exceptions import RegistrationException
from poi.models import Place
import urlparse

log = logging.getLogger('web.api')

class UrlencodedSerializer(Serializer):
    content_types = {
        'json': 'application/json',
        'jsonp': 'text/javascript',
        'xml': 'application/xml',
        'yaml': 'text/yaml',
        'html': 'text/html',
        'plist': 'application/x-plist',
        'urlencoded': 'application/x-www-form-urlencoded',
    }

    def from_urlencoded(self, data):
        """ handles basic formencoded url posts """
        qs = dict((k, v if len(v)>1 else v[0] )
            for k, v in urlparse.parse_qs(data).iteritems())

        return qs

class PersonAuthentication(Authentication):
    def is_authenticated(self, request, **kwargs):
        if request.method == 'POST':
            return True
        if not request.user.is_authenticated():
            return False
        return super(PersonAuthentication, self).is_authenticated(request, **kwargs)

class PersonAuthorization(DjangoAuthorization):
    def is_authorized(self, request, object=None):
        if request.method == 'POST':
            return True
        return super(PersonAuthorization, self).is_authorized(request, object)

class PersonResource(ModelResource):
    class Meta:
        list_allowed_methods = ['get', 'post']
        detail_allowed_methods = ['get', 'post']

        queryset = Person.objects.all()
        authentication = PersonAuthentication()
        authorization = PersonAuthorization()
        serializer = UrlencodedSerializer()

    def _check_field_list(self, bundle, required_fields):
        return all(
            map(
                lambda x: x in bundle.data, required_fields
            )
        )

    def override_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/logged/$" % self._meta.resource_name, self.wrap_view('obj_logged_user'), name="api_logged_user"),
            url(r"^(?P<resource_name>%s)/login/$" % self._meta.resource_name, self.wrap_view('obj_login_user'), name="api_login_user"),
            url(r"^(?P<resource_name>%s)/logout/$" % self._meta.resource_name, self.wrap_view('obj_logout_user'), name="api_logout_user"),
        ]

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
        log.info(request.user)
        self.method_check(request, allowed=['post'])
        log.info('test')

        self.throttle_check(request)
        logout(request)
        self.log_throttled_access(request)
        return self.create_response(request, None)

    def obj_logged_user(self, request, api_name, resource_name):
        self.method_check(request, allowed=['get'])
        self.throttle_check(request)

        if not request.user.is_authenticated():
            raise ImmediateHttpResponse(response=http.HttpUnauthorized())

        bundle = self.build_bundle(obj=request.user.get_profile(), request=request)
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

        # TODO: check if already registred
        # TODO: correct validation processing
        try:
            # is simple registration
            if self._check_field_list(bundle, simple_fields):
                bundle.obj = Person.register_simple(**bundle.data)
            elif self._check_field_list(bundle, vk_fields):
                bundle.obj = Person.register_vk(**bundle.data)
            else:
                raise NotFound('Registration with args [%s] not implemented' %
                   (', ').join(bundle.data.keys())
                )
        except RegistrationException as e:
            raise BadRequest(e.__class__.__name__)
        self.log_throttled_access(request)
        return bundle

class PlaceResource(ModelResource):
    class Meta:
        queryset = Place.objects.all()

    def override_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/search/$" % self._meta.resource_name, self.wrap_view('obj_search'), name="api_search_poi"),
        ]

    def obj_search(self, request, **kwargs):
        self.method_check(request, allowed=['get'])
        lat = request.GET.get('lat')
        lng = request.GET.get('lng')
        if not lat or not lng:
            raise ImmediateHttpResponse(response=http.HttpBadRequest('lat and lng params is required'))


        objects = []
        result = Place.places.search(lat, lng).all()[:50]
        for item in result:
            bundle = self.build_bundle(obj=item, request=request)
            bundle = self.full_dehydrate(bundle)
            objects.append(bundle)

        object_list = {
            'objects': objects,
        }

        self.log_throttled_access(request)
        return self.create_response(request, object_list)