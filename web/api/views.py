import logging
log = logging.getLogger(__name__)

from tastypie.resources import ModelResource
from person.models import Person

class PersonResource(ModelResource):
    class Meta:
        queryset = Person.objects.all()
        allowed_methods = ['get', 'post', 'delete']

    def obj_create(self, bundle, request=None):
        log.info(bundle)
