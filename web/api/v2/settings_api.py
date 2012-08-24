from django.conf import settings
from base import *

class SettingsGet(ApiMethod):
    def get(self):
        return {
            'vk_client_id' : settings.VK_CLIENT_ID,
            'vk_scopes' : settings.VK_SCOPES + ',messages',
        }