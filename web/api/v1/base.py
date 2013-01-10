# coding: utf-8

from logging import getLogger
from datetime import date
from decimal import Decimal
from django.conf import settings
from django.http import HttpResponse
from django.core.cache import cache
from django.views.decorators.csrf import csrf_exempt
from minidetector import exempt_mobile

from serializers import to_json, to_jsonp, to_json_custom, to_xml, iter_response

logger = getLogger('web.api')


class NotFoundError(Exception):
    pass


class ValidationError(Exception):
    pass


class AuthError(Exception):
    pass


class ApiMethod(object):
    """
    Parent class for all API methods.
    Define "get" method to implement HTTP GET in your child class or "post"
    method to implemet HTTP POST and so on (like in Django class based views).
    Does all serialization job by default. To implement your own serialization
    for a particular MIME type, define to_<type> method
    (e.g. to_json or to_xml).

    Also ApiMethod's children are callable in Python directly. You can
    construct the object by passing current HttpRequest instance to __init__,
    and then call "get" or "post" of the object with necessary arguments.
    """

    # Dict of MIME content types supported by API.
    # Key of dict is a short name of MIME type, value is a full MIME type
    # used as a value for HTTP header "Content-type".
    MIME_TYPES = {
        'json': 'application/json',
        'jsonp': 'application/javascript',
        'xml': 'application/xml',
        'yaml': 'application/yaml',
    }


    # List of HTTP methods.
    # http://en.wikipedia.org/wiki/HTTP#Request_methods
    # http://tools.ietf.org/html/rfc2616#page-51
    HTTP_METHODS = ['get', 'post', 'put', 'delete', 'head', 'options', 'trace']

    # List of MIME content types supported by current API method.
    # Proposed to be overridden in methods implementation.
    # Values must exist in self.MIME_TYPES.
    content_types = ['json', 'xml']

    # Content type of current instance of API method's class.
    # Detected automatically by current HttpRequest instance.
    content_type = None

    # Name for root XML node. It will be used if serialized value isn't a dict.
    # E.g. {'killa': 'gorilla'} -> <killa>gorilla</killa>, but
    # 'gorilla' -> '<xml_root_node>gorilla</xml_root_node>'
    xml_root_node = None

    # Requires that client must be authenticated by standard Django
    # authentication: request.user.is_authenticated() == True.
    is_auth_required = False

    @classmethod
    @csrf_exempt
    @exempt_mobile
    def view(cls, request, *args, **kwargs):
        """
        Shortcut method to use in urls.py.
        """
        api_obj = cls(request)
        api_obj.is_http = True
        return api_obj(*args, **kwargs)

    def __init__(self, request, *args, **kwargs):
        """
        Initializing partially taked out from __call__ to be able to call
        API's methods in python directrly.
        """
        self.request = request
        self._serializers = {
            'json': to_json,
            'jsonp': to_jsonp,
            'xml': to_xml,
            }
        custom_serializers = kwargs.get('serializers')
        if custom_serializers:
            for k, v in custom_serializers.items():
                self._serializers[k] = v
        #super(ApiMethod, self).__init__(*args, **kwargs)

    def __call__(self, *args, **kwargs):
        """
        Try to dispatch to the right HTTP method. If a method doesn't exist,
        defer to the error handler. Also defer to the error handler if the
        request method isn't on the approved list.
        """
        http_method = self.request.method.lower()
        if http_method in self.HTTP_METHODS and hasattr(self, http_method):
            handler = getattr(self, http_method)
        else:
            handler = self._method_not_allowed

        # Try to extract content_type from keyword arguments:
        # e.g. /method/(?P<id>\d+)\.(?P<content_type>json|xml) in urls.py
        if 'content_type' in kwargs:
            content_type = kwargs.pop('content_type')
        # Try to extract content_type from arguments:
        # e.g. /method/(\d+)\.(json|xml) in urls.py
        elif args and args[-1] in self.content_types:
            args = list(args)
            content_type = args.pop()
        else:
            raise AssertionError(
                'Cannot get content type.'
                ' Please, add an additional parameter to urls.py'
            )
        assert content_type in self.MIME_TYPES, \
            'Content type "%s" must be in MIME_TYPES property' % content_type
        if content_type not in self.content_types:
            return self.error(400, 'Unsupported format "%s"' % content_type)

        self.content_type = content_type

        # Check authentication possibly provided by additional mixin classes.
        if hasattr(self, 'auth'):
            res = self.auth()
            if isinstance(res, HttpResponse):
                return res

        if self.is_auth_required and not self.request.user.is_authenticated():
            return self.error(403, 'Forbidden')

        try:
            data = handler(*args, **kwargs)
        except ValidationError as e:
            return self.error(400, unicode(e))
        except NotFoundError as e:
            return self.error(404, unicode(e))
        except Exception as e:
            if settings.SERVER_ROLE != 'prod':
                raise
            logger.exception('Something goes wrong in API method')
            return self.error(500, 'Unexpected API error')

        if isinstance(data, HttpResponse):
            return data

        response = HttpResponse(self._serialize(data))
        response['Content-Type'] = self.MIME_TYPES[self.content_type]
        return response

    def _method_not_allowed(self, *args, **kwargs):
        response = self.error(405, 'Method Not Allowed')
        response['Allow'] = self._allowed_methods
        return response


    def options(self, *args, **kwargs):
        """
        Provides default implementation of OPTIONS method.
        """
        if hasattr(super(ApiMethod, self), 'options'):
            return super(ApiMethod, self).options(*args, **kwargs)
        response = HttpResponse()
        response['Allow'] = self._allowed_methods
        response['Content-Length'] = 0
        return response

    def error(self, status_code=400, message='', **kwargs):
        """
        Helper method allows to return response with HTTP error easily.
        If self.content_type is detected, method will return serialized
        structure with errors as response's body.
        """
        response = HttpResponse(status=status_code)
        if self.content_type:
            response['Content-Type'] = self.MIME_TYPES[self.content_type]
            body = {}
            if message:
                body['message'] = message
            if kwargs:
                body.update(kwargs)
            response.content = self._serialize(body)
        elif message:
            response.content = message
        return response

    def _serialize(self, data):
        """
        Serializes API method's response by default or overriden in method's
        class serializer.
        """
        if hasattr(self, 'refine'):
            data = iter_response(data, self.refine)

        serializer = getattr(
            self,
            'to_' + self.content_type,
            self._serializers[self.content_type]
        )
        params = []
        if self.content_type == 'xml' and self.xml_root_node:
            params.append(self.xml_root_node)
        elif self.content_type == 'jsonp':
            params.append(self.request.GET.get(
                'callback',
                getattr(self, 'jsonp_callback', 'callback')
            ))
        return serializer(data, *params)

    @property
    def _allowed_methods(self):
        return ', '.join([
            m.upper() for m in self.HTTP_METHODS if hasattr(self, m)
        ])


class FormValidationMixin(object):
    """
    This mixin allows to validate input parameters passed by HTTP request.
    It uses validation mechanism provided by Django forms.
    Just add this class to your method's parents, specify "form_class"
    property and you can get a valid parameters from self.valid_data.
    """

    # Class of Django form which will be used for validation of
    # API method's parameters.
    form_class = None

    # This property is used to store cleaned values of input data after
    # a successful validation.
    valid_data = None

    def validate(self):
        """
        Try to validate input data by Django form's validate method.
        If validation is failed, method will return HTTP response with
        a detailed explanation of each error provided by validation class.
        Otherwise it stores cleaned data to "valid_data" property
        and returns None.
        """
        assert self.form_class, \
            'You must specify name of form class by "form_class" property'

        # Prevent repeated validation.
        # It is possible because of "bad" __mro__ wheb childs of
        # FormValidationMixin are used.
        if self.valid_data:
            return

        data = getattr(
            self.request, (
                'POST'
                if self.request.method in ('POST', 'PUT', 'DELETE')
                else 'GET'
            )
        )
        form = self.form_class(data)
        if not form.is_valid():
            raise ValidationError(
                'Validation failed' +
                str(form.errors)
            )
        self.valid_data = form.cleaned_data


class FieldsMixin(object):
    """
    This mixin allows to filter API method's output by specified fields.
    Fieldset is passed to API method by "_fieldset" parameter. It can contains
    list of fields separated by comma or name of predefined set.
    For example:
        "/api/v1/hotels/1.json?_fieldset=id,name" will return
        {'id': 1, 'name': 'Shmotel'} even if the resourse have more fields.
    or:
        "/api/v1/hotel/1.json?_fieldset=_all_" will return values
        of all available fields for this resourse. "_all_" is the name of
        predefined fieldset (_all_ is provided automatically, you should not
        define it).
    Also allows to compute any vacant fields in response by defining method
    called "field_" plus name of a vacant field in your API method's
    implementation. Each of these methods accepts the link to the response
    object, so you can just modify it by adding necessary field.
    """

    # Cache for calculated fieldset of current instance.
    _fieldset = None

    _fields_getters = None

    # List of all available field names which could be gotten in response
    # of your API method.
    allowed_fields = None

    # If you specify class of Django model here, allowed_fields property
    # will be filled automatically by names of model's fields.
    # Note that one of "allowed_fields" or "filtered_model" properties
    # is required.
    filtered_model = None

    # Specifies set of fields which will be returned, if there is no
    # "_fieldset" parameter in request. Is required to be defined in
    # you API method's implementation.
    default_fieldset = None

    # Allows to make predefined fieldsets. For example:
    #     {
    #         '_mobile_': ['id', 'name'],
    #         '_fieldset_name_': ['field1', 'field2', ...]
    #         ...
    #     }
    # Predefined set is passed in request by "_fieldset" parameter. So choose
    # an unique name for predefined set which doesn't intersect with field
    # names.
    # Also there is one hardcoded fieldset called "_all_". It returns values of
    # all allowed fields.
    # Used tuple in base class, because it must be an immutable type.
    predefined_sets = tuple()

    @property
    def fieldset(self):
        """
        Calculates set of fields for current instance based on request's
        parameter "_fieldset" and settings of current class.
        """
        assert self.default_fieldset, \
            'You must define default_fieldset property in your class'
        if self._fieldset:
            return self._fieldset

        allowed_fields = self._allowed_fields()

        fieldset = self.request.GET.get('_fieldset')
        if fieldset:
            # Try to detect one of predefined fieldset
            if fieldset in self.predefined_sets:
                self.set_fieldset(fieldset)
            elif fieldset == '_all_':
                self._fieldset = allowed_fields
            # Treat "_fieldset" like a list of fields
            else:
                self._fieldset = [
                    f for f in fieldset.split(',')
                    if f in allowed_fields
                ]
        # Use default fieldset
        elif self.default_fieldset:
            self._fieldset = self.default_fieldset

        self._fieldset = set(self._fieldset)
        return self._fieldset

    def set_fieldset(self, name):
        """
        Set one of predefined fieldsets as a current. Useful for non
        HTTP usage.
        """
        assert name in self.predefined_sets, \
            'There are no "%s" fieldset in predefined_sets property' % name
        self._fieldset = self.predefined_sets[name]

    def options(self, *args, **kwargs):
        """
        Overrides OPTIONS to returns list of available fields in
        the response's body.
        """
        response = HttpResponse()
        response.content = self._serialize(
            sorted(list(self._allowed_fields()))
        )
        response['Content-Length'] = len(response.content)
        response['Content-Type'] = self.MIME_TYPES[self.content_type]
        response['Allow'] = self._allowed_methods
        return response

    def filter(self, data):
        """
        Removes fields not represented in "fieldset" property from API
        method's output ("data" argument). Can deal with dict or list of dicts.
        """
        return self._filter_dict(data)

    def _filter_dict(self, data):
        if not data:
            return data
        # Detect methods for computing fields (works only at the first call).
        if self._fields_getters is None:
            self._fields_getters = {
                f: getattr(self, 'field_' + f)
                for f in self.fieldset if f not in data
                if hasattr(self, 'field_' + f)
            }
        # Compute values of fields by detected methods.
        for field in self._fields_getters:
            r = self._fields_getters[field](data)
            if r is not None and field not in data:
                data[field] = r
        # Filter out unnecessary fields.
        return {f: data[f] for f in data if f in self.fieldset}

    def _allowed_fields(self):
        """
        Tries to fill "allowed_fields" automatically if it is empty.
        """
        if not self.allowed_fields and self.filtered_model:
            self.allowed_fields = (
                f.name for f in self.filtered_model._meta.fields
            )
        assert self.allowed_fields, \
            'You must specify all available fields by "allowed_fields"' \
            ' or "filtered_model" property'
        if type(self.allowed_fields) is not set:
            self.allowed_fields = set(self.allowed_fields)
        return self.allowed_fields


class FieldsListMixin(FieldsMixin):
    """
    A similar to FieldsMixin mixin, but filters response as a list
    of dicts, not as a single dict.
    """

    def filter(self, data):
        """
        Removes fields not represented in "fieldset" property from API
        method's output treated as a list of dicts ("data" argument).
        """
        if hasattr(self, 'get_filtered_object'):
            obj = self.get_filtered_object(data)
        else:
            obj = data
        for i in xrange(len(obj)):
            obj[i] = self._filter_dict(obj[i])
        return data


def _convert_by_type(type_, value):
    """
    Helper function provides value's coversion by type.
    Used in ApiParam and ParamsMixin.
    """
    if value is None and issubclass(type_, basestring):
        raise TypeError('Cannot convert None to %s' % type_.__name__)
    if isinstance(type_, type):
        return type_(value)
    if type_ == 'decimal':
        return Decimal(value)
    if type_ == 'date':
        return date(*map(int, value.split('-')))


def _validate_by_type(param, value):
    """
    Helper provides value's validation by type.
    Used in ApiParam and ParamsMixin.
    """
    if param['type'] == unicode:
        _value = len(value)
        messages = ('shorter', 'longer')
    else:
        _value = value
        messages = ('less', 'greater')
    if param.get('max') is not None and _value > param['max']:
        return 'must be %s than %s' % (messages[0], str(param['max']))
    if param.get('min') is not None and _value < param['min']:
        return 'must be %s than %s' % (messages[1], str(param['min']))


class ApiParam(dict):
    """
    Helper class for describing parameters of API method. Used in place of
    a simple dict with a certain structure generally because of specifying of
    constructor's keyword arguments allows to autocomplete them in the most
    of IDEs.
    """

    __allowed_types = (int, float, unicode, 'decimal', 'date')

    def __init__(self, type=None, default=None, required=False, validator=None,
                 max=None, min=None, **kwargs):
        """
        Note that in the body of __init__ a standard pythonic "type", "max"
        and "min" are overriden by keyword arguments.
        """
        assert type, 'Type argument is required'
        assert type in self.__allowed_types, \
            'Type must be one of %s' % str(self.__allowed_types)
        self['type'] = type
        self['required'] = required
        self['default'] = default
        self['validator'] = validator
        self['max'] = max
        self['min'] = min
        for k in kwargs:
            self[k] = kwargs[k]

    def __getattr__(self, name):
        if name in self:
            return self[name]

    def to_value(self, value):
        return _convert_by_type(self['type'], value)

    def validate(self, value):
        """
        Provides default validation for all types.
        Returns string with error message if value is invalid or None
        otherwise.
        """
        return _validate_by_type(self, value)


class ParamsMixin(object):
    """
    Mixin for inheritance in API methods allows to validate input parameters
    (defined by "params" ApiParam).
    """
    get_params = None
    post_params = None

    def validate(self):
        """
        Validates values of API method's parameters got from GET or POST.
        Sets a cleaned values to get_values and post_values properties
        and call a wrapped HTTP method's handler if success or returns
        400 HTTP error otherwise.
        """
        self.get_values = {}
        self.post_values = {}
        sources = [
            (self.get_params or {}, self.request.GET, self.get_values),
        ]
        if self.request.method == 'POST':
            sources.append(
                (self.post_params or {}, self.request.POST, self.post_values)
            )

        for params, data, values in sources:
            for name, param in params.iteritems():
                value = data.get(name, param.get('default'))
                if value is None:
                    if param.get('required'):
                        raise ValidationError(
                            '"%s" parameter is required' % name
                        )
                    else:
                        continue

                try:
                    values[name] = _convert_by_type(param['type'], value)
                except (TypeError, ValueError):
                    raise ValidationError(
                        '"%s" parameter must have a valid value of'
                        ' "%s" type' % (
                            name,
                            getattr(param['type'], '__name__', param['type'])
                        )
                    )

                error = _validate_by_type(param, values[name])
                if error:
                    raise ValidationError('Value of "%s" %s' (name, error))

                validator = (
                    getattr(param, 'validator', None) or
                    getattr(self, 'validate_' + name, None)
                )
                if validator:
                    error = validator(values[name])
                    if error:
                        raise ValidationError(
                            '"%s" parameter has a wrong value (%s)' %
                            (name, error)
                        )


def _model_dict(dict_):
    """
    Returns only valuable fields of Django model's __dict__.
    """
    return {
        k: v
        for k,v in dict_.items()
        if not k.startswith('_')
    }

class Api(object):
    def __init__(self):
        self.options = {
            'serializers' : {}
        }

    def setSerializer(self, ser_type, ser_callable):
        self.options['serializers'][ser_type] = ser_callable

    def method(self, method_cls):
        def wraper(request, *args, **kwargs):
            api_obj = method_cls(request, **self.options)

            api_obj.is_http = True
            return api_obj(*args, **kwargs)
        return wraper
