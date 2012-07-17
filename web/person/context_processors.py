from django.conf import settings
from django.core.urlresolvers import reverse

def site_settings(request):
    vk_login_url = 'http://oauth.vk.com/authorize?'\
       'client_id=%s&'\
       'scope=%s&'\
       'redirect_uri=%s&'\
       'display=%s&'\
       'response_type=token' % (
        settings.VK_CLIENT_ID,
        'friends,notify,photos,status,wall,offline,notifications,groups',
        request.build_absolute_uri(reverse('person_oauth')),
        'popup'
        )

    return {
        'vk_login_url' : vk_login_url
    }