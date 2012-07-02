import logging
log = logging.getLogger('web')

from django.conf.urls import url

from tastypie.authorization import Authorization, DjangoAuthorization
from tastypie.authentication import Authentication, BasicAuthentication
from tastypie.resources import ModelResource
from tastypie.validation import Validation
from tastypie.exceptions import NotFound, ImmediateHttpResponse
from tastypie import http

from person.models import Person

class PersonAuthentication(BasicAuthentication):
    pass

class PersonAuthorization(DjangoAuthorization):
    pass

class PersonResource(ModelResource):
    class Meta:
        list_allowed_methods = ['get']
        detail_allowed_methods = ['get', 'post']

        queryset = Person.objects.all()
        authentication = PersonAuthentication()
        authorization = PersonAuthorization()

    def _check_field_list(self, bundle, required_fields):
        return all(
                map(
                    lambda x: x in bundle.data, required_fields
                )
            )

    def override_urls(self):
        return [
            url(r"^(?P<resource_name>%s)/$" % self._meta.resource_name, self.wrap_view('obj_logged_user'), name="api_logged_user"),
            ]

    def obj_logged_user(self, request, api_name, resource_name):
        if not request.user.is_authenticated():
            raise ImmediateHttpResponse(response=http.HttpUnauthorized())

        bundle = self.build_bundle(obj=request.user.get_profile(), request=request)
        bundle = self.full_dehydrate(bundle)
        bundle = self.alter_detail_data_to_serialize(request, bundle)
        return self.create_response(request, bundle)


    def obj_create(self, bundle, request=None):
        # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email', 'password',
        )

        vk_fields = (
            'email', 'accesstoken'
        )

        # TODO: check if already registred
        # TODO: correct validation processing

        # is simple registration
        if self._check_field_list(bundle, simple_fields):
            bundle.obj.register_simple(**bundle.data)
        elif self._check_field_list(bundle, vk_fields):
            bundle.obj.register_vk(**bundle.data)
        else:
            raise NotFound('Registration with args [%s] not implemented' %
               (', ').join(bundle.data.keys())
            )
        return bundle
