import logging
log = logging.getLogger('web')

from tastypie.authorization import Authorization
from tastypie.authentication import Authentication

from tastypie.resources import ModelResource
from person.models import Person

class PersonResource(ModelResource):
    class Meta:
        queryset = Person.objects.all()
        authentication = Authentication()
        authorization = Authorization()

    def obj_create(self, bundle, request=None):
        # simple registration
        log.info(bundle.obj)
        log.info(bundle.data)
        return bundle
