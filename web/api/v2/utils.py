# coding=utf-8
import hmac
import hashlib
from urllib import urlencode
from django.core.exceptions import ObjectDoesNotExist
from django.http import HttpResponseNotFound
from base import ApiMethod
from django.conf import settings
from person.models import Person
from translation.dates import month_to_word_plural
from logging import getLogger

log = getLogger('web.api.utils')

def date_in_words(date):
    return '%s %s %s, %s' % (date.day, month_to_word_plural(date.month), date.year, date.strftime('%H:%M:%S'))

def doesnotexist_to_404(wrapped):
    def wrapper(*args, **kwargs):
        try:
            return wrapped(*args, **kwargs)
        except ObjectDoesNotExist as e:
            message = 'object not found'
            if len(args) >  0 and isinstance(args[0], ApiMethod):
                return args[0].error(status_code=404, message=message)
            return HttpResponseNotFound(message)
    return wrapper

def model_to_dict(model, fields):
    return dict([ (fname, unicode(getattr(model, fname))) for fname in fields ])

def filter_fields(data, required_fields):
    filtered = dict([ (k,v) for k,v in data.items() if k in required_fields])
    if set(filtered.keys()).issuperset(set(required_fields)):
        return filtered
    else:
        return {}

def create_signature(person_id, token, method, params):
    if not params:
        params = {}
    if 'auth' in params:
        del params['auth']

    #params = urlencode(dict([k, v.encode('utf-8')] for k, v in sorted(params.items(), key=lambda (k, v): k)))
    # Notice: Python uses quote_plus which encodes spaces with +s instead of percent escaping
    # which is good for forms but some other libraries use percent escapes for urlencode. See the topic
    # http://bugs.python.org/issue13866. I modified ios to escape spaces using +s
    params = {}
    for k, v in params.items():
        if isinstance(v, unicode):
            params[k] = v.encode('utf-8')
        else:
            params[k] = v

    params = urlencode(sorted(params.items(), key=lambda (k, v): k))

    params = method.upper() + ' ' + params + ' ' + settings.API_CLIENT_SALT
    signed = hmac.new(str(token), params, hashlib.sha256)
    msg = '%s:%s' % (person_id, signed.hexdigest())

    log.info('signature params: %s' % params)
    log.info('signature created: %s' % msg)
    return msg


class AuthTokenMixin(object):
    def auth(self):
        # TODO: remove it after Ryan implement token auth
        if self.request.REQUEST.get('person_id') and settings.DEBUG:
            person = Person.objects.get(id=self.request.REQUEST.get('person_id'))
            self.request.user = person.user
            return

        if 'auth' not in self.request.REQUEST:
            return self.error(status_code=403, message='unauthorized, incorrect signature')
        auth = self.request.REQUEST['auth']
        if ':' not in auth:
            return self.error(status_code=403, message='unauthorized, incorrect signature')

        person_id, signature = auth.split(':')
        try:
            person = Person.objects.get(id=person_id)
        except Person.DoesNotExist:
            return self.error(status_code=403, message='unauthorized, incorrect signature')

        data = dict(self.request.REQUEST) or None
        _, check_signature = create_signature(person.id, person.token, self.request.method, data).split(':')
        if signature != check_signature:
            return self.error(status_code=403, message='unauthorized, incorrect signature')

        # TODO: dirty hack for not implement auth backend. token should be work only for api, not for all site
        self.request.user = person.user

