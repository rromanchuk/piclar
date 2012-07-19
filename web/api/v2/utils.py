import hmac

from urllib import urlencode

from django.conf import settings
from person.models import Person

def model_to_dict(model, fields):
    return dict([ (fname, unicode(getattr(model, fname))) for fname in fields ])

def filter_fields(data, required_fields):
    filtered = dict([ (k,v) for k,v in data.items() if k in required_fields])
    if set(filtered.keys()).issuperset(set(required_fields)):
        return filtered
    else:
        return {}

def create_signature(person, method, params):
    if not params:
        params = {}
    if 'auth' in params:
        del params['auth']

    params = urlencode(sorted(params.items(), key=lambda (k, v): k))
    params = method.upper() + ' ' + params + ' ' + settings.API_CLIENT_SALT
    signed = hmac.new(str(person.token), params)
    msg = '%s:%s' % (person.id, signed.hexdigest())
    return msg


class AuthTokenMixin(object):
    def auth(self):
        # TODO: remove it after Ryan implement token auth
        if self.request.POST.get('person_id') and settings.DEBUG:
            person = Person.objects.get(id=self.request.POST.get('person_id'))
            self.request.user = person.user
            return

        if 'auth' not in self.request.REQUEST:
            return self.error(status_code=403, message='unauthorized, incorrect signature')

        person_id, signature = self.request.REQUEST['auth'].split(':')

        try:
            person = Person.objects.get(id=person_id)
        except Person.DoesNotExist:
            return self.error(status_code=403, message='unauthorized, incorrect signature')

        _, check_signature = create_signature(person, self.request.method, dict(self.request.REQUEST)).split(':')
        if signature != check_signature:
            return self.error(status_code=403, message='unauthorized, incorrect signature')

        # TODO: dirty hack for not implement auth backend. token should be work only for api, not for all site
        self.request.user = person.user

