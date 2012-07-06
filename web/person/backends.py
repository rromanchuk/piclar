from django.contrib.auth.models import User
from models import SocialPerson
from poi.provider import get_poi_client

class VkontakteBackend(object):
    def authenticate(self, access_token, user_id):
        client = get_poi_client('vkontakte')
        fetched_person = client.fetch_user(access_token, user_id)
        if 'error' in fetched_person:
            return None

        try:
            person = SocialPerson.objects.get(
                provider=SocialPerson.PROVIDER_VKONTAKTE,
                external_id=fetched_person['uid'],
            )
            return person.person.user
        except SocialPerson.DoesNotExist:
            return None

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None