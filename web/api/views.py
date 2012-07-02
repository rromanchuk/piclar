import logging
log = logging.getLogger('web')

from operator import contains
from tastypie.authorization import Authorization
from tastypie.authentication import Authentication
from tastypie.resources import ModelResource
from tastypie.validation import Validation
from tastypie.exceptions import NotFound

from person.models import Person




class PersonResource(ModelResource):
    class Meta:
        queryset = Person.objects.all()
        authentication = Authentication()
        authorization = Authorization()

    def _check_field_list(self, bundle, required_fields):
        return all(
                map(
                    lambda x: x in bundle.data, required_fields
                )
            )
    def obj_create(self, bundle, request=None):
        # simple registration
        simple_fields = (
            'firstname', 'lastname', 'email', 'password',
        )

        vk_fields = (
            'email', 'access_token'
        )

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
