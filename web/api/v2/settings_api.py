from django.conf import settings
from base import *

class SettingsGet(ApiMethod):
    def get(self):
        scopes =  settings.VK_SCOPES # + ',messages'
        vk_login_url = 'http://oauth.vk.com/authorize?'\
           'client_id=%s&'\
           'scope=%s&'\
           'redirect_uri=%s&'\
           'display=%s&'\
           'response_type=token' % (
            settings.VK_CLIENT_ID,
            scopes,
            'http://oauth.vk.com/blank.html',
            'touch',
        )

        return {
                'vk_client_id' : settings.VK_CLIENT_ID,
                'vk_scopes' : scopes,
                'vk_url' : vk_login_url,
            }