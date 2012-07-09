from tastypie.authorization import Authorization, DjangoAuthorization
from tastypie.authentication import Authentication, BasicAuthentication
from tastypie.resources import ModelResource, Resource
from tastypie.validation import Validation
from tastypie.exceptions import NotFound, BadRequest, ImmediateHttpResponse
from tastypie import http
from tastypie.serializers import Serializer


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

class CustomAuthentication(Authentication):
    def is_authenticated(self, request, **kwargs):
        if request.method == 'POST':
            return True
        if not request.user.is_authenticated():
            return False
        return super(CustomAuthentication, self).is_authenticated(request, **kwargs)

class CustomAuthorization(DjangoAuthorization):
    def is_authorized(self, request, object=None):
        if request.method == 'POST':
            return True
        return super(CustomAuthorization, self).is_authorized(request, object)

class BaseResource(ModelResource):
    class Meta:
        authentication = CustomAuthentication()
        authorization = CustomAuthorization()
        serializer = UrlencodedSerializer()

    def _check_field_list(self, bundle, required_fields):
        return all(
            map(
                lambda x: x in bundle.data, required_fields
            )
        )