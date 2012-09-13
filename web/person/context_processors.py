from django.conf import settings
from django.core.urlresolvers import reverse
from ostrovok_common.utils.urls import force_https

def site_settings(request):
    vk_login_url = 'http://oauth.vk.com/authorize?'\
       'client_id=%s&'\
       'scope=%s&'\
       'redirect_uri=%s&'\
       'display=%s&'\
       'response_type=token' % (
        settings.VK_CLIENT_ID,
        settings.VK_SCOPES,
        request.build_absolute_uri(reverse('person-oauth')),
        'popup'
        )

    proto_settings =  {
        'vk_login_url' : vk_login_url,
        'appstore_url' : settings.APPSTORE_APP_URL,
        'gmaps_api_key' : settings.GMAPS_API_KEY,
        'analytics_id' : settings.ANALYTICS_ID,
    }

    secure_names = [
        'person_login',
        'person_edit_credentials',
        'mobile_login',
    ]
    for name in secure_names:
        proto_settings[name + '_url'] = force_https(reverse(name), request)

    return proto_settings