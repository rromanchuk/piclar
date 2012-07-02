import logging
log = logging.getLogger(__name__)
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
        log.info(bundle)
