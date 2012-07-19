import hmac

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

def create_signature(person, request):
    if request.method == 'POST':
        data = urlencode(sorted(request.POST.items(), key=lambda (k, v): k))
    else:
        data = request.request_uri

    data = request.method.upper() + ' ' + data + ' ' + settings.API_CLIENT_SALT
    signed = hmac.new(person.token, data)
    msg = '%s:%s' % (person.id, signed.hexdigest())

    return msg


class AuthTokenMixin(object):
    def auth(self):
        if 'auth' not in self.request.REQUEST:
            return self.error(code=403, message='unauthorized, incorrect signature')

        person_id, signature = self.request.REQUEST['auth'].split(':')
        try:
            person = Person.objects.get(id=id)
        except Person.DoesNotExist:
            return self.error(code=403, message='unauthorized, incorrect signature')

        if signature != create_signature(person, request):
            return self.error(code=403, message='unauthorized, incorrect signature')

        # TODO: dirty hack for not implement auth backend. token should be work only for api, not for all site
        self.request.user = person.user

